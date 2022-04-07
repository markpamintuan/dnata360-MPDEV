public class BookingMaxMinDatesHelper {
	static Map<Id,Date> mBookingHeaderIdWithMinStartDate;
	static Map<Id,Date> mBookingHeaderIdWithMaxEndDate; 

	static Map<Id,Date> mBookingItemsIdWithMinStartDate; 
	static Map<Id,Date> mBookingItemsIdWithMaxEndDate;

    static Set<Booking__c> setBookings;
	static List<Booking__c> lBookings;

	public static Set<Booking__c> createListOfBookings(Set<Id> sBookingHeaderIds, Set<Id> sBookingIds){
		lBookings = new List<Booking__c>();
        setBookings = new Set<Booking__c>();
        mBookingHeaderIdWithMinStartDate = new Map<Id,Date>();
        mBookingHeaderIdWithMaxEndDate = new Map<Id,Date>();

        mBookingItemsIdWithMinStartDate = new Map<Id,Date>();
        mBookingItemsIdWithMaxEndDate = new Map<Id,Date>();

        determineMaxMinBookingHeadersWithItinerary(sBookingHeaderIds);
		determineMaxMinBookingItemWithItinerary(sBookingIds);

		determineMaxMinBookingHeaderItemWithItineraryDetail(sBookingHeaderIds);
		determineMaxMinBookingItemWithItineraryDetail(sBookingIds);        
		
        if(mBookingHeaderIdWithMinStartDate.size()>0 && mBookingHeaderIdWithMaxEndDate.size()>0){
        	createBookingsWithStartEndDate(mBookingHeaderIdWithMinStartDate, mBookingHeaderIdWithMaxEndDate);
            mBookingHeaderIdWithMinStartDate.clear();
            mBookingHeaderIdWithMaxEndDate.clear();
        }
        
        if(mBookingItemsIdWithMinStartDate.size()>0 && mBookingItemsIdWithMaxEndDate.size()>0){
        	createBookingsWithStartEndDate(mBookingItemsIdWithMinStartDate, mBookingItemsIdWithMaxEndDate);
            mBookingItemsIdWithMinStartDate.clear();
            mBookingItemsIdWithMaxEndDate.clear();
        }
		
		
		system.debug('#### createListOfBookings lBookings: ' + setBookings);
        return setBookings;

	}

	public static void createBookingsWithStartEndDate(	Map<Id,Date> mBookingRecordWithMinStartDate, 
														Map<Id,Date> mBookingRecordWithMaxEndDate){ 
		
		for(String bookingId: mBookingRecordWithMinStartDate.keySet()){
            system.debug('#### createBookingsWithStartEndDate bookingId: ' + bookingId);
			Booking__c book = new Booking__c();
			book.Id = bookingId;
			book.Org_Travel_Start_Date__c = mBookingRecordWithMinStartDate.get(bookingId);
			book.Org_Travel_End_Date__c = mBookingRecordWithMaxEndDate.get(bookingId);
			setBookings.add(book);
		}

	}

	public static void determineMaxMinBookingHeadersWithItinerary(Set<Id> sBookingHeaderIds){
        if(sBookingHeaderIds.size()>0){
            List<String> lBookingHeaderIdsToQuery =  new List<String>();
            for(Id bookingheaderId:sBookingHeaderIds){
          	  lBookingHeaderIdsToQuery.add(String.valueOf(bookingheaderId));
            }
            try{
                if(lBookingHeaderIdsToQuery.size()>0){
                    system.debug('#### determineMaxMinBookingHeadersWithItinerary lBookingHeaderIdsToQuery: ' + lBookingHeaderIdsToQuery);

                    AggregateResult[] bookingHeaders = [SELECT Org_Booking_Header_Id_Text__c, 
                                            MIN(Org_Check_In__c), 
                                            MAX(Org_Check_Out__c)
                                    FROM Itinerary__c
                                    WHERE Org_Booking_Header_Id_Text__c IN: lBookingHeaderIdsToQuery
                                    AND (NOT Type__c LIKE '%light%')
                                    GROUP BY Org_Booking_Header_Id_Text__c];  

                    for(AggregateResult ar : bookingHeaders){
                        system.debug('#### determineMaxMinBookingHeadersWithItinerary ar: ' + ar);

                        String sBookingHeaderId15Char = String.valueOf(ar.get('Org_Booking_Header_Id_Text__c')).left(15);

                        DateTime checkInDate = DateTime.valueOf(ar.get('expr0'));
                        Integer offsetCheckInDate = UserInfo.getTimezone().getOffset(checkInDate);
                        Date checkInDateLocale = Date.valueOf(checkInDate.addSeconds(offsetCheckInDate/1000));

                        DateTime checkOutDate = DateTime.valueOf(ar.get('expr1'));
                        Integer offsetCheckOutDate = UserInfo.getTimezone().getOffset(checkOutDate);
                        Date checkOutDateLocale = Date.valueOf(checkOutDate.addSeconds(offsetCheckOutDate/1000));

                        compareMinStartDate(mBookingHeaderIdWithMinStartDate, checkInDateLocale, sBookingHeaderId15Char);
                        compareMaxEndDate(mBookingHeaderIdWithMaxEndDate, checkOutDateLocale, sBookingHeaderId15Char);
                        system.debug('#### determineMaxMinBookingHeadersWithItinerary mBookingHeaderIdWithMinStartDate: ' + mBookingHeaderIdWithMinStartDate);
                        system.debug('#### determineMaxMinBookingHeadersWithItinerary mBookingHeaderIdWithMaxEndDate: ' + mBookingHeaderIdWithMaxEndDate);
                    }  
                }

            }catch(Exception e){

            }
        }
    }

    public static void determineMaxMinBookingItemWithItinerary(Set<Id> sBookingIds){       
        
        if(sBookingIds.size()>0){
           // List<String> lBookingItemsToQuery =  new List<String>();
            //lBookingItemsToQuery.addAll(sBookingIds);
            try{
                    AggregateResult[] bookedItems = [SELECT Org_Booking__c, 
                                                                MIN(Org_Check_In__c), 
                                                                MAX(Org_Check_Out__c)
                                                        FROM Itinerary__c
                                                        WHERE Org_Booking__c IN: sBookingIds
                                                        AND (NOT Type__c LIKE '%light%')
                                                        GROUP BY Org_Booking__c];  

                    for(AggregateResult ar : bookedItems){

                        system.debug('#### determineMaxMinBookingItemWithItinerary ar: ' + ar);
                        String sBookingitemId15Char = String.valueOf(ar.get('Org_Booking__c')).left(15); 

                        DateTime checkInDate = DateTime.valueOf(ar.get('expr0'));
                        Integer offsetCheckInDate = UserInfo.getTimezone().getOffset(checkInDate);
                        Date checkInDateLocale = Date.valueOf(checkInDate.addSeconds(offsetCheckInDate/1000));

                        DateTime checkOutDate = DateTime.valueOf(ar.get('expr1'));
                        Integer offsetCheckOutDate = UserInfo.getTimezone().getOffset(checkOutDate);
                        Date checkOutDateLocale = Date.valueOf(checkOutDate.addSeconds(offsetCheckOutDate/1000));

                        compareMinStartDate(mBookingItemsIdWithMinStartDate, checkInDateLocale, sBookingitemId15Char);
                        compareMaxEndDate(mBookingItemsIdWithMaxEndDate, checkOutDateLocale, sBookingitemId15Char);    
                        system.debug('#### determineMaxMinBookingItemWithItinerary mBookingItemsIdWithMinStartDate: ' + mBookingItemsIdWithMinStartDate);
                        system.debug('#### determineMaxMinBookingItemWithItinerary mBookingItemsIdWithMaxEndDate: ' + mBookingItemsIdWithMaxEndDate);
                    }
                
            }catch(Exception e){

            }
        }

	}

	public static void determineMaxMinBookingItemWithItineraryDetail(Set<Id> sBookingIds){       
        
        if(sBookingIds.size()>0){
            //List<String> lBookingItemsToQuery =  new List<String>();
            //lBookingItemsToQuery.addAll(sBookingIds);
            try{
    				AggregateResult[] bookedItems = [SELECT Org_Booking_Id__c, 
                                                                MIN(Org_Departure_Date__c), 
                                                                MAX(Org_Arrival_Date__c)

                                                        FROM Itinerary_Detail__c
                                                        WHERE Org_Booking_Id__c IN: sBookingIds
                                                        AND Itinerary_Detail_Type__c = 'Segment'
                                                        //AND Org_Booking_Id__c != NULL
                                                        GROUP BY Org_Booking_Id__c];  

                    for(AggregateResult ar : bookedItems){
                        system.debug('#### determineMaxMinBookingItemWithItineraryDetail ar: ' + ar);

                        String sBookingitemId15Char = String.valueOf(ar.get('Org_Booking_Id__c')).left(15); 

                        DateTime departureDate = DateTime.valueOf(ar.get('expr0'));
                        Integer offsetDepartureDate = UserInfo.getTimezone().getOffset(departureDate);
                        Date departureDateLocale = Date.valueOf(departureDate.addSeconds(offsetDepartureDate/1000));

                        DateTime arrivalDate = DateTime.valueOf(ar.get('expr1'));
                        Integer offsetArrivalDate = UserInfo.getTimezone().getOffset(arrivalDate);
                        Date arrivalDateLocale = Date.valueOf(arrivalDate.addSeconds(offsetArrivalDate/1000));

                        compareMinStartDate(mBookingItemsIdWithMinStartDate, departureDateLocale, sBookingitemId15Char);
                        compareMaxEndDate(mBookingItemsIdWithMaxEndDate, arrivalDateLocale, sBookingitemId15Char);   
                        system.debug('#### determineMaxMinBookingItemWithItineraryDetail mBookingItemsIdWithMinStartDate: ' + mBookingItemsIdWithMinStartDate);
                        system.debug('#### determineMaxMinBookingItemWithItineraryDetail mBookingItemsIdWithMaxEndDate: ' + mBookingItemsIdWithMaxEndDate);
                    }
            }catch(Exception e){

            }
        }
	}

	public static void determineMaxMinBookingHeaderItemWithItineraryDetail(Set<Id> sBookingHeaderIds){       
        
        if(sBookingHeaderIds.size()>0){
            List<String> lBookingHeaderItemsToQuery =  new List<String>();
            for(Id bookingHeaderId:sBookingHeaderIds ){
            	lBookingHeaderItemsToQuery.add(String.valueOf(bookingHeaderId));
            }
            try{
                if(lBookingHeaderItemsToQuery.size()>0){
                    system.debug('#### determineMaxMinBookingHeaderItemWithItineraryDetail lBookingItemsToQuery: ' + lBookingHeaderItemsToQuery);

    				AggregateResult[] bookedItems = [	SELECT Org_Booking_Header_Id__c, 
                                                                MIN(Org_Departure_Date__c), 
                                                                MAX(Org_Arrival_Date__c)

    	                                                FROM Itinerary_Detail__c
    	                                                WHERE Org_Booking_Header_Id__c IN: lBookingHeaderItemsToQuery
                                                        AND Itinerary_Detail_Type__c = 'Segment'
    	                                                //AND Org_Booking_Header_Id__c != NULL
    	                                                GROUP BY Org_Booking_Header_Id__c];  

                    for(AggregateResult ar : bookedItems){
                        system.debug('#### determineMaxMinBookingHeaderItemWithItineraryDetail ar: ' + ar);
                        String sBookingitemId15Char = String.valueOf(ar.get('Org_Booking_Header_Id__c')).left(15); 
                        
                        DateTime departureDate = DateTime.valueOf(ar.get('expr0'));
                        Integer offsetDepartureDate = UserInfo.getTimezone().getOffset(departureDate);
                        Date departureDateLocale = Date.valueOf(departureDate.addSeconds(offsetDepartureDate/1000));

                        DateTime arrivalDate = DateTime.valueOf(ar.get('expr1'));
                        Integer offsetArrivalDate = UserInfo.getTimezone().getOffset(arrivalDate);
                        Date arrivalDateLocale = Date.valueOf(arrivalDate.addSeconds(offsetArrivalDate/1000));

                        compareMinStartDate(mBookingHeaderIdWithMinStartDate, departureDateLocale, sBookingitemId15Char);
                        compareMaxEndDate(mBookingHeaderIdWithMaxEndDate, arrivalDateLocale, sBookingitemId15Char);  
                        system.debug('#### determineMaxMinBookingHeaderItemWithItineraryDetail mBookingHeaderIdWithMinStartDate: ' + mBookingHeaderIdWithMinStartDate);
                        system.debug('#### determineMaxMinBookingHeaderItemWithItineraryDetail mBookingHeaderIdWithMaxEndDate: ' + mBookingHeaderIdWithMaxEndDate);
                    }
                }
            }catch(Exception e){

            }
        }
	}



	public static void compareMinStartDate(Map<Id, Date> mBookingIdTravelStartDate, 
											Date minDateInQuery,
											String sBookingId){
        system.debug('#### Entering compareMinStartDate with mBookingIdTravelStartDate: ' + mBookingIdTravelStartDate);
        system.debug('#### Entering compareMinStartDate with minDateInQuery: ' + minDateInQuery);
        system.debug('#### Entering compareMinStartDate with sBookingId: ' + sBookingId);

		if(mBookingIdTravelStartDate.get(sBookingId) == null){
			mBookingIdTravelStartDate.put(sBookingId, minDateInQuery);
		}

		if(mBookingIdTravelStartDate.get(sBookingId) != null){
			if(minDateInQuery < mBookingIdTravelStartDate.get(sBookingId)){
				mBookingIdTravelStartDate.put(sBookingId, minDateInQuery);
			}
		}

	}

	public static void compareMaxEndDate(Map<Id, Date> mBookingIdTravelEndDate, 
											Date maxDateInQuery,
											String sBookingId){
        system.debug('#### Entering compareMinStartDate with mBookingIdTravelEndDate: ' + mBookingIdTravelEndDate);
        system.debug('#### Entering compareMinStartDate with maxDateInQuery: ' + maxDateInQuery);
        system.debug('#### Entering compareMinStartDate with sBookingId: ' + sBookingId);

		if(mBookingIdTravelEndDate.get(sBookingId) == null){
			mBookingIdTravelEndDate.put(sBookingId, maxDateInQuery);
		}

		if(mBookingIdTravelEndDate.get(sBookingId) != null){
			if(maxDateInQuery > mBookingIdTravelEndDate.get(sBookingId)){
				mBookingIdTravelEndDate.put(sBookingId, maxDateInQuery);
			}
		}

	}
}