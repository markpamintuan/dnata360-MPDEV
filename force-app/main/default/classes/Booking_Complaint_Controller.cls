/**************************************************************************************************
* Name               : Booking_Complaint_Controller
* Description        : This is a controller used for lightning components        
* Created Date       : 18-Aug-2019                                                                 
* Created By         : Evendo                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS             
************************************************************************************************/
public class Booking_Complaint_Controller {
    
 /**************************************************************************************************
* Name               : getAllBookings 
* Description        : Returns list of bookings
* Params             : List<String>
* Return             : List<Booking__c>
**************************************************************************************************/
    @AuraEnabled
    public static List<Booking__c> getAllBookings(List<String> lstRecordId){
       Booking__c booking = [Select Id,Booking_Header__c,RecordType.Name ,Org_Account_Name__c from Booking__c where id IN:lstRecordId];
       List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
        for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                Destination__c,Departure_Date__c,Org_Account_Name__r.Name,
                                    (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
                                WHERE Booking_Header__c =: booking.Booking_Header__c AND
                                 Booking_Status__c IN ('Active', 'Pending','Receipted')
                                ]){              
            lOpenBookingHeader.add(book);             
        }
        return lOpenBookingHeader;
    } 
    
/**************************************************************************************************
* Name               : getBookings 
* Description        : Returns list of all bookings 
* Params             : List<String>
* Return             : List<Booking__c>
**************************************************************************************************/
    @AuraEnabled
    public static List<Booking__c> getBookings(List<String> lstRecordId){
       List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
        Set<Booking__c> uniqueBookings = new Set<Booking__c>();
        for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                Destination__c,Departure_Date__c,Supplier_Name__c,Org_Account_Name__r.Name, //Added as part of v1.2
                                    (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
                                WHERE Name IN : lstRecordId AND
                                 Booking_Status__c IN ('Active', 'Pending','Receipted')
                               
                                ]){              
            lOpenBookingHeader.add(book);             
        }
        
        return lOpenBookingHeader;
    } 

/**************************************************************************************************
* Name               : getAllCase 
* Description        : Returns list of all the  cases linked to the booking
* Params             : List<String>
* Return             : List<Case>
**************************************************************************************************/    
     @AuraEnabled
    public static List<Case> getAllCase(List<String> lstRecordId){
        system.debug('Bookinglst'+lstRecordId);
        List<Case> caseList = new List<Case>();
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        for(String bookingList :lstRecordId ){
           Case cs = new Case();
           caseList =  [Select Id,Account.Name,CaseNumber,SuppliedEmail,Subject,CreatedDate,Category__c,Org_Case_Status__c,Org_Booking__r.Name from Case WHERE Org_Booking__r.Id =:bookingList and recordtypeid = :recordtypeid ORDER BY CreatedDate DESC LIMIT 10 ] ; 
          
        }
        if(caseList.size() >0)
        	return caseList;
        return null;
    }
    
/**************************************************************************************************
* Name               : createInternalRequest 
* Description        : creates internal request 
* Params             : String,String,String
* Return             : String
**************************************************************************************************/   
      @AuraEnabled
    public static String createInternalRequest(String InternalList,  string bookingid , string caseId){
        system.debug('InternalList ' + InternalList);
        system.debug('bookingId'+bookingid);
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        List<Case> internalstoinsert = new List<Case>();
        
        system.debug(bookingid);
        List<Case> internals = (List<Case>)System.JSON.deserializeStrict(InternalList, List<Case>.Class);
        
		Case parentCase = [Select Id,Account.Name,Org_Booking__c from Case where Id=: caseId];
        for(Case cs: internals){
            if(cs.id == null){
            cs.ParentId = parentCase.id;
            cs.AccountId = parentCase.Account.Id;
            cs.Org_Booking__c = bookingid;
            cs.RecordTypeId = recordtypeid;
            
            	internalstoinsert.add(cs);
            }
        }
		upsert internalstoinsert;
        
        
        
        return 'Success';
    }
/**************************************************************************************************
* Name               : fetchLookUpValues2 
* Description        : Returns list of users and queues
* Params             : String,String,String
* Return             : List<Booking_Complaint_Controller.UserLookupResultWrapper>
**************************************************************************************************/    
    @AuraEnabled
    public static list < Booking_Complaint_Controller.UserLookupResultWrapper > fetchLookUpValues2(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < Booking_Complaint_Controller.UserLookupResultWrapper > returnWrapperList = new list < Booking_Complaint_Controller.UserLookupResultWrapper > ();
        String searchKey = '%' + searchKeyWord + '%';
        string bunit = 'TRP';
            
                    
                    system.debug('searchType2::' + searchType);
                    if(searchType == 'Queue'){
                        system.debug('enter3::');
                        /*list<Business_Unit__c> bulist = [select id, Queue_ID__c, Org_Queue_Name__c, 
                                                        Org_Business_Unit_Team__c, Org_Business_Unit_Team__r.name
                                                    from Business_Unit__c where RecordType.Name = 'Team'
                                                    and Org_Business_Unit_Team__r.name =: bunit
                                                        and Org_Queue_Name__c like: searchKey
                                                        and IsActive__c = true];*/
                        list<Group> bulist = [select Id,Name from Group where Type = 'Queue' and Name like: searchKey];
                        system.debug('bulist::: ' + bulist);
                        if(bulist <> null && !bulist.isEmpty()){
                            for(Group bu: bulist){
                                Booking_Complaint_Controller.UserLookupResultWrapper wrap = new Booking_Complaint_Controller.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                       
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and IsActive = true and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                Booking_Complaint_Controller.UserLookupResultWrapper wrap = new Booking_Complaint_Controller.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }
                    
                
            
            
        
        
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
    }
    
/**************************************************************************************************
* Name               : fetchLookUpValuesForSubject 
* Description        : Returns list of subject based on the search word
* Params             : String,String
* Return             : List<String>
**************************************************************************************************/    
    
    //Added By Evendo
    @AuraEnabled
    public static List<String> fetchLookUpValuesForSubject(String searchKeyWord, String cid) {
   
        List<String> searchResults = new List<String>();
        String searchKey = '%' + searchKeyWord + '%';
        
        List<Travel_Republic_Category__mdt> SRCM = new List<Travel_Republic_Category__mdt>();
      	SRCM = [Select Category_Text__c from Travel_Republic_Category__mdt where Category_Text__c LIKE :searchKey];
            
        if(SRCM<> null && !SRCM.isEmpty()){
            for(Travel_Republic_Category__mdt src: SRCM){
                searchResults.add(src.Category_Text__c);
            }
        }
        
        
        return searchResults;
    }
 
/**************************************************************************************************
* Name               : UserLookupResultWrapper 
* Description        : Wrapper Class
* Params             : -
* Return             : -
**************************************************************************************************/
    public class UserLookupResultWrapper{
        @AuraEnabled
        public string rid {get; set;}
        @AuraEnabled
        public string rname {get; set;}
        
        public UserLookupResultWrapper(string rid, string rname){
            this.rid = rid;
            this.rname = rname;
        }
    }

  

}