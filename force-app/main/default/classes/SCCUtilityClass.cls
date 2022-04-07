/**
 * Utilization class
 *
 *
 * @author  Neeraj Yadav
 * @version 1.0
 * @since   2017-11-02
 */
public with sharing class SCCUtilityClass { 

/**
 * This method used for check if person type account is enabled or not.
 * @return boolean
 */
public static boolean isPersonAccountEnabled(){
	return Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
}

/**
 * This method check if person account exist or not using account id
 * @return boolean
 */
public static boolean isPersonAccountExist(String accountId){
	List<Account> personAccounts = [SELECT Id FROM Account WHERE isPersonAccount=True and Id =: accountId];
	if(!personAccounts.isEmpty()) {
		return true;
	}else{
		return false;
	}
}

/**
 * This method return record type id of account using account name.
 * @Todo. refactor it.
 * @return boolean
 */
public static RecordType getPersonAccountRecordType(String accountName){
	RecordType recordType = (RecordType)Cache.Org.get('local.SCCConnectorCustomSettings.RecordType'+accountName.replaceAll(' ', ''));
	if(recordType == null) {
		try{
			recordType = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True and Name =: accountName];
			Cache.Org.put('local.SCCConnectorCustomSettings.RecordType'+accountName.replaceAll(' ', ''), recordType);
			return recordType;
		}catch(Exception e) {
			return recordType;
		}
	}else{
		return recordType;
	}
}

/**
 * This method return account using account id if account is person type account.
 * @return boolean
 */
public static Account getPersonAccount(String accountId){
	Account acount;
	try{
		acount = [Select Id, PersonContactId From Account Where isPersonAccount=True and Id = :accountId];
		return acount;
	}catch(Exception e) {
		return acount;
	}
}

/**
 * This method return person type account or contact using id
 * @return Sobject
 */
public static Sobject getSojectByRefId(String crmRefId){
	Sobject sobj;
	try{
		if(!String.isEmpty(crmRefId)) {

			system.debug('crmRefId' + crmRefId);
			sobj = [Select Id, PersonContactId From Account Where isPersonAccount=True and Id = :crmRefId];
			system.debug('sobj' + sobj);
		}
	}catch(Exception e) {
		sobj = null;
	}
	//try if contact exist using supplied id.
	try{
		if(!String.isEmpty(crmRefId) && sobj == null) {
			sobj = [Select Id From Contact Where Id = :crmRefId];
		}
	}catch(Exception e) {
		sobj = null;
	}
	return sobj;
}

public static Account getDefaultAccount(){
	String query = SCCQueryUtilClass.getInstance()
	               .getQueryInstance()
	               .setObjectName('Account')
	               .setRelatedFields(new Set<String> {'Id'})
	               .setClause('Name = \'Default\'')
	               .setLimit('1')
	               .getQuery();
	// Checking whethere default account is present or not
	List<Account> defaultAccount = SCCQueryUtilClass.getRecords(query);
	if(defaultAccount != NULL && defaultAccount.size() > 0)
		return defaultAccount[0];
	else
		return null;
}

public static Address__c getAddressByName(String name){
	Address__c address;
	try{
		if(!String.isEmpty(name)) {
			address = [Select Id from Address__c where Name = :name];
		}
		return address;
	}catch(Exception e) {
		return address;
	}
}

/**
 * This method used to get object attribute mapping values from specified object.
 * @param objectName: String
 * @return Map<String, Schema.SObjectField>.
 */
public static Map<String, SObject> getAllCustomSettingValues(String objectName, SCCFileLogger logger) {
	String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
	logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
	Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.all'+objectAlias);
	if(returnMap == null) {
		logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'Cache Missed. Getting data from DB');
		returnMap = new Map<String, SObject>();
		String query = SCCQueryUtilClass.getInstance()
		               .getQueryInstance()
		               .setObjectName(objectAlias + 'FieldMapping__c')
		               .setAllFields()
		               .getQuery();
		List<SObject> objList = SCCQueryUtilClass.getRecords(query);
		logger.debug('SCCUtilityClass.getAllCustomSettingValues', 'query: '+query+ ' Records: '+objList);
		for(SObject obj : objList) {
			returnMap.put((String)obj.get('CC_Attribute__c'), obj);
		}
		Cache.Org.put('local.SCCConnectorCustomSettings.all'+objectAlias, returnMap);
	}
	return returnMap;
}

