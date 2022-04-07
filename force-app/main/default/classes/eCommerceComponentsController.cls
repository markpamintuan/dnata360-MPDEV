/**************************************************************************************************
* Name               : eCommerceComponentsController
* Description        : TController for eCommerce component
* Created Date       : 01-Oct-2019
* Created By         : Jed Canlas
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR           DATE           COMMENTS
* v1.0        Jed             01-Oct-2019     Initial version
**************************************************************************************************/
public without sharing class eCommerceComponentsController {
@AuraEnabled
public static boolean displayNewBookingButton(){
	User usr = [ SELECT Id, Profile.Name FROM User WHERE Id=:Userinfo.getUserId() limit 1];
	return(true);
}



@AuraEnabled
public static string fetchUser(){
	List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
	String MyProflieName = PROFILE[0].Name;
	return(MyProflieName);
}

@AuraEnabled
public static string getSobjectType(id objId){
	Schema.SObjectType token = objId.getSObjectType();
	return(string.valueOf(token));
}

@AuraEnabled
public static SObject getObjectRecord(id objId){
	Schema.SObjectType token = objId.getSObjectType();
	String objName = string.valueOf(token);
	SObject sObj = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().keySet()), ',') + ' FROM '+objName+' where Id =: objId limit 1');
	return(sObj);
	//return (SObject)Type.forName(string.valueOf(token)).newInstance();
}

@AuraEnabled
public static string getParentId(string objId){
    if(objId != ''){
        String pId = [select Id,Case__c from Order where Id =: objId limit 1].Case__c;
		return(pId); 
    }else{
        return null;
    }
	
}
@AuraEnabled
public static string getParentIdFromQuote(string objId){
	String pId = [select Id,Case__c from Quote_Header__c where Id =: objId limit 1].Case__c;
	return(pId);
}

@AuraEnabled
public static string getAfterSalesRT(string objId){

	Order o = [select id,SFCC_Brand__c from Order where Id =: objId limit 1];
	Id caseRt;
	if(o.SFCC_Brand__c == 'marhaba') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba B2C - After Sales Request').getRecordTypeId();
	}
	if(o.SFCC_Brand__c == 'Arabian Adventures') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA B2C - After Sales Request').getRecordTypeId();
	}
	if(o.SFCC_Brand__c == 'City Sightseeing Dubai') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSD B2C - After Sales Request').getRecordTypeId();
	}

	return(caseRt);
}

@AuraEnabled
public static string getComplaintsRT(string objId){

	Order o = [select id,SFCC_Brand__c from Order where Id =: objId limit 1];
	Id caseRt;
	if(o.SFCC_Brand__c == 'marhaba') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba B2C - Complaint').getRecordTypeId();
	}
	if(o.SFCC_Brand__c == 'Arabian Adventures') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA B2C - Complaint').getRecordTypeId();
	}
	if(o.SFCC_Brand__c == 'City Sightseeing Dubai') {
		caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSD B2C - Complaint').getRecordTypeId();
	}

	return(caseRt);
}

public static string getCreatableFieldsSOQL(string objectName){
	String selects = '';
	Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
	list<string> selectFields = new list<string>();
	if (fMap != null) {
		for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
			Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
			selectFields.add(fd.getName());
		}
	}
	// contruction of SOQL
	if (!selectFields.isEmpty()) {
		for (string s:selectFields) {
			selects += s + ',';
		}
		if (selects.endsWith(',')) {selects = selects.substring(0,selects.lastIndexOf(','));}

	}
	// return constrcucted query
	return('SELECT ' + selects + ' FROM ' + objectName);

}



@AuraEnabled
public static List < String > getselectOptions(string fld) {
	List < String > allOpts = new list < String > ();
	Schema.sObjectType objType = Schema.Case.getSObjectType();
	Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
	map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
	list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
	for (Schema.PicklistEntry a: values) {
		allOpts.add(a.getValue());
	}
	allOpts.sort();
	return(allOpts);
}

