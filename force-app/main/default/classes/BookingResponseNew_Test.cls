/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BookingResponseNew_Test {

    static testMethod void BookingResponseNew1() {
    BookingResponseNew bkNew = new BookingResponseNew();
    bkNew.Trips = new list<BookingResponseNew.cls_Trips>();
    bkNew.NotFoundBookings = new List<Integer>();
    
    BookingResponseNew.cls_Trips cls= new BookingResponseNew.cls_Trips();
    cls.TripId = 1;
    cls.Bookings = new List<BookingResponseNew.cls_Bookings>();
    BookingResponseNew.cls_Bookings booking = new BookingResponseNew.cls_Bookings();
    booking.BookingCore = new BookingResponseNew.cls_BookingCore();
    booking.BookingDetail = new BookingResponseNew.cls_BookingDetail();
    booking.LeadContact = new BookingResponseNew.cls_LeadContact();
    booking.CancellationDetails = new BookingResponseNew.cls_CancellationDetails();
    booking.Itinerary   = new BookingResponseNew.cls_Itinerary();
    booking.Passengers = new List<BookingResponseNew.cls_Passengers>();
    booking.LineItems =  new List<BookingResponseNew.cls_LineItems>();
    //booking.Notes = new List<BookingResponseNew.cls_Notes>();
    booking.AgentNotes = new List<BookingResponseNew.cls_Notes>();
    booking.Csrs = new List<BookingResponseNew.cls_Csrs>();
    booking.Balance = new BookingResponseNew.cls_Balance();
    booking.TicketInfo = new BookingResponseNew.cls_TicketInfo();
    booking.TrackingTag = '';
    
    
    BookingResponseNew.cls_BookingCore clscore = new BookingResponseNew.cls_BookingCore();
    clscore.Id =1;
    clscore.Type = 1;
    clscore.BookingRef ='';
    clscore.BookedDate='';
    clscore.CultureCode ='';
    clscore.PackageId ='';
    
    
    
    BookingResponseNew.cls_BookingDetail bookdetail = new BookingResponseNew.cls_BookingDetail();
    bookdetail.BookedById = 0;
    bookdetail.BookedBy ='';
    bookdetail.ClientCurrencyCode='';
    bookdetail.ClientCurrencyExchangeRate='';
    bookdetail.SpecialRequests='';
    bookdetail.LastModified ='';
    bookdetail.ApplicationType=1;
    bookdetail.FamilyId = '';
    
    BookingResponseNew.cls_CancellationDetails canceldet = new BookingResponseNew.cls_CancellationDetails();
    canceldet.CancellationRequested = false;
    canceldet.Requested = '';
    canceldet.Confirmed = '';
    
    BookingResponseNew.cls_Itinerary  itinera = new BookingResponseNew.cls_Itinerary();
    itinera.Description = '';
    itinera.DropOffDate = '';
    itinera.PickUpDate = '';
    itinera.AirportCode = '';
    itinera.AirportName = '';
    itinera.ParkingSiteCode = '';
    itinera.ParkingSiteName = '';
    itinera.Notes = '';
    itinera.OutboundFlight = new BookingResponseNew.Flight();
    itinera.InboundFlight = new BookingResponseNew.Flight();
    itinera.VendorCode ='';
    itinera.VendorName ='';
    itinera.PickUpPointCode ='';
    itinera.PickUpPointName ='';
    itinera.DropOffPointCode ='';
    itinera.DropOffPointName ='';
    itinera.CarDescription ='';
    itinera.SIPPCode ='';
    itinera.DoorCount=1;
    itinera.Model ='';
    itinera.ConnectingFlight = new BookingResponseNew.Flight();
    itinera.StartDate ='';
    itinera.EndDate ='';
    itinera.DestinationId =0;
    itinera.DestinationName ='';
    itinera.SchemeType =0;
    itinera.TripType =0;
    itinera.Adults =0;
    itinera.Children =0;
    itinera.Infants =0;
    itinera.SpecialRequests ='';
    itinera.ItineraryDate ='';
    itinera.Terminal ='';
    itinera.FlightNumber ='';
    itinera.Cabin = 0;
    itinera.ServiceCode  ='';
    itinera.StaffRates = false;
    itinera.Transfers = new List<BookingResponseNew.cls_Transfers>();
    
    BookingResponseNew.cls_Passengers pasemnger = new BookingResponseNew.cls_Passengers();
    pasemnger.Id=0;
    pasemnger.AgeCategory=0;
    pasemnger.Title='';
    pasemnger.DateOfBirth = '';
    pasemnger.AgeOnReturn = 0;
    pasemnger.ItineraryId = 0;
    
    BookingResponseNew.cls_LineItems line = new BookingResponseNew.cls_LineItems();
    line.Id =0;
    line.ItemTypeId = 0;
    line.ItemTypeTitle='';
    line.ItemTypeGroupId =0;
    line.CostType='';
    line.Quantity = 0;
    line.SupplierId = 0;
    line.SupplierRef ='';
    line.Title ='';
    line.SupplierNet ='';
    line.SupplierCommission ='';
    line.SupplierVat='';
    line.SupplierNetLocal='';
    line.SalesTax='';
    line.SupplierGross='';
    line.SupplierCurrency='';
    line.SupplierExchangeRate='';
    line.SupplierBalanceDue='';
    line.ClientGross='';
    line.Memo='';
    line.CreateDate='';
    line.AccountingCurrencyCode='';
    line.AccountingExchangeRate='';
    line.ReverseBookedItemId=0;
    line.LinkedNonSystemBookedItemId=0;
    line.ItineraryId=0;
    line.NonSystem='';
    line.OptionalExtraType=0;
    
    
    BookingResponseNew.cls_Notes clsnote = new BookingResponseNew.cls_Notes();
    clsnote.Title ='';
    clsnote.Description='';
    clsnote.CreatedById =0;
    clsnote.Id =0;
    clsnote.CreatedDate='';
    clsnote.CreatedBy='';
    clsnote.Subject='';
    clsnote.Text='';
    clsnote.CreatedByCustomer= false;
    clsnote.PublicAgentName='';
    clsnote.IsPublic = false;
    clsnote.LogId =0;
    
    BookingResponseNew.cls_Balance clsBal = new BookingResponseNew.cls_Balance();
    clsBal.TotalCost ='';
    clsBal.ClientTotalCost ='';
    clsBal.TotalMargin ='';
    clsBal.DueDate ='';
    clsBal.AmountDue ='';
    clsBal.AccountingCurrencyCode ='';
    clsBal.AccountingExchangeRate ='';
    clsBal.ClientCurrencyCode ='';
    clsBal.ClientExchangeRate ='';
    clsBal.ClientAmountDue ='';
    
    BookingResponseNew.cls_TicketInfo clsInfo = new BookingResponseNew.cls_TicketInfo();
    clsInfo.TicketsSent='';
    clsInfo.TodText ='';
    clsInfo.ETickets = false;
    
    BookingResponseNew.cls_Stays clsStay = new BookingResponseNew.cls_Stays();
    clsStay.CheckIn = '';
    clsStay.CheckOut = '';
    clsStay.EstabId =0;
    clsStay.EstabName = '';
    clsStay.DestinationName = '';
    clsStay.Description = '';
    
    BookingResponseNew.cls_Rooms clsroom = new BookingResponseNew.cls_Rooms();
    clsroom.ItineraryId =0;
    clsroom.Adults =0;
    clsroom.Children =0;
    clsroom.Infants =0;
    BookingResponseNew.cls_Tickets clstick = new BookingResponseNew.cls_Tickets();
    clstick.ItineraryId =0;
    clstick.Adults =0;
    clstick.Children =0;
    clstick.Infants =0;
    clstick.Description ='';
    clstick.StartDate ='';
    clstick.EndDate ='';
    
    BookingResponseNew.cls_Flights clsFli = new BookingResponseNew.cls_Flights();
    clsFli.ItineraryId =0;
    clsFli.Adults =0;
    clsFli.Children =0;
    clsFli.Infants =0;
    clsFli.ItineraryType =0;
    clsFli.AirlineLocator ='';
    
    
    BookingResponseNew.cls_Segments segent = new BookingResponseNew.cls_Segments();
    segent.Cabin=0;
    segent.DepartureDate ='';
    segent.DepartureAirport ='';
    segent.DepartureTerminal ='';
    segent.ArrivalDate ='';
    segent.ArrivalAirport ='';
    segent.ArrivalTerminal ='';
    segent.FlightNumber ='';
    segent.Description ='';
    segent.Aircraft ='';
    segent.MarketingCarrier ='';
    segent.OperatingCarrier ='';
    segent.BookingClass ='';
    segent.AirlineLocator ='';
    
    BookingResponseNew.cls_Transfers trans = new BookingResponseNew.cls_Transfers();
    trans.ItineraryId =0;
    trans.Adults=0;
    trans.Children=0;
    trans.Infants=0;
    trans.ItineraryDate ='';
    trans.TransferTitle='';
    trans.Address='';
    
    BookingResponseNew.PickUpPoint pick = new BookingResponseNew.PickUpPoint();
    pick.EndPointType =0;
    pick.EstabId =0;
    pick.ResortId =0;
    pick.AirportCode ='';
    pick.AirportName='';
    pick.EstabName='';
    pick.ResortName='';
    pick.Id='';
    pick.Name='';
    
    BookingResponseNew.DropOffPoint drop = new BookingResponseNew.DropOffPoint();
    drop.EndPointType =0;
    drop.ResortId=0;
    drop.EstabId=0;
    drop.AirportCode ='';
    drop.AirportName ='';
    drop.EstabName ='';
    drop.ResortName ='';
    drop.Id ='';
    drop.Name ='';
    
    BookingResponseNew.Flight fli = new BookingResponseNew.Flight();
    fli.FlightNumber ='';
    fli.DepartureDate='';
    fli.ArrivalDate='';
    
    BookingResponseNew.Destination dest = new BookingResponseNew.Destination();
    dest.ItineraryId =0;
    dest.ProvinceId = 0;
    dest.RegionId =0;
    dest.RegionTitle ='';
    
    BookingResponseNew.cls_LeadContact clsContact = new BookingResponseNew.cls_LeadContact();
    
    }
}