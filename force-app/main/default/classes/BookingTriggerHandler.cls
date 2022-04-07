/**************************************************************************************************
* Name               : BookingTriggerHandler 
* Description        : This is the trigger handler class for Booking trigger           
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Paramasiva                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS                
* v1.0        Paramasiva      08-Aug-2018     Initial version
* v1.1        Kaavya          19-Sep-2018     Link case with booking irrespective of status                                                 
* v1.2        Kaavya          08-Nov-2018     Rehlaty - Disable autoclose and Update Total Cost AED on Booking Header   
* v1.3        Kaavya          11-Dec-2018     Update earliest booked date on Booking header 
* v1.4        Sri Bala        28-Feb-2018     Booking DFO Update Queuable class
* v1.5        Maruf           06-Mar-2018     Added code to get a valid datetime to send email 
* v1.6        Jed Canlas      23-Apr-2019     T-00522 - Agent Email Id on Bookings and Language  
* v1.7        Jed Canlas      5-May-2019      T-00558 - Destination on booking header
* v1.8        Mark            3-Jul-2019      T-00611 & T-00596 - Added method to populate office name and cluster on booking.
* v1.9        Merul           14-Jul-2019     Introduction of recurssion to fix SOQL issue.
* v1.10       Mark            28-Jul-2019     T-00613 - Added criteria when populating Org_Total_Cost_Client_Currency_Number__c field
* v1.11       Mark            14-Aug-2019     moved updateBookedBy to after insert to avoid conflict on rollUpCostsToBookingHeader
* v1.12       Merul           02-Sep-2019     rollupBookingHeader for Status,Booking System and Booked By rollup.
* v1.13       Mark            06-Oct-2019     T-00782 - fixed issue on rollup recomputation upon creation of child booking
* v1.15       Sri Bala        24-Oct-2019     Update v1.5 from Org_Travel_End_Date__c to Post_Travel_Survey_Responded_Date__c
* v1.16       Keith           28-Oct-2019     Changed record type to new EKH -  Enquiry instead of EKUK - New Enquiry. Part of ROW project.
* v1.18       Kaavya          10-Dec-2019     Fix for Booking Status
* v1.19       Mark            12-Dec-2019     T-00783 - updated logic to populate Cluster based on Store Number instead of store name
* v1.20       Ravi            05-Feb-2020     Added the logic for
                                                    1. to fix duplicate Id in list
                                                    2. Code optimazation
                                                    3. Replicate the logic of Proccess Builder ( EKH Replication & )
 *v1.21       Kaavya          29-Mar-2020    Fix for Rehlaty booking linking to case   
*************************************************************************************************/
public class BookingTriggerHandler {
    static List<Case> casesToUpdate;
    static Set<String> sBookingHeaderIds;
    static List<Booking__c> lBookingHeadersToUpdate;
    static list<Booking__c> lBookingHeadersToUpdateHN;
    static list<Booking__c> productTypeCount;
    static Map<Id, Booking__c> mBookingIdWithTotalCostCurrency; 
    static map<Id,String> mBookingIdHotelName;
    static map<string,string> caseBookingMap;
    static map<string,string> BookingStatusMap;
    
    //v1.20
    public static Boolean BlockBookingTrigger = false;
    public static map<Id, User> mapCurrentUser = new map<Id, User>();
    public static Boolean BlockBookingTriggerForBatch = false;
    
    public static void onBeforeInsert(List<Booking__c> newBookingList){      
        instantiateListsAndSets();
        //Map<Id,Booking__c> newMap = new Map<Id,Booking__c>(); //v1.11
        list<Booking__c> noClusterBookings = new list<Booking__c>();
        for(Booking__c bkg : newBookingList){
            //newMap.put(bkg.Id,bkg); //v1.11
            mapFormulaFields(bkg, null);
            //v1.8 - Start
            if(string.IsEmpty(bkg.Cluster__c) && bkg.Org_Brand__c == 'dnata'){
                noClusterBookings.add(bkg);
            }
            //v1.8 End
        }
        //updateBookedBy(newMap); //v1.11

        //v1.8 - Start
        if(noClusterBookings.size() > 0){
            populateStoreAndCluster(noClusterBookings);
        }
        //v1.8 - End

        //v1.20.3
        populateEKHReplication(newBookingList, null);

    }

