/**************************************************************************************************
* Name               : Create_Internal_Req_And_Issues                                             * 
* Description        : Controller class for the CreateInternalRequestAndIssues Lightning Component*
* Created Date       : 14/07/2019                                                                 *
* Created By         : PWC                                                                        *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Evendo    14/07/2019      Initial Draft.  
**************************************************************************************************/
global class Create_Internal_Req_And_Issues {
      
    /*********************************************************************************************
    * @Description : Get All Internal Request Cases Given a list of booking ids.                 *
    * @Params      : List<String>                                                                *
    * @Return      : List<Case>                                                                  *
    *********************************************************************************************/    
    @AuraEnabled
    public static List<Case> getAllCase(List<String> lstRecordId,String complaintId){
        List<Case> caseList = new List<Case>();
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        for(String bookingList :lstRecordId ){
           Case cs = new Case();
           caseList =  [Select Id,Org_Case_Status__c,Org_Type__c,Category__c,OwnerId,Owner.Name,Owner_Name__c,Subject,End_Provider_Name__c from Case 
                        WHERE Org_Booking__r.Id =:bookingList and recordtypeid = :recordtypeid and ParentId =: complaintId
                        ORDER BY CreatedDate DESC ] ;          
        }
        if(caseList.size() >0)
        	return caseList;
        return null;
    }

    
    /*********************************************************************************************
    * @Description : Get All Issues given a list of booking ids.                                 *
    * @Params      : List<String>                                                                *
    * @Return      : List<Issues__c>                                                             *
    *********************************************************************************************/
    @AuraEnabled
    public static List<Issues__c> getAllIssues(List<String> lstRecordId){
        List<Issues__c> caseList = new List<Issues__c>();
        for(String bookingList :lstRecordId ){
           Issues__c iss = new Issues__c();
           caseList =  [Select id,Org_Case__c,Description__c,End_Provider_Name__c,Issue__c,Issue_Type__c,Org_Booking__c from Issues__c 
                        where Org_Booking__r.Id =:bookingList] ;          
        }
        if(caseList.size() >0)
        	return caseList;
        return null;
    }
    
   
    /*********************************************************************************************
    * @Description : Update Cases Given a List of Cases.                                         *
    * @Params      : List<Case>                                                                  *
    * @Return      : Boolean                                                                     *
    *********************************************************************************************/
    @AuraEnabled    
    public static boolean updateCase( List < Case > updatedCaseList ) {                
        try {            
            update updatedCaseList;  
            return true;               
        } catch(Exception e) {            
            return false;                
        }              
    }    
    
    
    /*********************************************************************************************
    * @Description : Return a List of Bookings given a list of Booking Names                     *
    * @Params      : List<String>                                                                *
    * @Return      : List<Booking__c>                                                            *
    *********************************************************************************************/
    @AuraEnabled
    public static List<Booking__c> getBookings(List<String> lstRecordId){
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
        for(Booking__c book : [SELECT Id,Booking_Type_Icon__c,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                Destination__c,Departure_Date__c, //Added as part of v1.2
                                    (SELECT Id, 
                                            Org_Booking_Type__c,
                                     		Org_Travel_Start_Date__c,
                                     		Org_Travel_End_Date__c,
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
    * @Description : Return Record Type Id given Record Type Name                                *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    public static String getRecordTypeId(string recordTypeName) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return devRecordTypeId;
    }

    
    /*********************************************************************************************
    * @Description : Create Case given case parameters.                                          *
    * @Params      : String , String , String , List<String> , String                            *
    * @Return      : Case                                                                        *
    *********************************************************************************************/
    @AuraEnabled 
    public static Case createCase(String subject,string email,string recordType,List<string> bookingId,String parentCaseId){
        Case cs = new Case();
        List<Booking__c> bk = [Select Id from Booking__c where Name IN: bookingId];
        for(Booking__c book : bk){
            cs.Subject = subject;
            cs.SuppliedEmail = email;
            cs.RecordTypeId = getRecordTypeId('Travel Republic - Internal Request');
            cs.Org_Booking__c = book.Id;
            cs.ParentId = parentCaseId;
        }       
        insert cs;
        return cs;
    }
    
    
    /*********************************************************************************************
    * @Description : Get all Booking Headers under an account under a case id                    *
    * @Params      : String                                                                      *
    * @Return      : List<Booking__c>                                                            *
    *********************************************************************************************/
    @AuraEnabled
    public static List<Booking__c> getAllRelatedBookingHeaders(String caseId){
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
		Case cse = [Select CaseNumber,Id,AccountId from Case where id =: caseId];      	
        String recordTypeId = [Select id from recordtype where developername = 'Booking_Header'].id;
        for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                CreatedDate,Name,Opportunity__c,Owner.Name,
                                Destination__c,Departure_Date__c,
                               (SELECT Id, 
                                            Org_Booking_Type__c,
                                            Org_Title__c,
                                Org_Travel_Start_Date__c,
                                     		Org_Travel_End_Date__c,
                                            Name
                                    FROM Bookings__r)
                                FROM Booking__c 
                                where recordtypeid = :recordTypeId and Org_Account_Name__c = :cse.AccountId
                                ]){              
            lOpenBookingHeader.add(book);             
        }
        return lOpenBookingHeader;
    }
    
    
    /*********************************************************************************************
    * @Description : Get all Bookings under a case.                                              *
    * @Params      : String , Boolean , String                                                   *
    * @Return      : List<Booking__c>                                                            *
    *********************************************************************************************/
     @AuraEnabled
    public static List<Booking__c> getAllRelatedBookings(String caseId,Boolean noBookingHeader,String bookingHeaderId){
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
		Case cse = [Select CaseNumber,Id,Org_Booking__c,Org_Booking__r.Org_Booking_Ref__c,Org_Booking__r.Booking_Header__c from Case where id =: caseId];
        if(noBookingHeader == null){
            noBookingHeader = false;
        }
        if(noBookingHeader){
            String bkheaderid = [Select id from Booking__c where name = :bookingHeaderId].id;
            for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                    Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                    Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                    Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                    CreatedDate,Name,Opportunity__c,Owner.Name,
                                    Destination__c,Departure_Date__c, //Added as part of v1.2
                                        (SELECT Id, 
                                                Org_Booking_Type__c, 
                                                Org_Title__c,
                                         		Org_Travel_Start_Date__c,
                                     		Org_Travel_End_Date__c,
                                                Name
                                        FROM Bookings__r)
                                    FROM Booking__c 
                                    WHERE Booking_Header__c =: bkheaderid AND
                                     Booking_Status__c IN ('Active', 'Pending','Receipted')
                                    ]){              
                lOpenBookingHeader.add(book);             
            }
        }else{
            for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                    Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                    Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                    Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                    CreatedDate,Name,Opportunity__c,Owner.Name,
                                    Destination__c,Departure_Date__c, //Added as part of v1.2
                                        (SELECT Id, 
                                                Org_Booking_Type__c, 
                                                Org_Title__c,
                                         Org_Travel_Start_Date__c,
                                     		Org_Travel_End_Date__c,
                                                Name
                                        FROM Bookings__r)
                                    FROM Booking__c 
                                    WHERE Booking_Header__c =: cse.Org_Booking__c AND
                                     Booking_Status__c IN ('Active', 'Pending','Receipted')
                                    ]){              
                lOpenBookingHeader.add(book);             
            }
        }
        return lOpenBookingHeader;
    }
    
    /*********************************************************************************************
    * @Description : Insert Cases                                                                *
    * @Params      : String , String , String , String , Boolean , String                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String saveAll(String InternalList, String CaseId, string bookingid,Boolean noBookingHeader, string bookingHeaderId){
        try{
        	Case c = [select id, CaseNumber, Org_Booking__c,AccountId, ContactId from Case where id = :CaseId];
        	String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        	List<Case> internalstoinsert = new List<Case>();
			List<Case> internals = (List<Case>)System.JSON.deserializeStrict(InternalList, List<Case>.Class);       
            if(noBookingHeader == null){
                noBookingHeader = false;
            }        
            if(noBookingHeader == true){
                String bkid = [Select id from Booking__c where name = :bookingHeaderId].id;
                c.Org_Booking__c = bkid;
                update c;
            }
        
       
        
        for(Case internal: internals){
            Case cc = new Case();
            cc.RecordTypeId = recordtypeid;
            cc.ParentId = c.id;
            cc.AccountId = c.AccountId;
            cc.Subject = internal.Subject;
            cc.OwnerId = internal.OwnerId;
            cc.End_Provider_Name__c = internal.End_Provider_Name__c;
            cc.Org_Case_Status__c = internal.Org_Case_Status__c;
            cc.ContactId = c.ContactId;
            cc.Org_Booking__c = bookingid;
            cc.Org_Brand__c = 'trp';
            internalstoinsert.add(cc);
        }
       
        insert internalstoinsert;
        System.debug(internalstoinsert);
        return internalstoinsert[0].id;
        
        }catch (Exception ex) {
            System.debug('Exception '+ ex);
            CustomExceptionData data = new CustomExceptionData('MyCustomServerError',ex.getMessage(), 123);
			throw new AuraHandledException(JSON.serialize(data));
        }

    }  
    
    
    /*********************************************************************************************
    * @Description : Update Cases                                                                *
    * @Params      : String , String 									                         *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String updateAll(String InternalList, String InternalId){
        try{
        	Case internalCase = [select id,Subject,Org_Case_Status__c,End_Provider_Name__c,OwnerId from Case where id =:InternalId ];
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
    
    
    
    /*********************************************************************************************
    * @Description : Delete Cases                                                                *
    * @Params      : String , String 									                         *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static void deleteAll(List<String> InternalList, List<String> IssueList){
        try{
        	
            
            List<Issues__c> issueToDelete = [Select id from issues__c where id in :IssueList];
            List<Case> caseToDelete = [Select id from Case where id in :InternalList];
            System.debug(caseToDelete);
            System.debug(issueToDelete);
            if(issueToDelete.size() > 0){
            	delete issueToDelete;
            }
            if(caseToDelete.size() > 0){
            	delete caseToDelete;
            }
        }catch (Exception ex) {
            System.debug('Exception '+ ex);
            CustomExceptionData data = new CustomExceptionData('MyCustomServerError', ex.getMessage(), 123);
			throw new AuraHandledException(JSON.serialize(data));
        }

    }  
    
    
    /*********************************************************************************************
    * @Description : Insert Cases and Issues.                                                    *
    * @Params      : String , String , String , String , Boolean , String                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String saveAllIssues(String InternalId, String IssueList, String CaseId, string bookingid,Boolean noBookingHeader, string bookingHeaderId){
        try{
        Case c = [select id, CaseNumber, Org_Booking__c,AccountId, ContactId from Case where id = :CaseId];
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        List<Issues__c> issuestoinsert = new List<Issues__c>();
        List<Issues__c> issues = (List<Issues__c>)System.JSON.deserializeStrict(IssueList, List<Issues__c>.Class);        
        if(noBookingHeader == null){
            noBookingHeader = false;
        }        
        if(noBookingHeader == true){
            String bkid = [Select id from Booking__c where name = :bookingHeaderId].id;
            c.Org_Booking__c = bkid;
            update c;
        }
        
       
        for(Issues__c iss: issues){
            if(iss.id == null) {
                system.debug('issue ' + iss.Issue__c );
                iss.Internal_Request__c = InternalId;
                iss.Org_Booking__c = bookingid;
                iss.Org_Case__c = c.id;            
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
    
    @AuraEnabled
    public static list < Create_Internal_Req_And_Issues.UserLookupResultWrapper > fetchLookUpValues2(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < Create_Internal_Req_And_Issues.UserLookupResultWrapper > returnWrapperList = new list < Create_Internal_Req_And_Issues.UserLookupResultWrapper > ();
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
                                Create_Internal_Req_And_Issues.UserLookupResultWrapper wrap = new Create_Internal_Req_And_Issues.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                       
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                Create_Internal_Req_And_Issues.UserLookupResultWrapper wrap = new Create_Internal_Req_And_Issues.UserLookupResultWrapper(u.Id, u.Name);
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