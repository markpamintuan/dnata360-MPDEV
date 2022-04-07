@isTest
public class GDPR_Test {  
    
    
    
    public static testMethod void testConstants(){ 
        
        test.startTest();
        System.assertEquals(GDPRConstant.GDPR_SELECTED_STATUS_NOT_STARTED,'Not started');
        System.assertEquals(GDPRConstant.GDPR_SELECTED_STATUS_COMPLETE,'Completed');
        System.assertEquals(GDPRConstant.GDPR_SELECTED_STATUS_ERROR,'Error');
        System.assertEquals(GDPRConstant.GDPR_SELECTED_STATUS_VALIDATED,'Validated');
        System.assertEquals(GDPRConstant.GDPR_CHILD_QUERY_STATUS_NEW,'New');
        System.assertEquals(GDPRConstant.GDPR_CHILD_QUERY_STATUS_COMPLETE,'Complete');
        System.assertEquals(GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED,'Failed');
        System.assertEquals(GDPRConstant.GDPR_CHILD_QUERY_STATUS_VALIDATED,'Validated');
        System.assertEquals(GDPRConstant.GDPR_CHILD_QUERY_STATUS_PASSED,'Passed'); 
        test.stopTest();
    }
     
    public static testMethod void testMethod1(){
        Id accountId = TestDataFactory.createEKUK_AccountId(); 
        
        GDPR_Job_Tracker__c jt = new GDPR_Job_Tracker__c();
        jt.Status__c = 'Not Started'; 
        insert jt;
        
        GDPR_Selected_Object__c so = new GDPR_Selected_Object__c();
        so.GDPR_Job_Tracker__c = jt.Id;
        so.Object_API_Name__c = 'Account';
        so.RecordIds__c = accountId + ','; 
        insert so;
        
        GDPR_Child_Query__c  cq = new GDPR_Child_Query__c();
        cq.SOQL_Query__c = 'SELECT Id, (SELECT Id FROM Histories), (SELECT Id FROM Feeds) FROM Account WHERE Id IN :passedInList';
        cq.Masking_Values_For_Fields__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true';
        cq.Object_API_Name__c = 'Account';
        cq.Query_Order_Number__c = 0;
        cq.GDPR_Selected_Object__c = so.Id;
        cq.Job_Status__c = 'Not started';
        insert cq;
        
        GDPR_Child_Query__c  cq2 = new GDPR_Child_Query__c();
        cq2.SOQL_Query__c = 'SELECT Id FROM Booking__c WHERE Org_Account_Name__c IN :[Query0]'; 
        cq2.Masking_Values_For_Fields__c = '';
        cq2.Object_API_Name__c = 'Booking__c';
        cq2.Query_Order_Number__c = 1;
        cq2.GDPR_Selected_Object__c = so.Id;
        cq2.Job_Status__c = 'Not started';
        insert cq2;
        
        GDPRValidationRecords.startValidateProcess(jt.Id);
        cq.Job_Status__c = 'Validated';
        update cq;
        GDPRValidationRecords.validateSelectedObject(jt.Id);
        System.enqueueJob(new GDPRValidationRecords(so.Id,jt.Id,new Map<String,List<String>>())); 
        cq2.Job_Status__c = 'Validated';
        update cq2;
        GDPRValidationRecords.validateSelectedObject(jt.Id);     
        
        GDPRProcessChildqueries processQuery = new GDPRProcessChildQueries();
        map<string,List<string>> mapChildQueryResult = processQuery.processChildQuery([select id,SOQL_Query__c,Query_Order_Number__c,GDPR_Selected_Object__c,Masking_Values_For_Fields__c from GDPR_Child_Query__c limit 1],new Map<String,List<String>>()); 
        GDPRUtility.fetchSelectedObjectQueryProcessing([select id from GDPR_Child_Query__c limit 1].Id);
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated', 0);
        GDPRUtility.resetQueryStatus([select id from GDPR_Child_Query__c limit 1].Id);
        GDPRUtility.resetTracker([select id from GDPR_Job_Tracker__c limit 1].Id);
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated', 'error');
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated');
        
        GDPRProcessChildQueries fetch = new GDPRProcessChildQueries();
       	Map<String,List<String>>  mapPreviousChildQueryResult = new Map<String,List<String>>();
        mapPreviousChildQueryResult.put('[Query0]', new List<String>());
        mapPreviousChildQueryResult.get('[Query0]').add('1234567898765');        
        fetch.fetchPreviousQueryIds(mapPreviousChildQueryResult,'[Query0]');
        
        
        
        system.debug('@@@@@@@@@@@@' + [SELECT FirstName, LastName FROM Account WHERE Id =: accountId]);
        
    }