/**
 * This method used to get object attribute mapping values applicable for sync from specified object.
 * @param objectName: String
 * @return Map<String, Schema.SObjectField>.
 */
public static Map<String, SObject> getSyncCustomSettingValues(String objectName, Boolean isSync, SCCFileLogger logger) {
	String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
	logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
	Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.sync'+objectAlias); 
	if(returnMap == null) {
		logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'Cache Missed. Getting data from DB');
		returnMap = new Map<String, SObject>();
		String query = SCCQueryUtilClass.getInstance()
		               .getQueryInstance()
		               .setObjectName(objectAlias + 'FieldMapping__c')
		               .setAllFields()
		               .setClause('Enable_Sync__c = '+isSync)
		               .getQuery();
		List<SObject> objList = SCCQueryUtilClass.getRecords(query);
		logger.debug('SCCUtilityClass.getSyncCustomSettingValues', 'query: '+query+ ' Records: '+objList);
		for(SObject obj : objList) {
			returnMap.put((String)obj.get('CC_Attribute__c'), obj);
		}
		Cache.Org.put('local.SCCConnectorCustomSettings.sync'+objectAlias, returnMap);
	}
	return returnMap;
}

/**
 * This method used to get object attribute mapping values applicable for patch from specified object.
 * @param objectName: String
 * @return Map<String, Schema.SObjectField>.
 */
public static Map<String, SObject> getPatchCustomSettingValues(String objectName, Boolean isPatch, SCCFileLogger logger) {
	String objectAlias = SCCClassAlias.classAliasMap.get(objectName);
	logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'objectName: ' + objectName + ' objectAlias: '+ objectAlias);
	Map<String, SObject> returnMap = (Map<String, SObject>)Cache.Org.get('local.SCCConnectorCustomSettings.patch'+objectAlias);
	if(returnMap == null) {
		logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'Cache Missed. Getting data from DB');
		returnMap = new Map<String, SObject>();
		String query = SCCQueryUtilClass.getInstance()
		               .getQueryInstance()
		               .setObjectName(objectAlias + 'FieldMapping__c')
		               .setAllFields()
		               .setClause('Enable_Patch__c = '+isPatch)
		               .getQuery();
		List<SObject> objList = SCCQueryUtilClass.getRecords(query);
		logger.debug('SCCUtilityClass.getPatchCustomSettingValues', 'query: '+query+ ' Records: '+objList);
		for(SObject obj : objList) {
			returnMap.put((String)obj.get('CC_Attribute__c'), obj);
		}
		Cache.Org.put('local.SCCConnectorCustomSettings.patch'+objectAlias, returnMap);
	}
	return returnMap;
}

/**
 * This method used for returned fields of selected object.
 * @param objectName: String
 * @return Map<String, Schema.SObjectField>.
 */
public static Map<String, Schema.SObjectField> getFields(String objectName) {
	Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
	return gd.get(objectName).getDescribe().fields.getMap();
}

/**
 * This method used for returned sobject instance dynamically.
 * @param objectName: String
 * @return SObject.
 */
public static SObject getNewSObject(String objectName) {
	Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
	Schema.SObjectType objectType = gd.get(objectName);
	Sobject obj = objectType.newSobject();
	return obj;
}

/**
 * This method used for returned all fields(apinames) of related sobject dynamically.
 * @param objectName: String
 * @return SObject.
 */
public static List<String> getAllFields(String objectName) {
	List<String> returnList = new List<String>();
	Map<String, Schema.SObjectField> fieldMap = SCCUtilityClass.getFields(objectName);
	for(String key : fieldMap.keySet()) {
		returnList.add(fieldMap.get(key).getDescribe().getName());
	}
	return returnList;
}

/**
 * This method used for returned wanted fields(apinames) of related sobject dynamically.
 * @param objectName: String
 * @param fieldApis: Set<String>
 * @return List<String>.
 */
