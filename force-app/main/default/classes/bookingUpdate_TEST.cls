@isTest
public class bookingUpdate_TEST {
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

	@isTest static void testupdate() {
		Account acc = [SELECT Id FROM Account limit 1];
		Case cse = [SELECT Id FROM Case limit 1];
		Booking__c book = [SELECT Id FROM Booking__c limit 1];
		map<id,id> bookCaseMap = new map<id,id>();	
		bookCaseMap.put(book.Id, cse.Id);
		bookingUpdate.updateBooking(bookCaseMap);
	}
}