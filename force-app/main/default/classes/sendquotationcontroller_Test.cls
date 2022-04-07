@isTest
public class sendquotationcontroller_Test {
    static testMethod void sendquotationcontroller() {
        Id accountId = TestDataFactory.createEKUK_AccountId();
                
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);

        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2 );
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        header.Customer__c = accountId;
        insert header;

        SendQuotationController.sendQuoteToCustomer(header.Id, header.Customer__c, header.Case__c, 'title', 'emailText');
        
        Test.startTest();
    	SendQuotationController.sendQuote(header.Id, header.Customer__c, header.Case__c, 'title');
        Test.stopTest();
    }

    static testMethod void sendquotationcontroller2() {
        Id accountId = TestDataFactory.createEKUK_AccountId();
                
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);

        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH - New Enquiry').getRecordTypeId(),
                                Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2 );
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        header.Customer__c = accountId;
        insert header;

        SendQuotationController.sendQuoteToCustomer(header.Id, header.Customer__c, header.Case__c, 'title', 'emailText');
        
        Test.startTest();
    	    SendQuotationController.sendQuote(header.Id, header.Customer__c, header.Case__c, 'title');
        Test.stopTest();
    }
    
}