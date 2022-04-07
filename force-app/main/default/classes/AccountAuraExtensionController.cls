/**************************************************************************************************
* Name               : AccountAuraExtensionController 
* Description        : This is a controller used for lightning components        
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Anil Valluri                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Anil             08-Aug-2018    Initial version                                                  
* v1.1        Keith            25-Sep-2018    T-00222: SOQL improvement 
* v1.2        Kaavya           22-Oct-2018    T-00253,T-00254,T-00300 - Open Cases and Active Bookings component change   
* v1.3        Kaavya           16-Jan-2019    T-00383: Fix for bookings without dates     
* v1.4        Evendo           15-Feb-2020    Remove Pending Bookings for trp accounts
* v1.5        Mark             05-Nov-2020    Include 'Cancelled by Client' status for EKH Historical Bookings
* v1.6        Mark             05-Jan-2021    Include 'Hold - Awaiting Confirmation' status for EKH Active Bookings
**************************************************************************************************/
public class AccountAuraExtensionController {

    static Date TIMENOW = Date.Today();
    
/**************************************************************************************************
* Name               : getOpenCases 
* Description        : Returns list of all the open cases linked to the account
* Params             : String
* Return             : List<Case>
**************************************************************************************************/
    @AuraEnabled
    public static List<Case> getOpenCases(String accId){
        List<Case> openCases = new List<Case>();
        system.debug(' Account Id From Lightnig component******');
        system.debug(accId);
        system.debug(' Account Id From Lightnig component******');
        for(Case oCase : [Select Id, Subject, Status, Org_Case_Status__c,Org_Type__c, CaseNumber, OwnerId, Owner.Name, CreatedDate, Createdby.Name, Priority, 
                            Origin,Org_Source__c,Opened_Date__c,Org_Brand__c,Category__c,Org_Destination__c,Display_Text__c,Record_Type_Name__c,Case_Type__c //Added as part of v1.2
                            From Case Where AccountId = :accId AND Org_Case_Status__c != 'Closed' ORDER By CreatedDate DESC LIMIT 5]){ //as part of v1.2 //LIMIT 10]){ //T-00222
            openCases.add(oCase); 
        }
        return openCases;
    }
/**************************************************************************************************
* Name               : getActiveBookings 
* Description        : Returns list of  all active bookings linked to the account
* Params             : String,String
* Return             : List<Booking__c>
**************************************************************************************************/
    @AuraEnabled
    public static List<Booking__c> getActiveBookings(String recId,String recno){ //changed as part of v1.2 //(String accId){
        String accountid='';
        if(recId!=null){
            if(recId.startsWith('001')) //if the record is of Account
                accountid =recId;
            else if(recId.startsWith('500')){ //if the record is of Case
                Case caserec= [select id, accountid from Case where id =:recId and accountid !=null];
                if(caserec!=null)
                accountid =caserec.accountid;
            }
            system.debug('accountid'+accountid);
        }
        integer count = 50000;
        if(recno!='All')
        count=integer.valueof(recno);
        List<Booking__c> actBookings = new List<Booking__c>();
        if(accountid!=''){
                for(Booking__c book : [SELECT Product_Type__c,Org_Title__c, Booking_Header__r.Org_Travel_End_Date__c, Org_Travel_Start_Date__c, 
                                        Org_Travel_End_Date__c, Org_Date_To__c,Org_Date_From__c,Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c,
                                        Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,CreatedDate,Name,Opportunity__c,Owner.Name, 
                                        Destination__c,Departure_Date__c //Added as part of v1.2
                                        FROM Booking__c Where Org_Account_Name__c =: accountid AND RecordType.Name = 'Booking' 
                                    AND (Org_Travel_End_Date__c >=: TIMENOW OR Booking_Header__r.Org_Travel_End_Date__c>=: TIMENOW OR Org_Booked_Date__c >=: TIMENOW) // v1.3 checking with Booking header dates //Added as part of v1.2
                                    Order by Org_Booked_Date__c DESC LIMIT :count]){ //as part of v1.2 //50000]){
                
                //Order by Org_Travel_End_Date__c THIS WAS THE ORIGINAL QUERY
                system.debug('### book.Org_Travel_End_Date__c: ' + book.Org_Travel_End_Date__c);
                system.debug('### book.Org_Booked_Date__c: ' + book.Org_Booked_Date__c);
                
               
                actBookings.add(book);                
    
               
            }
        }
        system.debug(' getActiveBookings actBookings******: ' + actBookings);
        return actBookings;
    }
/**************************************************************************************************
* Name               : getActiveBookings 
* Description        : Returns list of all historic bookings linked to the account
* Params             : String
* Return             : List<Booking__c>
**************************************************************************************************/
    
