@isTest
public class CSRTriggerHandler_TEST {

    /*
    @testSetup static void dataSetup() {
        //CreateAccount
        Id accountId = TestDataFactory.createEKUK_AccountId();
        system.debug('#### dataSetup with accountId: ' + accountId);
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        
        Booking__c bookheader = TestDataFactory.createActiveBookingHeader(accountId);
        bookheader.Org_Brand__c = 'dnata';
        insert bookheader;

        TestDataFactory.createCSR(bookheader.Id);

        //Create Cases
        TestDataFactory.createCaseEKH(accountId);
        
    } 
    */  

    @isTest static void testActiveBookings() 
    {
    
        User usr = new User(
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'dTME - Retail Agent'].Id,
                             LastName = 'last',
                             Email = 'puser000@amamama.com',
                             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'
                             //UserRoleId = r.Id
                        );
                        
       System.runas(usr) 
       {
            
            //CreateAccount
            Id accountId = TestDataFactory.createEKUK_AccountId();
            system.debug('#### dataSetup with accountId: ' + accountId);
            
            //Create Entitlement        
            BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
            TestDataFactory.createEntitlement(accountId, bhs.Id);
            
            Booking__c bookheader = TestDataFactory.createActiveBookingHeader(accountId);
            bookheader.Org_Brand__c = 'dnata';
            insert bookheader;
    
            TestDataFactory.createCSR(bookheader.Id);
    
            //Create Cases
            TestDataFactory.createCaseEKH(accountId);
            
            
            
            Account acc = [SELECT Id FROM Account limit 1];
            CSR__c csr = [SELECT Id, Status__c FROM CSR__c limit 1];
            csr.Status__c = 'Completed';
            update csr;
       
       }
        

    }
}