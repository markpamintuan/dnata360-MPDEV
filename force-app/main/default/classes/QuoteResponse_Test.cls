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
private class QuoteResponse_Test {

    static testMethod void QuoteResponseTest1() {
        QuoteResponse.cls_Products obj = new QuoteResponse.cls_Products();
        obj.Id = '';
        obj.AvailabilityId = '';
        obj.Type = '';
        obj.TypeID = 1; 
        obj.Product =  new QuoteResponse.cls_product();
        obj.Establishment = '';
        obj.EstablishmentId = '';
        obj.CheckInDate = '';
        obj.CheckOutDate = '';
        obj.QuotedCost = '';
        obj.CurrentCost = '';
        obj.Destination = new QuoteResponse.cls_Destination();
        obj.StalePrice  = false; 
        obj.RestoreFailed = false;
        obj.IsHidden = false;
        obj.IsPriceHidden = false;
        obj.IsOnRequest = false;
        obj.PackageId = '';
        obj.Options = new list<QuoteResponse.cls_Options>();
        obj.Adults  = 1;
        obj.PickUpPoint = '';
        obj.PickUpType = '';
        obj.DropOffPoint = '';
        obj.DropOffType = '';
        obj.Passengers = '';
        obj.ResortLocation = '';
        obj.Airport = '';
        obj.OutboundDate = '';
        obj.ReturnDate = '';
        obj.TransferDuration = '';
        obj.TransferFrequency = '';
        obj.PickUpDate = '';
        obj.DropOffDate = '';
        obj.Description = '';
        obj.ProductDate = '';
        obj.TerminalId = '';
        obj.Terminal = '';
        obj.AirportCode = '';
        
        obj.Rooms = new list<string>();
        obj.Rooms.add('');
        
        obj.SpecialOffers = new list<string>();
        obj.SpecialOffers.add('');
        
        obj.Titles = new list<string>();
        obj.Titles.add('');
        
        QuoteResponse.cls_Destination obj1 = new QuoteResponse.cls_Destination();
        obj1.TypeId  = 1; 
        obj1.Type = ''; 
        obj1.Id  = 1; 
        obj1.Country = ''; 
        obj1.Province = ''; 
        obj1.Location = '';
        
        QuoteResponse.cls_Options obj2 = new QuoteResponse.cls_Options();
        obj2.Id  = ''; 
        obj2.Title = ''; 
        obj2.Quantity  = 1; 
        obj2.QuotedUnitCost = ''; 
        obj2.CurrentUnitCost = ''; 
        obj2.Currencyval = '';
        obj2.OnRequest = false;
        obj2.RestoreFailed = false;
        
        QuoteResponse.Agency obj3 = new QuoteResponse.Agency();
        obj3.Id = 1; 
        obj3.AgencyType  = 1; 
        obj3.Name = ''; 
        obj3.AbtaNumber = ''; 
        obj3.VatNumber = ''; 
        
        QuoteResponse.cls_Segments obj4 = new QuoteResponse.cls_Segments();
        obj4.CarrierName = '';
        obj4.CodeshareAirlineName = '';
        obj4.CabinName = '';
        obj4.Cabin = '';
        obj4.FlightNumber = '';
        obj4.DepartureDate = '';
        obj4.DepartureAirportCode = '';
        obj4.DepartureAirportTitle = '';
        obj4.DepartureTerminal = '';
        obj4.ArrivalDate = '';
        obj4.DestinationAirportCode = '';
        obj4.DestinationAirportTitle = '';
        obj4.DestinationTerminal = '';
        obj4.ZonedDepartureDate = '';
        obj4.ZonedArrivalDate = '';
        obj4.Logo = '';
        obj4.SupplierFareClass = '';
        
        
        QuoteResponse.Customer obj5 = new QuoteResponse.Customer();
        obj5.Title = '';
        obj5.FirstName = '';
        obj5.LastName = '';
        obj5.LoyaltyNumber = '';
        
        QuoteResponse.ImpersonatedAgent obj6 = new QuoteResponse.ImpersonatedAgent();
        obj6.Reference = '';
        obj6.Id = 1;
        obj6.FirstName = '';
        obj6.LastName = '';
        obj6.FullName = '';
        obj6.Email = '';
        obj6.IsSharedAccount = false;
        obj6.Active = false;
        
        QuoteResponse.Quotes obj7 = new QuoteResponse.Quotes();
        obj7.Id = '';
        obj7.Reference = '';
        obj7.BasketId = '';
        obj7.AccountingCurrency = '';
        obj7.Currencyval = '';
        obj7.TrackingTag = '';
        obj7.Created = '';
        obj7.Deposit = '';
        obj7.DueDate = '';
        obj7.DomainId = 1;
        obj7.ForHoliday = false;
        obj7.StalePrices = false;
        obj7.SharedUse = false;
        
        
        QuoteResponse.ImpersonatedCustomer obj8 = new QuoteResponse.ImpersonatedCustomer();
        obj8.Id = '';
        obj8.EmailAddress = '';
        obj8.PhoneNumber = '';
        obj8.Title = '';
        obj8.FirstName = '';
        obj8.LastName = '';
        obj8.LoyaltyNumber = '';
        
        QuoteResponse.Notes obj9 = new QuoteResponse.Notes();
        obj9.Id = '';
        obj9.Text = '';
        obj9.Created = '';
        obj9.CreatedById = 1;
        obj9.CreatedBy = '';
        
        QuoteResponse.cls_Itinerary iti = new QuoteResponse.cls_Itinerary();
        iti.ItemTime ='';
        iti.Description ='';
        QuoteResponse.CreatedByAgent obj10 = new QuoteResponse.CreatedByAgent();
        obj10.Id = 1;
        obj10.FirstName = '';
        obj10.LastName = '';
        obj10.FullName = '';
        obj10.Email = '';
        obj10.IsSharedAccount = false;
        obj10.Active = false;
        QuoteResponse.cls_Alternatives alt = new QuoteResponse.cls_Alternatives();
        alt.Id ='';
        alt.Room = '';
        alt.Board ='';
        alt.Cost =0;
        QuoteResponse.cls_InboundLeg out= new QuoteResponse.cls_InboundLeg();
        out.TypeId = 1;
        out.Type = '';
        QuoteResponse.cls_Legs leg = new QuoteResponse.cls_Legs();
        leg.TypeId = 1;
        leg.Type = '';
        leg.QuotedCost ='';
        leg.CurrentCost ='';
        QuoteResponse.cls_Product pro = new QuoteResponse.cls_Product();
        pro.Title = '';
        pro.Details ='';
        pro.StartType ='';
        pro.StartDate ='';
        pro.EndDate ='';
        pro.ValidFrom ='';
        pro.ValidTo ='';
        pro.Adults = 0; 
        pro.ChildAges = new list<integer>{1,2};
        pro.Quantity = 1;
        pro.PickUpLocation = '';
        pro.DropOffLocation = '';
        QuoteResponse.cls_OutboundLeg outbou=new QuoteResponse.cls_OutboundLeg();
        outbou.TypeId = 0;
        outbou.Type = '';
        outbou.Segments = new list<QuoteResponse.cls_Segments>();
    //  outbou.Segments = new list<cls_Segments>();
        
        
        String myJSON1 = JSON.serialize(obj);
        QuoteResponse.parse(myJSON1); 
        
        String myJSON2 = JSON.serialize(obj1);
        QuoteResponse.cls_Destination.parse(myJSON2); 
        
        String myJSON3 = JSON.serialize(obj2);
        QuoteResponse.cls_Options.parse(myJSON3); 
        
        String myJSON4 = JSON.serialize(obj3);
        QuoteResponse.Agency.parse(myJSON4); 
        
        String myJSON5 = JSON.serialize(obj4);
        QuoteResponse.parse(myJSON5); 
        
        String myJSON6 = JSON.serialize(obj5);
        QuoteResponse.parse(myJSON6); 
        
        String myJSON7 = JSON.serialize(obj6);
        QuoteResponse.parse(myJSON7); 
        
        String myJSON8 = JSON.serialize(obj7);
        QuoteResponse.parse(myJSON8); 
        
        String myJSON9 = JSON.serialize(obj8);
        QuoteResponse.parse(myJSON9); 
        
        String myJSON10 = JSON.serialize(obj9);
        QuoteResponse.parse(myJSON10); 
        
        String myJSON11 = JSON.serialize(obj10);
        QuoteResponse.parse(myJSON11); 
        
    }
}