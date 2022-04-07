@isTest
public class NewBookingPagePreviewController_Test {
        static testMethod void NewBookingPagePreviewController(){
        Id accountId = TestDataFactory.createEKUK_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);

        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2 );
        insert objCase;

        Booking__c newBookingHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert newBookingHeader;
        system.debug('newbookingheader ' + newBookingHeader.id);
        Booking__c newBooking = TestDataFactory.createActiveBooking(accountId,newBookingHeader.Id);
        insert newBooking;
        system.debug('newbooking ' + newBookingHeader.id);
        
        
        system.debug('here');
        system.debug(objCase);
        
        Itinerary__c itinerary = new Itinerary__c();
        Itinerary_Detail__c itineraryDetail = new Itinerary_Detail__c();
        Traveller__c traveller = new Traveller__c();
        Booking_Price_Breakdown__c bookingPriceBreakdown = new Booking_Price_Breakdown__c();
        
        traveller.Name = traveller.Org_First_Name__c + ' ' + traveller.Org_Last_Name__c;  
        traveller.Org_Booking__c = newBooking.Id;
        insert traveller;
        
        
         bookingPriceBreakDown.Org_Title__c = 'test';
         bookingPriceBreakDown.Org_Client_Gross__c = 123;
         bookingPriceBreakDown.Org_Quantity__c = 2;
         bookingPriceBreakDown.Org_Supplier_Gross__c = 231;
         bookingPriceBreakDown.Org_Booking__c = newBooking.Id;
         insert bookingPriceBreakDown;
         
         itinerary.Org_Booking__c = newBooking.Id;
         insert Itinerary;
         
         itineraryDetail.Departure_Airport__c = 'Test';
         itineraryDetail.Arrival_Airport__c = 'New Test';
         itineraryDetail.Org_Departure_Date__c = Date.today();
         itineraryDetail.Org_Arrival_Date__c  = Date.today().addDays(1);
         itineraryDetail.Itinerary__c = itinerary.id;
         insert itineraryDetail;
         system.debug(itineraryDetail);
         PageReference myVfPage = Page.NewBookingPagePreview;
         Test.setCurrentPage(myVfPage);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',newBooking.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(newBooking);
        NewBookingPagePreviewController obj = new NewBookingPagePreviewController(stdCntlr);
        obj.showItineraryDetail = false;
        obj.showtravellerTable = true;
        obj.showBookingPriceTable = true;
        obj.itineraryMapKey = 'test';
        obj.travellerMapKey = 'test1';
        obj.bookingPriceBreakdownMapKey = 'test2';
        obj.randomBooked = new booking__c();
        obj.itineraryDetailId = itineraryDetail.id;
        obj.bookingPriceBreakDownId ='';
        obj.ItineraryBoolean = false;
        obj.itineraryId = itinerary.id;
        obj.travellerId = '';
        
        
        
       
 }   
}