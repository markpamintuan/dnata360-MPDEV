public class BookingIdResponse {
     	public cls_Bookings[] Bookings;
    	public class cls_Bookings{
	    	public String BookingId{get;set;}
	    	public Decimal Version{get;set;}
    	}
    	public String NextPageId{get;set;}
    	public static BookingIdResponse parse(String json){
        return (BookingIdResponse) System.JSON.deserialize(json, BookingIdResponse.class);
    }
}