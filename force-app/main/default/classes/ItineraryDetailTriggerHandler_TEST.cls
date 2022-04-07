@isTest
public class ItineraryDetailTriggerHandler_TEST {
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

		Booking__c historicBookingHeader = TestDataFactory.createHistoricBookingHeader(accountId);
		insert historicBookingHeader;

		//Create Historic bookings
		Booking__c historicBooking = TestDataFactory.createHistoricBooking(accountId, historicBookingHeader.Id);
		insert historicBooking;

		Itinerary__c itin = TestDataFactory.createItinerary(historicBooking.Id);
		insert itin;

		Itinerary_Detail__c itinDetail = TestDataFactory.createItineraryDetail(itin.Id);
		insert itinDetail;
	}

	@isTest static void testItinerary() {
		Account acc = [SELECT Id FROM Account limit 1];
		Itinerary_Detail__c itinDetail = [SELECT Id, Org_Departure_Date__c, Org_Arrival_Date__c FROM Itinerary_Detail__c limit 1 ];
		itinDetail.Org_Departure_Date__c = System.today() - 100;
		itinDetail.Org_Arrival_Date__c = System.today()  + 100;
		update itinDetail;
	}
}