public class AccountAuraExtensionControllerHistory {
    
    static Date TIMENOW = Date.Today();
	//KR
    @AuraEnabled
    public static List<Booking__c> getActiveBookingsWithLineItems(String accId){
       
        List<Booking__c> lBookings = new List<Booking__c>();

        for(Booking__c book : [SELECT Product_Type__c, Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                    (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
                                WHERE Org_Account_Name__c =: accId 
                               	AND Booking_Status__c IN ('Active', 'Pending','Receipted')
                                AND RecordType.Name = 'Booking Header'
                                AND (Org_Travel_End_Date__c >=: TIMENOW OR Org_Booked_Date__c >=: TIMENOW)
                                ORDER BY Org_Travel_End_Date__c
                                 
                                DESC LIMIT 50000]){              
                  
                                     if(book.Booking_Header__c != null && book.Booking_Header__r.Org_Travel_End_Date__c != null &&  TIMENOW > Date.valueOf(book.Booking_Header__r.Org_Travel_End_Date__c)){
               lBookings.add(book);
           }
        }
        system.debug('#### lOpenBookingHeader: ' + lBookings);
        return lBookings;
    }
}