public static List<String> getWantedFields(String objectName, Set<String> fieldApis) {
	Set<String> fieldApiSet = new Set<String>();
	for(String s : fieldApis) {
		fieldApiSet.add(s.toLowerCase());
	}
	List<String> returnList = new List<String>();
	Map<String, Schema.SObjectField> fieldMap = SCCUtilityClass.getFields(objectName);
	for(String key : fieldMap.keySet()) {
		if(fieldApiSet.contains(key)) {
			returnList.add(fieldMap.get(key).getDescribe().getName());
		}
	}
	return returnList;
}

/**
 * This method used for initializing the object.
 * @param jsonMap: Map<String, SObject>
 * @param objectName: String
 * @return SObject.
 */
public static SObject initializeObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings, SCCFileLogger logger) {
	logger.debug('SCCUtilityClass.initializeObject','Initializing '+objectName+' jsonMap '+jsonMap);
	return SCCUtilityClass.createObject(jsonMap, objectName, fieldMappings, logger);
}

/**
 * This method used for populating fields the object.
 * @param jsonMap: Map<String, SObject>
 * @param objectName: String
 * @return SObject.
 */
public static SObject createObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings, SCCFileLogger logger) {
	logger.debug('SCCUtilityClass.createObject','Creating Object '+objectName+' jsonMap '+jsonMap);
	SObject obj = SCCUtilityClass.getNewSObject(objectName);
	for(String key : fieldMappings.keySet()) {
		Object value = SCCJsonUtil.getValueByKey(key, jsonMap, logger);
		if(value!=null) {
			logger.debug('SCCUtilityClass.createObject',key + ' fieldMappings.get(key).get Field_Api_Name__c: ' + (String)fieldMappings.get(key).get('Field_Api_Name__c'));
			SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
			Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
			Schema.SObjectField field = (Schema.sObjectField) mfields.get((String)fieldMappings.get(key).get('Field_Api_Name__c'));
			if(field!=null) {
				Schema.DisplayType fieldType = field.getDescribe().getType();
				logger.debug('SCCUtilityClass.createObject','mfields: '+mfields+' Schema.SObjectField: '+field+' Schema.DisplayType: '+fieldType);

				if(fieldType == Schema.DisplayType.String ||
				   fieldType == Schema.DisplayType.TextArea ||
				   fieldType == Schema.DisplayType.Id ||
				   fieldType == Schema.DisplayType.Picklist ||
				   fieldType == Schema.DisplayType.Reference ||
				   fieldType == Schema.DisplayType.Phone ||
				   fieldType == Schema.DisplayType.Email ||
				   fieldType == Schema.DisplayType.URL)
					obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), String.valueOf(value));
				if(fieldType == Schema.DisplayType.Currency ||
				   fieldType == Schema.DisplayType.Double)
					obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), (Decimal)value);
				if(fieldType == Schema.DisplayType.Integer)
					obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), Integer.valueOf(value));
				if(fieldType == Schema.DisplayType.Boolean)
					obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), Boolean.valueOf(value));
				if(fieldType == Schema.DisplayType.DateTime)
					obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), formatDate(String.valueOf(value)));
				if(fieldType == Schema.DisplayType.Date)
					if(((String)value).contains('-')) {
						obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), Date.valueOf((String)value));
					}else{
						obj.put((String)fieldMappings.get(key).get('Field_Api_Name__c'), Date.parse((String)value));
					}
			}
		}
	}
	return obj;
}


/**
 * This method used for populating additional and required fields for contact object
 * @param record: Contact
 * @param jsonMap: Map<String, Object>
 * @return Contact.
 */
public static Contact additionalFieldsforContact(Contact record, Map<String, Object> jsonMap) {
	if(jsonMap.containsKey('customer_name')) {
		String[] contactName = new List<String>();
		String firstName = '';
		String lastName = '';
		contactName = ((String)jsonMap.get('customer_name')).split(' ');
		firstName = contactName[0];
		for(Integer i = 0; i < contactName.size(); i++) {
			if(i != 0) {
				lastName += contactName[i] + ' ';
			}
		}
		lastName = lastName.removeEnd(' ');
		record.FirstName = firstName;
		record.LastName  = lastName;
	}

	String query = SCCQueryUtilClass.getInstance()
	               .getQueryInstance()
	               .setObjectName('Account')
	               .setRelatedFields(new Set<String> {'Id'})
	               .setClause('Name = \'Default\'')
	               .setLimit('1')
	               .getQuery();
	record.AccountId = ((List<Account>)SCCQueryUtilClass.getRecords(query))[0].Id;
	record.From_SFCC__c  = true;
	record.Contact_Status__c  = 'Created';
	return record;
}

