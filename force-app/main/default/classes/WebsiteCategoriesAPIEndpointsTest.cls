@isTest
public class WebsiteCategoriesAPIEndpointsTest {
    static testMethod void test1(){
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
        bk.Org_Booking_Type__c = 'Flight';
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/website-categories';  
        req.addParameter('booking-id', '18150247');
       
      
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        WebsiteCategoriesAPIEndpoints.getCategories();
    }
    
    
    static testMethod void test2(){
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/website-categories';  
        
        req.addParameter('booking-type-number', '1');
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        WebsiteCategoriesAPIEndpoints.getCategories();
    }
    
    
    static testMethod void test3(){
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/website-categories';  
       
        req.addParameter('category-group-name', 'Other');
      
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        WebsiteCategoriesAPIEndpoints.getCategories();
    }
    
    
    static testMethod void test4(){
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/website-categories';  
       
        
      
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        WebsiteCategoriesAPIEndpoints.getCategories();
    }
}