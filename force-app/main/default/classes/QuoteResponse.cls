/**************************************************************************************************
* Name               : QuoteResponse 
* Description        : This is the class generated for the json response for getting Quote details          
* Created Date       : 11-June-2018                                                                 
* Created By         : PwC- Paramasivan Arunachalam                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
*                                                      
**************************************************************************************************/
public class QuoteResponse {


   

    public class cls_Products {
         // Hotel Product
    public String Id{get;set;}
    public cls_Destination Destination{get;set;}
    public String AvailabilityId{get;set;}
    public String Type{get;set;}
    public integer TypeID{get;set;}
    public String Establishment{get;set;}
    public String EstablishmentId{get;set;}
    public String CheckInDate{get;set;}
    public String CheckOutDate{get;set;}
    public String QuotedCost{get;set;}
    public String CurrentCost{get;set;}
    public List<String> Rooms{get;set;}
    public List<String> SpecialOffers{get;set;}
    public List<cls_Options> Options {get;set;}
   //public List<cls_Alternatives> Alternatives {get;set;} 
    public Boolean StalePrice {get;set;} 
    public Boolean RestoreFailed{get;set;}
    public Boolean IsHidden{get;set;}
    public Boolean IsPriceHidden{get;set;}
    public Boolean IsOnRequest{get;set;}
    public String PackageId{get;set;}
   //public List<cls_InboundLeg> InboundLeg{get;set;}
    public List<cls_Legs> legs{get;set;}
   //public List<cls_OutboundLeg> OutboundLeg{get;set;}
    public  Integer Adults {get;set;}
    public List<Integer> ChildAges{get;set;}
    
    //Transfer Product

    public String PickUpPoint{get;set;}
    public String PickUpType{get;set;}
    public String DropOffPoint{get;set;}
    public  String DropOffType{get;set;}
    public  String Passengers{get;set;}
    public  String ResortLocation{get;set;}
    public  String Airport{get;set;}
    public  String OutboundDate{get;set;}
    public  String ReturnDate{get;set;}

    //Airport Parking Product 

    public List<String> Titles{get;set;}
    public  String TransferDuration{get;set;}
    public  String TransferFrequency{get;set;}

    //Car Hire Product

    public  String PickUpDate{get;set;}
    public  String DropOffDate{get;set;}


    //Marhaba Product 

    public string Description{get;set;}

    public String ProductDate{get;set;}
    public String TerminalId{get;set;}

    public String Terminal{get;set;}

    public String AirportCode{get;set;}
    
    //adhoc product
    
    public cls_product Product{get;set;}
    }
    
    
    public class cls_Destination{
    public Integer TypeId {get;set;} 
    public String Type {get;set;} 
    public Integer Id {get;set;} 
    public string Country {get;set;} 
    public string Province {get;set;} 
    public String Location {get;set;} 
    }
    

    public class cls_Options{
    public String Id {get;set;} 
    public String Title {get;set;} 
    public Integer Quantity {get;set;} 
    public string QuotedUnitCost {get;set;} 
    public string CurrentUnitCost {get;set;} 
    public Boolean OnRequest {get;set;} 
    public Boolean RestoreFailed {get;set;} 
    public String Currencyval {get;set;} 
    }

    public class cls_Alternatives{

    public String Id {get;set;} 
    public String Room {get;set;} 
    public String Board {get;set;} 
    public Integer Cost {get;set;} 

    }

     

    //Flight Product

    public class cls_OutboundLeg{
    public Integer TypeId{get;set;}
    public String Type{get;set;}
    public list<cls_Segments> Segments{get;set;}
     
    }

    public class cls_Segments{

    public String CarrierName {get;set;}
    public String CodeshareAirlineName {get;set;}
    public string CabinName {get;set;}
    public string Cabin{get;set;}
    public string FlightNumber{get;set;}
    public string DepartureDate{get;set;}
    public string DepartureAirportCode{get;set;}
    public string DepartureAirportTitle{get;set;}
    public string DepartureTerminal{get;set;}
    public string ArrivalDate{get;set;}
    public string DestinationAirportCode{get;set;}
    public string DestinationAirportTitle{get;set;}
    public string DestinationTerminal{get;set;}
    public string ZonedDepartureDate{get;set;}
    public string ZonedArrivalDate{get;set;}
    public string Logo{get;set;}
    public string SupplierFareClass{get;set;}

    }


    public class cls_InboundLeg{
    public Integer TypeId{get;set;}
    public String Type {get;set;}
    public list<cls_Segments> Segments{get;set;}

    }

    public class cls_Legs{
    public Integer TypeId{get;set;}
    public String Type {get;set;}
    public list<cls_Segments> Segments{get;set;}

    public string QuotedCost{get;set;}
    public string CurrentCost{get;set;}
    public List<cls_Options> options{get;set;}

    }


    

    //Bundle Product

    public class cls_Product{
    public  String  Title{get;set;}
    public  String Details{get;set;}
    public  String StartType{get;set;}
    public  String  StartDate{get;set;}
    public  String  EndDate{get;set;}
    public  String ValidFrom{get;set;}
    public  String ValidTo{get;set;}
    public  Integer Adults{get;set;}
    public  List<Integer> ChildAges{get;set;}
    public integer Quantity{get;set;}
    public string PickUpLocation{get;set;}
    public string DropOffLocation{get;set;}
    public list<cls_Itinerary> Itinerary{get;set;}

    }

    public class  cls_Itinerary{
    public string ItemTime{get;set;}
    public string Description{get;set;}
    }

    public class Agency {
        public Integer Id;
        public Integer AgencyType;
        public String Name;
        public String AbtaNumber;
        public String VatNumber;
    }

    public List<Quotes> Quotes;
    public List<String> NotFoundQuotes;

    public class Customer {
        public String Title;
        public String FirstName;
        public String LastName;
        public String LoyaltyNumber;
    }

    public class ImpersonatedAgent {
        public String Reference;
        public Customer Customer;
        public Integer Id;
        public String FirstName;
        public String LastName;
        public String FullName;
        public String Email;
        public Boolean IsSharedAccount;
        public Boolean Active;
        public Agency Agency;
    }

    public class Quotes {
        public String Id;
        public String Reference;
        public String BasketId;
        public String AccountingCurrency;
        public String Currencyval;
        public Boolean ForHoliday;
        public List<cls_Products> Products;
        public Boolean StalePrices;
        public Boolean SharedUse;
        public List<Integer> BookingIds;
        public ImpersonatedAgent ImpersonatedAgent;
        public ImpersonatedCustomer ImpersonatedCustomer;
        public String Created;
        public CreatedByAgent CreatedByAgent;
        public String Deposit;
        public String DueDate;
        public List<Notes> Notes;
        public Integer DomainId;
        public String TrackingTag;
    }

    public class ImpersonatedCustomer {
        public String Id;
        public String EmailAddress;
        public String PhoneNumber;
        public String Title;
        public String FirstName;
        public String LastName;
        public String LoyaltyNumber;
    }

    public class Notes {
        public String Id;
        public String Text;
        public String Created;
        public Integer CreatedById;
        public String CreatedBy;
    }

    public class CreatedByAgent {
        public Integer Id;
        public String FirstName;
        public String LastName;
        public String FullName;
        public String Email;
        public Boolean IsSharedAccount;
        public Boolean Active;
        public Agency Agency;
    }

    
    public static QuoteResponse parse(String json) {
        return (QuoteResponse) System.JSON.deserialize(json, QuoteResponse.class);
    }
}