    public static testMethod void testMethod2(){
        Id accountId = TestDataFactory.createEKUK_AccountId(); 
        
        GDPR_Job_Tracker__c jt = new GDPR_Job_Tracker__c();
        jt.Status__c = 'Not Started'; 
        insert jt;
        
        GDPR_Selected_Object__c so = new GDPR_Selected_Object__c();
        so.GDPR_Job_Tracker__c = jt.Id;
        so.Object_API_Name__c = 'Account';
        so.RecordIds__c = accountId + ','; 
        insert so;
        
        GDPR_Child_Query__c  cq = new GDPR_Child_Query__c();
        cq.SOQL_Query__c = 'SELECT Id, (SELECT Id FROM Histories), (SELECT Id FROM Feeds) FROM Account WHERE Id IN :passedInList';
        cq.Masking_Values_For_Fields__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true';
        cq.Object_API_Name__c = 'Account';
        cq.Query_Order_Number__c = 0;
        cq.GDPR_Selected_Object__c = so.Id;
        cq.Job_Status__c = 'Validated';
        insert cq;
        
        GDPR_Child_Query__c  cq2 = new GDPR_Child_Query__c();
        cq2.SOQL_Query__c = 'SELECT Id FROM Booking__c WHERE Org_Account_Name__c IN :[Query0]'; 
        cq2.Masking_Values_For_Fields__c = '';
        cq2.Object_API_Name__c = 'Booking__c';
        cq2.Query_Order_Number__c = 1;
        cq2.GDPR_Selected_Object__c = so.Id;
        cq2.Job_Status__c = 'Not started';
        insert cq2;
        
        GDPRValidationRecords.startValidateProcess(jt.Id);
        
    }    
    
    public static testMethod void Validate_processResult() { 
        
        Id accountId = TestDataFactory.createEKUK_AccountId(); 
        List<String> strIds = new List<String>();
        strIds.add(accountId);
        
        Wrapper_Utility.selectedRecordsDetails srdWrap = new Wrapper_Utility.selectedRecordsDetails();
        srdWrap.objectName = 'Account';
        srdWrap.recList = strIds;
        
        List<Wrapper_Utility.selectedRecordsDetails> recsToProcess = new List<Wrapper_Utility.selectedRecordsDetails>();
        recsToProcess.add(srdWrap);
        
        ProcessResult.processRecords(JSON.serialize(recsToProcess));
        
        GDPRProcessChildqueries processQuery = new GDPRProcessChildQueries();
        map<string,List<string>> mapChildQueryResult = processQuery.processChildQuery([select id,SOQL_Query__c,Query_Order_Number__c,GDPR_Selected_Object__c,Masking_Values_For_Fields__c from GDPR_Child_Query__c limit 1],new Map<String,List<String>>()); 
        
        system.debug('\n\n\n########################################' + [select id from GDPR_Job_Tracker__c limit 1] + '\n\n\n');
        system.debug('\n\n\n########################################' + [select id from GDPR_Selected_Object__c limit 1] + '\n\n\n');
        system.debug('\n\n\n########################################' + [select id from GDPR_Child_Query__c] + '\n\n\n');
        
        System.enqueueJob(new GDPRValidationRecords([select id from GDPR_Selected_Object__c limit 1].Id,[select id from GDPR_Job_Tracker__c limit 1].Id,mapChildQueryResult));
        
        GDPRUtility.fetchSelectedObjectQueryProcessing([select id from GDPR_Child_Query__c limit 1].Id);
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated', 0);
        GDPRUtility.resetQueryStatus([select id from GDPR_Child_Query__c limit 1].Id);
        GDPRUtility.resetTracker([select id from GDPR_Job_Tracker__c limit 1].Id);
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated', 'error');
        GDPRUtility.updateQueryStatus([select id from GDPR_Child_Query__c limit 1].Id, 'Validated');
        
    }
    

