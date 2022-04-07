@isTest
private class AsyncDerwentWebService_Batches_Test {

 static testmethod void AsyncDerwentWebService_Csr_Batch(){
 
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Csr';
        reqLog.Entity_Id__c = '1113333';
        reqLog.Status__c = 'New';
        reqLog.Unique__c = true;
        insert reqLog;
        
        test.starttest();
        database.executebatch(new AsyncDerwentWebService_Csr_Batch());
        test.stoptest();
 }
 
 static testmethod void AsyncDerwentWebService_Booking_Batch(){
 
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Booking';
        reqLog.Entity_Id__c = '999882772';
        reqLog.Status__c = 'New';
        reqLog.Unique__c = true;
        insert reqLog;
        
        test.starttest();
        database.executebatch(new AsyncDerwentWebService_Booking_Batch());
        test.stoptest();
 }
 
 static testmethod void AsyncDerwentWebService_Customer_Batch(){
 
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Customer';
        reqLog.Entity_Id__c = '2131313131';
        reqLog.Status__c = 'New';
        reqLog.Unique__c = true;
        insert reqLog;
        
        test.starttest();
        database.executebatch(new AsyncDerwentWebService_Customer_Batch());
        test.stoptest();
 }
 
 static testmethod void AsyncDerwentWebService_Quote_Batch(){
 
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Quote';
        reqLog.Entity_Id__c = '213131313123';
        reqLog.Status__c = 'New';
        reqLog.Unique__c = true;
        insert reqLog;
        test.starttest();
        database.executebatch(new AsyncDerwentWebService_Quote_Batch());
        test.stoptest();
 }
 static testmethod void AsyncDerwentWebService_SFCustomer_Batch(){
 
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        acc.Re_Push__c=true;
        insert acc;
       
        
        test.starttest();
        database.executebatch(new AsyncDerwentWebService_SFCustomer_Batch());
        test.stoptest();
 }

}