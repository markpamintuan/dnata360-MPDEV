/**************************************************************************************************
* Name               : BookingResponseNew 
* Description        : This is the class generated for the json response for getting Bookings          
* Created Date       : 24-May-2018                                                                 
* Created By         : PwC- Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                COMMENTS                                              
*  v1.1       kaavya            24-May-2018
*  v1.2       Sri Bala          24-Feb-2019
*  v1.3       Sri Bala          27-Mar-2019
*  v1.4       Kaavya            22-Apr-2019       Added Agent Email
*  v1.5       Sri Bala          25-Jul-2019       Added Version Number
*  v1.6       Sri Bala          13-Oct-2019       Changed the field type for office number from integer to string
*  v1.7       Mark				10-Nov-2019		  T-00816 - Added Star Rating to cls_Stays class
*  v1.8       Ravi				15-Mar-2019		  Added the new fields BookedByUsername and bookedDomain
**************************************************************************************************/
public class BookingResponseNew{
    public cls_Trips[] Trips;
    //public cls_NotFoundBookings[] NotFoundBookings;
    public Integer[] NotFoundBookings;
    public class cls_Trips {
        public Integer TripId;  //0
        public cls_Bookings[] Bookings;
    }
    public class cls_Bookings {
        public cls_BookingCore BookingCore; /**done**/
        public cls_BookingDetail BookingDetail; /**done DOMAIN**/
        public cls_LeadContact LeadContact;/**done* Salutation__c*/
        public cls_CancellationDetails CancellationDetails; /**done**/
        public cls_Itinerary Itinerary;/**done**/
        public cls_Passengers[] Passengers; /**done* DateofBirth  */
        public cls_LineItems[] LineItems; /**done*/
        //public cls_Notes[] Notes;/**done**///commented as a part of v1.3
        public cls_Notes[] AgentNotes;
        public cls_Csrs[] Csrs;/**done* */
        public cls_Balance Balance; /**done**/
        public cls_TicketInfo TicketInfo; /**done**/
        public cls_SupplierInfo SupplierInfo;// added as a part of v1.2
        public string TrackingTag;
        public string Version{get;set;} //Added as a part of v1.4
    }
    public class cls_BookingCore {
        public Integer Id {get;set;}    //0
        public Integer Type {get;set;}  //1
        public String BookingRef {get;set;} //string
        public String BookedDate {get;set;} //2018-05-17T15:32:52.416Z
        public Integer Status {get;set;}    //1
        public Integer DomainId {get;set;}  //0
        public String CultureCode {get;set;}    //string
        public String PackageId {get;set;}  //string
        public String BookingLanguage{get;set;}
    }
    public class cls_BookingDetail {
        public String Title {get;set;}  //string
        public Integer BookedById {get;set;}    //0
        public String BookedBy {get;set;}   //string
        //Added as part of v1.4
        public String AgentEmail {get;set;}   //string  
        public String ClientCurrencyCode {get;set;} //string
        public String ClientCurrencyExchangeRate {get;set;} //1
        public String SpecialRequests {get;set;}    //string
        public String UserId {get;set;} //string
        public String LastModified {get;set;}   //2018-05-17T15:32:52.416Z
        public Integer ApplicationType {get;set;}   //0
        public String FamilyId {get;set;}   //string
        public String OfficeNo{get;set;}//added as a part of v1.3
        public String OfficeName{get;set;}//added as a part of v1.2
        public String BookedByUsername {get;set;}//added as a part of v1.8
        public String DomainBookedOn {get;set;}//added as a part of v1.8
    }
    public class cls_LeadContact { 
        public String Title;    //string
        public String FirstName;    //string
        public String LastName; //string
        public String AddressLine1; //string
        public String AddressLine2; //string
        public String AddressLine3; //string
        public String AddressLine4; //string
        public String County;   //string
        public String PostCode; //string
        public String CountryCode;  //string
        public String Email;    //string
        public String PhoneHome;    //string
        public String PhoneMobile;  //string
        public String PhoneWork;    //string
        public boolean AllowTexts;
    }
    //Added as a part of v1.2
    public class cls_SupplierInfo{
        public Integer SupplierId{get;set;}
        public String SupplierName{get;set;}
        
    }
    public class cls_CancellationDetails {
        public boolean CancellationRequested {get;set;}
        public String Requested {get;set;}  //2018-05-17T15:32:52.416Z
        public String Confirmed {get;set;}  //2018-05-17T15:32:52.416Z
    }
    public class cls_Itinerary {
        public Integer BookingType {get;set;}   //1 
        