    public static void onAfterInsert(List<Booking__c> newBookingList){     
        caseBookingMap  = new map<string,string>() ;
        
        instantiateListsAndSets();
        Map<Id,Booking__c> bookIdDFOList = new Map<Id,Booking__c>();
        
        Map<Id,Booking__c> newMap = new Map<Id,Booking__c>(); //v1.11
        set<String> setBookingHeaderIds = new set<String>(); //v1.13
        
        for(Booking__c bkg : newBookingList){
          
            //added as part of v1.4
           if(bkg.Org_External_System_ID__c != '' && bkg.Org_External_System_ID__c != null && bkg.Booking_System__c == 'DFO' &&  bkg.Org_Brand__c == 'dnata')
           {
                bookIdDFOList.put(bkg.id,bkg);  
           }
          //end of v1.4
         
            if(bkg.Org_SF_Case_Reference__c != null){
                string str = bkg.Org_SF_Case_Reference__c;
                str = str.removeEnd('\"').removeStart('\"');
                if(str != null){      //&& bkg.Booking_Status__c == 'Receipted'){ // Commented as part of v1.1
                caseBookingMap.put(str,bkg.id);
                
                //Added as part of v1.1
                if(bkg.Booking_Status__c!=null && bkg.Auto_close__c) //Autoclose added as part of v1.2
                    BookingStatusMap.put(bkg.id,bkg.Booking_Status__c); 
                }
            }
            
            newMap.put(bkg.Id,bkg); //v1.11 
        
        }
        //v1.4
        if(bookIdDFOList != null && bookIdDFOList.size() >0 )
        {
               Id jobID = System.enqueueJob(new BookingDFOUpdate(bookIdDFOList));
                system.debug('Id@@'+jobID);
        }
         //end of v1.4
        for(Booking__c bkg : newBookingList){
            createSetBookingHeaderIds(bkg, null);
            
        }

        setBookingHeaderIds = sBookingHeaderIds; //v1.13 - created a new set to contain sBookingHeaderIds initial content. sBookingHeaderIds becomes empty after rollupBookingHeader is called
        
        if(sBookingHeaderIds.size() > 0){   //v1.11 - Added checking
            //Merul: To fix the recurssion issue.
            if(AvoidRecursion.isRollUpBookingRun())
            {
                rollupBookingHeader(NULL,newBookingList,NULL,(Map<Id,Booking__c>)trigger.newMap);
                //createCasesToUpdate(caseBookingMap);// Commented as part of v1.1
                //createCasesToUpdate(caseBookingMap,BookingStatusMap); //Added as part of v1.1 //v1.11
                system.debug('@@@'+sBookingHeaderIds);
                rollUpCostsToBookingHeader(setBookingHeaderIds); //v1.13
                //updateCases(); //v1.11
                System.debug('### onAfterInsert lBookingHeadersToUpdate: ' + lBookingHeadersToUpdate);

                BlockBookingTrigger = true; //v1.20
                if(AsyncDerwentWebService.isFromDerwentCall == false)
                    update lBookingHeadersToUpdate;
                BlockBookingTrigger = false;
                
                updateBookedBy(JSON.serialize(newMap));//v1.11
            }
        }
        
        //v1.11
        createCasesToUpdate(caseBookingMap,BookingStatusMap); //Added as part of v1.1 //v1.11
        updateCases();         
        
    }

    public static void onBeforeUpdate(  List<Booking__c> oldBookingList,
                                        List<Booking__c> newBookingList, 
                                        Map<Id,Booking__c> oldBookingMap,
                                        Map<Id,Booking__c> newBookingMap){

        //v1.20
        if(BlockBookingTrigger) return;
                
        list<Booking__c> noClusterBookings = new list<Booking__c>();                                         
        
        for(Booking__c bkg : newBookingList){
            mapFormulaFields(bkg, null);
            //v1.8 - Start
            Booking__c oldBooking = oldBookingMap.get(bkg.Id);
            if(oldBooking.Office_Name__c != bkg.Office_Name__c || string.IsEmpty(bkg.Cluster__c)){//v1.19
                if(bkg.Org_Brand__c == 'dnata')
                    noClusterBookings.add(bkg);
            }
            //v1.8 - End           
        }
        
        //updateBookedBy(newBookingMap); //v1.11
        
                                           
        updateEkhTPSSendEmailDate(newBookingList); //Add in v1.5     
        instantiateListsAndSets();
        
        //v1.8 - Start
        if(noClusterBookings.size() > 0){
            populateStoreAndCluster(noClusterBookings);
        }
        //v1.8 - End      

        //v1.20.3
        populateEKHReplication(newBookingList, oldBookingMap);
    }

