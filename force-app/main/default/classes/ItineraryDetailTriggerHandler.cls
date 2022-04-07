/**************************************************************************************************
* Name               : ItineraryDetailTriggerHandler 
* Description        : This is a handler for itineraryDetail Trigger       
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Kaavya                                                     
* ----------------------------------------------------------------------------------------------- 
* v1.0       Kaavya		08-Aug-2018 	Intial Draft
* v1.1       Sri Bala	24-Jul-2019     Mix and Match (TRP)
* v1.2		 Ravi       05-Feb-2020     Added the logic for Code optimazation
*****************************************************************************************************/
public class ItineraryDetailTriggerHandler{
    static Set<Id> sBookingIds;
    static Set<Id> sBookingHeaderIds;  
    static List<Booking__c> lBookingToUpdate;
    static Set<Booking__c> setBookings;
	static List<Id> itinListforMixMatch;
    public static void onBeforeInsert(List<Itinerary_Detail__c> newItinDetailList){
        for(Itinerary_Detail__c itinDetail: newItinDetailList){ 
            itinDetail.Org_Booking_Header_Id__c = itinDetail.Org_Booking_Header_Id_Formula__c;
            itinDetail.Org_Booking_Id__c = itinDetail.Org_Booking_Id_Formula__c;
               
        }
    }


