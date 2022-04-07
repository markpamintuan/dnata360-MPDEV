public class bookingUpdate
{

    @future

    public static void updateBooking(map<id,id> newBooking){
    List<booking__c> bokingList = new List<booking__c>();
    for(id bookIds:newBooking.keyset()){
    booking__c book = new booking__c(id=bookIds,Org_SF_Case_Reference__c = newBooking.get(bookIds));
    
    bokingList.add(book);
    }
    
    if(bokingList.size() > 0){
    AvoidRecursion.receiptBookingRun = false;
    update bokingList;
    }

   }
}