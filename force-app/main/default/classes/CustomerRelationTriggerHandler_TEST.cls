@isTest
public class CustomerRelationTriggerHandler_TEST {
	@testSetup static void dataSetup() {
		//CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
		
		//Create Cases
		TestDataFactory.createCaseEKH(accountId);

		//Create Booking Header
		Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
		insert bookHeader;

		//Create Active Bookings
		Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
		insert book;

		//Create Historic bookings
		Booking__c historicBookingHeader = TestDataFactory.createHistoricBookingHeader(accountId);
		insert historicBookingHeader;

		Booking__c historicBooking = TestDataFactory.createHistoricBooking(accountId, historicBookingHeader.Id);
		insert historicBooking;

		
	}

	@isTest static void testNoAccount() {
		Account acc = [SELECT Id FROM Account limit 1];
		Relation__c rel2 = new Relation__c();
		rel2.Org_AccountName__c = acc.Id;
		rel2.Org_Relationship__c = 'Mother';
		rel2.Org_Last_Name__c = 'TestLastNam435e';
		rel2.Org_Mobile__c = '08546574859';
		rel2.Org_Email__c = 'test123fdsfds45@gmail.com';
		rel2.UniqueId__c = 'DERW123';
		insert rel2;	

	}

	@isTest static void testNoAccountOrEmail() {
		Account acc = [SELECT Id FROM Account limit 1];
		Relation__c rel2 = new Relation__c();
		rel2.Org_AccountName__c = acc.Id;
		rel2.Org_Relationship__c = 'Mother';
		rel2.Org_Last_Name__c = 'TestLastNam435e';
		rel2.Org_Mobile__c = '08546574859';
        rel2.UniqueId__c = 'DFOW123';
		try{
			insert rel2;
		}catch(Exception e){

		}
		

	}

	@isTest static void testNoAccountOrPhone() {
		Account acc = [SELECT Id FROM Account limit 1];
		Relation__c rel2 = new Relation__c();
		rel2.Org_AccountName__c = acc.Id;
		rel2.Org_Relationship__c = 'Mother';
		rel2.Org_Last_Name__c = 'TestLastNam435e';
        rel2.UniqueId__c = 'DERW123';
		try{
			insert rel2;
		}catch(Exception e){
			
		}
	}

}