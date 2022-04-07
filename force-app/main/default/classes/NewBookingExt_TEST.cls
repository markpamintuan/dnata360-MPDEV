@isTest
public class NewBookingExt_TEST {
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
        
        //Need to create a quote linked to the case here
        Booking__c randomBooked ;
        Booking_Price_Breakdown__c bookingPriceBreakDown ;
        String itineraryDetailId ;
        String bookingPriceBreakDownId;
        //itineraryDetailId
        boolean ItineraryBoolean;
        boolean TravellerBoolean;
        boolean PricingBoolean;
        
        Traveller__c traveller ;
        String itineraryId ;
        String travellerId ;
        
        Itinerary__c itin = new Itinerary__c();
        itin.Org_Booking__c = bookHeader.Id;
        itin.Org_Check_In__c = system.today() + 100;
        itin.Org_Check_Out__c = system.today() - 100;
        itin.Org_Hotel_Name__c = 'Test';
        itin.Room_Type__c = 'Normal';
        itin.Org_Destination_Name__c = 'Hotel';
        insert itin;
        
    }	
    
    @isTest static void testSaveBookingItem() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Org_Current_Team_Name__c,
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);        
        newBookExt.saveBookingItem();
    }
    
    @isTest static void testItineraryDetail() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);  
        newBookExt.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExt.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExt.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExt.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExt.itineraryDetail.Flight_Type__c = 'Flight Outbound';
        newBookExt.itineraryDetail.Org_Airline_Locator__c = 'Dubai-001';
        newBookExt.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExt.addItineraryDetail();
        String str =  String.valueof(newBookExt.itineraryDetail.Org_Departure_Date__c);
        newBookExt.mapItinDetailKeyToItinerayRecord.put(str,newBookExt.itineraryDetail);
        
        
        NewBookingExt newBookOtherExt = new NewBookingExt(sc);  
        newBookOtherExt.itineraryDetail.From__c = 'Dubai';
        newBookOtherExt.itineraryDetail.To__c = 'London';
        newBookOtherExt.itineraryDetail.Start_Date__c = System.today() + 100;
        newBookOtherExt.itineraryDetail.End_date__c = System.today() - 100;
        String strother = string.valueOf( newBookOtherExt.itineraryDetail.Start_Date__c );
        newBookOtherExt.mapItinDetailKeyToItinerayRecord.put(strother,newBookOtherExt.itineraryDetail);
	    newBookOtherExt.addOtherItineraryDetail();
        
        NewBookingExt newBookHotelExt = new NewBookingExt(sc);  
        newBookHotelExt.itineraryDetail.Org_Hotel_Name__c = 'Dubai Mariott';
        newBookHotelExt.itineraryDetail.Org_Hotel_City__c = 'Dubai';
        newBookHotelExt.itineraryDetail.Org_Room_Type__c = 'Normal';
        newBookHotelExt.itineraryDetail.Org_Check_In__c = System.today() + 100;
        newBookHotelExt.itineraryDetail.Org_Check_Out__c = System.today() - 100;
        String strhotel = String.valueOf(newBookHotelExt.itineraryDetail.Org_Check_In__c);
        newBookHotelExt.mapItinDetailKeyToItinerayRecord.put(strHotel,newBookHotelExt.itineraryDetail);
        newBookHotelExt.addHotelItineraryDetail();
     
        newBookExt.editItineraryDetail();
        newBookExt.deleteItinerary();
        newBookExt.doAction();
    }
   
    
 
    @isTest static void testNegativeItineraryDetail() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        
        NewBookingExt newBookExtDepartGreaterThanArrival = new NewBookingExt(sc);  
        newBookExtDepartGreaterThanArrival.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExtDepartGreaterThanArrival.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtDepartGreaterThanArrival.itineraryDetail.Org_Arrival_Date__c = System.today() - 100;
        newBookExtDepartGreaterThanArrival.itineraryDetail.Org_Departure_Date__c = System.today() + 100;
        newBookExtDepartGreaterThanArrival.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtDepartGreaterThanArrival.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
        newBookExtDepartGreaterThanArrival.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtDepartGreaterThanArrival.addItineraryDetail();
        
        NewBookingExt newBookExtDepartureDateNull = new NewBookingExt(sc);
        newBookExtDepartureDateNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtDepartureDateNull.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExtDepartureDateNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtDepartureDateNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtDepartureDateNull.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
       newBookExtDepartureDateNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtDepartureDateNull.addItineraryDetail();
        
        NewBookingExt newBookExtArrivalDateNull = new NewBookingExt(sc);
        newBookExtArrivalDateNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtArrivalDateNull.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExtArrivalDateNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtArrivalDateNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtArrivalDateNull.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
        newBookExtArrivalDateNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtArrivalDateNull.addItineraryDetail();
        
        NewBookingExt newBookExtDepartAirportNull = new NewBookingExt(sc);  
        newBookExtDepartAirportNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtDepartAirportNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtDepartAirportNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtDepartAirportNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtDepartAirportNull.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
        newBookExtDepartAirportNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtDepartAirportNull.addItineraryDetail();
        
        NewBookingExt newBookExtArrivalAirportNull = new NewBookingExt(sc);  
        newBookExtArrivalAirportNull.itineraryDetail.Departure_Airport__c = 'London';
        newBookExtArrivalAirportNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtArrivalAirportNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtArrivalAirportNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtArrivalAirportNull.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
        newBookExtArrivalAirportNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtArrivalAirportNull.addItineraryDetail();
        
        
        NewBookingExt newBookExtFlightTypeNull = new NewBookingExt(sc);  
        newBookExtFlightTypeNull.itineraryDetail.Departure_Airport__c = 'London';
        newBookExtFlightTypeNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtFlightTypeNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtFlightTypeNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtFlightTypeNull.itineraryDetail.Org_Airline_Locator__c = 'Dubai';
        newBookExtFlightTypeNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtFlightTypeNull.addItineraryDetail();
        
        NewBookingExt newBookExtAirlinlocNull = new NewBookingExt(sc);  
        newBookExtAirlinlocNull.itineraryDetail.Departure_Airport__c = 'London';
        newBookExtAirlinlocNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtAirlinlocNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtAirlinlocNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtAirlinlocNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtAirlinlocNull.itineraryDetail.Org_Flight_Number__c = '127';
        newBookExtAirlinlocNull.addItineraryDetail();
        
        NewBookingExt newBookExtFlightNumNull = new NewBookingExt(sc);  
        newBookExtFlightNumNull.itineraryDetail.Departure_Airport__c = 'London';
        newBookExtFlightNumNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtFlightNumNull.itineraryDetail.Flight_Type__c = 'Inbound';
        newBookExtFlightNumNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtFlightNumNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtFlightNumNull.itineraryDetail.Org_Airline_Locator__c = 'D-127';
        newBookExtFlightNumNull.addItineraryDetail();
        
        NewbookingExt newHotelBookingHotelNull = new NewBookingExt(sc);
        newHotelBookingHotelNull.itineraryDetail.Org_Room_Type__c = 'Normal';
        newHotelBookingHotelNull.itineraryDetail.Org_Hotel_City__c = 'Dubai';
        newHotelBookingHotelNull.itineraryDetail.Org_Check_In__c = System.today() + 100;
        newHotelBookingHotelNull.itineraryDetail.Org_Check_Out__c = System.today() - 100;
        newHotelBookingHotelNull.addHotelItineraryDetail();
        
        NewbookingExt newHotelBookingCheckInGreater = new NewBookingExt(sc);
        newHotelBookingCheckInGreater.itineraryDetail.Org_Room_Type__c = 'Normal';
        newHotelBookingCheckInGreater.itineraryDetail.Org_Hotel_Name__c = 'Dubai';
        newHotelBookingCheckInGreater.itineraryDetail.Org_Check_In__c = System.today() - 100;
        newHotelBookingCheckInGreater.itineraryDetail.Org_Check_Out__c = System.today() + 100;
        newHotelBookingCheckInGreater.addHotelItineraryDetail();
        
        NewbookingExt newHotelBookingCheckoutNull = new NewBookingExt(sc);
        newHotelBookingCheckoutNull.itineraryDetail.Org_hotel_Name__c = 'taj';
        newHotelBookingCheckoutNull.itineraryDetail.Org_Hotel_City__c = 'Dubai';
        newHotelBookingCheckoutNull.itineraryDetail.Org_Room_Type__c = 'Normal';
        newHotelBookingCheckoutNull.itineraryDetail.Org_Check_In__c = System.today() + 100;
        newHotelBookingCheckoutNull.addHotelItineraryDetail();
        
        NewbookingExt newHotelBookingCheckInNull = new NewBookingExt(sc);
        newHotelBookingCheckInNull.itineraryDetail.Org_Hotel_Name__c = 'taj';
        newHotelBookingCheckInNull.itineraryDetail.Org_Hotel_City__c = 'Dubai';
        newHotelBookingCheckInNull.itineraryDetail.Org_Room_Type__c = 'Normal';
        newHotelBookingCheckInNull.itineraryDetail.Org_Check_Out__c = System.today() + 100;
        newHotelBookingCheckInNull.addHotelItineraryDetail();
        
		NewbookingExt newHotelBookingroomtypeNull = new NewBookingExt(sc);
        newHotelBookingroomtypeNull.itineraryDetail.Org_Hotel_Name__c = 'Normal';
        newHotelBookingroomtypeNull.itineraryDetail.Org_Hotel_City__c = 'Dubai';
        newHotelBookingroomtypeNull.itineraryDetail.Org_Check_In__c = System.today() - 100;
        newHotelBookingroomtypeNull.itineraryDetail.Org_Check_Out__c = System.today() + 100;
       newHotelBookingroomtypeNull.addHotelItineraryDetail();        
        
        
        NewBookingExt newBookFromNull = new NewBookingExt(sc);  
        newBookFromNull.itineraryDetail.To__c = 'London';
        newBookFromNull.itineraryDetail.Start_Date__c = System.today() + 100;
        newBookFromNull.itineraryDetail.End_date__c = System.today() - 100;
        newBookFromNull.addOtherItineraryDetail();
        
        NewBookingExt newBookToNull = new NewBookingExt(sc);  
        newBookToNull.itineraryDetail.From__c = 'Dubai';
        newBookToNull.itineraryDetail.Start_Date__c = System.today() + 100;
        newBookToNull.itineraryDetail.End_date__c = System.today() - 100;
        newBookToNull.addOtherItineraryDetail();
        
        NewBookingExt newBookStartDateNull = new NewBookingExt(sc);  
        newBookStartDateNull.itineraryDetail.From__c = 'Dubai';
        newBookStartDateNull.itineraryDetail.To__c = 'London';
        newBookStartDateNull.itineraryDetail.End_date__c = System.today() - 100;
        newBookStartDateNull.addOtherItineraryDetail();
        
        NewBookingExt newBookEndDateNull = new NewBookingExt(sc);  
        newBookEndDateNull.itineraryDetail.From__c = 'Dubai';
        newBookEndDateNull.itineraryDetail.To__c = 'London';
        newBookEndDateNull.itineraryDetail.Start_date__c = System.today() - 100;
        newBookEndDateNull.addOtherItineraryDetail();
        
        NewBookingExt newBookStartGreater = new NewBookingExt(sc);  
        newBookStartGreater.itineraryDetail.From__c = 'Dubai';
        newBookStartGreater.itineraryDetail.To__c = 'London';
        newBookStartGreater.itineraryDetail.Start_Date__c = System.today() - 100;
        newBookStartGreater.itineraryDetail.End_date__c = System.today() + 100;
        newBookStartGreater.addOtherItineraryDetail();
        
    }
    
    @isTest static void testAddingTraveller() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);        
        newBookExt.traveller.Org_First_Name__c = 'John';
        newBookExt.traveller.Org_Last_Name__c = 'Doe';
        newBookExt.addTraveller();
        newBookExt.editTraveller();
        newBookExt.deleteTraveller();
    }
    
    @isTest static void testNegativeAddingTraveller() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);        
        newBookExt.traveller.Org_First_Name__c = 'John';
        newBookExt.addTraveller();
        newBookExt.editTraveller();
        newBookExt.deleteTraveller();
    }
    
    @isTest static void testAddingBookingPriceBreakdown() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);        
        newBookExt.bookingPriceBreakDown.Org_Title__c = 'Flights';
        newBookExt.bookingPriceBreakDown.Org_Client_Gross__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Quantity__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Supplier_Gross__c = 2.0;
        newBookExt.addBookingPriceBreakDown();
        newBookExt.editBookingPriceBreakdown();
        newBookExt.deleteBookingPriceBreakDown();
        newBookExt.deleteAllRecords();
    }

	 @isTest static void testNegativeAddingBookingPriceBreakdown() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc);        
        newBookExt.addBookingPriceBreakDown();
        newBookExt.editBookingPriceBreakdown();
        newBookExt.deleteBookingPriceBreakDown();
        newBookExt.deleteAllRecords();
    }
	
	    @isTest static void testFlightSaveAll() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Org_Current_Team_Name__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc); 
        newBookExt.bookingItem.Name = 'test123';
        newBookExt.bookingItem.Org_Booking_Type__c ='Flight';
        newBookExt.bookingItem.Total_Margin_AED__c =200;
        newBookExt.bookingItem.Total_Cost_AED__c =2000; 
       	        List<Quote_Line_Item__c> lQuoteLineItems = new List<Quote_Line_Item__c>();

         lQuoteLineItems = [SELECT   Airline__c,
                                   Arrival_Date_Time__c,
                                   Departure_Date_Time__c,
                                   Flight_No__c,
                                   From__c,
                                   To__c,
                                   Type__c,
                                   Check_Out__c,
                                   Check_In__c,
                                   Hotel_Name__c,Hotel_Location__c,
                                   Room_Type__c, //added by sri bala
                                   Quote_Option__r.Status__c,
                                   Quote_Option__r.Name,
                                   Quote_Option__r.Flight_Price__c,
                                   Quote_Option__r.Quote_Header__c,
                                   Quote_Option__r.Quote_Header__r.Date_From__c,
                                   Quote_Option__r.Quote_Header__r.Date_To__c,
                                   Quote_Option__r.Quote_Header__r.Destination__c,
                                   Quote_Option__r.Quote_Header__r.Status__c
                                   FROM Quote_Line_Item__c
                                   WHERE Quote_Option__r.Quote_Header__r.Status__c = 'Accepted'
                                   AND Quote_Option__r.Status__c = 'Finalized'
                                   AND Type__c = 'Flight'
                                   AND Quote_Option__r.Quote_Header__r.Case__c =: cse.Id 
                                   ORDER BY Departure_Date_Time__c ASC];
       /* itin.Org_Check_In__c = system.today() + 100;
        itin.Org_Check_Out__c = system.today() - 100;
        itin.Org_Hotel_Name__c = 'Test';
        itin.Room_Type__c = 'Normal';
        itin.Org_Destination_Name__c = 'Hotel';
        insert itin;*/
        newBookExt.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExt.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExt.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExt.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        String str = String.valueof(newBookExt.itineraryDetail.Org_Departure_Date__c);
        newBookExt.mapItinDetailKeyToItinerayRecord.put(str,newBookExt.itineraryDetail);
        newBookExt.addItineraryDetail();  
        
        newBookExt.bookingPriceBreakDown.Org_Title__c = 'Flights';
        newBookExt.bookingPriceBreakDown.Org_Client_Gross__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Quantity__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Supplier_Gross__c = 2.0;
        newBookExt.addBookingPriceBreakDown();
        
        newBookExt.traveller.Org_First_Name__c = 'John';
        newBookExt.traveller.Org_Last_Name__c = 'Doe';
        newBookExt.addTraveller();
        test.startTest();
        newBookExt.saveAll();
        //newBookExt.saveItineraries();
        //newBookExt.saveTravellers();
        newBookExt.saveBookingItem();
            test.stopTest();
    }
        
    @isTest static void testSaveAll() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Org_Current_Team_Name__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc); 
        newBookExt.bookingItem.Name = 'test123';
        newBookExt.bookingItem.Org_Booking_Type__c ='Accommodation';
       
       /* itin.Org_Check_In__c = system.today() + 100;
        itin.Org_Check_Out__c = system.today() - 100;
        itin.Org_Hotel_Name__c = 'Test';
        itin.Room_Type__c = 'Normal';
        itin.Org_Destination_Name__c = 'Hotel';
        insert itin;*/
        newBookExt.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExt.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExt.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExt.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        String str = String.valueof(newBookExt.itineraryDetail.Org_Departure_Date__c);
        newBookExt.mapItinDetailKeyToItinerayRecord.put(str,newBookExt.itineraryDetail);
        newBookExt.addItineraryDetail();  
        
        newBookExt.bookingPriceBreakDown.Org_Title__c = 'Flights';
        newBookExt.bookingPriceBreakDown.Org_Client_Gross__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Quantity__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Supplier_Gross__c = 2.0;
        newBookExt.addBookingPriceBreakDown();
        
        newBookExt.traveller.Org_First_Name__c = 'John';
        newBookExt.traveller.Org_Last_Name__c = 'Doe';
        newBookExt.addTraveller();
        test.startTest();
        newBookExt.saveAll();
        //newBookExt.saveItineraries();
        //newBookExt.saveTravellers();
        newBookExt.saveBookingItem();
        test.stopTest();
    }
    
    @isTest static void testOtherSaveAll() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,Org_Current_Team_Name__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExt = new NewBookingExt(sc); 
        newBookExt.bookingItem.Name = 'test123';
        newBookExt.bookingItem.Org_Booking_Type__c ='Marhaba';
        newBookExt.bookingItem.Total_Margin_AED__c =200;
        newBookExt.bookingItem.Total_Cost_AED__c =2000;
        
       /* itin.Org_Check_In__c = system.today() + 100;
        itin.Org_Check_Out__c = system.today() - 100;
        itin.Org_Hotel_Name__c = 'Test';
        itin.Room_Type__c = 'Normal';
        itin.Org_Destination_Name__c = 'Hotel';
        insert itin;*/
        newBookExt.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExt.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExt.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExt.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        String str = String.valueof(newBookExt.itineraryDetail.Org_Departure_Date__c);
        newBookExt.mapItinDetailKeyToItinerayRecord.put(str,newBookExt.itineraryDetail);
         
        
        newBookExt.bookingPriceBreakDown.Org_Title__c = 'Flights';
        newBookExt.bookingPriceBreakDown.Org_Client_Gross__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Quantity__c = 2.0;
        newBookExt.bookingPriceBreakDown.Org_Supplier_Gross__c = 2.0;
        
        
        newBookExt.traveller.Org_First_Name__c = 'John';
        newBookExt.traveller.Org_Last_Name__c = 'Doe';
       
        test.startTest();
        newBookExt.addBookingPriceBreakDown();
        newBookExt.addItineraryDetail(); 
         newBookExt.addTraveller();
        newBookExt.saveAll();
        //newBookExt.saveItineraries();
        //newBookExt.saveTravellers();
        newBookExt.saveBookingItem();
        test.stopTest();
    }
    
    @isTest static void testNegativeSaveAll() {
        Case cse = 	[SELECT Id, 
                     AccountId,
                     Org_Brand__c,
                     Org_Destination_list__c,
                     Reason,
                     Org_Booking__c, 
                     CaseNumber,
                     Org_Case_Status__c,
                     Org_Case_Close_Reason__c, 
                     Closing_Comments__c,
                     Org_Current_Team_Name__c,Staff_Region__c
                     FROM Case 
                     limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExt newBookExtBookingItemNameNull = new NewBookingExt(sc); 
        Boolean showItineraryDetailTest = newBookExtBookingItemNameNull.showItineraryDetail;
        Boolean showBookingTypeTest = newBookExtBookingItemNameNull.showBookingType;
        Boolean  showtravellerTableTest = newBookExtBookingItemNameNull.showtravellerTable;
        Boolean  showBookingPriceTableTest = newBookExtBookingItemNameNull.showBookingPriceTable;
        List<SelectOption> typeFlightTest = newBookExtBookingItemNameNull.typeFlight;
        List<SelectOption> bookingSystemTest = newBookExtBookingItemNameNull.bookingSystem;

        newBookExtBookingItemNameNull.itineraryDetail.Departure_Airport__c = 'Dubai';
        newBookExtBookingItemNameNull.itineraryDetail.Arrival_Airport__c = 'London';
        newBookExtBookingItemNameNull.itineraryDetail.Org_Arrival_Date__c = System.today() + 100;
        newBookExtBookingItemNameNull.itineraryDetail.Org_Departure_Date__c = System.today() - 100;
        newBookExtBookingItemNameNull.addItineraryDetail();  
        newBookExtBookingItemNameNull.saveAll();
        
        NewBookingExt newBookExtBookingNoItinerary = new NewBookingExt(sc);
        newBookExtBookingNoItinerary.bookingItem.Name = 'test123';
        newBookExtBookingNoItinerary.bookingItem.Total_Margin_AED__c =200;
        newBookExtBookingNoItinerary.bookingItem.Total_Cost_AED__c =2000;
        newBookExtBookingNoItinerary.saveAll();
    }
    
    
    
    @isTest static void convertQuoteTest() {
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                               Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2 );
        insert objCase;
        
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Status__c = 'Accepted';
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
        insert header;
        
        list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        opt.Status__c = 'Finalized';
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        opt.Status__c = 'Finalized';
        options.add(opt1);
        insert options;
        
        list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
        
        Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
                                                            Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
        listQLI.add(objQLI1);
        
        Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Aegean Airlines', 
                                                            From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
                                                            Arrival_Date_Time__c = system.today().adddays(1));
        listQLI.add(objQLI2);
        
        Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
        listQLI.add(objQLI3);
        
        Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
        listQLI.add(objQLI4);
        
        Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
        listQLI.add(objQLI5);
        
        Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
        listQLI.add(objQLI6);
        
        Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
        listQLI.add(objQLI7);
        
        Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
        listQLI.add(objQLI8);
        
        Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
        listQLI.add(objQLI9);
        
        Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
        listQLI.add(objQLI10);
        
        Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
        listQLI.add(objQLI11);
        
        insert listQLI;
        
        list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
        
        Quote_Traveller__c traveller1 = new Quote_Traveller__c();
        traveller1.Quote__c = header.id;
        traveller1.Traveller_Type__c = 'Infant';
        listQT.add(traveller1);
        
        Quote_Traveller__c traveller2 = new Quote_Traveller__c();
        traveller2.Quote__c = header.id;
        traveller2.Traveller_Type__c = 'Child';
        traveller2.Date_of_Birth__c = system.today().adddays(-365);
        listQT.add(traveller2);
        
        insert listQT;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
        NewBookingExt newBookExt = new NewBookingExt(sc); 
    }
    
    
    @isTest static void testLookupRemoteCallouts() {
        Lookup__c lu = new Lookup__c();
        lu.Name = 'Dubai';
        lu.Type__c ='Airport';
        insert lu;
        
        
        NewBookingExt.getFromFlights('Dubai');
        NewBookingExt.getToFlights('Dubai');
        
    }
    
    
    
}