    public static void onAfterUpdate(   List<Booking__c> oldBookingList,
                                        List<Booking__c> newBookingList, 
                                        Map<Id,Booking__c> oldBookingMap,
                                        Map<Id,Booking__c> newBookingMap){
        //v1.20
        if(BlockBookingTrigger) return;
        
        caseBookingMap  = new map<string,string>();                                            
        instantiateListsAndSets();
        for(Booking__c bkg : newBookingList){
        
            if(bkg.Org_SF_Case_Reference__c != null){
                string str = bkg.Org_SF_Case_Reference__c;
                str = str.removeEnd('\"').removeStart('\"');
                if(str != null){         // && bkg.Booking_Status__c == 'Receipted') // Commented as part of v1.1
                    caseBookingMap.put(str,bkg.id);
                    system.debug('######BookingId####'+bkg.id);
                    system.debug('######Status####'+bkg.Booking_Status__c);
                    //Added as part of v1.1
                    if(bkg.Booking_Status__c != null && bkg.Booking_Status__c != '' && bkg.Auto_close__c) //Autoclose added as part of v1.2
                        BookingStatusMap.put(bkg.id,bkg.Booking_Status__c); 
                }
            }
            
        }
                                          
        for(Booking__c bkg : newBookingList){

            createSetBookingHeaderIds(bkg, null);
            //createCasesToUpdate(bkg, null); 
        }
        
        if(sBookingHeaderIds.size() > 0){ //v1.11 - Added checking
            //Merul: To fix the recurssion issue.
            if(AvoidRecursion.isRollUpBookingRun())
            {
                rollupBookingHeader(oldBookingList,newBookingList,oldBookingMap,newBookingMap);
                //createCasesToUpdate(caseBookingMap);// Commented as part of v1.1
                //createCasesToUpdate(caseBookingMap,BookingStatusMap); //Added as part of v1.1 //v1.11
                rollUpCostsToBookingHeader(sBookingHeaderIds);                                    
                //updateCases(); //v1.11
                System.debug('### onAfterUpdate lBookingHeadersToUpdate: ' + lBookingHeadersToUpdate);
                
                BlockBookingTrigger = true; //v1.20
                if(AsyncDerwentWebService.isFromDerwentCall == false)
                    update lBookingHeadersToUpdate;
                BlockBookingTrigger = false;

                updateBookedBy(JSON.serialize(newBookingMap)); //v1.11
            }
        }
        
        //v1.11
        createCasesToUpdate(caseBookingMap,BookingStatusMap);  //Added as part of v1.1                                
        updateCases();        
                                           
    }
    
    
    //Merul: rollupBookingHeader for Status,Booking System and Booked By rollup.
    /**************************************************************************************************
* Name               : rollupBookingHeader 
* Description        : for Status,Booking System and Booked By rollup.
* Params             : List<Booking__c>,List<Booking__c>,Map<Id,Booking__c>,Map<Id,Booking__c>
* Return             : -
**************************************************************************************************/
    public static void rollupBookingHeader( List<Booking__c> oldBookingList,
                                            List<Booking__c> newBookingList, 
                                            Map<Id,Booking__c> oldBookingMap,
                                            Map<Id,Booking__c> newBookingMap)
    {
        //Filters:processing only status change and it should be child.
        Set<Id> headerIdSet = new Set<Id>();
        Set<Id> headerIdStatusSet = new Set<Id>();
        Set<Id> headerIdBookSysSet = new Set<Id>();
        List<Booking__c> bookingHeaderToBeUpdate = new List<Booking__c>();
        
        //v1.20
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;

        for(Booking__c newBooking : newBookingList )
        {
            
            
            // On Isert or update.
            if(oldBookingMap == NULL || (oldBookingMap != NULL 
                       && newBooking.Booking_Status__c != oldBookingMap.get(newBooking.Id).Booking_Status__c ) )
            {
                if( newBooking.Booking_Header__c != NULL && newBooking.Org_Brand__c != 'ekh' )
                {
                   headerIdSet.add(newBooking.Booking_Header__c);
                   
                }
                  
            }
            
            //if Booking_System__c is changed.....T-00729
            if(oldBookingMap == NULL || (oldBookingMap != NULL 
                      && newBooking.Booking_System__c != oldBookingMap.get(newBooking.Id).Booking_System__c) )
           {
                if(newBooking.Booking_Header__c != NULL)
                {
                   headerIdSet.add(newBooking.Booking_Header__c);
                    
                }
                  
           }
            
            //if Org_BookedByName__c is changed....T-00727
           if(oldBookingMap == NULL || (oldBookingMap != NULL 
                   && newBooking.Org_BookedByName__c != oldBookingMap.get(newBooking.Id).Org_BookedByName__c ) )
           {
                if(newBooking.Booking_Header__c != NULL)
                {
                   headerIdSet.add(newBooking.Booking_Header__c);
                    
                }
           }
            
        }
            
            //Groupping HeaderID and all its related 
            Map<Id,List<Booking__c>> headerChildMap = new Map<Id,List<Booking__c>>();
            for(Booking__c childBooking : [SELECT id,
                                                  Booking_Header__c,
                                                  Booking_Status__c,
                                                  Booking_System__c,
                                                  Org_Brand__c,
                                                  CreatedDate,
                                                  Booked_By_Email__c,
                                                  Org_BookedById__c,
                                                  Org_BookedByName__c,
                                                  Org_Booked_Date__c 
                                             FROM Booking__c 
                                            WHERE Booking_Header__c IN:headerIdSet 
                                         ORDER BY CreatedDate ASC])
            {
                List<Booking__c> childBookingAll = ( headerChildMap.containsKey(childBooking.Booking_Header__c) ? headerChildMap.get(childBooking.Booking_Header__c) : new List<Booking__c>() );
                childBookingAll.add(childBooking);
                headerChildMap.put(childBooking.Booking_Header__c ,childBookingAll);
            }
            system.debug('$$$$$$ headerChildMap '+headerChildMap);
        
            for(String bookingHeader : headerChildMap.keySet())
            {
                    List<Booking__c> childBookingLst = headerChildMap.get(bookingHeader);
                    if( childBookingLst  != NULL && childBookingLst.size() > 0 )
                    {
                         //initliza Header....as per T-00727
                         Booking__c bookingHeaderObj = new Booking__c(id = bookingHeader,
                                                                      //Booking_Status__c = '',
                                                                      Booking_System__c = childBookingLst[0].Booking_System__c
                                                                     );
                        if (childBookingLst[0].Org_Brand__c != 'ekh') {                                        
                            bookingHeaderObj.Booking_Status__c = childBookingLst[0].Booking_Status__c; //Added as part of v1.18    
                        }                                                         
                                                                
                                                                
                        for(Booking__c childBooking : childBookingLst )
                        {
                            if(childBooking.Booking_Status__c == 'Receipted' && childBooking.Org_Brand__c != 'ekh')
                            {
                                   //bookingHeaderObj.Booking_Status__c = 'Receipted';
                                   if(bookingHeaderObj.Booking_Status__c != 'Receipted')
                                   {
                                       bookingHeaderObj.Booking_Status__c = 'Receipted';
                                   }
                                   
                            } 
                            
                            if( bookingHeaderObj.Booking_System__c != childBooking.Booking_System__c  )
                            {
                                bookingHeaderObj.Booking_System__c = 'Multiple Systems';
                            }
                            
                            system.debug('$$$$$$$$$$$ childBooking.Org_Brand__c '+childBooking.Org_Brand__c);
                            if( childBooking.Org_Brand__c != 'ekh' )
                            {
                                system.debug('$$$$$$$$$$$2 childBooking.Org_Brand__c '+childBooking.Org_Brand__c);
                                bookingHeaderObj.Booked_By_Email__c = childBookingLst[0].Booked_By_Email__c;
                                bookingHeaderObj.Org_BookedById__c = childBookingLst[0].Org_BookedById__c;
                                bookingHeaderObj.Org_BookedByName__c = childBookingLst[0].Org_BookedByName__c;
                                bookingHeaderObj.Org_Booked_Date__c = childBookingLst[0].Org_Booked_Date__c; 
                            }
                           
                        }
                        bookingHeaderToBeUpdate.add(bookingHeaderObj);                                       
                    }
                  
            }
            
            //updating header booking.
            //v1.20
            BlockBookingTrigger = true;
            update bookingHeaderToBeUpdate;
            BlockBookingTrigger = false;
    }
 /**************************************************************************************************
* Name               : createCasesToUpdate 
* Description        : links the booking to case and if the booking is receipted the case status and reason are updated
* Params             : map<string,string>,map<string,string>
* Return             : -
**************************************************************************************************/   
    private static void createCasesToUpdate(map<string,string> caseBookMap, map<string,string> BookStatusMap){
            list<id> recIds= new list<id>(); 
            List<case> csList = new List<case>();
           
            recIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId());
            recIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH - New Enquiry').getRecordTypeId()); //v1.15 
            
