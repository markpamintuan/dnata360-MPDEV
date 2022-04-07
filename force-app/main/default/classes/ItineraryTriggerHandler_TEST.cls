@isTest
public class ItineraryTriggerHandler_TEST {
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
        itin.Type__c = 'Accommodation';
		insert itin;
	}

	@isTest static void testItinerary() {
		Account acc = [SELECT Id FROM Account limit 1];
		Itinerary__c itin = [SELECT Id, Org_Start_Date__c, Org_End_Date__c FROM Itinerary__c limit 1 ];
		itin.Org_Start_Date__c = System.today() - 100;
		itin.Org_End_Date__c = System.today()  + 100;
		update itin;
	}

	@isTest static void testItineraryUpdate() {
		Account acc = [SELECT Id FROM Account limit 1];
		Itinerary__c itin = [SELECT Id, Org_Start_Date__c, Org_End_Date__c FROM Itinerary__c limit 1 ];
		itin.Org_Start_Date__c = System.today() - 100;
		itin.Org_End_Date__c = System.today()  + 100;
		update itin;
	}
    
    @isTest static void testItineraryDelete() {
		Itinerary__c itin = [SELECT Id, Org_Start_Date__c, Org_End_Date__c FROM Itinerary__c limit 1 ];
		delete itin;
	}

}