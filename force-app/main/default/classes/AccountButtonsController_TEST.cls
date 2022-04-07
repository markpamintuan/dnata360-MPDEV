@isTest
public class AccountButtonsController_TEST {

	@testSetup static void dataSetup() {
		//CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
	}

	@isTest static void testCreateCase() {
		Account acc = [SELECT Id FROM Account limit 1];		
		String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId();
		AccountButtonsController.autoCreateCase(String.valueOf(acc.Id), recordTypeId , 'Test Subject');
		List<Case> lCases = new List<Case>();
		lCases = [SELECT Id FROM Case];	
		system.assertEquals(1, lCases.size());
	}
}