@isTest
public class updateBookingHeaderHotelName_Test {
	@testSetup static void dataSetup() {
		//CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
        
		//Create Booking Header
		Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
        bookHeader.Org_Brand__c ='ekh';
        bookHeader.Org_Booking_Type__c = 'Accommodation';
		insert bookHeader;

		//Create Active Bookings
		Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
        bookHeader.Org_Brand__c ='ekh';
        bookHeader.Org_Booking_Type__c = 'Accommodation';
		insert book;

		Itinerary__c itin = TestDataFactory.createItinerary(book.Id);
        itin.Type__c = 'Accommodation';
        itin.Org_Hotel_Name__c = 'Test';
		insert itin;

		Itinerary_Detail__c itinDetail = TestDataFactory.createItineraryDetail(itin.Id);
		insert itinDetail;
	}

	@isTest static void updateMethodTest() {
        Test.startTest();
             List<Itinerary__c> itineraryList = new List<Itinerary__c>([SELECT Org_Booking_Header_Id_Formula__c,Org_Hotel_Name__c,Org_Check_In__c,No_of_days__c,Org_Booking__r.Booking_Header__r.Hotel_Name__c FROM Itinerary__c]);
            updateBookingHeaderHotelName obj = new updateBookingHeaderHotelName();
            Database.QueryLocator ql = obj.start(null);
            obj.execute(null,itineraryList);
            obj.Finish(null);
        Test.stopTest();
	}
}