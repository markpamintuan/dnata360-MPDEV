/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class QuoteLightningController_Test {

    static testMethod void QuoteLightningControllerTest1() {
    	string parentRecordId = 'Test';
    	QuoteLightningController obj = new QuoteLightningController();
    	
    	QuoteLightningController.getConfiguration(parentRecordId);
    	
    	//CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
    	
    	Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
    							Subject = 'Test', Org_Destination__c = 'Test',
    							Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
    							Org_No_of_Children_Travelling__c = 1);
    							
		insert objCase;		
		
    	QuoteLightningController.getCaseDetails(objCase.id);
    	
    	QuoteLightningController.CaseQuoteInfo c = new QuoteLightningController.CaseQuoteInfo();
        c.CaseNumber = objCase.CaseNumber;
        c.Subject = objCase.Subject;
        c.Destination = objCase.Org_Destination__c;
        c.TravellerType = objCase.Org_Traveller__c;
        c.NoOfAdults = string.valueOf(objCase.Org_No_of_Adults_Travelling__c);
        c.NoOfChildren = string.valueOf(objCase.Org_No_of_Children_Travelling__c);
        c.DateFrom = system.today();
        c.DateTo = system.today();
        
        QuoteLightningController.QuoteWrapper objQW = new QuoteLightningController.QuoteWrapper();
        objQW.CSS = 'Test';
        
        QuoteLightningController.CustomerInfo objCI = new QuoteLightningController.CustomerInfo();
        objCI.RecordId = 'Test';
        objCI.CustomerName = 'Test';
        
        
    }
}