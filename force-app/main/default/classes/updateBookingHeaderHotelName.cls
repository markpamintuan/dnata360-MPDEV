global class updateBookingHeaderHotelName implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Org_Booking_Header_Id_Formula__c,Org_Hotel_Name__c,Org_Check_In__c,No_of_days__c,Org_Booking__r.Booking_Header__r.Hotel_Name__c FROM Itinerary__c WHERE Org_Booking__r.Org_Brand__c = \'ekh\' AND Org_Hotel_Name__c != \'\' AND Org_Booking_Header_Id_Formula__c != \'\' AND Type__c = \'Accommodation\' AND Org_Booking__r.Booking_Header__r.Hotel_Name__c = \'\' ORDER BY No_of_days__c ASC, Org_Check_In__c ASC'
        );
    }
    global void execute(Database.BatchableContext bc, List<Itinerary__c> itinToUpdate){
        Map<String,List<Itinerary__c>> BookingHeaderMap = new Map<String,List<Itinerary__c>>();
        List<Booking__c> bookingToUpdate = new List<Booking__c>();
        for(Itinerary__c itn:itinToUpdate){
            if(BookingHeaderMap.containskey(itn.Org_Booking_Header_Id_Formula__c)){
                BookingHeaderMap.get(itn.Org_Booking_Header_Id_Formula__c).add(itn);
            } else {
                List<Itinerary__c> templst = new List<Itinerary__c>();
                templst.add(itn);
                BookingHeaderMap.put(itn.Org_Booking_Header_Id_Formula__c,templst);
            }
        }

        for(String bookingId:BookingHeaderMap.keyset()){
            Booking__c updateBook = new Booking__c();
            if(BookingHeaderMap.get(bookingId) != null && BookingHeaderMap.get(bookingId).size() > 0 && bookingToUpdate.size() < 9000){
                updateBook.id = bookingId;  
                updateBook.Hotel_Name__c = BookingHeaderMap.get(bookingId)[0].Org_Hotel_Name__c;
                bookingToUpdate.add(updateBook);
                system.debug('bookingToUpdate==>'+updateBook);
                 recordsProcessed = recordsProcessed + 1;
            }
        }
        update bookingToUpdate;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed!');
    }    
}