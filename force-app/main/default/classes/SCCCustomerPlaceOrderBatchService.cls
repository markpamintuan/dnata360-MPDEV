/**
* Rest Service class for post order informations' details => Customer Place Order
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(urlMapping='/Order/Placement/Batch/*')
global class SCCCustomerPlaceOrderBatchService {  
    
    /**
* This is the method using on "POST" requests.
* @return SCCCustomerOrderResponse.
*/    
    @HttpPost
    global static List<SCCCustomerOrderResponse> create() {  
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerOrderResponse> response;
        Sobject sobj;
        try{
            response = createAccountOrderRecord(RestContext.request, logger);           
        }catch(Exception e) {
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            response = new List<SCCCustomerOrderResponse>();
            response.add(SCCCustomerOrderResponse.createError(e));
            return response;
        }finally{
            logger.flush();
        }
        system.debug(response);
        return response;
    }
    
    /**
* This is the method using on "POST" requests
* @return SCCCustomerOrderResponse.
*/
    public static List<SCCCustomerOrderResponse> createAccountOrderRecord(RestRequest request, SCCFileLogger logger){
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();    
        Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);
        Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);             
        List<Order> orderUpsert = new List<Order>();                        
        List<Object> jsonDataList = new List<Object>();                 
        JSONParser parser = JSON.createParser(request.requestBody.toString());
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                jsonDataList.add((Object)System.JSON.deserializeUntyped(request.requestBody.toString()));
            }
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
                system.debug('######################RECORDS - ' + jsonDataList.size());
            }
            break;
        }              
        
        for (Object jsonData : jsonDataList) {
            Map<String, Object> jsonMap = (Map<String, Object>)jsonData;   
            try {
                if(jsonMap.containsKey('orderNo')) {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Order')
                        .setRelatedFields(new Set<String> {'Id', 'AccountId', 'Name', 'SFCC_Brand__c', 'OrderNumber', 'SFCC_Order_Number__c', 'Case__c'})
                        .setClause('SFCC_Order_Number__c = \'' + (String)jsonMap.get('orderNo') + '\'')
                        .getQuery();
                    List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);      
                    Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, 'Order', orderfieldMappings, logger);                    
                    record.from_SFCC__c = true;//setting to true for sfcc orders
                    record.Status__c = 'Confirmed';                    
                    //order brand
                    if(jsonMap.containsKey('custom')) {
                        Map<String, Object> customDetailsMap = (Map<String, Object>)jsonMap.get('custom');
                        if(customDetailsMap.containsKey('siteID')) {
                            if(customDetailsMap.get('siteID').toString() == 'marhaba'){
                                record.SFCC_Brand__c = 'marhaba';
                            }
                            if(customDetailsMap.get('siteID').toString() == 'aa'){
                                record.SFCC_Brand__c = 'Arabian Adventures';
                            }
                            if(customDetailsMap.get('siteID').toString() == 'css'){
                                record.SFCC_Brand__c = 'City Sightseeing Dubai';
                            }
                        }
                    } 
                    //update existing order
                    if(!orderList.isEmpty()) {                       
                        //Existing order processing.
                        record.Id = orderList.get(0).Id;
                        record.Order_SCCSync_Status__c = 'Updated';   
                        Database.update(record, true);
                        if(jsonMap.containsKey('productLineItems') ) {
                            SCCUtilityClass.createOrderLineItems(jsonMap,record.Id,logger);
                        }
                        respList.add(SCCCustomerOrderResponse.createResponse(record));
                    }else{
                        if(jsonMap.containsKey('customerNo')) { 
                            query = SCCQueryUtilClass.getInstance()
                                .getQueryInstance()
                                .setObjectName('Account')
                                .setRelatedFields(new Set<String> {'Id', 'PersonEmail', 'PersonContactId' , 'SFCC_Customer_Number__pc'})
                                .setClause('SFCC_Customer_Number__pc = \'' + (String)jsonMap.get('customerNo') + '\'')
                                .getQuery();
                            List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query); 
                            
                            if(!accountList.isEmpty()) {
                                record = additionalFieldsforNewOrder(record);
                                record.isContactIdExist__c = true;
                                record.Order_Contact__c = accountList[0].PersonContactId;
                                record.AccountId = accountList[0].Id;     
                                record.SFCC_Order_Number__c = (String)jsonMap.get('orderNo');                           
                                Database.insert(record, true);
                                if(jsonMap.containsKey('productLineItems') ) {
                                    SCCUtilityClass.createOrderLineItems(jsonMap,record.Id,logger);
                                }
                            } else {
                                Account accRecord = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                                accRecord.From_SFCC__pc = true;
                                accRecord.Org_Brand__c = 'dnata eCommerce'; 
                                accRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId();
                                accRecord = SCCUtilityClass.additionalFieldsforAccount(accRecord, jsonMap);
                                accRecord.PersonEmail = (String)jsonMap.get('customerEmail');
                                accRecord.LastName = (String)jsonMap.get('customerName');
                                accRecord.Contact_Status__pc  = 'Created';
                                accRecord.SFCC_Customer_Number__pc = (String)jsonMap.get('customerNo');
                                Database.DMLOptions dml = new Database.DMLOptions();
                                dml.DuplicateRuleHeader.AllowSave = true; 
                                Database.SaveResult sr = Database.insert(accRecord, dml); 
                                if (sr.isSuccess()) {                                       
                                    record = additionalFieldsforNewOrder(record);
                                    record.SFCC_Order_Number__c = (String)jsonMap.get('orderNo');
                                    record.Order_Contact__c = null;
                                    record.AccountId = sr.getId();  
                                    Database.insert(record, true);
                                    if(jsonMap.containsKey('productLineItems') ) {
                                        SCCUtilityClass.createOrderLineItems(jsonMap,record.Id,logger);
                                    }
                                }
                            }                            
                        }else{
                            Account accRecord = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                            accRecord.From_SFCC__pc = true;
                            accRecord.Org_Brand__c = 'dnata eCommerce'; 
                            accRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId();
                            accRecord = SCCUtilityClass.additionalFieldsforAccount(accRecord, jsonMap);
                            accRecord.PersonEmail = (String)jsonMap.get('customerEmail');
                            accRecord.LastName = (String)jsonMap.get('customerName');
                            accRecord.Contact_Status__pc  = 'Created';
                            Database.DMLOptions dml = new Database.DMLOptions();
                            dml.DuplicateRuleHeader.AllowSave = true; 
                            Database.SaveResult sr = Database.insert(accRecord, dml); 
                            if (sr.isSuccess()) {  
                                record = additionalFieldsforNewOrder(record);
                                record.SFCC_Order_Number__c = (String)jsonMap.get('orderNo');
                                record.Order_Contact__c = null;
                                record.AccountId = sr.getId();                                  
                                Database.insert(record, true);
                                if(jsonMap.containsKey('productLineItems') ) {
                                    SCCUtilityClass.createOrderLineItems(jsonMap,record.Id,logger);
                                }
                            }                                                        
                        }
                        
                        respList.add(SCCCustomerOrderResponse.createResponse(record));
                    }
                }
            } catch(Exception e) {
                logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                             + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                respList.add(SCCCustomerOrderResponse.createError(e, (String)jsonMap.get('orderNo')));
            }
        }
        
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + respList);
        
        return respList;
    }
    
    /**
* This method used for populating additional and required fields for order object
* @param record: Order
* @return Order.
*/
    public static Order additionalFieldsforNewOrder(Order record) {
        record.EffectiveDate = System.today();
        record.from_SFCC__c = true;
        record.Order_SCCSync_Status__c = 'Created';
        record.Status = 'Draft';
        return record;
    }
}