/**
 * This method used for populating additional and required fields for contact object
 * @param record: Account
 * @param jsonMap: Map<String, Object>
 * @return Account.
 */
public static Account additionalFieldsforAccount(Account record, Map<String, Object> jsonMap) {
	if(jsonMap.containsKey('customer_name')) {
		String[] contactName = new List<String>();
		String firstName = '';
		String lastName = '';
		contactName = ((String)jsonMap.get('customer_name')).split(' ');
		firstName = contactName[0];
		for(Integer i = 0; i < contactName.size(); i++) {
			if(i != 0) {
				lastName += contactName[i] + ' ';
			}
		}
		lastName = lastName.removeEnd(' ');
		record.FirstName = firstName;
		record.LastName  = lastName;
	}
	return record;
}

/**
 * This method parse date string to DateTime
 * @param dateString: String
 * @return DateTime.
 */
public static DateTime formatDate(String dateString){
	datetime dateObj = null;
	if(dateString.contains('T')) {
		dateString = dateString.replace('T',' ');
		if(dateString.contains('.')) {
			dateString = dateString.substring(0,dateString.indexOf('.'));
		}
		dateObj  = datetime.valueof(dateString);
	}else{
		dateObj  = datetime.valueof(dateString);
	}
	return dateObj;
}






public static List<Order_Line_Item__c> createOrderLineItems(Map<String, Object> jsonMap, String orderId, SCCFileLogger logger){
    
    

    system.debug('-----------------------------------------------CHECKING LINE ITEM CLASS   order ID  ---   '  + orderId);    
    system.debug('-----------------------------------------------CHECKING LINE ITEM CLASS   JSON MAP  ---   '  + jsonMap);    
    

	List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
	List<Order_Traveller__c> oTravellerListTemp = new List<Order_Traveller__c>();
	List<Order_Traveller__c> oTravellerList = new List<Order_Traveller__c>();
	//Map<String,List<Order_Traveller__c>> oTravellerMap = new Map<String,List<Order_Traveller__c>>();

	Map<String, Object> orderLineItemMap = (Map<String, Object>)jsonMap.get('productLineItems');
	Map<String, Object> customMap = (Map<String, Object>)jsonMap.get('custom');
	
	if(customMap.containsKey('passengers')) {
		Map<String, Object> customPassengersMap = (Map<String, Object>)customMap.get('passengers');        
		oTravellerListTemp.addAll(createOrderTravellers(customPassengersMap,logger));
	}
	List<Object> objList = new List<Object>();
	objList.addAll(orderLineItemMap.values());

	String queryOLI = SCCQueryUtilClass.getInstance()
	                  .getQueryInstance()
	                  .setObjectName('Order_Line_Item__c')
	                  .setRelatedFields(new Set<String> {'Id'})
	                  .setClause('Order__c = \'' + orderId + '\'')
	                  .getQuery();
	List<Order_Line_Item__c> orderLineItemListDelete = (List<Order_Line_Item__c>)SCCQueryUtilClass.getRecords(queryOLI);
	List<Order_Line_Item__c> orderLineItemListInsert = new List<Order_Line_Item__c>();
	Map<String, SObject> orderLineItemfieldMappings = OrderLineItemFieldMapping__c.getAll();
	for(Object o: objList) {
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));

		Order_Line_Item__c recordOLI = (Order_Line_Item__c)SCCUtilityClass.initializeObject(m, 'Order_Line_Item__c', orderLineItemfieldMappings, logger);
		recordOLI.Order__c = orderId;
		//recordOLI.External_ID__c = getUniqueStr();
		orderLineItemListInsert.add(recordOLI);




	}

	if(orderLineItemListDelete.size()>0) {
		delete orderLineItemListDelete;
	}


	if(orderLineItemListInsert.size()>0) {

		insert orderLineItemListInsert;
		for(Order_Line_Item__c ol: orderLineItemListInsert) {
			for(Order_Traveller__c ot: oTravellerListTemp) {

				Order_Traveller__c temp = new Order_Traveller__c();
				temp.Id = ot.Id;
				temp.Org_First_Name__c = ot.Org_First_Name__c;
				temp.Org_Last_Name__c = ot.Org_Last_Name__c;
				temp.Org_Date_of_Birth__c =  ot.Org_Date_of_Birth__c;
				temp.Name = ot.Name;
				temp.Order_Line_Item__c = ol.Id;
				oTravellerList.add(temp);

			}
			/**
			   if(oTravellerMap.containsKey(ol.External_ID__c)){
			    if(oTravellerMap.get(ol.External_ID__c).size() > 0){
			        for(Order_Traveller__c ot: oTravellerMap.get(ol.External_ID__c)){
			                ot.Order_Line_Item__c = ol.Id;
			            oTravellerList.add(ot);
			        }
			    }

			   } **/
		}
	}
	
    
    
	if(oTravellerList.size()>0) {
		insert oTravellerList;
        
    }
	
    try{
		delete [select id from Order_Traveller__c where Order_Line_Item__c = null];
	}catch (exception e) {}
    
    return orderLineItemListInsert;
	
    
}