        //AccommodationItinerary; 
        public cls_Stays[] Stays;   /**done**/  
        
        //AirportParkingItinerary; //done
        public Integer ItineraryId {get;set;}
        public String Description {get;set;}
        public String DropOffDate {get;set;}
        public String PickUpDate {get;set;}
        public String AirportCode {get;set;}
        public String AirportName {get;set;}
        public String ParkingSiteCode {get;set;}
        public String ParkingSiteName {get;set;}
        public String Notes {get;set;} 
        public Flight OutboundFlight {get;set;}
        public Flight InboundFlight {get;set;}
        
        //AttractionsItinerary;
        public cls_Tickets[] Tickets; /**done* */
        
        //CarHireItinerary; //done
        public String VendorCode {get;set;}
        public String VendorName {get;set;}
        //public String PickUpDate;
        public String PickUpPointCode {get;set;}
        public String PickUpPointName {get;set;}
        //public String DropOffDate;
        public String DropOffPointCode {get;set;}
        public String DropOffPointName {get;set;}
        public String CarDescription {get;set;}
        public String SIPPCode {get;set;}
        public Integer DoorCount {get;set;}
        public String Model {get;set;}
        public Flight ConnectingFlight {get;set;}
        
        //FlightItinerary;
        public cls_Flights[] Flights; /**done**/
        
        //InsuranceItinerary; //done
        public String StartDate {get;set;}
        public String EndDate{get;set;}
        public Integer DestinationId{get;set;}
        public String DestinationName{get;set;}
        public Integer SchemeType{get;set;}
        public Integer TripType{get;set;}
        public Integer Adults{get;set;}
        public Integer Children{get;set;}
        public Integer Infants{get;set;}
        public String SpecialRequests{get;set;}
        
        //MarhabaItinerary;
        public String ItineraryDate; /*****keyword****/
        //public String AirportCode;
        public String Terminal;
        public String FlightNumber;
        public Integer Cabin;
        public String ServiceCode;
        public Boolean StaffRates;
        //public Integer Adults;
        //public Integer Children;
        //public Integer Infants;
        
        //TransferItinerary;
        public cls_Transfers[] Transfers;/**done**/
        
        //AdHocItinerary;
        //public String EndDate;
        //public String Description;
        
        //OtherItinerary;
        //public String EndDate;
    }
    public class cls_Passengers {
        public Integer Id {get;set;}    //0
        public Integer AgeCategory {get;set;}   //1
        public String Title {get;set;}  //string
        public String FirstName {get;set;}  //string
        public String SurName {get;set;}    //string
        public String DateOfBirth {get;set;}    //2018-05-17T15:32:52.416Z
        public Integer AgeOnReturn {get;set;}   //0
        public Integer ItineraryId {get;set;}   //0
    }
    public class cls_LineItems {
        public Integer Id {get;set;}    //0
        public Integer ItemTypeId {get;set;}    //0
        public String ItemTypeTitle {get;set;}  //string
        public Integer ItemTypeGroupId {get;set;}   //0
        public String CostType {get;set;}   //string
        public Integer Quantity {get;set;}  //0
        public Integer SupplierId {get;set;}    //0
        public String SupplierRef {get;set;}    //string
        public String SupplierName {get;set;}    //string
        public String Title {get;set;}  //string
        public String SupplierNet {get;set;}   //0
        public String SupplierNetLocal {get;set;}  //0
        public String SupplierCommission {get;set;}    //0
        public String SupplierVat {get;set;}   //0
        public String SalesTax {get;set;}  //0
        public String SupplierGross {get;set;} //0
        public String SupplierCurrency {get;set;}   //string
        public String SupplierExchangeRate {get;set;}   //0
        public String SupplierBalanceDue {get;set;} //2018-05-17T15:32:52.416Z
        public String ClientGross {get;set;}   //0
        public String Memo {get;set;}   //string
        public String CreateDate {get;set;} //2018-05-17T15:32:52.416Z
        public String AccountingCurrencyCode {get;set;} //string
        public String AccountingExchangeRate {get;set;} //0
        public Integer ReverseBookedItemId {get;set;}   //0
        public Integer LinkedNonSystemBookedItemId {get;set;}   //0
        public Integer ItineraryId {get;set;}   //0
        public String NonSystem {get;set;}
        public Integer OptionalExtraType {get;set;} //0
        public String UpsellAmount{get;set;} //added as a part of v1.2
        public String RebateAmount{get;set;} //added as a part of v1.2 
    }
    public class cls_Notes {
        
