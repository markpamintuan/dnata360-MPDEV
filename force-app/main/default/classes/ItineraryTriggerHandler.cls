/**************************************************************************************************
* Name               : ItineraryTriggerHandler 
* Description        : This is the trigger handler class for Itinerary trigger           
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Paramasiva                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS                
* v1.0        Paramasiva      08-Aug-2018     Initial version
* v1.1        SriBala         29-Jan-2019     T-00316 - Hotel name on Booking header record   
* v1.2        Maruf           10-Apr-2019     Id case sensitive issue 
* v1.3        Sri Bala        13-Oct-2019     Exception fix on v1.1
* v1.4		  Ravi			  05-Feb-2020	  Added the logic for Code optimazation
**************************************************************************************************/

public class ItineraryTriggerHandler{
    static Set<Id> sBookingIds; 
    static List<Booking__c> lBookingToUpdate;
    static Set<Id> sBookingHeaderIds;
    static Set<Booking__c> setBookings;
    static Map<String, Booking__c> mBookingIdToBookingRecord = new Map<String, Booking__c>();
    static list<Booking__c> lBookingHeadersToUpdateHN;//added as a part of v1.1
    static Map<Id, Booking__c> mBookingIdWithTotalCostCurrency = new Map<Id,Booking__c>(); //added as a part of v1.1
    
    public static void onBeforeInsert(List<Itinerary__c> newItineraryList){
        
        for(Itinerary__c itin: newItineraryList){
            itin.Org_Booking_Header_Id_Text__c = itin.Booking_Header_18_Digit_ID__c; //added as a part of v1.2
        }
    }
    
    public static void onAfterInsert(List<Itinerary__c> newItineraryList){
        //v1.4
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
        instantiateListsAndSets();
        
        for(Itinerary__c itin: newItineraryList){
            populateBookingSets(itin, null);
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);        
        rollUpHotelNameToBookingHeader(sBookingHeaderIds);   //added as a part of v1.1
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerHandler lBookingToUpdate afterInsert: ' + lBookingToUpdate);
        //v1.4
        BookingTriggerHandler.BlockBookingTrigger = true;
        update lBookingToUpdate;
        BookingTriggerHandler.BlockBookingTrigger = false;
    }
    
    public static void onBeforeUpdate(  List<Itinerary__c> oldItineraryList,
                                      List<Itinerary__c> newItineraryList, 
                                      Map<Id,Itinerary__c> oldItineraryMap,
                                      Map<Id,Itinerary__c> newItineraryMap){ 
                                          
                                          for(Itinerary__c itin: newItineraryList){
                                              itin.Org_Booking_Header_Id_Text__c = itin.Booking_Header_18_Digit_ID__c; //added as a part of v1.2
                                          }
                                      }
    
    public static void onAfterUpdate(   List<Itinerary__c> oldItineraryList,
                                     List<Itinerary__c> newItineraryList, 
                                     Map<Id,Itinerary__c> oldItineraryMap,
                                     Map<Id,Itinerary__c> newItineraryMap){
        
        //v1.4
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
        
            instantiateListsAndSets();
        for(Itinerary__c itin: newItineraryList){
            populateBookingSets(itin, null);
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);
        system.debug('### Itin OnAfterUpdate :'+lBookingHeadersToUpdateHN);                                
        rollUpHotelNameToBookingHeader(sBookingHeaderIds);  //added as a part of v1.1    
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerHandler lBookingToUpdate afterupdate: ' + lBookingToUpdate);
        update lBookingToUpdate;
        lBookingToUpdate.clear();
    }
    
