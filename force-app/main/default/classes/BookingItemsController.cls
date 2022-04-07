public class BookingItemsController {
	@AuraEnabled
    public static List<Booking__c> getActiveBookingsWithLineItems(String recId){
       
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
	/*
        for(Booking__c book : [SELECT (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
								where Booking_Header__c = :recId
                                
                                ]){              
            lOpenBookingHeader.add(book);             
        }
*/
        
        for(Booking__c book : [SELECT ID,
                               		Org_Booking_Type__c,
                               		Org_Title__c,
                               		Name
                               FROM Booking__c
                               where Booking_Header__c = :recId]){
        	lOpenBookingHeader.add(book); 
            
        }
        system.debug('#### lOpenBookingHeader: ' + lOpenBookingHeader);
        return lOpenBookingHeader;
    }
}