@isTest
public class BookingTriggerHandler_TEST {

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


        Booking__c book = [SELECT Id, 
                                        Org_Travel_Start_Date__c, 
                                        Org_Travel_End_Date__c 
                                FROM Booking__c
                                WHERE Booking_Header__c != null 
                                AND Org_Travel_Start_Date__c =: System.today() 
                                AND Org_Travel_End_Date__c =: System.today() + 7
                                LIMIT 1 ];
        system.debug('### testActiveBookings book: ' + book);
        book.Org_Travel_Start_Date__c = System.today() - 3;
        book.Org_Travel_End_Date__c = System.today() + 20;
        update book;
        
    }
    
    //test method added to cover code added in v1.5 in triggerhandler
    @isTest static void testgetValidEmailDate() {
        test.startTest();
        for(Integer i = 1; i < 7; i++){
            Date testDate = System.today()+i;
            Datetime ValidTime = BookingTriggerHandler.getvalidEmailDate(testDate);
            system.debug('ValidTime==>'+ValidTime);
            system.assertNotEquals('Sat', ValidTime.formatGmt('E'));
            system.assertNotEquals('Sun', ValidTime.formatGmt('E'));
        }
        test.stopTest();
    }
}