    //added as a part of v1.1
 /**************************************************************************************************
* Version			 : v1.1
* Name               : rollUpHotelNameToBookingHeader 
* Description        : Rolls up hotel name to booking header from itinerary
* Params             : String
* Return             : List<Case>
**************************************************************************************************/
    public static void rollUpHotelNameToBookingHeader(Set<Id> sBookingHeaderIds)
    {
        //v1.4
        if(AsyncDerwentWebService.isFromDerwentCall == false)
            return;
            
        if(sBookingHeaderIds.size()>0){
            System.debug('### ItinTrigger Entering rollUpHotelNameToBookingHeader with sBookingIds: ' + sBookingHeaderIds);
            List<String> lBookingHeaderIdsToQuery =  new List<String>();
            for(Id bookingHeadId:sBookingHeaderIds){
            	lBookingHeaderIdsToQuery.add(String.valueOf(bookingHeadId));
            }
            system.debug('@@@'+lBookingHeaderIdsToQuery);
           
            try{
                List<Itinerary__c> ItinList = [SELECT Org_Booking_Header_Id_Text__c,Org_Hotel_Name__c,No_of_days__c
                                                FROM Itinerary__c
                                                WHERE Type__c = 'Accommodation' AND Org_Booking_Header_Id_Text__c  IN: lBookingHeaderIdsToQuery
                                                AND Org_Booking_Header_Id_Text__c != NULL ORDER BY No_of_days__c ASC]; 
                system.debug('hotelName'+ItinList);
                List<Itinerary__c> templist = new List<Itinerary__c>();
                if(ItinList.size()>0){ //v1.3
                    templist = ItinList;
                    System.debug('@@fl'+templist);
                    Integer max;
                    String hotelname;
                    Booking__c bookheader = new Booking__c();    
                    for(Itinerary__c arg : ItinList){
                        System.debug('### rollHotelNameToBookingHeader with ar : ' + arg); 
                        //commented as a part of v1.2
                        // String sBookingHeaderId15Char = String.valueOf(arg.get('Org_Booking_Header_Id_Text__c')).left(15); 
                        // system.debug('ID15 :'+sBookingHeaderId15Char);
                        
                        bookheader.Id = arg.Org_Booking_Header_Id_Text__c;//sBookingHeaderId15Char;
                        max = (Integer)templist[0].No_of_days__c;
                        system.debug('maxDays'+Integer.valueof(templist[0].No_of_days__c));
                        for(Integer i = 0 ;i <ItinList.size();i++)
                        {
                            system.debug('Start');
                            if((max <= templist[i].No_of_days__c))
                            {
                                system.debug('Entered');
                                if (!templist.isEmpty()) {
                                    system.debug('Calculating');
                                    max = (Integer)templist[i].No_of_days__c;
                                    hotelname = templist[i].Org_Hotel_name__c;
                                    system.debug('@@@@'+templist[i].Org_Hotel_name__c);
                                    system.debug('@@@@'+max);
                                }
                            }
                        }
                        
                        bookheader.Hotel_Name__c = hotelname;
                        lBookingHeadersToUpdateHN.add(bookheader);
                        mBookingIdWithTotalCostCurrency.putall(lBookingHeadersToUpdateHN);   
                        system.debug('Hotel Name'+ bookheader.Hotel_Name__c);
                        system.debug('mBookingIdWithTotalCostCurrency'+mBookingIdWithTotalCostCurrency);
                        system.debug('bh@'+bookheader);
                        
                        
                        
                    }
                    System.debug('###@@@ AfterUpdate lBookingHeadersToUpdateHN: ' + bookheader);
                    update bookheader;
                    System.debug('### Exiting rollHotelNameToBookingHeader with lBookingHeadersToUpdateHN : ' + bookheader);
                    lBookingHeadersToUpdateHN.clear();
                }
            }catch(Exception e){
                System.debug('### EXCEPTIOn'+e+'rollHotelNameToBookingHeader with lBookingHeadersToUpdateHN : ' + lBookingHeadersToUpdateHN);
                
            }
            
        }
    }
    
    // end of v1.1 
    public static void onAfterDelete(   List<Itinerary__c> oldItineraryList,
                                     Map<Id,Itinerary__c> oldItineraryMap){
        
        //v1.4
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
        
            instantiateListsAndSets();
        for(Itinerary__c itin: oldItineraryList){
            populateBookingSets(itin, null);
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerHandler lBookingToUpdate afterdelete: ' + lBookingToUpdate);
        update lBookingToUpdate;
        lBookingToUpdate.clear();
    }
    
    public static void populateBookingSets(Itinerary__c newItinerary, Itinerary__c oldItinerary){
        if(newItinerary.Org_Booking_Header_Id_Text__c != null){
            //commented as a part of v1.2
           // String s15CharId = String.valueOf(newItinerary.Org_Booking_Header_Id_Text__c).left(15);
            sBookingHeaderIds.add(newItinerary.Org_Booking_Header_Id_Text__c);
        }
        
        //If there is no header, then it is not an item
        if(newItinerary.Org_Booking__c != null && newItinerary.Org_Booking_Header_Id_Text__c != null){
            //commented as a part of v1.2
            //String s15CharId = String.valueOf(newItinerary.Org_Booking__c).left(15); 
            sBookingIds.add(newItinerary.Org_Booking__c);        
        }
    }
    // Variable instantiating 
    private static void instantiateListsAndSets(){
        setBookings = new Set<Booking__c>();
        sBookingIds = new Set<Id>();
        lBookingToUpdate = new List<Booking__c>();
        lBookingHeadersToUpdateHN = new List<Booking__c>();
        mBookingIdWithTotalCostCurrency = new Map<Id, Booking__c>();
        sBookingHeaderIds = new Set<Id>();
    }
}