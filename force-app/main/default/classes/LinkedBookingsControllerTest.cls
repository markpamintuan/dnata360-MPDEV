@isTest
public class LinkedBookingsControllerTest {
    static testmethod void test1(){
        string bookingRecordType = [select id from recordtype where name = 'Booking'].id;
        string bookingHeaderRecordType = [select id from recordtype where name = 'Booking Header'].id;
        Booking__c bk1 = new Booking__c();
       	bk1.RecordTypeId = bookingHeaderRecordType;
        insert bk1;
        
        Booking__c bk2 = new Booking__c();
        bk2.RecordTypeId = bookingRecordType;
        bk2.Booking_Header__c = bk1.id;
        bk2.Booking_Status__c = 'Active';
        insert bk2;
        
        Case c = new Case();
        c.Org_Booking__c = bk1.id;
        insert c;
        
        Case c2 = new Case();
        c2.Org_Booking__c = bk2.id;
        insert c2;
           
        LinkedBookingsController.getAllBookingsRelatedToCase(c.id);
        LinkedBookingsController.getAllBookingsRelatedToCase(c2.id);
        LinkedBookingsController.getAllBookingsRelatedToCase(bk1.id);
        LinkedBookingsController.getAllBookingsRelatedToCase(bk2.id);
    }
}