            if(caseBookMap.size() > 0){
                set<string> caseId = new set<string>();// = caseBookMap.keyset();
                for(string cId : caseBookMap.keyset()){
                    string bookId = caseBookMap.get(cId);
                    system.debug('bookId is : '+bookId);
                    system.debug('BookStatusMap.containsKey(bookId) is : '+BookStatusMap.get(bookId));
                    //if(BookStatusMap.containsKey(bookId)){ //commented as per v1.21
                        system.debug('cId is : '+cId);
                        caseId.add(cId);
                    //}
                }
                system.debug('caseId is : '+caseId);
                if(!caseId.isEmpty())
                    csList=[select id,Origin,Org_Current_Team_Name__c from case where id in:caseId and Org_Type__c ='Booking Enquiry' AND Org_Case_Status__c != 'Closed' ]; // commented as part of v1.2 //and recordtypeid in:recIds];
            }
            
            
            if(csList.size() > 0){
                for(case c:csList){
                    Case cs = new Case(Id = c.id);
                    cs.Org_Booking__c = caseBookingMap.get(c.id);
                    if(BookStatusMap!=null){
                        if(BookStatusMap.containsKey(caseBookingMap.get(c.id))){ //Added as part of v1.21
                            if(BookStatusMap.get(caseBookingMap.get(c.id)) == 'Receipted'){ //if condition added as part of v1.1
                                cs.Org_Case_Status__c = 'Closed';
                                cs.Reason = 'Closed Confirmed';
                                
                            }
                        }

                    }
                   casesToUpdate.add(cs);
                }
            }    
        
    }
