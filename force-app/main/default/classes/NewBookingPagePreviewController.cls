public without sharing class NewBookingPagePreviewController {

    /**********New lists to show on UI*******/
    public Map<String, Itinerary_Detail__c> mapItinDetailKeyToItinerayRecord {
        get{
            if(mapItinDetailKeyToItinerayRecord == null) 
                mapItinDetailKeyToItinerayRecord = new Map<String, Itinerary_Detail__c>();

            return mapItinDetailKeyToItinerayRecord;
        }
        set;
    }

    public Map<String, Itinerary__c> mapItinDetailKeyToItineray {
        get{
            if(mapItinDetailKeyToItineray == null) 
                mapItinDetailKeyToItineray = new Map<String, Itinerary__c>();

            return mapItinDetailKeyToItineray;
        }
        set;
    }
    
    public boolean showItineraryDetail {
        get{
            if(mapItinDetailKeyToItinerayRecord.size()>0){
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

    /***************************************/
    private final Case cse;
    private Booking__c bookingHeader;
    public Booking__c bookingItem {get;set;}
    public List<Itinerary__c> itinerary {get;set;} //This can be deleted in future
    public List<Itinerary_Detail__c> itineraryDetail {get;set;}

    public Booking__c randomBooked {get;set;}
    public List<Booking_Price_Breakdown__c> bookingPriceBreakDown {get;set;}
    public String itineraryDetailId {get;set;}
    public String bookingPriceBreakDownId {get;set;}
    
    //itineraryDetailId
    public boolean ItineraryBoolean{get;set;}
    public List<Traveller__c> traveller {get;set;}
    public String itineraryId {get;set;}
    public String travellerId {get;set;}
 
    private Map<Id, Itinerary_Detail__c> mapItineraryDetailIdToObject; 
    private Map<Id, Traveller__c> maptravellerIdToObject;
    private Map<Id, Booking_Price_Breakdown__c> mapbookingPriceBreakdownIdToObject; 
    private List<Itinerary__c> lItineraries;
    
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                // if (fd.isCreateable()){ // field is creatable
                selectFields.add(fd.getName());
                //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
        
    }
    
    
    
    public NewBookingPagePreviewController(ApexPages.StandardController controller) {
        system.debug('### entering constructor');
       
        //List<String> fields = new List<String> { 'Org_Brand__c','Org_Destination_list__c','Reason','Org_Booking__c', 'AccountId', 'CaseNumber','Org_Case_Status__c','Org_Case_Close_Reason__c', 'Closing_Comments__c'};
        //if (!Test.isRunningTest()) stdController.addFields(fields);
        
        //this.cse = (Case)stdController.getRecord();
        //system.debug(this.cse);
       // populateItineraryFromQuotes();
         itineraryDetail = new List<itinerary_detail__c>(); 
        System.debug(ApexPages.currentPage().getParameters().get('id'));
        bookingItem = [select id,name,Org_Booked_Date__c,Booking_System__c,Org_Booking_Type__c from booking__c where id = :ApexPages.currentPage().getParameters().get('id')];
        itinerary = [select id,org_check_in__c,org_check_out__c,org_hotel_name__c,description__c, org_destination_name__c,org_estab_id__c from itinerary__c where org_booking__c = :bookingItem.id];
        for(itinerary__c itin : itinerary){
            mapItinDetailKeyToItineray.put(''+ itin.Org_Check_In__c + Datetime.now() , itin);
        
        itinerary_detail__c test = new itinerary_detail__c();
            try{   
                string iditin = itin.id;
                string ReqQuery = getCreatableFieldsSOQL('itinerary_detail__c');
                //string entity='CSR';
                ReqQuery += ' where itinerary__c = :iditin ' ;
                List<itinerary_detail__c> test2 =  database.query(ReqQuery);
                itineraryDetail.add(database.query(ReqQuery)); 
                System.debug(test2);
            } catch(Exception e) {
                system.debug(e);
            }
        }
        
        for(itinerary_detail__c itindet : itineraryDetail){
            mapItinDetailKeyToItinerayRecord.put(itindet.Departure_Airport__c + Datetime.now(), itindet);
        }
        system.debug(bookingItem);
        system.debug(itinerary);
        system.debug(itineraryDetail);
        
        traveller = [select id,Org_First_Name__c,Org_Last_Name__c,Org_Date_of_birth__c from traveller__c where org_booking__c = :bookingItem.id];
        for(traveller__c travlist : traveller){
            mapTravellerKeyToTravellerRecord.put(travlist.Org_First_Name__c,travlist);
        }
       
         bookingPriceBreakDown = [select id,Org_Client_Gross__c,Org_Supplier_Gross__c,Name from Booking_Price_Breakdown__c where org_booking__c = :bookingItem.id];
        for(Booking_Price_Breakdown__c bpbdlist : bookingPriceBreakDown){
            mapBookingPriceKeyToBookingPriceBreakdown.put(bpbdlist.Name,bpbdlist);
        }
    }

}