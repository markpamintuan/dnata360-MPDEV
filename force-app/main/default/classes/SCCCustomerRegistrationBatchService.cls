/**
* Rest Service class for post contact informations' details => Customer Registration
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(urlMapping='/Contact/Registration/Batch/*')
global with sharing class SCCCustomerRegistrationBatchService {
    
    /**
* This is the method using on "POST" requests
* @return SCCCustomerRegResponse.
*/
    @HttpPost
    global static List<SCCCustomerRegResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerRegResponse> response;
        try{
            if(SCCUtilityClass.isPersonAccountEnabled()) {
                response = createAccountRecord(RestContext.request, logger);
            }
        }catch(Exception e) {
            logger.error('SCCCustomerRegistrationBatchService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            response = new List<SCCCustomerRegResponse>();
            response.add(SCCCustomerRegResponse.createError(e));
            return response;
        }finally{
            logger.flush();
        }
        return response;
    }
    
    /**
* This is the method using on "POST" requests
* @return SCCCustomerRegResponse.
*/
    static List<SCCCustomerRegResponse> createAccountRecord(RestRequest request, SCCFileLogger logger){
        
        Id accRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId();
        //SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();
        List<Id> recordIds = new List<Id>();
        try {
            Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);
            
            /**
Messaging.reserveSingleEmailCapacity(2);
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {'adm.dnata@gmail.com'}; 
String[] ccAddresses = new String[] {'adm.dnata@gmail.com'};
mail.setToAddresses(toAddresses);
mail.setCcAddresses(ccAddresses);
mail.setReplyTo('adm.dnata@gmail.com');
mail.setSenderDisplayName('Salesforce Support');
mail.setSubject('New Case Created');
mail.setBccSender(false);
mail.setUseSignature(false);
mail.setPlainTextBody(request.requestBody.toString());
mail.setHtmlBody(request.requestBody.toString());
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); **/
            
            
            List<Object> jsonDataList = new List<Object>(); 
            
            JSONParser parser = JSON.createParser(request.requestBody.toString());
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    
                    system.debug('######################OBJECT');
                    jsonDataList.add((Object)System.JSON.deserializeUntyped(request.requestBody.toString()));
                }
                //System.debug(parser.getText() + parser.nextToken() + ' - ' + parser.getText());
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    
                    system.debug('######################ARRAY');
                    jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
                    system.debug('######################RECORDS - ' + jsonDataList.size());
                }
                break;
            }
            
            
            
            for (Object jsonData : jsonDataList){
                
                Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
                for(string s: jsonMap.keyset()){
                    //system.debug('1@@@@@@@@@@@@@@@@@@@@@' + s + '     ------------       ' + jsonMap.get(s));    
                }
                //if((String)jsonMap.get('email') != ''){
                try {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Account')
                        .setRelatedFields(new Set<String> {'Id', 'PersonEmail', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc'})
                        .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\' and RecordTypeId = \'' + accRT + '\'')
                        .getQuery();
                    List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                    Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                    record.From_SFCC__pc = true;
                    record.Org_Brand__c = 'dnata eCommerce'; 
                    record.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId();
                    record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
                    
                    
                    if(!accountList.isEmpty()) {
                        system.debug('ACCOUNT FOUND');
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Updating existing account: '+record);
                        record.Id = accountList[0].Id;
                        record.Contact_Status__pc  = 'Updated';
                        record.SFCC_update__c = true;
                        
                    }else{
                        system.debug('ACCOUNT NOT FOUND');
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Creating new account: '+ record);
                        //RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('dnata eCommerce');
                        //record.RecordTypeId = recordType.Id;
                        record.Contact_Status__pc  = 'Created';
                    }
                    Database.upsert(record, true);
                    recordIds.add(record.Id);
                    respList.add(SCCCustomerRegResponse.createResponse(record)); 
                } catch(Exception e) {
                    logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    respList.add(SCCCustomerRegResponse.createError((String)jsonMap.get('customer_no'), e));
                }
                
                //}
            }
            //SCCCommerceCloudConnect.synchroniseObjectFutureBatch(recordIds);
            return respList;
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            respList.add(SCCCustomerRegResponse.createError(e));
            return respList;
        }
    }
    
}