    @AuraEnabled
    public static List<Booking__c> getHistoricalBookings(String accId){
        List<Booking__c> lBookings = new List<Booking__c>();
        for(Booking__c book : [SELECT Product_Type__c, Org_Travel_End_Date__c, Org_Title__c, Org_Travel_Start_Date__c,
                                Booking_Header__r.Org_Travel_End_Date__c, Org_Date_To__c,Org_Date_From__c,Org_Account_Name__c,Org_BookedById__c,
                                Org_BookedByName__c,Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,CreatedDate,Name,Opportunity__c,Owner.Name, 
                                Destination__c,Departure_Date__c //Added as part of v1.2
                                FROM Booking__c Where Org_Account_Name__c =: accId  AND RecordType.Name = 'Booking' AND Booking_Header__r.Org_Travel_End_Date__c <: TIMENOW // v1.3 checking with Booking header dates
                                Order by Org_Travel_End_Date__c  DESC LIMIT 50000]){

            

            system.debug('### getHistoricalBookings book.Org_Travel_End_Date__c: ' + book.Org_Travel_End_Date__c);
            system.debug('### getHistoricalBookings book.Org_Booked_Date__c: ' + book.Org_Booked_Date__c);

            if(book.Booking_Header__c != null && book.Booking_Header__r.Org_Travel_End_Date__c != null &&  TIMENOW > Date.valueOf(book.Booking_Header__r.Org_Travel_End_Date__c)){
                lBookings.add(book);
            }

           
        }
        system.debug(' getHistoricalBookings lBookings******: ' + lBookings);
        return lBookings;
    }
/**************************************************************************************************
* Name               : getActiveBookingsWithLineItems 
* Description        : Returns list of  all active bookings with booking items linked to the account
* Params             : String
* Return             : List<Booking__c>
**************************************************************************************************/
    //KR
    @AuraEnabled
    public static List<Booking__c> getActiveBookingsWithLineItems(String accId){
        
        String Brand = getBrand(accid); //v1.5 //[Select org_brand__c from account where id = :accid].org_brand__c;//v1.4
         
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();

        //v1.6
        set<String> bookingStatuses = new set<String>{'Active','Pending','Receipted'};
        if(brand == 'ekh'){
            bookingStatuses.add('Hold - Awaiting Confirmation');
        }

        if(brand == 'trp'){
            bookingStatuses.remove('Pending');
        }
        //End v1.6        

        if(Brand != 'trp'){
            for(Booking__c book : [SELECT Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                        Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                        Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                        Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,
                                        CreatedDate,Name,Opportunity__c,Owner.Name,
                                        Destination__c,Departure_Date__c, //Added as part of v1.2
                                        (SELECT Id, 
                                                Org_Booking_Type__c,
                                                Org_Title__c,
                                                Name
                                        FROM Bookings__r)
                                    FROM Booking__c 
                                    WHERE Org_Account_Name__c =: accId 
                                    AND Booking_Status__c IN: bookingStatuses
                                    AND RecordType.Name = 'Booking Header'
                                    AND (Org_Travel_End_Date__c >=: TIMENOW OR Org_Booked_Date__c >=: TIMENOW)
                                    ORDER BY Org_Travel_End_Date__c
                                    DESC LIMIT 50000]){              
                lOpenBookingHeader.add(book);             
            }
        }else{
            for(Booking__c book : [SELECT Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                        Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                        Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                        Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,
                                        CreatedDate,Name,Opportunity__c,Owner.Name,
                                        Destination__c,Departure_Date__c, //Added as part of v1.2
                                        (SELECT Id, 
                                                Org_Booking_Type__c,
                                                Org_Title__c,
                                                Name
                                        FROM Bookings__r)
                                    FROM Booking__c 
                                    WHERE Org_Account_Name__c =: accId 
                                    AND Booking_Status__c IN: bookingStatuses
                                    AND RecordType.Name = 'Booking Header'
                                    AND (Org_Travel_End_Date__c >=: TIMENOW OR Org_Booked_Date__c >=: TIMENOW)
                                    ORDER BY Org_Travel_End_Date__c   
                                    DESC LIMIT 50000]){              
                lOpenBookingHeader.add(book);  
        }
        }
        system.debug('#### lOpenBookingHeader: ' + lOpenBookingHeader);
        return lOpenBookingHeader;
    }
/**************************************************************************************************
* Name               : getActiveBookingsWithLineItems 
* Description        : Returns list of all historic bookings with booking items linked to the account
* Params             : String
* Return             : List<Booking__c>
**************************************************************************************************/
    //Added as part of v1.2
    @AuraEnabled
    public static List<Booking__c> getHistoricalBookingsWithLineItems(String accId){
       
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
        //v1.5
        String brand = getBrand(accId);
        set<String> bookingStatuses = new set<String>{'Active', 'Pending','Receipted'};

        if(brand == 'ekh'){
            bookingStatuses.add('Cancelled by Client');
        }
        //End v1.5

        for(Booking__c book : [SELECT Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                Destination__c,Departure_Date__c, //Added as part of v1.2
                                    (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
                                WHERE Org_Account_Name__c =: accId 
                                AND Booking_Status__c IN: bookingstatuses
                                AND RecordType.Name = 'Booking Header'
                                AND Org_Travel_End_Date__c <=: TIMENOW 
                                ORDER BY Org_Travel_End_Date__c
                                 
                                DESC LIMIT 50000]){              
            lOpenBookingHeader.add(book);             
        }
        system.debug('#### lOpenBookingHeader: ' + lOpenBookingHeader);
        return lOpenBookingHeader;
    }
    //v1.5
    static String getBrand(String accID){
        return [SELECT Org_Brand__c FROM Account WHERE Id = :accID].Org_Brand__c;
    }
    
}