        public String Title {get;set;}  //string
        public String Description {get;set;}    //string
        public Integer CreatedById {get;set;}   //0
        public Integer Id {get;set;}    //0
        public String CreatedDate {get;set;}    //2018-05-17T15:32:52.416Z
        public String CreatedBy {get;set;} //string
        
        public String Subject {get;set;}    //string
        public String Text {get;set;}   //string        
        public boolean CreatedByCustomer {get;set;}
        
        public String PublicAgentName {get;set;}    //string
        public boolean IsPublic {get;set;} /***keyword**/
        
        public integer LogId{get;set;}
    }
    public class cls_Csrs {
        public Integer CsrId;   //0
        public Integer CategoryId;  //0
        public String Subject;  //string
        public String Text; //string
        public Integer Status;  //1
        public boolean TextAlerts;
        public String CreatedDate;  //2018-05-17T15:32:52.416Z
        public String PublicAgentName;  //string
        public boolean IsPublic; /***keyword**/
        public String ResponseRequiredDate; //2018-05-17T15:32:52.416Z
        public String TaskStatusChangedDate;    //2018-05-17T15:32:52.416Z
        public boolean ResponseRequired;
        public boolean IsTravelChange;
        public cls_Questions[] Questions;
        public cls_Notes[] Notes;
    }
    public class cls_Questions {
        public Integer QuestionId;  //0
        public String QuestionText; //string
        public String Answer;   //string
        public String QuestionDate; //2018-05-17T15:32:52.416Z
        public String AnswerDate;   //2018-05-17T15:32:52.416Z
        public String PublicAgentName;  //string
    }
    public class cls_Balance {
        public String TotalCost {get;set;} //0
        public String ClientTotalCost {get;set;}   //0
        public String TotalMargin {get;set;}   //0
        public String DueDate {get;set;}    //2018-05-17T15:32:52.416Z
        public String AmountDue {get;set;} //0
        public String AccountingCurrencyCode {get;set;} //string
        public String AccountingExchangeRate {get;set;} //0
        public String ClientCurrencyCode {get;set;} //string
        public String ClientExchangeRate {get;set;}    //0
        public String ClientAmountDue {get;set;}   //0
    }
    public class cls_TicketInfo {
        public String TicketsSent {get;set;}    //2018-05-17T15:32:52.416Z
        public String TodText {get;set;}    //string
        public boolean ETickets {get;set;}
    }
    /*
    public class cls_NotFoundBookings {
    }*/
    public class cls_Stays {
        public String CheckIn {get;set;}
        public String CheckOut {get;set;}
        public Integer EstabId {get;set;}
        public String EstabName {get;set;}
        public String Description {get;set;}
        public String DestinationName {get;set;}
        //Added as a part of v1.2
        public cls_Destination Destination;
        public List<cls_Rooms> Rooms; 
        public integer StarRating {get; set;} //v1.7      
    }
    
    //added as a part of v1.2
    public class cls_Destination{
        public string Name;
        public string Country;
        public string Province;
        public String Location;
        
    }
    public class cls_Rooms {
        public Integer ItineraryId{get;set;}
        public String RoomType{get;set;}
        public String BoardType{get;set;}
        public String AdditionalBoardDesc{get;set;}
        public Integer Adults{get;set;}
        public Integer Children{get;set;}
        public Integer Infants{get;set;}
    }
    
    public class cls_Tickets {
        public Integer ItineraryId{get;set;}
        public String Description{get;set;}
        public String StartDate{get;set;}
        public String EndDate{get;set;}
        public Integer Adults{get;set;}
        public Integer Children{get;set;}
        public Integer Infants{get;set;}
        public Destination Destination;
    }
    
    public class cls_Flights {
        public Integer ItineraryId{get;set;}
        public Integer Adults{get;set;}
        public Integer Children{get;set;}
        public Integer Infants{get;set;}
        public Integer ItineraryType{get;set;}
        public String AirlineLocator{get;set;}
        public List<cls_Segments> Segments;
    }
    
