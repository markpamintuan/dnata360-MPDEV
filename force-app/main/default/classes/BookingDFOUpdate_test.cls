@isTest
public class BookingDFOUpdate_test {
    static testmethod void test1() {
        // startTest/stopTest block to force async processes 
        //   to run in the test.
         Id accountId = TestDataFactory.createDTME_AccountId();
        
        Account acc = new Account(Id=accountID);
        acc.Child_IDs__c = 'DFO1211';
        update acc;
        
        DFOAccount__c dfo = new DFOAccount__C();
        dfo.Child_Id__c = 'DFO1211';
        dfo.Account__c = accountId;
        insert dfo;
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        
        //Create Cases
        TestDataFactory.createDTME_Case();
        
        Booking__c book = new Booking__c();
        book.Org_Account_Name__c = accountId;
        book.Booking_System__c = 'DFO';
        book.Booking_Status__c = 'Pending';
        book.Org_External_System_ID__c = 'DFO1211';
        book.Org_Brand__c = 'dnata';
        insert book;
        Map<Id,Booking__c> bookinglist = new Map<Id,Booking__c>();
        bookinglist.put(book.id,book);
        Test.startTest();        
        System.enqueueJob(new BookingDFOUpdate(bookinglist));
        Test.stopTest();
        
    }
}