@isTest
public with sharing class BatchFailedWebServicesTest {
    
    @isTest
    public static void myTest(){
        
        Account objAccount = new Account();
        objAccount.name = 'Test';
        objAccount.Org_Derwent_Customer_No__c = 'abc123456';
        insert objAccount;
        
        list<Request_Log__c> lstLogs = new list<Request_Log__c>();
        Request_Log__c objLog = new Request_Log__c();
        objLog.Is_Synchronous__c = true;
        objLog.Entity__c = 'Booking';
        objLog.Entity_Id__c = '1138764';
        objLog.Error_Log__c = 'Entity_Deleted';
        objLog.Status__c = 'Failed';
        objLog.Repush__c = true;
        lstLogs.add(objLog);

        objLog = new Request_Log__c();
        objLog.Is_Synchronous__c = true;
        objLog.Entity__c = 'Customer';
        objLog.Entity_Id__c = 'abc123456';
        objLog.Error_Log__c = 'DUPLICATES_DETECTED, Use one of these records?';
        objLog.Status__c = 'Failed';
        objLog.Repush__c = false;
        lstLogs.add(objLog);
        insert lstLogs;

        lstLogs[1].Repush__c = false;
        update lstLogs[1];

        test.startTest();
            Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        	BatchFailedWebServices objBatchFailedWebServices = new BatchFailedWebServices();    
        	//database.executebatch(objBatchFailedWebServices , 1 );
            objBatchFailedWebServices.execute(null);
        test.stopTest();

    }
}