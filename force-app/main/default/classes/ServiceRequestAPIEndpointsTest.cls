@isTest
public class ServiceRequestAPIEndpointsTest {
    
    
	static testMethod void testGetBookingIds() {

        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/service-requests/';  
        req.addParameter('booking-ids', '123123123,1321312312');
      
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        ServiceRequestAPIEndpoints.getServiceRequests();
    }
    
    static testMethod void testGetCases() {
        
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs1.id;
        ent.AccountId = acc.id;
        insert ent;
        
        Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
        Booking__c bk = new Booking__c();
        bk.Booking_ID__c = '123132';
        insert bk;
        
        system.debug('booking' + bk);
        
        Case c = new Case();
        c.Subject = 'Test';
        c.RecordTypeId = trpServiceRequestRecordTypeId;
        c.Org_Booking__c = bk.id;
        c.Is_Public__c = true;
        c.Org_Brand__c = 'trp';
        insert c;
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Message__c = 'test';
        cc.Service_Request__c = c.id;
        cc.Status__c = 'Sent';
        insert cc;
        
        String casenum = [Select CaseNumber from Case where id = :c.id].CaseNumber;
        Case checkingCase = [Select CaseNumber,Is_Public__c,RecordTypeId,Org_Booking_Id__c from Case where id = :c.id];
        system.debug('case' + checkingCase.Org_Booking_Id__c);
		system.debug('caseNum' + casenum);
        String caseNumberWithoutLeadingZeros = '';
        while(casenum.startsWith('0')){
        	casenum = casenum.removeStart('0');
        	caseNumberWithoutLeadingZeros = casenum;
        }
        
        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/service-requests/';  
        req.addParameter('case-number',caseNumberWithoutLeadingZeros );
      
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        ServiceRequestAPIEndpoints.getServiceRequests();
    }
    
    static testMethod void  testPostCustomerComm(){
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs1.id;
        ent.AccountId = acc.id;
        insert ent;

        Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
        GlobalClassOverride.AllowCaseTrigger = false;
        Booking__c bk = new Booking__c();
        insert bk;
        
        system.debug('booking' + bk);
        
        Case c = new Case();
        c.Subject = 'Test';
        c.RecordTypeId = trpServiceRequestRecordTypeId;
        c.Org_Booking__c = bk.id;
        c.Is_Public__c = true;
        c.Org_Brand__c = 'trp';
        insert c;
        
        String casenum = [Select CaseNumber from Case where id = :c.id].CaseNumber;
		system.debug('caseNum' + casenum);
        
        String caseNumberWithoutLeadingZeros = '';
        while(casenum.startsWith('0')){
        	casenum = casenum.removeStart('0');
        	caseNumberWithoutLeadingZeros = casenum;
        }

           ServiceRequestAPIEndpoints reqst=new ServiceRequestAPIEndpoints();
           String JsonMsg=JSON.serialize(reqst);
           Test.startTest();
        
           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/service-requests/'+caseNumberWithoutLeadingZeros+'/customer-communications'; 
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof('{"Text":"New Customer Communication"}');
            RestContext.request = req;
            RestContext.response= res;
            ServiceRequestAPIEndpoints.createServiceRequests();
            
            Test.stopTest();

   }
    
    
    static testMethod void testPostCases(){
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs1.id;
        ent.AccountId = acc.id;
        insert ent;

        Id bookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();               
        Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
        GlobalClassOverride.AllowCaseTrigger = false;
        Booking__c bk = new Booking__c();
        bk.Booking_ID__c = '18150247';
        bk.RecordTypeId = bookingItemRecordTypeId;
        insert bk;
        
        system.debug('booking' + bk);
        
        Case c = new Case();
        c.Subject = 'Test';
        c.RecordTypeId = trpServiceRequestRecordTypeId;
        c.Org_Booking__c = bk.id;
        c.Is_Public__c = true;
        c.Org_Brand__c = 'trp';
        insert c;
        
        String casenum = [Select CaseNumber from Case where id = :c.id].CaseNumber;
		system.debug('caseNum' + casenum);
		
           ServiceRequestAPIEndpoints reqst=new ServiceRequestAPIEndpoints();
           String JsonMsg=JSON.serialize(reqst);
           Test.startTest();
        
           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/service-requests'; 
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof('{"BookingId":"18150247","ReceiveTextAlert":false,"Subject":"This may not be relevant.","Text":"This is the message to the agent","CategoryId": 1,"CreatedByCustomer": false,"CreatedByAutoCancellation": false}');
            RestContext.request = req;
            RestContext.response= res;
            ServiceRequestAPIEndpoints.createServiceRequests();
            
            Test.stopTest();

   }
    
    @isTest
    static void testPatch() {
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs1.id;
        ent.AccountId = acc.id;
        insert ent;

        Id bookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();               
        Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
        GlobalClassOverride.AllowCaseTrigger = false;
        Booking__c bk = new Booking__c();
        bk.Booking_ID__c = '18150247';
        bk.RecordTypeId = bookingItemRecordTypeId;
        insert bk;
        
        system.debug('booking' + bk);
        
        Case c = new Case();
        c.Subject = 'Test';
        c.RecordTypeId = trpServiceRequestRecordTypeId;
        c.Org_Booking__c = bk.id;
        c.Is_Public__c = true;
        c.Org_Brand__c = 'trp';
        c.Reason = 'Resolved';
        c.Closing_Comments__c = 'test';
        insert c;
        
        

        
        String casenum = [Select CaseNumber from Case where id = :c.id].CaseNumber;
        String caseNumberWithoutLeadingZeros = '';
        while(casenum.startsWith('0')){
        	casenum = casenum.removeStart('0');
        	caseNumberWithoutLeadingZeros = casenum;
        }
		system.debug('caseNum' + casenum);
        RestRequest req = new RestRequest();
        req.requestUri = System.URL.getSalesforceBaseUrl().toExternalForm() + '/service-requests/'+caseNumberWithoutLeadingZeros+'/auto-cancel/notify';     
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"Success": true}'); 
        RestContext.request = req;
        ServiceRequestAPIEndpoints.updateServiceRequest();
        	
    }
    
    
    @isTest
    static void testPatch2() {
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs1.id;
        ent.AccountId = acc.id;
        insert ent;

        Id bookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();               
        Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
        GlobalClassOverride.AllowCaseTrigger = false;
        Booking__c bk = new Booking__c();
        bk.Booking_ID__c = '18150247';
        bk.RecordTypeId = bookingItemRecordTypeId;
        insert bk;
        
        system.debug('booking' + bk);
        
        Case c = new Case();
        c.Subject = 'Test';
        c.RecordTypeId = trpServiceRequestRecordTypeId;
        c.Org_Booking__c = bk.id;
        c.Is_Public__c = true;
        c.Org_Brand__c = 'trp';
        c.Reason = 'Resolved';
        c.Closing_Comments__c = 'test';
        insert c;
        
        

        
        String casenum = [Select CaseNumber from Case where id = :c.id].CaseNumber;
        String caseNumberWithoutLeadingZeros = '';
        while(casenum.startsWith('0')){
        	casenum = casenum.removeStart('0');
        	caseNumberWithoutLeadingZeros = casenum;
        }
		system.debug('caseNum' + casenum);
        RestRequest req = new RestRequest();
        req.requestUri = System.URL.getSalesforceBaseUrl().toExternalForm() + '/service-requests/'+caseNumberWithoutLeadingZeros+'/auto-cancel/notify';     
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"Success": false}'); 
        RestContext.request = req;
        ServiceRequestAPIEndpoints.updateServiceRequest();
        	
    }
    
    
}