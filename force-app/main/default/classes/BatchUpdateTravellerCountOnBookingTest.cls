@isTest
public with sharing class BatchUpdateTravellerCountOnBookingTest {
    @isTest
    public static void BatchUpdateTravellerCountOnBookingTest() {


        Id accountId = TestDataFactory.createEKUK_AccountId();
        
        Booking__c newBookingHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert newBookingHeader;
        
        Booking__c newBooking = TestDataFactory.createActiveBooking(accountId,newBookingHeader.Id);
        newBooking.RecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByDeveloperName().get('Booking').getRecordTypeId();
        insert newBooking;

        list<Traveller__c> lstTravellers = new list<Traveller__c>();
        Traveller__c traveller = new Traveller__c();        
        traveller.Name = 'Test';  
        traveller.Org_Booking__c = newBooking.Id;
        traveller.Org_Age_Category__c = 'Adult';
        lstTravellers.add(traveller);

        traveller = new Traveller__c();        
        traveller.Name = 'Test';  
        traveller.Org_Booking__c = newBooking.Id;
        traveller.Org_Age_Category__c = 'Child';
        lstTravellers.add(traveller);

        insert lstTravellers;

        test.startTest();

            BatchUpdateTravellerCountOnBooking objBatch = new BatchUpdateTravellerCountOnBooking();
            objBatch.cutoffdate = system.today().addDays(2);
            objBatch.execute(null);

        test.stopTest();

    }
}