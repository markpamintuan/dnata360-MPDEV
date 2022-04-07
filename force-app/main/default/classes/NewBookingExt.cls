/**************************************************************************************************
* Name               : NewBookingExt 
* Description        : This is the quotes class where new Quotes are created and updated.           
* Created Date       : 09-May-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Evendo        08-Aug-2018    Initial version
* v1.1        Sri Bala      10-Dec-2018    T-00095 -  Booking Custom Page   
* v1.2        Sri Bala      13-Jan-2019    T-00342 -  More product types
* v1.3        Jed Canlas    22-Apr-2019    T-00547 -  Gross and Nett Price in New Booking Other
* v1.4        Jed Canlas    23-Apr-2019    T-00549 -  Airline to be added in New Booking Other
* v1.5        Mark          11-Jul-2019    T-00613 -  Added validation Booking Type before saving booking
* v1.6        Jed Canlas    16-Jul-2019    T-00566 -  Dutytravel Fix
* v1.7        Merul         02-Sep-2019    T-00714 - Rename Non - Bundle to Package/Single Product
**************************************************************************************************/

public without sharing class NewBookingExt {
    
    /**********New lists to show on UI*******/
    public Map<String, Itinerary_Detail__c> mapItinDetailKeyToItinerayRecord {
        get{
            if(mapItinDetailKeyToItinerayRecord == null) 
                mapItinDetailKeyToItinerayRecord = new Map<String, Itinerary_Detail__c>();
            
            return mapItinDetailKeyToItinerayRecord;
        }
        set;
    }
    
    public boolean showItineraryDetail {
        get{
            if(mapItinDetailKeyToItinerayRecord.size()>0 ){
                return true;
            }else{
                return false;
            }
        }
        set;
    }
    
    public boolean showBookingType {
        get{
            if(mapItinDetailKeyToItinerayRecord.size()>0 && quotefinalised == false){
                return true;
            }else{
                return false;
            }
        }
        set;
    }
    
    public Map<String, Traveller__c> mapTravellerKeyToTravellerRecord {
        get{
            if(mapTravellerKeyToTravellerRecord == null) 
                mapTravellerKeyToTravellerRecord = new Map<String, Traveller__c>();
            
            return mapTravellerKeyToTravellerRecord;
        }
        set;
    }
    
    public boolean showtravellerTable {
        get{
            if(mapTravellerKeyToTravellerRecord.size()>0){
                return true;
            }else{
                return false;
            }
        }
        set;
    }
    
    //Added as a part of v1.3
    public boolean checkProfile {
        get{           
            
            return [select name from profile where id =: UserInfo.getProfileId() limit 1].name.containsIgnoreCase('retail');
        }
        set;
    }
    
    
    
    
    public Map<String, Booking_Price_Breakdown__c> mapBookingPriceKeyToBookingPriceBreakdown {
        get{
            if(mapBookingPriceKeyToBookingPriceBreakdown == null) 
                mapBookingPriceKeyToBookingPriceBreakdown = new Map<String, Booking_Price_Breakdown__c>();
            
            return mapBookingPriceKeyToBookingPriceBreakdown;
        }
        set;
    }
    
    public boolean showBookingPriceTable {
        get{
            if(mapBookingPriceKeyToBookingPriceBreakdown.size()>0){
                return true;
            }else{
                return false;
            }
        }
        set;
    }
    
    public String itineraryMapKey {get;set;}
    public String travellerMapKey {get;set;}
    public String bookingPriceBreakdownMapKey {get;set;}
    
    public Boolean editFlag{get;set;}
    public Boolean quotefinalised{get;set;}
    /***************************************/
    private final Case cse;
    private Booking__c bookingHeader;
    public Booking__c bookingItem {get;set;}
    public Itinerary__c itinerary {get;set;} //This can be deleted in future
    public Itinerary_Detail__c itineraryDetail {get;set;}
    
    public Booking__c randomBooked {get;set;}
    public Booking_Price_Breakdown__c bookingPriceBreakDown {get;set;}
    public String itineraryDetailId {get;set;}
    public String bookingPriceBreakDownId {get;set;}
    public string selectOption{get;set;}
    //itineraryDetailId
    public boolean ItineraryBoolean{get;set;}
    public boolean TravellerBoolean{get;set;}
    public boolean PricingBoolean{get;set;}
    
    public Traveller__c traveller {get;set;}
    public String itineraryId {get;set;}
    public String travellerId {get;set;}
    
    private Map<Id, Itinerary_Detail__c> mapItineraryDetailIdToObject; 
    private Map<Id, Traveller__c> maptravellerIdToObject;
    // private Map<Id, Booking_Price_Breakdown__c> mapbookingPriceBreakdownIdToObject; 
    private List<Itinerary__c> lItineraries;

    public String dutyTravelTeam {get;set;}//MPamintuan added as part of v1.5
    
    //Added as a part of v1.1
    public List<SelectOption> typeFlight {
        set;get{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =
                Itinerary__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getValue() == 'Flight Inbound' || f.getValue() == 'Flight Outbound')
                    options.add(new SelectOption(f.getValue(), f.getValue()));
            }       
            return options;
        }
    }
    
    //Added as a part of v1.4
    public List<SelectOption> airline {   
        set;get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('--None--','--None--'));
            for(lookup__c a: [select name from lookup__c where Type__c ='Airline'  ORDER BY name ASC]){
            
                options.add(new SelectOption(a.Name, a.Name)); 
            }       
            return options;
        }
    }
    
    public List<SelectOption> bookingSystem {
        set;get{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Booking__c.Booking_System__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Profile currentUserProfile = [SELECT Name From Profile WHERE ID =: UserInfo.getProfileId()];
            for( Schema.PicklistEntry f : ple)
            {  
                if(currentUserProfile.Name == 'dutyTravel Agent'){
                    //Added as a part of v1.6 (f.getValue() =='EK Consultant Tickets')
                    if(f.getValue() == 'GDS' || f.getValue() == 'Other' || f.getValue() == 'Direct Contract' || f.getValue() == 'EK Crew Hotel' || f.getValue() =='Preferred Hotel'){
                        options.add(new SelectOption(f.getValue(), f.getValue()));
                    }
                    if(this.cse.Record_Type_Name__c == 'Duty Travel - New Enquiry' && f.getValue() == 'EK Consultant Tickets'){
                        options.add(new SelectOption(f.getValue(), f.getValue()));
                    }                    
                }else{
                  if(f.getValue() == 'GDS' || f.getValue() == 'Other' || f.getValue() =='LCC' )
                    options.add(new SelectOption(f.getValue(), f.getValue()));
                }  
            }       
            return options;
        }
    }    

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 14 July 2019
     * @description: return Booking Types picklist values //v1.5
     * @history:                
     */
    public List<SelectOption> getBookingTypes() 
    {

        list<SelectOption> options = new list<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Booking__c.Org_Booking_Type__c.getDescribe();
        list<Schema.PicklistEntry> bookingTypes = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry bType : bookingTypes){  
            //if(bType.getValue() != 'Bundle' && bType.getValue() != 'Non- Bundle' ){
            if(bType.getValue() != 'Bundle' && bType.getValue() != 'Package/Single Product' ){
                options.add(new SelectOption(bType.getValue(), bType.getValue()));
            } 
        } 

        return options;

    }
    
    public NewBookingExt(ApexPages.StandardController stdController) {
        system.debug('### entering constructor');
        List<String> fields = new List<String> { 'Org_Brand__c','Org_Destination_list__c','Reason','Org_Booking__c', 'AccountId', 'CaseNumber','Org_Case_Status__c','Org_Case_Close_Reason__c', 'Closing_Comments__c','Org_Current_Team_Name__c','Staff_Region__c','Record_Type_Name__c'};
            if (!Test.isRunningTest()) stdController.addFields(fields);
        
        this.cse = (Case)stdController.getRecord();
        //populateItineraryFromQuotes();
        itinerary = new Itinerary__c();
        itineraryDetail = new Itinerary_Detail__c();
        bookingItem = new Booking__c();
        bookingItem.Org_Account_Name__c = this.cse.AccountId;
        //bookingItem.Org_Booking_Type__c = 'Flight';
        itinerary.Flight_Type__c = null;
        
        
        bookingItem.Org_Booked_Date__c = System.now();
        bookingItem.Org_Brand__c = this.cse.Org_Brand__c;
        bookingItem.Booking_Status__c = 'Receipted';
        
        bookingPriceBreakDown = new Booking_Price_Breakdown__c();
        traveller = new Traveller__c();
 
        dutyTravelTeam = this.cse.Staff_Region__c; //MPamintuan added as part of v1.5       
        
    }
    
    private void populateItineraryFromQuotes(){
        system.debug('### entering populateItineraryFromQuotes');
        
        List<Quote_Line_Item__c> lQuoteLineItems = new List<Quote_Line_Item__c>();
        system.debug('### lQuoteLineItems before: ' + lQuoteLineItems);
        try{
            if(bookingItem.Org_Booking_Type__c == 'Flight'){
                lQuoteLineItems = [SELECT   Airline__c,
                                   Org_Airline__c,
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
                                   AND Quote_Option__r.Quote_Header__r.Case__c =: this.cse.Id 
                                   ORDER BY Departure_Date_Time__c ASC];  
                
                for(Quote_Line_Item__c qli: lQuoteLineItems){ 
                    Itinerary_Detail__c itinDetail =  new Itinerary_Detail__c();          
                    
                    system.debug('Details!!'+itinDetail);
                    itinDetail = convertQuoteItemToItineraryDetail(qli,itinDetail);
                    String sItinDetailKey = itinDetail.Org_Departure_Date__c + '_' +datetime.now(); 
                    mapItinDetailKeyToItinerayRecord.put(sItinDetailKey, itinDetail); 
                }                     
                
            }
            if(bookingItem.Org_Booking_Type__c == 'Accommodation'){
                lQuoteLineItems = [SELECT  Type__c,
                                   Airline__c,
                                   Org_Airline__c,
                                   Check_Out__c,
                                   Check_In__c,
                                   Hotel_Name__c,Hotel_Location__c,
                                   Room_Type__c, //added by sri bala
                                   Quote_Option__r.Status__c,
                                   Quote_Option__r.Name,
                                   Quote_Option__r.Quote_Header__c,
                                   Quote_Option__r.Quote_Header__r.Date_From__c,
                                   Quote_Option__r.Quote_Header__r.Date_To__c,
                                   Quote_Option__r.Quote_Header__r.Destination__c,
                                   Quote_Option__r.Quote_Header__r.Status__c
                                   FROM Quote_Line_Item__c
                                   WHERE Quote_Option__r.Quote_Header__r.Status__c = 'Accepted'
                                   AND Quote_Option__r.Status__c = 'Finalized'
                                   AND Type__c = 'Hotel'
                                   AND Quote_Option__r.Quote_Header__r.Case__c =: this.cse.Id 
                                   ORDER BY Check_In__c ASC];  
                for(Quote_Line_Item__c qli: lQuoteLineItems){ 
                    Itinerary_Detail__c itinDetail =  new Itinerary_Detail__c();          
                    
                    system.debug('Details!!'+itinDetail);
                    itinDetail = convertQuoteItemToItineraryDetail(qli,itinDetail);
                    String sItinDetailKey = itinDetail.Org_Check_In__c + '_' +datetime.now();
                    mapItinDetailKeyToItinerayRecord.put(sItinDetailKey, itinDetail);

                }                     
                           
            }
            
            
            quotefinalised = true;
            system.debug('###  populateItineraryFromQuotes with mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
            
        } 
    catch(Exception e){
        
    }
    
    
    
    
    }

    private Itinerary_Detail__c convertQuoteItemToItineraryDetail(Quote_Line_Item__c qli, Itinerary_Detail__c itinDetail){
        
        if(qli.Type__c == 'Flight'){
            itinDetail.Itinerary_Detail_Type__c = 'Segment';
            itinDetail.Org_Airline__c = qli.Org_Airline__c;
            itinDetail.Departure_Airport__c = qli.From__c;
            itinDetail.Org_Departure_Date__c = qli.Departure_Date_Time__c;
            itinDetail.Arrival_Airport__c = qli.To__c;
            itinDetail.Org_Arrival_Date__c = qli.Arrival_Date_Time__c;
            itinDetail.Org_Flight_Number__c = qli.Flight_No__c;
            return itinDetail;
        }
        if(qli.Type__c == 'Hotel'){
            //itinDetail.Itinerary__r.Org_Booking__r.Org_Booking_Type__c = 'Accommodation';
            itinDetail.Itinerary_Detail_Type__c = 'Room';
            itinDetail.Org_Check_In__c = qli.Check_In__c;
            itinDetail.Org_Check_Out__c = qli.Check_Out__c;
            itinDetail.Org_Hotel_Name__c = qli.Hotel_Name__c;
            itinDetail.Org_Room_Type__c = qli.Room_Type__c;
            itinDetail.Org_Hotel_City__c = qli.Hotel_Location__c;
            return itinDetail;
        }
        
        return null;
        
    }

/*public List<Itinerary_Detail__c> getItineraryDetails(){
mapItineraryDetailIdToObject = new Map<Id, Itinerary_Detail__c>(); 

for(Itinerary_Detail__c itinDet: [SELECT Id, 
Org_Departure_Date__c, 
Org_Departure_Airport__c, 
Org_Arrival_Date__c, 
Org_Arrival_Airport__c,
Org_Flight_Number__c,
Org_Airline_Locator__c,
Itinerary__c,
PNR__c,
Org_Check_In__c,
Org_Check_Out__c, 
Itinerary__r.Org_Hotel_Name__c,
Org_Description__c,
Org_Room_Type__c,
Org_Board_Type__c                               
FROM Itinerary_Detail__c
WHERE Itinerary__r.Org_Booking__c =: bookingItem.Id Order By Org_Departure_Date__c ASC]){
system.debug(itinDet.Org_Departure_Date__c);
mapItineraryDetailIdToObject.put(itinDet.Id,itinDet);

}
return mapItineraryDetailIdToObject.values();
} */

// added as a part v1.2
// 

    public pagereference addOtherItineraryDetail()
    {
        
        /*if(mapItinDetailKeyToItinerayRecord.size() == 0)
    editFlag = true;
    else
    editFlag = false;*/
        if(itineraryDetail.Start_Date__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the start date');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        if(itineraryDetail.End_date__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the end Date');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        if(itineraryDetail.From__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the From');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        if(itineraryDetail.To__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the To');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        String sItinDetailKey = itineraryDetail.From__c + '' + datetime.now();
        //itineraryDetail.Departure_Airport__c + '_' + 
        //itineraryDetail.Org_Departure_Date__c + '_' + 
        //itineraryDetail.Arrival_Airport__c + '_' + 
        //itineraryDetail.Org_Arrival_Date__c;
        system.debug('### sItinDetailKey: ' + sItinDetailKey);
        mapItinDetailKeyToItinerayRecord.put(sItinDetailKey, itineraryDetail);
        system.debug('### 22 mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
        itineraryDetail = new Itinerary_Detail__c();
        system.debug('size'+mapItinDetailKeyToItinerayRecord.size());
        //itinerary = new Itinerary__c();
        //
        
        return null; 
        
        
    }
    public pageReference addHotelItineraryDetail()
    {
     system.debug('itineraryDetail==>'+itineraryDetail);   
        if(itineraryDetail.Org_Hotel_Name__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Hotel Name');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        if(itineraryDetail.Org_Hotel_City__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Hotel City');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        if(itineraryDetail.Org_Check_In__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Check-in Date');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        if(itineraryDetail.Org_Check_Out__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Check-out date');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        if(itineraryDetail.Org_Room_Type__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Room Type');
            ApexPages.addMessage(myMsg);
            return null;  
        }
        
        String sItinDetailKey = itineraryDetail.Org_Hotel_Name__c + '' + datetime.now();
        //itineraryDetail.Departure_Airport__c + '_' + 
        //itineraryDetail.Org_Departure_Date__c + '_' + 
        //itineraryDetail.Arrival_Airport__c + '_' + 
        //itineraryDetail.Org_Arrival_Date__c;
        system.debug('@@### sItinDetailKey: ' + sItinDetailKey);
        mapItinDetailKeyToItinerayRecord.put(sItinDetailKey, itineraryDetail);
        system.debug('@@### 22 mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
        itineraryDetail = new Itinerary_Detail__c();
        
        //itinerary = new Itinerary__c();
        //
        return null; 
        
    }

    public pagereference doAction()
    {
        system.debug('@@!!'+mapItinDetailKeyToItinerayRecord);
        system.debug('Started');
        populateItineraryFromQuotes();
        if(mapItinDetailKeyToItinerayRecord.size()!=0 && quotefinalised == false)
        {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please create a different booking for other booking type.');
            ApexPages.addMessage(myMsg);
            
        }
        return null;
    }
    // end of v1.1
    public PageReference addItineraryDetail(){ 
        system.debug('### adding flight itin with mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
        system.debug('### adding flight itin with itineraryDetail: ' + itineraryDetail);
        if(itineraryDetail.Flight_Type__c == null)
        {
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Type');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(itineraryDetail.Departure_Airport__c == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Departure Airport');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(itineraryDetail.Org_Arrival_Date__c <  itineraryDetail.Org_Departure_Date__c){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Arrival Date cannot be earlier than Depature Date');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(itineraryDetail.Org_Departure_Date__c  == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Departure Date');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        
        if(itineraryDetail.Arrival_Airport__c  == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Arrival Airport');
            ApexPages.addMessage(myMsg);
            return null;
            
        }
        
        if(itineraryDetail.Org_Arrival_Date__c  == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Arrival Date');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(itineraryDetail.Org_Flight_Number__c  == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Flight Number');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(itineraryDetail.Org_Airline_Locator__c  == null ){
            ItineraryBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Airline PNR Reference Number');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        //upsert itineraryDetail;
        
        String sItinDetailKey = itineraryDetail.Org_Departure_Date__c + '' + datetime.now();
        //itineraryDetail.Departure_Airport__c + '_' + 
        //itineraryDetail.Org_Departure_Date__c + '_' + 
        //itineraryDetail.Arrival_Airport__c + '_' + 
        //itineraryDetail.Org_Arrival_Date__c;
        system.debug('### sItinDetailKey: ' + sItinDetailKey);
        mapItinDetailKeyToItinerayRecord.put(sItinDetailKey, itineraryDetail);
        system.debug('### 22 mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
        itineraryDetail = new Itinerary_Detail__c();
        
        
        //itinerary = new Itinerary__c();
        //
        
        return null; 
    }

    public void deleteItinerary(){ 
        
        string keyval = apexpages.currentpage().getparameters().get('itineraryDetailIdToDelete');
        system.debug('keyval@@@@@@@@@@@@@@@@@@@@@@@@'+keyval);
        //itinerary = new Itinerary__c();   
        //Itinerary__c itineraryToDelete = new Itinerary__c();
        //itineraryToDelete.Id = mapItineraryDetailIdToObject.get(itineraryDetailId).Itinerary__c;
        
        //   if(itineraryToDelete.Id !=null) delete itineraryToDelete;
        
        //Itinerary_Detail__c itinDetailToDelete = mapItineraryDetailIdToObject.get(itineraryDetailId);
        //delete itinDetailToDelete; 
        mapItinDetailKeyToItinerayRecord.remove(keyval);
        system.debug('@@ '+mapItinDetailKeyToItinerayRecord);
        
    }
    
    public void editItineraryDetail(){
        system.debug('### entering editItineraryDetail with itineraryDetailId: ' + itineraryMapKey);
        system.debug('### entering editItineraryDetail with mapItinDetailKeyToItinerayRecord: ' + mapItinDetailKeyToItinerayRecord);
        
        
        itineraryDetail = mapItinDetailKeyToItinerayRecord.get(itineraryMapKey);
        //mapItinDetailKeyToItinerayRecord.remove(itineraryMapKey);
        //itineraryDetail = mapItineraryDetailIdToObject.get(itineraryDetailId);       
        system.debug('### entering editItineraryDetail with itineraryDetail: ' + itineraryDetail);
        
    }

    public void editTraveller(){
        system.debug('### entering edit traveller');
        system.debug('### entering edit traveller with travellerMapKey: ' + travellerMapKey);
        traveller = mapTravellerKeyToTravellerRecord.get(travellerMapKey);
        mapTravellerKeyToTravellerRecord.remove(travellerMapKey);
        system.debug('### traveller: ' + traveller);
    }
    
    public void editBookingPriceBreakdown(){
        system.debug('### entering editBookingPriceBreakdown');
        bookingPriceBreakDown = mapBookingPriceKeyToBookingPriceBreakdown.get(bookingPriceBreakdownMapKey);
        mapBookingPriceKeyToBookingPriceBreakdown.remove(bookingPriceBreakdownMapKey);
        
    }

    public PageReference addTraveller(){
        /*
    traveller.Name = traveller.Org_First_Name__c + ' ' + traveller.Org_Last_Name__c;  
    traveller.Org_Booking__c = bookingItem.Id;
    upsert traveller;
    */
        if(traveller.Org_Last_Name__c == null){
            TravellerBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter the Last Name');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        String sTravellerKey =  traveller.Org_First_Name__c + '_' + 
            traveller.Org_Last_Name__c + '_' + 
            traveller.Org_Date_Of_Birth__c;
        mapTravellerKeyToTravellerRecord.put(sTravellerKey, traveller);
        
        traveller = new Traveller__c();
        return null; 
    }

/*  public List<Traveller__c> getTravellers(){      
maptravellerIdToObject = new Map<ID, Traveller__c>();

for(Traveller__c traveller: [SELECT Id, 
Org_First_Name__c, 
Org_Last_Name__c, 
Org_Date_Of_Birth__c                                    
FROM Traveller__c
WHERE Org_Booking__c =: bookingItem.Id AND Org_Booking__c != null]){
maptravellerIdToObject.put(traveller.Id,traveller);
}
return maptravellerIdToObject.values();
} */

    public void deleteTraveller(){ 
        mapTravellerKeyToTravellerRecord.remove(travellerMapKey);
        /*
    traveller = new Traveller__c(); 
    Traveller__c travellerToDelete = maptravellerIdToObject.get(travellerId);
    delete travellerToDelete;
    */
    }

    public PageReference addBookingPriceBreakDown(){ 
        
        if((bookingPriceBreakDown.Org_Title__c == null) && (bookingPriceBreakDown.Org_Client_Gross__c == null) && (bookingPriceBreakdown.Org_Supplier_Gross__c == null)){
            PricingBoolean = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Values in Pricing Detail.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        String sBookingPriceKey =   bookingPriceBreakDown.Org_Title__c + '_' + 
            bookingPriceBreakDown.Org_Client_Gross__c + '_' + 
            bookingPriceBreakDown.Org_Quantity__c + '_' + 
            bookingPriceBreakDown.Org_Supplier_Gross__c;
        mapBookingPriceKeyToBookingPriceBreakdown.put(sBookingPriceKey, bookingPriceBreakDown);
        
        bookingPriceBreakDown = new Booking_Price_Breakdown__c();
        return null; 
        /*
    bookingPriceBreakDown.Org_Booking__c = bookingItem.Id;
    upsert bookingPriceBreakDown;
    bookingPriceBreakDown = new Booking_Price_Breakdown__c();      
    return null;
    */ 
    }

    @TestVisible private void saveBookingPriceBreakDown(){ 
        List<Booking_Price_Breakdown__c> lBookingPriceBreakdown = new List<Booking_Price_Breakdown__c>();
        for(Booking_Price_Breakdown__c bookPriceBreakDown: mapBookingPriceKeyToBookingPriceBreakdown.values()){
            system.debug('### saveBookingPriceBreakDown bookPriceBreakDown: ' + bookPriceBreakDown);
            bookPriceBreakDown.Org_Booking__c = bookingItem.Id;
            lBookingPriceBreakdown.add(bookPriceBreakDown);
        }
        system.debug('### saveBookingPriceBreakDown lBookingPriceBreakdown: ' + lBookingPriceBreakdown);
        
        insert lBookingPriceBreakdown;
        //String sBookingPriceKey =   bookingPriceBreakDown.Org_Title__c + '_' + 
        //                            bookingPriceBreakDown.Org_Client_Gross__c + '_' + 
        //                            bookingPriceBreakDown.Org_Supplier_Gross__c;
        //mapBookingPriceKeyToBookingPriceBreakdown.put(sBookingPriceKey, bookingPriceBreakDown);
        
        //bookingPriceBreakDown = new Booking_Price_Breakdown__c();
        //return null; 
        /*
    bookingPriceBreakDown.Org_Booking__c = bookingItem.Id;
    upsert bookingPriceBreakDown;
    bookingPriceBreakDown = new Booking_Price_Breakdown__c();      
    return null;
    */ 
    }

/*   public List<Booking_Price_Breakdown__c> getBookingPriceBreakDowns(){      
mapbookingPriceBreakdownIdToObject = new Map<ID, Booking_Price_Breakdown__c>();

for(Booking_Price_Breakdown__c bookPriceBreakDown: [SELECT Id, 
Org_Client_Gross__c, 
Org_Quantity__c, 
Org_Supplier_Gross__c,
Org_Title__c,
CurrencyIsoCode                                    
FROM Booking_Price_Breakdown__c
WHERE Org_Booking__c =: bookingItem.Id AND Org_Booking__c != null]){
mapbookingPriceBreakdownIdToObject.put(bookPriceBreakDown.Id,bookPriceBreakDown);
}
return mapbookingPriceBreakdownIdToObject.values();
} */

    public void deleteBookingPriceBreakDown(){        
        List<Itinerary__c> litineraryToInsertFromQuotes = new List<Itinerary__c>();
        mapBookingPriceKeyToBookingPriceBreakdown.remove(bookingPriceBreakdownMapKey); 
        
        //Booking_Price_Breakdown__c bookingPriceBreakDownToDelete = 
        //mapbookingPriceBreakdownIdToObject.get(bookingPriceBreakDownId);
        //delete bookingPriceBreakDownToDelete; 
    }
    
    public PageReference deleteAllRecords(){
        //List<Traveller__c> lTravellersToDelete = new List<Traveller__c>();
        //List<Itinerary_Detail__c> lItineraryDetailsToDelete = new List<Itinerary_Detail__c>();
        //List<Booking_Price_Breakdown__c> lBookingPriceBreakdown = new List<Booking_Price_Breakdown__c>();
        //List<Itinerary__c> lItinerariesToDelete = new List<Itinerary__c>();
        
        //lTravellersToDelete.addAll(maptravellerIdToObject.values());
        //lItineraryDetailsToDelete.addAll(mapItineraryDetailIdToObject.values());
        //lBookingPriceBreakdown.addAll(mapbookingPriceBreakdownIdToObject.values()); 
        
        //for(Itinerary_Detail__c itinDetail: mapItineraryDetailIdToObject.values()){
        //    Itinerary__c itin = new Itinerary__c();
        //    itin.Id = itinDetail.Itinerary__c;
        //    lItinerariesToDelete.add(itin);
        //}
        
        //if(lTravellersToDelete.size()>0) delete lTravellersToDelete;
        //if(lItineraryDetailsToDelete.size()>0) delete lItineraryDetailsToDelete;
        //if(lBookingPriceBreakdown.size()>0) delete lBookingPriceBreakdown;
        //if(lItinerariesToDelete.size()>0) delete lItinerariesToDelete;
        //delete bookingItem;
        
        PageReference casePage = new ApexPages.StandardController(this.cse).view();
        casePage.setRedirect(true);
        return casePage;
    }


    public PageReference saveAll(){
        
        system.debug('bookingItem===>'+bookingItem);
        if(bookingItem.Name == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please add dnata reference');
            ApexPages.addMessage(myMsg);
            return null;
        }
    
        //v1.5 
        if(bookingItem.Org_Booking_Type__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Booking Type');
            ApexPages.addMessage(myMsg);
            return null;
        }
    
         if(bookingItem.Org_Total_Cost__c == null && dutyTravelTeam == 'UK'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Total Cost');
            ApexPages.addMessage(myMsg);
            return null;
        }       
        
        if(bookingItem.Org_Total_Margin__c == null  && !checkProfile && dutyTravelTeam == 'UK'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Total Margin');
            ApexPages.addMessage(myMsg);
            return null;
        }     
        //End v1.5 
    
        if(bookingItem.Total_Margin_AED__c == null  && !checkProfile && dutyTravelTeam != 'UK'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Total Margin');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
         if(bookingItem.Total_Cost_AED__c == null && dutyTravelTeam != 'UK'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Total Cost');
            ApexPages.addMessage(myMsg);
            return null;
        }
        //Added as a part of v1.3 - Jed
        if(bookingItem.Total_Net_AED__c == null && checkProfile){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Total Net');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(mapItinDetailKeyToItinerayRecord.size() == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please add Itineraries');
            ApexPages.addMessage(myMsg);
            return null;
        }
        saveBookingItem();
        saveItineraries();
        saveTravellers();
        saveBookingPriceBreakDown();
        
        return new ApexPages.StandardController(this.cse).view();
        
    }

    @TestVisible
    private void saveBookingItem(){
        system.debug('#### Entering saveBookingItem with bookingItem: ' + bookingItem);
        if(this.cse.Org_Booking__c == null){
            Booking__c bookingHeader = new Booking__c();
            
            bookingHeader.Name =  'Booking for Case - ' + this.cse.CaseNumber ;
            system.debug('@!#'+bookingHeader.Name );
            bookingHeader.Org_Brand__c = this.cse.Org_Brand__c;
            bookingHeader.Org_Booking_Type__c = 'Package/Single Product';  //changed as per v1.7 //bookingHeader.Org_Booking_Type__c = 'Non- Bundle'; 
            bookingHeader.Org_Account_Name__c = this.cse.AccountId;
            bookingHeader.Org_Case_TeamName__c = this.cse.Org_Current_Team_Name__c;
            //Added as a part of v1.1
            
            bookingHeader.Booking_Status__c = 'Receipted';
            
            bookingHeader.RecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
            insert bookingHeader;
            
            this.cse.Org_Booking__c = bookingHeader.Id;
            //this.cse.Org_Case_Status__c = 'Closed';
            //this.cse.Org_Case_Close_Reason__c = 'Closed Confirmed';
            //this.cse.Closing_Comments__c = 'Closed confirmed from booking page';            
            //this.cse.Reason = 'Closed Confirmed';
            //this.cse.Comments = 'Closed confirmed from booking page';
            update cse;
        }
        
        bookingItem.Booking_Header__c = this.cse.Org_Booking__c;
        if(this.cse.Org_Destination_list__c == null){
            bookingItem.Org_Title__c =  this.bookingItem.Name+'-'+this.bookingItem.Org_Booking_Type__c; 
        }else{
            bookingItem.Org_Title__c = this.bookingItem.Name+'-'+this.bookingItem.Org_Booking_Type__c;   
        }
        
        //added v1.4
        if(checkProfile){
            bookingItem.Total_Margin_AED__c = bookingItem.Total_Cost_AED__c - bookingItem.Total_Net_AED__c;
        }
        
        system.debug('Detail:'+itineraryDetail.Arrival_Airport__c);
        //edited as a part of v1.1
        bookingItem.RecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        
        //v1.5
        if(bookingItem.Total_Cost_AED__c != null){
            bookingItem.Org_Total_Cost_Client_Currency_Number__c = bookingItem.Total_Cost_AED__c;
            bookingItem.Total_Cost__c = bookingItem.Total_Cost_AED__c;
            bookingItem.Org_ClientCurrencyCode__c = 'AED';
        }
    
        if(bookingItem.Org_Total_Cost__c != null){
            bookingItem.Total_Cost__c = bookingItem.Org_Total_Cost__c;
            bookingItem.Org_Total_Cost_Client_Currency_Number__c = bookingItem.Org_Total_Cost__c;
            bookingItem.Org_ClientCurrencyCode__c = 'GBP';
        }
        //v1.5 - End    
        
        upsert bookingItem;
        system.debug('#### Exiting saveBookingItem with bookingItem: ' + bookingItem);
    }

    @TestVisible private void saveItineraries(){
        List<Itinerary__c> lItineraryToInsert = new List<Itinerary__c>();
        List<Itinerary_Detail__c> lItineraryDetails = new List<Itinerary_Detail__c>();
        //Itinerary__c itin = new Itinerary__c();          
        for(String key: mapItinDetailKeyToItinerayRecord.keyset()){
            Itinerary__c itin = new Itinerary__c();
            itin.Org_Booking__c = bookingItem.Id;
            //added as a part of v1.2
            if(bookingItem.Org_Booking_Type__c == 'Accommodation') 
            {
                itin.Org_Check_In__c = mapItinDetailKeyToItinerayRecord.get(key).Org_Check_In__c;
                itin.Org_Check_Out__c = mapItinDetailKeyToItinerayRecord.get(key).Org_Check_Out__c;
                itin.Org_Hotel_Name__c = mapItinDetailKeyToItinerayRecord.get(key).Org_Hotel_Name__c;
                itin.Room_Type__c = mapItinDetailKeyToItinerayRecord.get(key).Org_Room_Type__c;
                itin.Org_Destination_Name__c =  mapItinDetailKeyToItinerayRecord.get(key).Org_Hotel_City__c;
            }
            else
            {
                itin.Org_Start_Date__c = mapItinDetailKeyToItinerayRecord.get(key).Start_Date__c;
                itin.Org_End_Date__c = mapItinDetailKeyToItinerayRecord.get(key).End_Date__c;
                itin.From__c = mapItinDetailKeyToItinerayRecord.get(key).From__c;
                itin.To__c = mapItinDetailKeyToItinerayRecord.get(key).To__c;
            }
            
            system.debug('CheckIN'+itin.Org_Check_In__c);
            
            //itin.Org_End_Date__c = itineraryDetail.Org_Departure_Date__c;
            //itin.Type__c = itinerary.Flight_Type__c;
            
            
            //added as a part v1.1
            //modified as a part of v1.2
            if(bookingItem.Org_Booking_Type__c == 'Flight')
                itin.Type__c= mapItinDetailKeyToItinerayRecord.get(key).Flight_Type__c;
            else
                itin.Type__c = this.bookingItem.Org_Booking_Type__c;
            system.debug('itinerary.Flight_Type__c:'+itinerary.Flight_Type__c);
            system.debug('init'+itin);
            //end of part v1.2
            lItineraryToInsert.add(itin);
            system.debug('lItineraryToInsert'+lItineraryToInsert);
            
            
        }
        
        insert lItineraryToInsert;
        
        system.debug('@!@'+lItineraryToInsert);
        
        //insert itinerary details
        if(bookingItem.Org_Booking_Type__c == 'Flight' || bookingItem.Org_Booking_Type__c == 'Accommodation') // added as a part of v1.2
        {
            Integer i=0;
            for(String key: mapItinDetailKeyToItinerayRecord.keyset()){
                Itinerary_Detail__c itinDetail =  new Itinerary_Detail__c();
                Itinerary__c itin = new Itinerary__c();
                itinDetail = mapItinDetailKeyToItinerayRecord.get(key);
                system.debug('Details__'+itinDetail);
                //Added as a part of v1.1
                if(itinDetail.Flight_Type__c == 'Flight Outbound')
                {
                    bookingItem.Destination__c = itinDetail.Arrival_Airport__c;
                    system.debug('@@##'+bookingItem.Destination__c);
                    
                }
                
                itinDetail.Itinerary__c = lItineraryToInsert[i].Id;
                system.debug('@!!'+lItineraryToInsert[i] );
                if(bookingItem.Org_Booking_Type__c == 'Flight')
                    itinDetail.Itinerary_Detail_Type__c = 'Segment';
                if(bookingItem.Org_Booking_Type__c == 'Accommodation')
                    itinDetail.Itinerary_Detail_Type__c = 'Room';
                lItineraryDetails.add(itinDetail);
                system.debug('lItineraryDetails'+lItineraryDetails);
                system.debug('HotelName'+itinDetail.Org_Hotel_Name__c);
                system.debug('HotelName'+itinDetail.Org_Hotel_City__c);
                system.debug('Check in'+itinDetail.Org_Check_In__c);
                i++;
            }
            insert lItineraryDetails; 
            upsert bookingItem;
        }
    }

    @TestVisible private void saveTravellers(){
        List<Traveller__c> lTravellers = new List<Traveller__c>();
        for(Traveller__c traveller: mapTravellerKeyToTravellerRecord.values()){
            traveller.Org_Booking__c = bookingItem.Id;
            traveller.Name = traveller.Org_First_Name__c + ' ' + traveller.Org_Last_Name__c;
            lTravellers.add(traveller);
        }
        insert lTravellers;
    }

    @RemoteAction
    public static Set<String> getFromFlights(string flightname){
        Set<String> airports = new Set<String>();
        if(flightname.length() > 1){
            string newflightname = '%'+flightname+'%';
            
            for(lookup__c fa: [select name from lookup__c where (name  LIKE :newflightname AND (name != '' OR name != null) And  Type__c ='Airport') OR (code__c LIKE :newflightname And Type__c ='Airport') ORDER BY name ASC  LIMIT 10 ]){
                airports.add(fa.name);
            }
        }
        return airports;
        
    }

    /**
    @RemoteAction
    public static Set<String> getFromAirline(string airline){ 
        Set<String> airlines = new Set<String>();
        if(airline.length() > 1){
            string newairlinename = '%'+airline+'%';
            
            //for(lookup__c a: [select name from lookup__c where (name  LIKE :newairlinename AND (name != '' OR name != null) And  Type__c ='Airline') OR (code__c LIKE :newairlinename And Type__c ='Airline') ORDER BY name ASC  LIMIT 10 ]){
            for(lookup__c a: [select name from lookup__c where Type__c ='Airline'  ORDER BY name ASC]){
                airlines.add(a.name);
            }
        }
        return airlines;
        
    }**/

    @RemoteAction
    public static Set<String> getToFlights(string flightname){
        Set<String> airportsto = new Set<String>();
        if(flightname.length() > 1){
            string newflightname = '%'+flightname+'%';
            
            for(lookup__c fa: [select name from lookup__c where (name  LIKE :newflightname AND (name != '' OR name != null) And  Type__c ='Airport') OR (code__c LIKE :newflightname And Type__c ='Airport') ORDER BY name ASC LIMIT 10 ]){
                airportsto.add(fa.name);
            }
        }
        return airportsto;
        
    }

}