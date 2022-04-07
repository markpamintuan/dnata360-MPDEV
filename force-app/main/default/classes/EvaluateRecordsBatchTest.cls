@isTest
public class EvaluateRecordsBatchTest {
    
    
    @isTest static void testCSR() {
        
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
        
        System.runas(usr){
            
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
            
            //create margin movement
            
            
            CSR__c csr = [select id,Account__c from CSR__c limit 1];
            csr.Account__c = null;
            update csr;
            
            
            Test.startTest();
            Database.executeBatch(new EvaluateRecordsBatch('SELECT Id, Account__c,Booking_ID__r.Org_Account_Name__r.Id FROM CSR__c where Account__c = null'),200);
            test.stopTest();
            CSR__c csr2 = [select id,Account__c from CSR__c limit 1];
            system.assertNotEquals(csr2.Account__c, null);
            

        } 
    }
    
    
@isTest static void testMM() {
        
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
        
        System.runas(usr){
            
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
            
            //create margin movement
            
            Margin_Movement__c mm = new Margin_Movement__c();
            mm.Amount__c = 1;
            mm.Booking__c = bookheader.Id; 
            insert mm;
            
            mm.Account__c = null;
            update mm;
            
            
            Test.startTest();
            Database.executeBatch(new EvaluateRecordsBatch('SELECT Id, Account__c,Booking__r.Org_Account_Name__r.Id,Case__r.Account.Id FROM Margin_Movement__c where Account__c = null'),200);
            test.stopTest();
            Margin_Movement__c mm2 = [select id,Account__c from Margin_Movement__c limit 1];
            system.assertNotEquals(mm2.Account__c, null);
            

        } 
    }    
    
}