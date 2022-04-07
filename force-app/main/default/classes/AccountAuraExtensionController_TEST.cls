@isTest
public class AccountAuraExtensionController_TEST {
 
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

    @isTest static void testActiveBookings() {
        Account acc = [SELECT Id FROM Account limit 1];
        List<Booking__c> lBookings = new List<Booking__c>();

        lBookings = AccountAuraExtensionController.getActiveBookings(String.valueOf(acc.Id),'All');
        //system.assertEquals(1, lBookings.size());

    }

    @isTest static void testHistoricBookings() {
        Account acc = [SELECT Id FROM Account limit 1];
        List<Booking__c> lBookings = new List<Booking__c>();

        lBookings = AccountAuraExtensionController.getHistoricalBookings(String.valueOf(acc.Id));
        //system.assertEquals(1, lBookings.size());

    }

    @isTest static void testActiveBookingsLineItems() {
        Account acc = [SELECT Id FROM Account limit 1];
        List<Booking__c> lBookings = new List<Booking__c>();

        lBookings = AccountAuraExtensionController.getActiveBookingsWithLineItems(String.valueOf(acc.Id));
        //system.assertEquals(1, lBookings.size());

    }
    
    
    @isTest static void testHistoricBookingsLineItems() {
        Account acc = [SELECT Id FROM Account limit 1];
        List<Booking__c> lBookings = new List<Booking__c>();

        lBookings = AccountAuraExtensionController.getHistoricalBookingsWithLineItems(String.valueOf(acc.Id));
        //system.assertEquals(1, lBookings.size());

    }

    @isTest static void testOpenCases() {
        Account acc = [SELECT Id FROM Account limit 1];
        List<Case> lCases = new List<Case>();

        lCases = AccountAuraExtensionController.getOpenCases(String.valueOf(acc.Id));
        //system.assertEquals(1, lCases.size());

    }
}