/**************************************************************************************************
* Name               : createSetBookingHeaderIds 
* Description        : creates list of booking headers
* Params             : Booking__c,Booking__c
* Return             : -
**************************************************************************************************/
    private static void createSetBookingHeaderIds(Booking__c newBooking, Booking__c oldBooking){
        if(newBooking.Booking_Header__c != null){
            sBookingHeaderIds.add(newBooking.Booking_Header__c);
        }
    }
/**************************************************************************************************
* Name               : mapFormulaFields 
* Description        : updates Org_Total_Cost_Client_Currency_Number__c on Booking 
* Params             : Booking__c,Booking__c
* Return             : -
**************************************************************************************************/
    private static void mapFormulaFields(Booking__c newBooking, Booking__c oldBooking){
        if(newBooking.Booking_Header__c != null && newBooking.Org_Total_Cost_Client_Currency_Number__c == null) //v1.10
            newBooking.Org_Total_Cost_Client_Currency_Number__c = newBooking.Total_Cost_Client_Currency__c;            
        
    }
/**************************************************************************************************
* Name               : rollUpCostsToBookingHeader 
* Description        : Rolls up all the booking price field to Header
* Params             : Set<String>
* Return             : -
**************************************************************************************************/    
    public static void rollUpCostsToBookingHeader(Set<String> sBookingIds){ 
        System.debug('### Entering rollUpCostsToBookingHeader with sBookingIds: ' + sBookingIds);
        //v1.20
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;

        if(sBookingIds.size()>0){
            List<String> lBookingHeaderIdsToQuery =  new List<String>();
            lBookingHeaderIdsToQuery.addAll(sBookingIds);
            //Set<String> bookingHeaderId = new Set<String>();
            //Map<Id,Booking__c> bookingHeaderMap = new Map<Id,Booking__c>();
            
            try{
                AggregateResult[] bookingHeaders = [SELECT Booking_Header__c,                                                                                                               
                                                        SUM(Org_Total_Cost__c),                                                        
                                                        SUM(Org_Total_Cost_Client_Currency_Number__c),
                                                        SUM(Total_Cost_AED__c), //Added as part of v1.2
                                                        COUNT(Id), //Added as part of v1.2
                                                        MIN(Org_Booking_Type__c),//Added as part of v1.2
                                                        MIN(Org_Booked_Date__c)//Added as part of v1.3
                                                    FROM Booking__c
                                                    WHERE Booking_Header__c IN: lBookingHeaderIdsToQuery
                                                    AND Booking_Header__c != NULL
                                                    GROUP BY Booking_Header__c];  
                                                    
                                                    
                //for(AggregateResult ar : bookingHeaders){
                    //bookingHeaderId.add(ar.get('Booking_Header__c'));
                //}
                //if(bookingHeaderId.size()>0){
                   // bookingHeaderMap.putAll([select id,Booked_By_Email__c,Org_BookedById__c,Org_BookedByName__c,OwnerId from Booking__c where id IN:  bookingHeaderId]);
                //}                                    

                for(AggregateResult ar : bookingHeaders){
                    System.debug('### rollUpCostsToBookingHeader with ar : ' + ar);
                    String sBookingHeaderId15Char = String.valueOf(ar.get('Booking_Header__c')).left(15);   
                    Booking__c bookHeader = new Booking__c();                    
                    bookHeader.Id = sBookingHeaderId15Char;
                    if(ar.get('expr0')!=null)
                    bookHeader.Org_Total_Cost__c = (Decimal)ar.get('expr0');
                    if(ar.get('expr1')!=null)
                    bookHeader.Org_Total_Cost_Client_Currency_Number__c = (Decimal)ar.get('expr1');
                    //Added as part of v1.2
                    if(ar.get('expr2')!=null)
                    bookHeader.Total_Cost_AED__c = (Decimal)ar.get('expr2');                     
                    if((Decimal)ar.get('expr3')>1)
                        //bookHeader.Product_Type__c = 'Bundle';
                        bookHeader.Product_Type__c = 'Package';
                    else
                        bookHeader.Product_Type__c = String.valueof(ar.get('expr4'));  
                    // end of v1.2    
                    
                    //Added as part of v1.3
                    if(ar.get('expr5')!=null)
                    bookHeader.Org_Booked_Date__c = Datetime.valueof(ar.get('expr5'));
                    
                    lBookingHeadersToUpdate.add(bookHeader);  
                    mBookingIdWithTotalCostCurrency.putall(lBookingHeadersToUpdate);                   
                    
                    
                }
                System.debug('### Exiting rollUpCostsToBookingHeader with lBookingHeadersToUpdate : ' + lBookingHeadersToUpdate);
            }catch(Exception e){
                System.debug('### EXCEPTIOn'+e+'rollUpCostsToBookingHeader with lBookingHeadersToUpdate : ' + lBookingHeadersToUpdate);

            }
        }
    }
    
    
    private static void updateCases(){
        try{
            if(casesToUpdate.size()>0) update casesToUpdate;
        }catch(Exception e){

        }
    }

    private static void instantiateListsAndSets(){
        casesToUpdate = new List<Case>();
        sBookingHeaderIds = new Set<String>();
        lBookingHeadersToUpdate = new List<Booking__c>();
        lBookingHeadersToUpdateHN = new List<Booking__c>();
        mBookingIdWithTotalCostCurrency = new Map<Id, Booking__c>();
        BookingStatusMap = new map<string,string>();

    } 
    
    //Added as a part of changes in v1.5
    /**************************************************************************************************
* Name               : updateEkhTPSSendEmailDate 
* Description        : For Ekh Booking update EKH_TPS_Send_Date__c based on Post_Travel_Survey_Responded_Date__c
* Params             : List<Booking__c>
* Return             : -
**************************************************************************************************/
    public static void updateEkhTPSSendEmailDate(List<Booking__c> newBookingList){
        string recordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        for(Booking__c book:newBookingList){
            if(book.RecordTypeId == recordTypeId && book.Org_Brand__c == 'ekh' && book.Post_Travel_Survey_Responded_Date__c != null){
                book.EKH_TPS_Send_Date__c = getvalidEmailDate(book.Post_Travel_Survey_Responded_Date__c); // updated as a part of v1.15
                system.debug('booking TPS Date'+book.EKH_TPS_Send_Date__c);            
            }
        }
    }
    
    //Added as a part of changes in v1.5