    /**
public static testMethod void testMethod2(){

Id accountId = TestDataFactory.createEKUK_AccountId();
Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
Subject = 'Test', Org_Destination__c = 'Test',
Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
Org_No_of_Children_Travelling__c = 1);

insert objCase; 

GDPR_Job_Tracker__c jt = new GDPR_Job_Tracker__c();
jt.Status__c = 'Validated'; 
insert jt;

GDPR_Selected_Object__c so = new GDPR_Selected_Object__c();
so.GDPR_Job_Tracker__c = jt.Id;
so.Object_API_Name__c = 'Case';
so.RecordIds__c = objCase.Id;
insert so;

GDPR_Child_Query__c  cq= new GDPR_Child_Query__c();
cq.SOQL_Query__c = 'SELECT Id, (SELECT Id FROM Histories), (SELECT Id FROM Feeds) FROM Case WHERE Id IN :passedInList';
cq.Masking_Values_For_Fields__c = 'GDPR_Forgotten__c:true,';
cq.Object_API_Name__c = 'Case';
cq.Query_Order_Number__c = 0;
cq.GDPR_Selected_Object__c = so.Id;
cq.Job_Status__c = 'Validated';
insert cq;

Map<String,List<String>> strMap = new Map<String,List<String>>();
strMap.put('a', new List<String>{'a','b'}); 
//strMap.get('a').putAll({'1','2'});


//String s = '[{"objectName":"Case","recList":['+objCase.Id+']}]';

//ProcessResult.processRecords(s);
//
Test.startTest();

GDPRProcessRecords pr = new GDPRProcessRecords(so.Id,jt.Id,null);


// startTest/stopTest block to force async processes to run
System.enqueueJob(pr);
GDPRProcessRecords.processSelectedObject(jt.Id);
//ID jobID = System.enqueueJob(updater);
Test.stopTest();       

}

public static testMethod void testMethod3(){ 

Id accountId = TestDataFactory.createEKUK_AccountId();
Id accountId2 = TestDataFactory.createDTME_AccountId();
Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
Subject = 'Test', Org_Destination__c = 'Test',
Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
Org_No_of_Children_Travelling__c = 1, AccountId = accountId);

insert objCase; 

GDPR_Job_Tracker__c jt = new GDPR_Job_Tracker__c();
jt.Status__c = 'Not Started'; 
insert jt;

GDPR_Selected_Object__c so = new GDPR_Selected_Object__c();
so.GDPR_Job_Tracker__c = jt.Id;
so.Object_API_Name__c = 'Account';
so.RecordIds__c = accountId;
insert so;
GDPR_Selected_Object__c so2 = new GDPR_Selected_Object__c();
so2.GDPR_Job_Tracker__c = jt.Id;
so2.Object_API_Name__c = 'Account';
so2.RecordIds__c = accountId2;
insert so2;

GDPR_Child_Query__c  cq= new GDPR_Child_Query__c();
cq.SOQL_Query__c = 'SELECT Id, (SELECT Id FROM Histories), (SELECT Id FROM Feeds) FROM Account WHERE Id IN :passedInList';
cq.Masking_Values_For_Fields__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true,Org_Master_Account__c:[null],';
cq.Object_API_Name__c = 'Account';
cq.Query_Order_Number__c = 0;
cq.GDPR_Selected_Object__c = so.Id;
cq.Job_Status__c = 'Not Started';
insert cq;

GDPR_Child_Query__c  cq2= new GDPR_Child_Query__c();
cq2.SOQL_Query__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true,Org_Master_Account__c:[null],';
cq2.Masking_Values_For_Fields__c = 'GDPR_Forgotten__c:true,';
cq2.Object_API_Name__c = 'Account';
cq2.Query_Order_Number__c = 0;
cq2.GDPR_Selected_Object__c = so2.Id;
cq2.Job_Status__c = 'Not Started';
insert cq2;

Map<String,List<String>> strMap = new Map<String,List<String>>();
strMap.put('a', new List<String>{'a','b'}); 
//strMap.get('a').putAll({'1','2'});


//String s = '[{"objectName":"Case","recList":['+objCase.Id+']}]';

//ProcessResult.processRecords(s);
//
Test.startTest();
GDPRValidationRecords vr = new GDPRValidationRecords(so.Id,jt.Id,null);

// startTest/stopTest block to force async processes to run
System.enqueueJob(vr);

GDPRValidationRecords.startValidateProcess(jt.Id);

Test.stopTest();       

}

public static testMethod void testMethod4(){ 

Id accountId = TestDataFactory.createEKUK_AccountId();
Id accountId2 = TestDataFactory.createDTME_AccountId();
Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
Subject = 'Test', Org_Destination__c = 'Test',
Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
Org_No_of_Children_Travelling__c = 1, AccountId = accountId);

insert objCase; 

GDPR_Job_Tracker__c jt = new GDPR_Job_Tracker__c();
jt.Status__c = 'Validated'; 
insert jt;

GDPR_Selected_Object__c so = new GDPR_Selected_Object__c();
so.GDPR_Job_Tracker__c = jt.Id;
so.Object_API_Name__c = 'Account';
so.RecordIds__c = accountId;
insert so;
GDPR_Selected_Object__c so2 = new GDPR_Selected_Object__c();
so2.GDPR_Job_Tracker__c = jt.Id;
so2.Object_API_Name__c = 'Account';
so2.RecordIds__c = accountId2;
insert so2;

GDPR_Child_Query__c  cq= new GDPR_Child_Query__c();
cq.SOQL_Query__c = 'SELECT Id, (SELECT Id FROM Histories), (SELECT Id FROM Feeds) FROM Account WHERE Id IN :passedInList';
cq.Masking_Values_For_Fields__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true,Org_Master_Account__c:[null],';
cq.Object_API_Name__c = 'Account';
cq.Query_Order_Number__c = 0;
cq.GDPR_Selected_Object__c = so.Id;
cq.Job_Status__c = 'Validated';
insert cq;

GDPR_Child_Query__c  cq2= new GDPR_Child_Query__c();
cq2.SOQL_Query__c = 'PersonMobilePhone:111111111,PersonEmail:[recordid]anonymous@dnata.com,FirstName:Anonymized,LastName:Anonymized,GDPR_Forgotten__c:true,Org_Master_Account__c:[null],';
cq2.Masking_Values_For_Fields__c = 'GDPR_Forgotten__c:true,';
cq2.Object_API_Name__c = 'Account';
cq2.Query_Order_Number__c = 0;
cq2.GDPR_Selected_Object__c = so2.Id;
cq2.Job_Status__c = 'Validated';
insert cq2;

Map<String,List<String>> strMap = new Map<String,List<String>>();
strMap.put('a', new List<String>{'a','b'}); 
//strMap.get('a').putAll({'1','2'});


//String s = '[{"objectName":"Case","recList":['+objCase.Id+']}]';

//ProcessResult.processRecords(s);
//
Test.startTest();
GDPRProcessRecords pr = new GDPRProcessRecords(so.Id,jt.Id,null);


// startTest/stopTest block to force async processes to run
System.enqueueJob(pr);
GDPRProcessRecords.processSelectedObject(jt.Id);
//ID jobID = System.enqueueJob(updater);

Test.stopTest();       

}
**/
    
    
}