public static List<Order_Traveller__c> createOrderTravellers(Map<String, Object> jsonMap, SCCFileLogger logger){
    

	List<Object> objList = new List<Object>();
	objList.addAll(jsonMap.values());


	List<Order_Traveller__c> oTravellerListInsert = new List<Order_Traveller__c>();
	Map<String, SObject> oTravellerfieldMappings = OrderTravellerFieldMapping__c.getAll();
	for(Object o: objList) {
		Object obj = JSON.deserializeUntyped((String)o);
        system.debug('#####################################' + obj);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        system.debug(m.keyset());
		Order_Traveller__c record = (Order_Traveller__c)SCCUtilityClass.initializeObject(m, 'Order_Traveller__c', oTravellerfieldMappings, logger);
		Date myDate = Date.newInstance(Integer.valueof(m.get('year')), Integer.valueof(m.get('month')), Integer.valueof(m.get('day')));
		record.Org_Date_of_Birth__c = Date.newInstance(Integer.valueof(m.get('year')), Integer.valueof(m.get('month')), Integer.valueof(m.get('day')));
		//record.External_ID__c = uniqueStr;
		record.Name = record.Org_First_Name__c + ' ' + record.Org_Last_Name__c;
		oTravellerListInsert.add(record);
	}
	if(oTravellerListInsert.size()>0) {
		return oTravellerListInsert;
	}else{
		return null;
	}

}




public static Case createBookingEnquiryCase(id accId, string brand,Order o){ 
	Case cse = new Case();
	Id caseRt = null;
	if(brand == 'marhaba') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba B2C - New Enquiry').getRecordTypeId();
	}else if(brand == 'Arabian Adventures') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA B2C - New Enquiry').getRecordTypeId();
	}else if(brand == 'City Sightseeing Dubai') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSD B2C - New Enquiry').getRecordTypeId();
	}

	cse.recordtypeId = caseRt;
	cse.AccountId = accId;
	cse.Org_Brand__c = brand;
    cse.Order__c = o.Id;
    cse.Order_Total__c = o.SFCC_Order_Total__c;
    cse.SFCC_Order_No__c = o.SFCC_Order_Number__c;
	insert cse;
	return cse;
}


public class LineitemPassengerWrapper {

public Order_Line_Item__c ol {get; set;}
public List<Order_Traveller__c> otList {get; set;}
public String uniqueIdTr {get; set;}

public LineitemPassengerWrapper(Order_Line_Item__c ol){
	this.ol = ol;
	this.uniqueIdTr = getUniqueStr();

}
}


public static string getUniqueStr(){
	Blob b = Crypto.GenerateAESKey(128);
	String h = EncodingUtil.ConvertTohex(b);
	String guid = h.SubString(0,8) + h.SubString(8,12) + h.SubString(12,16) + h.SubString(16,20) + h.substring(20);
	return guid;
}





}