    public class cls_Segments {
        public String DepartureDate{get;set;}
        public String DepartureAirport{get;set;}
        public String DepartureTerminal{get;set;}
        public String ArrivalDate{get;set;}
        public String ArrivalAirport{get;set;}
        public String ArrivalTerminal{get;set;}
        public String FlightNumber{get;set;}
        public String Description{get;set;}
        public Integer Cabin{get;set;}
        public String Aircraft{get;set;}
        public String MarketingCarrier{get;set;}
        public String OperatingCarrier{get;set;}
        public String BookingClass{get;set;}
        public String AirlineLocator{get;set;}
    }
    
    public class cls_Transfers {
        public Integer ItineraryId{get;set;}
        public String ItineraryDate{get;set;} /***keyword***/
        public PickUpPoint PickUpPoint;
        public DropOffPoint DropOffPoint{get;set;}
        public String TransferTitle{get;set;}
        public String Address{get;set;}
        public Integer Adults{get;set;}
        public Integer Children{get;set;}
        public Integer Infants{get;set;}
        public Flight OutboundFlight;
        public Flight InboundFlight;
    }
    
    public class PickUpPoint {
        public Integer EndPointType{get;set;}
        public String AirportCode{get;set;}
        public String AirportName{get;set;}
        public Integer EstabId{get;set;}
        public String EstabName{get;set;}
        public Integer ResortId{get;set;}
        public String ResortName{get;set;}
        public String Id{get;set;}
        public String Name{get;set;}
        
    }
    
    public class DropOffPoint {
        public Integer EndPointType{get;set;}
        public String AirportCode{get;set;}
        public String AirportName{get;set;}
        public Integer EstabId{get;set;}
        public String EstabName{get;set;}
        public Integer ResortId{get;set;}
        public String ResortName{get;set;}
        public String Id{get;set;}
        public String Name{get;set;}
        
    }
    
    public class Flight {
        public String FlightNumber{get;set;}
        public String DepartureDate{get;set;}
        public String ArrivalDate{get;set;}
    }
    
    
    