    public static void onAfterInsert(List<Itinerary_Detail__c> newItinDetailList){        
        //v1.2
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
        instantiateListsAndSets();
        for(Itinerary_Detail__c itinDetail: newItinDetailList){
            populateBookingSets(itinDetail, null);
        	populateItineraryIdforMixMatch(itinDetail);//v1.1
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerDETAILHandler lBookingToUpdate afterInsert: ' + lBookingToUpdate);
        update lBookingToUpdate;
        lBookingToUpdate.clear();
        system.debug('Brand @@@@@'+newItinDetailList[0].Brand__c);
        system.debug('Itin detail List '+newItinDetailList[0]);
        if(newItinDetailList[0].Brand__c == 'trp')
        	getMixMatchAirportName(null,newItinDetailList); // Added as a part of v1.1
    }

    public static void onBeforeUpdate(  List<Itinerary_Detail__c> oldItinDetailList,
                                        List<Itinerary_Detail__c> newItinDetailList, 
                                        Map<Id,Itinerary_Detail__c> oldItinDetailMap,
                                        Map<Id,Itinerary_Detail__c> newItinDetailMap){
        
        for(Itinerary_Detail__c itinDetail: newItinDetailList){ 
            itinDetail.Org_Booking_Header_Id__c = itinDetail.Org_Booking_Header_Id_Formula__c;
            itinDetail.Org_Booking_Id__c = itinDetail.Org_Booking_Id_Formula__c;
        }
    }

    public static void onAfterUpdate(   List<Itinerary_Detail__c> oldItinDetailList,
                                        List<Itinerary_Detail__c> newItinDetailList, 
                                        Map<Id,Itinerary_Detail__c> oldItinDetailMap,
                                        Map<Id,Itinerary_Detail__c> newItinDetailMap){
        //v1.2
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
            
        instantiateListsAndSets();
        for(Itinerary_Detail__c itinDetail: newItinDetailList){
            populateBookingSets(itinDetail, null);
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerDETAILHandler lBookingToUpdate afterupdate: ' + lBookingToUpdate);
        update lBookingToUpdate;
        lBookingToUpdate.clear();
        if(newItinDetailList[0].Brand__c == 'trp')                                    
       		 getMixMatchAirportName(null,newItinDetailList);//v1.1
    }

    public static void onAfterDelete(   List<Itinerary_Detail__c> oldItinDetailList,
                                        Map<Id,Itinerary_Detail__c> oldItinDetailMap){
        //v1.2
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;
        instantiateListsAndSets();
        for(Itinerary_Detail__c itinDetail: oldItinDetailList){
            populateBookingSets(itinDetail, null);
        }
        setBookings = BookingMaxMinDatesHelper.createListOfBookings(sBookingHeaderIds, sBookingIds);
        lBookingToUpdate.addAll(setBookings);
        system.debug('### ItinTriggerDETAILHandler lBookingToUpdate afterdelete: ' + lBookingToUpdate);
        update lBookingToUpdate;
        lBookingToUpdate.clear();
    }



/**************************************************************************************************
* Version			 : v1.1
* Name               : populateItineraryIdforMixMatch 
* Description        : populate Itinerary Id and adds it to list 
* Params             : Itinerary_Detail__c
* Return             : 
**************************************************************************************************/
    public static void populateItineraryIdforMixMatch(Itinerary_Detail__c newItineraryDetail){
        system.debug('Itin Detail Brand '+newItineraryDetail.Brand__c);
        system.debug('newItineraryDetail.Itinerary__r.Org_Booking__c'+newItineraryDetail.Org_Booking_Id__c);
        system.debug('newItineraryDetail.Itinerary__r.Brand__c'+newItineraryDetail.Itinerary__r.Brand__c);
        if(newItineraryDetail.Brand__c == 'trp' && newItineraryDetail.Itinerary__c != null && newItineraryDetail.Org_Booking_Id__c != null){
           system.debug('newItineraryDetail.Itinerary__r.Org_Booking__c'+newItineraryDetail.Org_Booking_Id__c);
           itinListforMixMatch.add(newItineraryDetail.Org_Booking_Id__c);
           system.debug('List of Ids'+itinListforMixMatch);
        }
    }
    //end
    public static void populateBookingSets( Itinerary_Detail__c newItineraryDetail, 
                                            Itinerary_Detail__c oldItineraryDetail){

        if(newItineraryDetail.Org_Booking_Header_Id__c != null){
           // String s15CharId = String.valueOf(newItineraryDetail.Org_Booking_Header_Id__c).left(15);
            sBookingHeaderIds.add(newItineraryDetail.Org_Booking_Header_Id__c);
        }

        //Only items with a header should be added to the items list
        if(newItineraryDetail.Org_Booking_Id__c != null && newItineraryDetail.Org_Booking_Header_Id__c != null){
            //String s15CharId = String.valueOf().left(15); 
            sBookingIds.add(newItineraryDetail.Org_Booking_Id__c);        
        }
    }
/**************************************************************************************************
* Name               : getMixMatchAirportName 
* Description        : Mix and MAtch logic for TRP
* Params             : List<Itinerary_Detail__c>,List<Itinerary_Detail__c> 
* Return             : -
**************************************************************************************************/
    //added as a part of v1.1
    public static void getMixMatchAirportName(List<Itinerary_Detail__c> oldItineraryDetail,List<Itinerary_Detail__c> newItinDetailList){
    	try{
				List<Itinerary_Detail__c> itindetail = new List<Itinerary_Detail__c>();
            	List<Itinerary__c> itinList = new List<Itinerary__c>();
				Map<Id,Itinerary_Detail__c> itindetailInboundMap = new Map<Id,Itinerary_Detail__c>();
				Map<Id,Itinerary_Detail__c> itindetailOutboundMap = new Map<Id,Itinerary_Detail__c>();
            	itinList = [Select Id,Org_Booking__c from Itinerary__c where Org_Booking__c IN : itinListforMixMatch];
            	system.debug('List of itin'+itinList);
				itindetail = [Select Id,Itinerary__c,Itinerary__r.Type__c,Itinerary__r.Org_Booking__c,Itinerary_Detail_Type__c,Org_Marketing_Carrier__c 
								from Itinerary_Detail__c where Itinerary__r.Org_Booking__c IN:itinListforMixMatch and Itinerary_Detail_Type__c = 'Segment'];
				system.debug('List of itindetails'+itindetail);
				for(Itinerary_Detail__c itin : itindetail){
					system.debug('itin *(****)'+itin);
					if(itin.Itinerary__r.Type__c == 'Flight Inbound')
						itindetailInboundMap.put(itin.Itinerary__c,itin);
					else if (itin.Itinerary__r.Type__c == 'Flight Outbound')
						itindetailOutboundMap.put(itin.Itinerary__c,itin);
				}
				system.debug('inbound map'+itindetailInboundMap);
				system.debug('outbound map'+itindetailOutboundMap);
				
				List<Itinerary_Detail__c> inboundItindetailList = new List<Itinerary_Detail__c>();
				List<Itinerary_Detail__c> outboundItindetailList = new List<Itinerary_Detail__c>();
				if(itindetailInboundMap.values().size() > 0){
					
						inboundItindetailList = [Select Id,Arrival_Airport__c,Org_Arrival_Airport__c,Org_Arrival_Date__c,Itinerary__c,Org_Departure_Date__c, 
													Org_Marketing_Carrier__c,Itinerary__r.Org_Booking__c from Itinerary_Detail__c where Itinerary__c IN :itindetailInboundMap.keySet() order by CreatedDate DESC ];
						system.debug('list of itin details '+inboundItindetailList);
						Integer size = inboundItindetailList.size();
						system.debug('first of itin details '+inboundItindetailList[size-1]);
						system.debug('Size of itin details'+size);
						system.debug('last of itin details '+inboundItindetailList[0]);
						

    		
    	}
    	
    	if(itindetailOutboundMap.values().size() > 0){
    			outboundItindetailList = [Select Id,Arrival_Airport__c,Org_Arrival_Airport__c,Org_Arrival_Date__c,Itinerary__c,Org_Departure_Date__c,Departure_Airport__c 
    										,Org_Marketing_Carrier__c,Itinerary__r.Org_Booking__c from Itinerary_Detail__c where Itinerary__c IN :itindetailOutboundMap.keySet() order by CreatedDate ASC ];
    			system.debug('list of itin details '+outboundItindetailList);
    			system.debug('first of itin details '+outboundItindetailList[0]);
    			Integer size = outboundItindetailList.size();
    			system.debug('Size of itin details'+size);
    			system.debug('last of itin details '+outboundItindetailList[size-1]);
    			    		
    	}
    	
    	if(outboundItindetailList.size()>0)
    		system.debug('First Outbound Departure Airport '+outboundItindetailList[0].Departure_Airport__c);
    	if(inboundItindetailList.size()>0)
    		system.debug('Last Inbound Arrival Airport '+inboundItindetailList[0].Arrival_Airport__c);
            if(outboundItindetailList.size()>0 && inboundItindetailList.size()>0){	
                if(outboundItindetailList[0].Departure_Airport__c != inboundItindetailList[0].Arrival_Airport__c){
                    system.debug('YAAAAAYYYY ********************* MIX AND MATCH');
                    Booking__c book = [Select Id,Mix_Match__c from Booking__c where Id=:outboundItindetailList[0].Itinerary__r.Org_Booking__c];
                    book.Mix_Match__c = true;
                    update book;
                    system.debug('MIX AND MATCH SUCCESSFULL'+book);
                }
                else if(outboundItindetailList[0].Org_Marketing_Carrier__c != inboundItindetailList[0].Org_Marketing_Carrier__c){
                    system.debug('MIX AND MATCH CARRIER');
                    Booking__c book = [Select Id,Mix_Match__c from Booking__c where Id=:outboundItindetailList[0].Itinerary__r.Org_Booking__c];
                    book.Mix_Match__c = true;
                    update book;
                    
                }
            }
            else {
                Booking__c book = [Select Id,Mix_Match__c from Booking__c where Id IN:itinListforMixMatch];
                book.Mix_Match__c = false;
                update book;
                system.debug('NOT A Mix and Match');
            }
    	}
    	catch(Exception e){
    		System.debug('Exception'+e + 'Line Number'+e.getLineNumber());
    	}
    	
    }
    private static void instantiateListsAndSets(){
        setBookings = new Set<Booking__c>();
        sBookingIds = new Set<Id>();
        lBookingToUpdate = new List<Booking__c>();
        sBookingHeaderIds = new Set<Id>();
        itinListforMixMatch =new List<Id>(); //v1.1
    }
}