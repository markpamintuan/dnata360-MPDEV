/**************************************************************************************************
* Name               : BookingAPIEndpoints 
* Description        : This is the endpoint class to get salesforce Id when a derwent Id is passed    
* Created Date       : 21-Aug-2019                                                                 
* Created By         : Sri Bala                                                       
* ----------------------------------------------------------------------------------------------- 
* 
**************************************************************************************************/
@RestResource(urlMapping='/bookings/*')
global class BookingAPIEndpoints {
     @HttpGet
    global static WebsiteDataStructure.BookingIdSalesforce getSalesforceBookingId() {
       	RestRequest request = RestContext.request;
        WebsiteDataStructure.BookingIdSalesforce lBookingIds ;
        // grab the bookingId from the end of the URL
        String bookingId = request.params.get('booking-id');
        System.debug('BookingId =' + bookingId);
        List<Booking__c> BookingIds = new List<Booking__c>();
        if(bookingId != null)
        	 BookingIds = [select id from Booking__c where Org_Brand__c=:'trp' and Booking_ID__c = :bookingId];
        if(BookingIds.size() >	0 ){
            for(Booking__c book:BookingIds){
                lBookingIds = new WebsiteDataStructure.BookingIdSalesforce(String.valueof(book.Id));
            }
        }
        else
			lBookingIds = new WebsiteDataStructure.BookingIdSalesforce('null');            
        return lBookingIds;
    }

}