public static Map<Id, String> recordtypemapComplaint {get; set;}
public static Map<Id, String> recordtypemapCommendation {get; set;}
public static Map<Id, String> recordtypemapGeneralEnquiry {get; set;}
@AuraEnabled
public static List<String> fetchCaseComplaintRecordTypeValues(){
	List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
	recordtypemapComplaint = new Map<Id, String>();
	Set<String> complaintRt =new Set<String> {'marhaba B2C - Complaint','AA B2C - Complaint','CSD B2C - Complaint'};
	for(RecordTypeInfo rt : recordtypes) {
		if(complaintRt.contains(rt.getName())) {
			recordtypemapComplaint.put(rt.getRecordTypeId(), rt.getName());
		}
	}
	return(recordtypemapComplaint.values());
}
@AuraEnabled
public static List<String> fetchCaseCommendationRecordTypeValues(){
	List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
	recordtypemapCommendation = new Map<Id, String>();
	Set<String> complaintRt =new Set<String> {'marhaba B2C - Commendations/Suggestions','AA B2C - Commendations/Suggestions','CSD B2C - Commendations/Suggestions'};
	for(RecordTypeInfo rt : recordtypes) {
		if(complaintRt.contains(rt.getName())) {
			recordtypemapCommendation.put(rt.getRecordTypeId(), rt.getName());
		}
	}
	return(recordtypemapCommendation.values());
}
@AuraEnabled
public static List<String> fetchCaseGeneralEnquirytRecordTypeValues(){
	List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
	recordtypemapGeneralEnquiry = new Map<Id, String>();
	Set<String> complaintRt =new Set<String> {'marhaba B2C - Generic','AA B2C - Generic','CSD B2C - Generic'};
	for(RecordTypeInfo rt : recordtypes) {
		if(complaintRt.contains(rt.getName())) {
			recordtypemapGeneralEnquiry.put(rt.getRecordTypeId(), rt.getName());
		}
	}
	return(recordtypemapGeneralEnquiry.values());
}
@AuraEnabled
public static Id getRecTypeId(String recordTypeLabel){
	Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
	return(recid);
}
    
    @AuraEnabled
        public static boolean caseOwnerNotMatching(string cid){
        boolean notmatched = true;
        if(cid <> null && cid <> '' && cid.startsWith('500')){           
            string uid = userinfo.getUserId();
            case cse = new case();
            cse = [select id, ownerid from case where id=: cid];
            //uncommented code in  v1.1
            if(cse <> null){
                if(uid <> cse.ownerid){
                    notmatched = true;
                }
                else{
                    notmatched = false;
                }
            } 
        }
        system.debug('notmatched:::' + notmatched);
        return notmatched;
    }
	 @AuraEnabled
    public static void changeCaseOwner(string cid) {
        if(cid <> null && cid <> '' && cid.startsWith('500')){
            
            string uid = userinfo.getUserId();
            case cse = [select id, ownerid from case where id=: cid];
            if(cse <> null){
                cse.OwnerId = uid;
                update cse;
            }
        }
    }
    
    @AuraEnabled
    public static list < eCommerceComponentsController.UserLookupResultWrapper > fetchLookUpValues (String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < eCommerceComponentsController.UserLookupResultWrapper > returnWrapperList = new list < eCommerceComponentsController.UserLookupResultWrapper > ();
        String searchKey = '%' + searchKeyWord + '%';
        //string bunit = '';
        string brand = ''; //v1.2
        system.debug('cid::: ' + cid);
        system.debug(cid);
        if(cid <> null && cid <> ''){
            Case cse = [select id, RecordTypeId, RecordType.Name, Org_Business_Unit__c, Org_Brand__c from Case where id=: cid];
            system.debug('cse.Org_Brand__c::: ' + cse.Org_Brand__c);
            if(cse <> null && cse.Org_Brand__c <> null){
                system.debug('enter1::');
                brand = cse.Org_Brand__c; //v1.2
                system.debug(brand);
                if(brand <> ''){
                    system.debug('enter2::');
                    system.debug('searchType2::' + searchType);
                    if(searchType == 'Queue'){
                        system.debug('enter3::');
                        list<Business_Unit__c> bulist = [SELECT Id,
                                                                Queue_ID__c,
                                                                Org_Queue_Name__c, 
                                                                Org_Business_Unit_Team__c,
                                                                Org_Business_Unit_Team__r.name
                                                            FROM Business_Unit__c
                                                            WHERE RecordType.Name = 'Team'
                                                            AND Org_Brand__c =: brand
                                                            AND Org_Queue_Name__c like: searchKey
                                                            AND IsActive__c = true]; //v1.2
                        system.debug('bulist::: ' + bulist);
                        if(bulist <> null && !bulist.isEmpty()){
                            for(Business_Unit__c bu: bulist){
                                eCommerceComponentsController.UserLookupResultWrapper wrap = new eCommerceComponentsController.UserLookupResultWrapper(bu.Queue_ID__c, bu.Org_Queue_Name__c);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                        //string bunit=cse.Org_Business_Unit__c; //v1.6 variable for business unit
                        string soql = 'select id, Name from user where Name like: searchKey'; //v1.6 includes ( :cse.Org_Business_Unit__c ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                eCommerceComponentsController.UserLookupResultWrapper wrap = new eCommerceComponentsController.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }
                    
                }
            }
            
        }
        
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
    }
    
    @AuraEnabled 
    public static String cloneCaseTest(string caseId){
        system.debug('###Case Id Recieved' + caseId);
   
        try{
            Case originalcase = new Case();
          //  originalcase = [SELECT Id,RecordTypeId,Org_Business_Unit_Text__c FROM Case WHERE Id = :caseId];
            string ReqQuery = getCreatableFieldsSOQL('Case');
            
            ReqQuery+=' where Id = :caseId';
            originalcase = database.query(ReqQuery);
            system.debug('### case: ' + originalcase);
            if(originalcase.Id != null){
                Case newcase = originalcase.clone();
                newcase.Org_Booking__c = null;
                newcase.ParentId = originalcase.Id;
                newcase.Org_Current_Team_Name__c = originalcase.Org_Current_Team_Name__c;
                newcase.Org_Original_Team_Name__c = originalcase.Org_Original_Team_Name__c;
                newcase.IsClone__c = true;
                newcase.Org_Email_From_Customer__c = false;
                insert newcase;
                system.debug('new clone case : ' + newcase);
                return newcase.Id;  
            }else{
                return null;
            } 
        }catch(Exception e){
            system.debug('### getDerwentLookupCode Exception: ' + e);  
            return null;
        }
    }
    
    @AuraEnabled 
    public static void reassignOwner(string cid, string seluserorqueue, string selrt, Boolean sendEmail){
        if(cid <> null && cid <> ''){
            case cse = [select id, ownerid, recordtypeid from case where id=: cid];
            if(cse <> null){
                if(seluserorqueue <> null && seluserorqueue <> ''){
                    cse.ownerid = seluserorqueue;
                    //cse.Send_Notification_Email__c = sendEmail;
                }
                if(selrt <> null && selrt != ''){
                    cse.recordtypeid = selrt;
                }
                update cse;
            }
        }
    }  
    
    
     public class UserLookupResultWrapper{
        @AuraEnabled
        public string rid {get; set;}
        @AuraEnabled
        public string rname {get; set;}
        
        public UserLookupResultWrapper(string rid, string rname){
            this.rid = rid;
            this.rname = rname;
        }
    }
    
}