/**************************************************************************************************
* Name               : getvalidEmailDate 
* Description        : Returns the date for EKH TPS email
* Params             : Datetime
* Return             : Datetime
**************************************************************************************************/
    public static DateTime getvalidEmailDate(Datetime triggeredDate){
        
        Date trigGMTDate = Date.valueOf(String.valueOf(triggeredDate));
        trigGMTDate = trigGMTDate + 3;
        Datetime MailingDateTime = trigGMTDate;
        String dayofweek = MailingDateTime.formatGmt('E');
        DateTime ReturnDateTime;
        if(dayofweek!='Sat' && dayofweek != 'Sun'){
            //create a new instance of date time with hour as 8
            Integer year = MailingDateTime.yearGmt();
            Integer month = MailingDateTime.monthGmt();
            Integer day = MailingDateTime.dayGmt();
            ReturnDateTime =  DateTime.newInstanceGmt(year, month, day, 08, 00, 00);
        } else {
            //Add hours to the date and check if it meets the conditions 
            for(Integer i=1;i <= 72;i++){
                MailingDateTime = MailingDateTime.addHours(1);
                Integer hourofMalingday =MailingDateTime.hourGmt() ;
                String dayofMailingweek = MailingDateTime.formatGmt('E');
                if(hourofMalingday == 8 && (dayofMailingweek!='Sat' && dayofMailingweek != 'Sun') && ReturnDateTime == null){
                    ReturnDateTime = MailingDateTime;
                }
            }
        }
        system.debug('ReturnDateTime >>>>>>>>>>>'+ReturnDateTime);
        return ReturnDateTime;
    }
    
    
    //added v1.6 - jed
    private static void updateBookedBy(String strNewMap){

        //v1.20
        if(AsyncDerwentWebService.isFromDerwentCall)
            return;

        Set<Id> bookingHeaderIds = new Set<Id>();//Added as part of v1.7
        // v2.20
        //List<Booking__c> bookingHeadersToUpdate = new List<Booking__c>();
        map<Id, Booking__c> mapBookingHeadersToUpdate = new map<Id, Booking__c>();

        Map<Id,Booking__c> bookingHeaderMap = new Map<Id,Booking__c>();//Added as part of v1.7

        map<Id,Booking__c> newMap = (map<Id,Booking__c>)JSON.deserialize(strNewMap,map<Id,Booking__c>.class); //v1.11        
        
        Map<String,List<User>> userEmailIdMap = new Map<String,List<User>>();
        for(Booking__c bkg : newMap.values()){
            if(bkg.Booking_Header__c != null){//Added as part of v1.7
                bookingHeaderIds.add(bkg.Booking_Header__c);    
            }
            if(bkg.Booked_By_Email__c != null && bkg.Booked_By_Email__c != ''){
               userEmailIdMap.put(bkg.Booked_By_Email__c,new List<User>()); 
            }
        }
        
        if(bookingHeaderIds.size()>0){//Added as part of v1.7
            bookingHeaderMap.putAll([select id,Booked_By_Email__c,Org_BookedById__c,Org_BookedByName__c,Flight_Destination__c,Hotel_Destination__c,OwnerId,Destination__c from Booking__c where id IN: bookingHeaderIds]);
        }
        
        if(!userEmailIdMap.isEmpty()){ //v1.20
            for(User u: [select id,email,name from User where isActive = true and email IN: userEmailIdMap.keySet()]){ 
                if(userEmailIdMap.containsKey(u.Email)){
                    userEmailIdMap.get(u.Email).add(u);    
                }            
            }
        }
        for(Booking__c bkg : newMap.values()){
            Booking__c bkgHeader = mapBookingHeadersToUpdate.containsKey(bkg.Booking_Header__c) ? mapBookingHeadersToUpdate.get(bkg.Booking_Header__c) : new Booking__c();//Added as part of v1.7 // v1.20
            
            if(bookingHeaderMap.containsKey(bkg.Booking_Header__c)){//Added as part of v1.7
                bkgHeader.Id = bookingHeaderMap.get(bkg.Booking_Header__c).Id;//Added as part of v1.7

                if(bkg.Org_Booking_Type__c == 'Flight'){//Added as part of v1.7
                    bkgHeader.Flight_Destination__c = bkg.Destination__c;
                }
                if(bkg.Org_Booking_Type__c == 'Accommodation'){ //Added as part of v1.7
                    bkgHeader.Hotel_Destination__c = bkg.Destination__c;
                }
            }
            
            if(userEmailIdMap.containsKey(bkg.Booked_By_Email__c) && userEmailIdMap.get(bkg.Booked_By_Email__c).size() == 1){ //validate if the email belongs to a single user in salesforce
                if(userEmailIdMap.get(bkg.Booked_By_Email__c)[0].Id != null){
                    bkg.OwnerId = userEmailIdMap.get(bkg.Booked_By_Email__c)[0].Id;
                }
            }
            bkgHeader.OwnerId = bkg.OwnerId;//Added as part of v1.6
            bkgHeader.Org_ClientCurrencyCode__c = bkg.Org_ClientCurrencyCode__c; //MPamintuan added as part of v1.10
            if(string.isNotEmpty(bkgHeader.Id)){//Added MPamintuan 8/14/2019
                //bookingHeadersToUpdate.add(bkgHeader);//Added as part of v1.7    
                mapBookingHeadersToUpdate.put(bkgHeader.Id, bkgHeader);
            }
            
        }    
        
        if(!mapBookingHeadersToUpdate.isEmpty()){//Added as part of v1.7
            try{
                BlockBookingTrigger = true; //v1.20
                update mapBookingHeadersToUpdate.values();
                BlockBookingTrigger = false;
            }catch (exception e){
                system.debug(e.getMessage());
            }
        }
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 3 July 2019
     * @description: method to update Office name and Cluster on booking //v1.8
     * @history:                
     */
    private static void populateStoreAndCluster(list<Booking__c> lstBookings){

        map<String,String> storeClusterMap = new map<String,String>();
        //v1.20 String userRetailStore = [SELECT Store__c FROM User WHERE Id =: UserInfo.getUserId()].Store__c;
        //v1.20
        Boolean falg = false;
        for(Booking__c booking : lstBookings){
            if(string.IsEmpty(booking.Office_Number__c)){
                falg = true;
                break;
            }
        }
        if(falg){
            if(!mapCurrentUser.containsKey(UserInfo.getUserId())){
                for(User obj : [select Id, Store__c from User WHERE Id =: UserInfo.getUserId()])
                    mapCurrentUser.put(obj.Id, obj);
            }
        }
        String userRetailStore = mapCurrentUser.containsKey(UserInfo.getUserId()) ? mapCurrentUser.get(UserInfo.getUserId()).Store__c : '';

        for(User_Role_And_Store_Map__mdt storeCluster : [SELECT Id,Agent_Role_Name__c,Lead_Role_Name__c,Queue_Name__c,Store_Name__c, Store_Number__c, Cluster__c FROM User_Role_And_Store_Map__mdt]){
            storeClusterMap.put(storeCluster.Agent_Role_Name__c,storeCluster.Cluster__c);
            storeClusterMap.put(storeCluster.Lead_Role_Name__c,storeCluster.Cluster__c);
            storeClusterMap.put(storeCluster.Queue_Name__c,storeCluster.Cluster__c);
            storeClusterMap.put(storeCluster.Store_Name__c,storeCluster.Store_Number__c); //v1.19
            storeClusterMap.put(storeCluster.Store_Number__c,storeCluster.Cluster__c); //v1.19            
        }

        for(Booking__c booking : lstBookings){
            if(string.IsEmpty(booking.Office_Number__c)){
                booking.Office_Name__c = userRetailStore;
                booking.Office_Number__c = storeClusterMap.containsKey(userRetailStore) ? storeClusterMap.get(userRetailStore) : ''; //v1.19
                booking.Cluster__c = storeClusterMap.containsKey(booking.Office_Number__c) ? storeClusterMap.get(booking.Office_Number__c) : ''; //v1.19                
            } else {
                booking.Cluster__c = storeClusterMap.containsKey(booking.Office_Number__c) ? storeClusterMap.get(booking.Office_Number__c) : ''; //v1.19
            }
        }
    }     

    //v1.20.3
/**************************************************************************************************
* Name               : populateEKHReplication 
* Description        : update replicated and reconfirmed details for EKH on booking
* Params             : list<Booking__c>,map<Id, Booking__c>
* Return             : -
**************************************************************************************************/
    public static void populateEKHReplication(list<Booking__c> lstNewBookings, map<Id, Booking__c> mapOldBookings){
        for(Booking__c objBook : lstNewBookings){
            Booking__c objOldBook = mapOldBookings != null ? mapOldBookings.get(objBook.Id) : null ;
            if(objBook.Replicated__c == true && ( objOldBook == null || (objOldBook != null && objOldBook.Replicated__c != objBook.Replicated__c)  )){
                objBook.Replicated_By__c = UserInfo.getUserId();
                objBook.Replicated_Date_Time__c = system.now();
            }
            if(objBook.Reconfirmed__c == true && ( objOldBook != null && objOldBook.Reconfirmed__c != objBook.Reconfirmed__c  )){
                objBook.Reconfirmed_By__c = UserInfo.getUserId();
                objBook.Reconfirmed_Date_Time__c = system.now();
            }
        }
    }
}