    public class Destination {
        public Integer ItineraryId{get;set;}
        public Integer ProvinceId{get;set;}
        public Integer RegionId{get;set;}
        public String RegionTitle{get;set;}
       
    }
   
    

    
    public static BookingResponseNew parse(String json){
        return (BookingResponseNew) System.JSON.deserialize(json, BookingResponseNew.class);
    }
/*
    static testMethod void testParse() {
        String json=        '{'+
        '"Trips": ['+
        '{'+
        '"BookingId": 0,'+
        '"Bookings": ['+
        '{'+
        '"BookingCore": {'+
        '"Id": 0,'+
        '"Type": 1,'+
        '"BookingRef": "string",'+
        '"BookedDate": "2018-05-17T15:32:52.416Z",'+
        '"Status": 1,'+
        '"DomainId": 0,'+
        '"CultureCode": "string",'+
        '"PackageId": "string"'+
        '},'+
        '"BookingDetail": {'+
        '"Title": "string",'+
        '"BookedById": 0,'+
        '"BookedBy": "string",'+
        '"ClientCurrencyCode": "string",'+
        '"ClientCurrencyExchangeRate": 0,'+
        '"SpecialRequests": "string",'+
        '"UserId": "string",'+
        '"LastModified": "2018-05-17T15:32:52.416Z",'+
        '"ApplicationType": 0,'+
        '"FamilyId": "string"'+
        '},'+
        '"LeadContact": {'+
        '"Title": "string",'+
        '"FirstName": "string",'+
        '"LastName": "string",'+
        '"AddressLine1": "string",'+
        '"AddressLine2": "string",'+
        '"AddressLine3": "string",'+
        '"AddressLine4": "string",'+
        '"County": "string",'+
        '"PostCode": "string",'+
        '"CountryCode": "string",'+
        '"Email": "string",'+
        '"PhoneHome": "string",'+
        '"PhoneMobile": "string",'+
        '"PhoneWork": "string",'+
        '"AllowTexts": true'+
        '},'+
        '"CancellationDetails": {'+
        '"CancellationRequested": true,'+
        '"Requested": "2018-05-17T15:32:52.416Z",'+
        '"Confirmed": "2018-05-17T15:32:52.416Z"'+
        '},'+
        '"Itinerary": {'+
        '"Type": 1'+
        '},'+
        '"Passengers": ['+
        '{'+
        '"Id": 0,'+
        '"AgeCategory": 1,'+
        '"Title": "string",'+
        '"FirstName": "string",'+
        '"SurName": "string",'+
        '"DateOfBirth": "2018-05-17T15:32:52.416Z",'+
        '"AgeOnReturn": 0,'+
        '"ItineraryId": 0'+
        '}'+
        '],'+
        '"LineItems": ['+
        '{'+
        '"Id": 0,'+
        '"ItemTypeId": 0,'+
        '"ItemTypeTitle": "string",'+
        '"ItemTypeGroupId": 0,'+
        '"CostType": "string",'+
        '"Quantity": 0,'+
        '"SupplierId": 0,'+
        '"SupplierRef": "string",'+
        '"Title": "string",'+
        '"SupplierNet": 0,'+
        '"SupplierNetLocal": 0,'+
        '"SupplierCommission": 0,'+
        '"SupplierVat": 0,'+
        '"SalesTax": 0,'+
        '"SupplierGross": 0,'+
        '"SupplierCurrency": "string",'+
        '"SupplierExchangeRate": 0,'+
        '"SupplierBalanceDue": "2018-05-17T15:32:52.416Z",'+
        '"ClientGross": 0,'+
        '"Memo": "string",'+
        '"CreateDate": "2018-05-17T15:32:52.416Z",'+
        '"AccountingCurrencyCode": "string",'+
        '"AccountingExchangeRate": 0,'+
        '"ReverseBookedItemId": 0,'+
        '"LinkedNonSystemBookedItemId": 0,'+
        '"ItineraryId": 0,'+
        '"NonSystem": true,'+
        '"OptionalExtraType": 0'+
        '}'+
        '],'+
        '"Notes": ['+
        '{'+
        '"Title": "string",'+
        '"Description": "string",'+
        '"CreatedById": 0,'+
        '"Id": 0,'+
        '"CreatedDate": "2018-05-17T15:32:52.416Z",'+
        '"CreatedBy": "string"'+
        '}'+
        '],'+
        '"Csrs": ['+
        '{'+
        '"CsrId": 0,'+
        '"CategoryId": 0,'+
        '"Subject": "string",'+
        '"Text": "string",'+
        '"Status": 1,'+
        '"TextAlerts": true,'+
        '"CreatedDate": "2018-05-17T15:32:52.416Z",'+
        '"PublicAgentName": "string",'+
        '"Public": true,'+
        '"ResponseRequiredDate": "2018-05-17T15:32:52.416Z",'+
        '"TaskStatusChangedDate": "2018-05-17T15:32:52.416Z",'+
        '"ResponseRequired": true,'+
        '"IsTravelChange": true,'+
        '"Questions": ['+
        '{'+
        '"QuestionId": 0,'+
        '"QuestionText": "string",'+
        '"Answer": "string",'+
        '"QuestionDate": "2018-05-17T15:32:52.416Z",'+
        '"AnswerDate": "2018-05-17T15:32:52.416Z",'+
        '"PublicAgentName": "string"'+
        '}'+
        '],'+
        '"Notes": ['+
        '{'+
        '"Subject": "string",'+
        '"Text": "string",'+
        '"CreatedDate": "2018-05-17T15:32:52.416Z",'+
        '"CreatedByCustomer": true,'+
        '"PublicAgentName": "string",'+
        '"Public": true'+
        '}'+
        ']'+
        '}'+
        '],'+
        '"Balance": {'+
        '"TotalCost": 0,'+
        '"ClientTotalCost": 0,'+
        '"TotalMargin": 0,'+
        '"DueDate": "2018-05-17T15:32:52.416Z",'+
        '"AmountDue": 0,'+
        '"AccountingCurrencyCode": "string",'+
        '"ClientCurrencyCode": "string",'+
        '"ClientExchangeRate": 0,'+
        '"ClientAmountDue": 0'+
        '},'+
        '"TicketInfo": {'+
        '"TicketsSent": "2018-05-17T15:32:52.416Z",'+
        '"TodText": "string",'+
        '"ETickets": true'+
        '}'+
        '}'+
        ']'+
        '}'+
        '],'+
        '"NotFoundBookings": ['+
        '1'+
        ']'+
        '}';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    } */
}