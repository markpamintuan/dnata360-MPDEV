@isTest
private class RequestLogBatch_Test {

 static testmethod void RequestLogBatch(){
 
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Customer';
        reqLog.Entity_Id__c = '1113333';
        reqLog.Status__c = 'New';
        reqLog.Unique__c = true;
        insert reqLog;
        
        RequestLogBatch test1= new RequestLogBatch();
        test1.getDerwentsetting('Get_Customer');
        String customerRequest='{\r\n\t\t\t\"Customers\": [\r\n\t\t\t{\r\n\t\t\t\"CustomerId\": \"bfb73454-5a3a-457e-b8e1-a942ae47fbf8\",\r\n\t\t\t\"TenantId\": 2,\r\n\t\t\t\"Email\": \"test@test.com\",\r\n\t\t\t\"Title\": \"Mr\",\r\n\t\t\t\"FirstName\": \"test\",\r\n\t\t\t\"LastName\": \"test\",\r\n\t\t\t\"CountryCode\": \"GB\",\r\n\t\t\t\"PostCode\": \"test\",\r\n\t\t\t\"Address\": \"test\",\r\n\t\t\t\"City\": \"test\",\r\n\t\t\t\"County\": \"\",\r\n\t\t\t\"HomeTel\": \"65765765\",\r\n\t\t\t\"MobileTel\": \"\",\r\n\t\t\t\"Notes\": \"\",\r\n\t\t\t\"LoyaltyId\": \"\",\r\n\t\t\t\"Nationality\": \"GB\",\r\n\t\t\t\"SendTextAlerts\": true,\r\n\t\t\t\"EmailSignup\": true\r\n\t\t\t}\r\n\t\t\t],\r\n\"CommunicationPreferenceDetails\": [\r\n{\r\n\"CommunicationChannel\": \"Email\",\r\n\"Source\": \"TravelRepublic\",\r\n\"Reason\": \"Booking Form\",\r\n\"EventDate\": \"2018-07-31T09:16:43.03\"\r\n},\r\n{\r\n\"CommunicationChannel\": \"Sms\",\r\n\"Source\": \"TravelRepublic\",\r\n\"Reason\": \"Booking Form\",\r\n\"EventDate\": \"2018-07-31T09:16:43.033\"\r\n}\r\n]\r\n,\r\n\t\t\t\"NotFoundCustomers\": [\r\n\t\t\t\"04372647-04b1-0000-a380-ac4c8d3a74d2\"\r\n\t\t\t]\r\n\t\t\t}';

        test1.parseGetCustResponse(customerRequest);
        test.starttest();
        database.executebatch(new RequestLogBatch());
        test.stoptest();
 }
 
 static testmethod void RequestLogBatch_MatchCompleted(){
          
        Parameters__c  obj = new Parameters__c ();
        obj.Start_Date__c = Date.today()-1;
        obj.End_Date__c = date.today()+1;
        obj.Entity__c='Customer';
        insert obj;
        
        Request_Log__c reqLog = new Request_Log__c();
        reqLog.Entity__c = 'Customer';
        reqLog.Entity_Id__c = '1113333';
        reqLog.Status__c = 'Completed';        
        insert reqLog;
        
        Request_Log__c reqLog2 = new Request_Log__c();
        reqLog2.Entity__c = 'Customer';
        reqLog2.Entity_Id__c = '1113333';
        reqLog2.Status__c = 'Failed';        
        insert reqLog2;
        
        test.starttest();
        database.executebatch(new BatchRequestLog_MatchCompleted());
        test.stoptest();
 }
}