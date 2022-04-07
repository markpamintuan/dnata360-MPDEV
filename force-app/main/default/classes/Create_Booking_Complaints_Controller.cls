/**************************************************************************************************
* Name               : Create_Booking_Complaints_Controller                                       * 
* Description        : Controller class for the Add Complaint Buttom on Booking                   *
* Created Date       : 28/08/2019                                                                 *
* Created By         : PWC                                                                        *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Evendo    28/08/2019      Initial Draft.                                               *   
* 1.1      Evendo    10/02/2020		 Adding Limits to certain queries                             *
**************************************************************************************************/
public class Create_Booking_Complaints_Controller {
    
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
    
    
    /*********************************************************************************************
    * @Description : Update Cases                                                                *
    * @Params      : String , String 									                         *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String updateAll(String InternalList, String InternalId){
        try{
        	Case internalCase = [select id,Subject,Org_Case_Status__c,End_Provider_Name__c,OwnerId from Case where id =:InternalId limit 1 ]; //v1.1
        	List<Case> internalstoinsert = new List<Case>();
			List<Case> internals = (List<Case>)System.JSON.deserializeStrict(InternalList, List<Case>.Class);       
            
       
        
        
            internalCase.Subject = internals[0].Subject;
            internalCase.Org_Case_Status__c = internals[0].Org_Case_Status__c;
            internalCase.End_Provider_Name__c = internals[0].End_Provider_Name__C;
            internalCase.OwnerId = internals[0].OwnerId;
            update internalCase;
            
            return internalCase.id;
            
       
        } catch (Exception ex) {
            System.debug('Exception '+ ex);
            CustomExceptionData data = new CustomExceptionData('MyCustomServerError', 'Some message about the error', 123);
			throw new AuraHandledException(JSON.serialize(data));
        }

    }  
    
     @AuraEnabled
    public static List<Case> getAllCase(List<String> lstRecordId, String complaintId){
        system.debug('Bookinglst'+lstRecordId);
        List<Case> caseList = new List<Case>();
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        if(complaintId != ''){
        for(String bookingList :lstRecordId ){
           Case cs = new Case();
           caseList =  [Select Id,Account.Name,CaseNumber,SuppliedEmail,Subject,CreatedDate,Category__c,Org_Case_Status__c,Org_Booking__r.Name,End_Provider_Name__c,OwnerId,Owner.Name,Owner_Name__c,Owner.Id from Case WHERE Org_Booking__r.Id =:bookingList and recordtypeid = :recordtypeid and ParentId = :complaintId ORDER BY CreatedDate DESC LIMIT 10 ] ; 
          
        }
        }
        
        if(caseList.size() >0)
        	return caseList;
        return null;
    }
    
    /*********************************************************************************************
    * @Description : Delete Cases                                                                *
    * @Params      : String , String 									                         *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static void deleteAll(List<String> InternalList, List<String> IssueList,String complaintId){
        try{
        	
            
            List<Issues__c> issueToDelete = [Select id from issues__c where id in :IssueList limit 50];//v1.1
            List<Case> caseToDelete = [Select id from Case where id in :InternalList limit 50];//v1.1
            System.debug(caseToDelete);
            System.debug(issueToDelete);
            if(issueToDelete.size() > 0){
            	delete issueToDelete;
            }
            if(caseToDelete.size() > 0){
            	delete caseToDelete;
            }
            Case c = [Select id from Case where id = : complaintId];
            delete c;
        }catch (Exception ex) {
            System.debug('Exception '+ ex);
            
        }

    }  
    
   
    @AuraEnabled
    public static List<Issues__c> getAllIssues(List<String> lstRecordId){
        system.debug('Bookinglst'+lstRecordId);
        List<Issues__c> caseList = new List<Issues__c>();
        for(String bookingList :lstRecordId ){
           Issues__c iss = new Issues__c();
           caseList =  [select id,Org_Case__c,Issue__c,Issue_Type__c,Org_Booking__c,Description__c,End_Provider_Name__c from Issues__c where Org_Booking__r.Id =:bookingList] ; 
          
        }
        if(caseList.size() >0)
        	return caseList;
        return null;
    }
    
    
    
    /*********************************************************************************************
    * @Description : Create Complaint                                                            *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
 	@AuraEnabled
    public static String createComplaint(String bookingid){
        	Booking__c book = [Select Id,Org_Account_Name__c,Booking_Header__c,Org_Account_Name__r.Name  from Booking__c where Id =: bookingid];
            String complaintrecordtypeid = [select id from recordtype where developername = 'Travel_Republic_Complaints'].id;
        	String complaintId = '';
         	Case newcase = new Case();
            newCase.Org_Booking__c = book.Booking_Header__c;
            newCase.AccountId = book.Org_Account_Name__c;
            newCase.Subject = 'Complaint for ' + book.Org_Account_Name__r.Name;
            newCase.RecordTypeId = complaintRecordTypeId;
            insert newCase;
        	complaintId = [Select Id from Case where Id=:newCase.Id].id;
        
        	return complaintId;
    }    
    
     /*********************************************************************************************
    * @Description : Insert Cases                                                                *
    * @Params      : String , String , String , String , Boolean , String                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String saveAll(String InternalList, string bookingid, string complaintId){
        try{
           
            Booking__c book = [Select Id,Org_Account_Name__c,Booking_Header__c,Org_Account_Name__r.Name  from Booking__c where Id =: bookingid];
            String complaintrecordtypeid = [select id from recordtype where developername = 'Travel_Republic_Complaints'].id;
            
        	String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        	List<Case> internalstoinsert = new List<Case>();
			List<Case> internals = (List<Case>)System.JSON.deserializeStrict(InternalList, List<Case>.Class);       
            
       
        
            for(Case internal: internals){
                Case cc = new Case();
                cc.RecordTypeId = recordtypeid;                
                cc.Subject = internal.Subject;
                cc.OwnerId = internal.OwnerId;
                cc.ParentId = complaintId;
                cc.AccountId = book.Org_Account_Name__c;
                cc.End_Provider_Name__c = internal.End_Provider_Name__c;
                cc.Org_Case_Status__c = internal.Org_Case_Status__c;
                cc.Org_Booking__c = bookingid;
                cc.Org_Brand__c = 'trp';
                internalstoinsert.add(cc);
            }
       
            insert internalstoinsert;
            
            return internalstoinsert[0].id;
            
            }catch (Exception ex) {
                System.debug('Exception '+ ex);
                CustomExceptionData data = new CustomExceptionData('MyCustomServerError',ex.getMessage(), 123);
                throw new AuraHandledException(JSON.serialize(data));
            }

    }  
    
    
    
    /*********************************************************************************************
    * @Description : Insert Cases and Issues.                                                    *
    * @Params      : String , String , String , String , Boolean , String                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String saveAllIssues(String InternalId, String IssueList, string bookingid,String complaintId){
        try{
		 
        Booking__c book = [Select Id,Org_Account_Name__c,Booking_Header__c,Org_Account_Name__r.Name  from Booking__c where Id =: bookingid];        
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        List<Issues__c> issuestoinsert = new List<Issues__c>();
        List<Issues__c> issues = (List<Issues__c>)System.JSON.deserializeStrict(IssueList, List<Issues__c>.Class);        
        
        
       
        for(Issues__c iss: issues){
            if(iss.id == null) {
                system.debug('issue ' + iss.Issue__c );
                iss.Internal_Request__c = InternalId;
                iss.Org_Booking__c = bookingid;
                iss.Org_Case__c = complaintId;
            	issuestoinsert.add(iss);
            }
        }
        
        insert issuestoinsert;
            
         return issuestoinsert[0].id;
            
        } catch (Exception ex) {
            System.debug('Exception '+ ex);
            CustomExceptionData data = new CustomExceptionData('MyCustomServerError', ex.getMessage(), 123);
			throw new AuraHandledException(JSON.serialize(data));
        }
       
    }
    
    
     
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
    
    @AuraEnabled
    public static list < Create_Booking_Complaints_Controller.UserLookupResultWrapper > fetchLookUpValues2(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < Create_Booking_Complaints_Controller.UserLookupResultWrapper > returnWrapperList = new list < Create_Booking_Complaints_Controller.UserLookupResultWrapper > ();
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
                                Create_Booking_Complaints_Controller.UserLookupResultWrapper wrap = new Create_Booking_Complaints_Controller.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                       
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                Create_Booking_Complaints_Controller.UserLookupResultWrapper wrap = new Create_Booking_Complaints_Controller.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }
                    
                
            
            
        
        
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
    }
    
    
    
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
  
    @AuraEnabled 
    public static List<String> getSupplierName(String bookingid){
        List<String> SupplierNameList = new List<String>();
        Booking__c bk = [Select id,Org_Booking_Type__c,Supplier_Name__c from Booking__c where id = :bookingid];
        if(bk.Org_Booking_Type__c == 'Flight'){
            List<Itinerary__c> itinlist = [Select id from Itinerary__c where Org_Booking__c =:bk.id];
            List<String> itinIdList = new List<String>();
            for(Itinerary__c itin: itinlist){
                itinIdList.add(itin.id);
            }
            
            List<Itinerary_Detail__c> itinDetailList = [Select id,Org_Marketing_Carrier__c,Org_Operating_Carrier__c from Itinerary_Detail__c where Itinerary__c = :itinIdList];
            for(Itinerary_Detail__c itindet : itinDetailList){
                if(itindet.Org_Marketing_Carrier__c != '' || itindet.Org_Marketing_Carrier__c != null){
                    SupplierNameList.add(itindet.Org_Marketing_Carrier__c);
                }
                if(itindet.Org_Operating_Carrier__c != '' || itindet.Org_Operating_Carrier__c != null){
                    SupplierNameList.add(itindet.Org_Operating_Carrier__c);
                }
            }
            
            
        }else{
            SupplierNameList.add(bk.Supplier_Name__c);
        }
        
        return SupplierNameList;
    }
    
    
    
    @AuraEnabled 
    public static List<String> getSupplierNameIssues(String bookingid){
        List<String> SupplierNameList = new List<String>();
        Booking__c bk = [Select id,Org_Booking_Type__c,Supplier_Name__c from Booking__c where id = :bookingid];
        if(bk.Org_Booking_Type__c == 'Flight'){
            List<Itinerary__c> itinlist = [Select id from Itinerary__c where Org_Booking__c =:bk.id];
            List<String> itinIdList = new List<String>();
            for(Itinerary__c itin: itinlist){
                itinIdList.add(itin.id);
            }
            
            List<Itinerary_Detail__c> itinDetailList = [Select id,Org_Marketing_Carrier__c,Org_Operating_Carrier__c from Itinerary_Detail__c where Itinerary__c = :itinIdList];
            for(Itinerary_Detail__c itindet : itinDetailList){
                if(itindet.Org_Marketing_Carrier__c != '' || itindet.Org_Marketing_Carrier__c != null){
                    SupplierNameList.add(itindet.Org_Marketing_Carrier__c);
                }
                if(itindet.Org_Operating_Carrier__c != '' || itindet.Org_Operating_Carrier__c != null){
                    SupplierNameList.add(itindet.Org_Operating_Carrier__c);
                }
            }
            
            
        }else if(bk.Org_Booking_Type__c == 'Accommodation'){
            List<Itinerary__c> itinlist = [Select id,Org_Hotel_Name__c from Itinerary__c where Org_Booking__c =:bk.id];            
            for(Itinerary__c itin: itinlist){
                SupplierNameList.add(itin.Org_Hotel_Name__c);
            }           
        }else{
            SupplierNameList.add(bk.Supplier_Name__c);
        }
        
        return SupplierNameList;
    }
    
    
  
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

 
    // Wrapper class for my custom exception data
public class CustomExceptionData {
    public String name;
    public String message;
    public Integer code;

    public CustomExceptionData(String name, String message, Integer code) {
        this.name = name;
        this.message = message;
        this.code = code;
    }
}


}