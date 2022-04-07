/**************************************************************************************************
* Name               : MassEmailSenderController                                                  * 
* Description        : Controller class for the sending Mass Emails.                              *
* Created Date       : 02/05/2019                                                                 *
* Created By         : PWC                                                                        *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Evendo    02/05/2019      Initial Draft.                                               *       
**************************************************************************************************/
public class MassEmailSenderController {
    
    
    //Variable Assignments    
    public static Boolean isSaveCase = false;
    public static Integer reportSize{get;set;}
    public static List<String> BookingRecords{get;set;}
    public static List<String> BookingIdsList{get;set;}
    public static Map<Id, String> recordtypemap {get;set;}
    public static map<String,String> BookingIdToEmails{get;set;}
       
    
    /*********************************************************************************************
    * @Description : Constructor.                                                                *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/    
    public MassEmailSenderController(){
        	BookingIdToEmails = new map<String,String>();
    }
    
    
    /*********************************************************************************************
    * @Description : Method to return list of email folders.                                     *
    * @Params      : void                                                                        *
    * @Return      : List<Folder>                                                                *
    *********************************************************************************************/
    @AuraEnabled 
    public static List<Folder> getEmailFolder(){
        String foldername = '%' + Label.Template_Name_TRP + '%';
        return [SELECT Id,Name,Developername,Type FROM Folder where developername like :foldername and Type = 'Email'];
    }
    
    
    /*********************************************************************************************
    * @Description : Method to return list of email templates given a specific emailfolder.      *
    * @Params      : void                                                                        *
    * @Return      : List<EmailTemplate>                                                         *
    *********************************************************************************************/
    @AuraEnabled 
    public static List<EmailTemplate> getEmails(String foldername){
        return [select id,Name,Folder.DeveloperName,DeveloperName from emailtemplate where Folder.DeveloperName = :foldername order by Name];
    }
    
    
    /*********************************************************************************************
    * @Description : Method to return list of reports.                                           *
    * @Params      : void                                                                        *
    * @Return      : List<Report>                                                                *
    *********************************************************************************************/
    @AuraEnabled 
    public static List<Report> fetchReports(){
        return [Select Id,DeveloperName,Name,FolderName from Report where FolderName = :System.label.TR_Report_Folder_Name];
    }
    
    
    /*********************************************************************************************
    * @Description : Method to return Email Content Body given a email template name             *
    * @Params      : String                                                                      *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled 
    public static String getEmailContents(String templatename){
        return [select Body from emailtemplate where Developername = :templatename].Body;
    }
    

    /*********************************************************************************************
    * @Description : Method to return current logged in user name                                *
    * @Params      : void                                                                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled 
    public static string fetchUser(){      
        return userinfo.getFirstName();
    }
    
   
    /*********************************************************************************************
    * @Description : Method to return record types for Travel Republic Cases                     *
    * @Params      : void                                                                        *
    * @Return      : List<String>                                                                *
    *********************************************************************************************/
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        recordtypemap = new Map<Id, String>();
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();            
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.getName().contains('Travel Republic') && (rt.getName().contains('Internal Request') || rt.getName().contains('Service Request')))
            		recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
    
    /*********************************************************************************************
    * @Description : Method to return record type id , given record type name                    *
    * @Params      : String                                                                      *
    * @Return      : Id                                                                          *
    *********************************************************************************************/
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }      
           
    /*********************************************************************************************
    * @Description : Method to create a case if a file is uploaded                               *
    * @Params      : String,String,String,String,String,String,Boolean,String                    *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
	public static String saveCase(String description,String category,String seluserorqueue,String recordtypename,string status,string subject,boolean SendSMS, string fileContents) {
        String recordtypeid;       
        Map<String,String> BookingIdToAccountId = new Map<String,String>();
        Map<String,String> CaseItems = new Map<String,String>();
        List<Case> SRtoInsert = new List<Case>();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        
        try{
            recordtypeid = [select id from RecordType where Name = :recordtypename].id;
        }catch(Exception e){
            System.debug(e);
        }
        
        Bulk_Case_Job__c bcp = new Bulk_Case_Job__c();       
        bcp.Description__c = description;
        bcp.Category__c = category;
        bcp.Request_Type__c = recordtypename;
        bcp.Subject__c = subject;
        bcp.Send_SMS__c = SendSMS;
        bcp.Case_Owner_Id__c = seluserorqueue;
        insert bcp;
        
        system.debug('fileContents : '+fileContents);
        String stringFile = EncodingUtil.urlDecode(fileContents, 'UTF-8');
        system.debug('stringFile : '+stringFile);
        Blob blobObj = blob.valueOf(stringFile);
        system.debug('blobObj'+blobObj);
         
        ContentVersion version = new ContentVersion();
    	version.Title='FileVersion';
        version.PathOnClient = 'C:\\FileVersion.csv';
        version.VersionData = blobObj;//EncodingUtil.base64Decode(stringFile);//blobObj;
        insert version;
   
        // Insert a simple post
        FeedItem post = new FeedITem();
        post.body = 'File Upload';
        post.ParentID = bcp.id;
        insert post;
    
        // Associate the file with the post
        FeedAttachment postAttachment = new FeedAttachment();
        postAttachment.FeedEntityId = post.id;
        postAttachment.Type = 'Content';
        postAttachment.RecordId = version.id;
        insert postAttachment;
               
        /**** Call batch ****/
        Database.executeBatch(new ImportBatch(blobObj,bcp),2000);
        
        return String.valueOf('Success') ;      
	}
    
    
    //Method purely for file upload debugging purposes
    //
    //
    @AuraEnabled
    public static void getFileBlob(String FileName,String FileType, Blob blobDataObj){
        System.debug('FileName :: '+FileName);
        System.debug('FileType :: '+FileType);
        System.debug('blobDataObj :: '+blobDataObj);       
    }
    
    
    /*********************************************************************************************
    * @Description : Method to check if booking ids entered are valid                            *
    * @Params      : String													                     *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
	public static String checkBookingIdList(String BookingIdList) {
    	List<String> BookingIds = BookingIdList.split('\r\n');
        try{
        	Integer j = 0;
            while (j < BookingIds.size())
            {
              if(BookingIds.get(j) == '')
              {
                BookingIds.remove(j);
              }else
              {
                j++;
              }
            }
        }catch(Exception e){
            System.debug(e);
        }
        System.debug('BookingIdList Manual ' + BookingIds);
        List<Booking__c> bookings = [Select id,Booking_ID__c from Booking__c where Booking_ID__c IN :BookingIds];
       
        //Check for no bookings
        Map<String,String> BookingIdToId = new Map<String,String>();
        List<String> noBookingIds = new List<String>();
        for(Booking__c book: bookings){
            BookingIdToId.put(book.Booking_ID__c, book.Id);
        }
        
        for(String tempbookingids:BookingIds){
            if(!BookingIdToId.containsKey(tempbookingids)){
                noBookingIds.add(tempbookingids);
            }
        }
        
        System.debug(noBookingIds);
        if(noBookingIds.size() != 0){
            return String.valueOf(noBookingIds);
        }else{
            return 'Success';
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to save case if booking ids are entered manually                     *
    * @Params      : String,String,String,String,String,String,String,Boolean                    *
    * @Return      : String                                                                      *
    *********************************************************************************************/
     @AuraEnabled
	public static String saveCaseManual(String description,String category,String BookingIdList,string seluserorqueue,String recordtypename,string status,string subject,Boolean sendSMS) {	           
        List<Case> SRToInsert = new List<Case>();
        System.debug('seluserorqueue' + seluserorqueue);
        List<String> BookingIds = BookingIdList.split('\r\n');
        try{
        	Integer j = 0;
            while (j < BookingIds.size())
            {
              if(BookingIds.get(j) == '')
              {
                BookingIds.remove(j);
              }else
              {
                j++;
              }
            }
        }catch(Exception e){
            System.debug(e);
        }
        
        System.debug(BookingIds);        
        Set<String> bookingsfinal = new Set<String>();
        bookingsfinal.addAll(BookingIds);
        BookingIds.clear();
        BookingIds.addAll(bookingsfinal);
        List<Booking__c> bookings = [Select id,Booking_ID__c from Booking__c where Booking_ID__c IN :BookingIds];       
        //Check for no bookings
        Map<String,String> BookingIdToId = new Map<String,String>();
        List<String> noBookingIds = new List<String>();
        for(Booking__c book: bookings){
            BookingIdToId.put(book.Booking_ID__c, book.Id);
        }
        
        for(String tempbookingids:BookingIds){
            if(!BookingIdToId.containsKey(tempbookingids)){
                noBookingIds.add(tempbookingids);
            }
        }        
        System.debug(noBookingIds);
        if(noBookingIds.size() != 0){
            return String.valueOf(noBookingIds);
        }        
        Bulk_Case_Job__c bcp = new Bulk_Case_Job__c();
        bcp.Description__c = description;
        bcp.Request_Type__c = recordtypename;
        bcp.Send_SMS__c = sendSMS;
        bcp.Subject__c = subject;
        bcp.Category__c = category;
        bcp.Case_Owner_Id__c = seluserorqueue;
        insert bcp;       
        List<Bulk_Case_Job_Item__c> bcclist = new List<Bulk_Case_Job_Item__c>();
        for(Booking__c book: bookings){
			Bulk_Case_Job_Item__c bca = new Bulk_Case_Job_Item__c();
            bca.BookingId__c = book.Booking_ID__c;
            bca.Bulk_Case_Job__c = bcp.id;
            bca.Status__c = 'New';
            bcclist.add(bca);
        }
        insert bcclist;
        Database.executeBatch(new MassCSRCreateBatchClass(bcp.id), 100);     
        return 'Success';
	}
    
    
    
    
    
   
    /*********************************************************************************************
    * @Description : Method to fetch lookup values for user or queue                             *
    * @Params      : String,String,String													     *
    * @Return      : List<WrapperClass>                                                          *
    *********************************************************************************************/
    @AuraEnabled
    public static list < MassEmailSenderController.UserLookupResultWrapper > fetchLookUpValues(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);        
        list < MassEmailSenderController.UserLookupResultWrapper > returnWrapperList = new list < MassEmailSenderController.UserLookupResultWrapper > ();
        String searchKey = '%' + searchKeyWord + '%';
        string bunit = 'TRP';
        system.debug('searchType2::' + searchType);
        if(searchType == 'Queue'){
             system.debug('enter3::');
             list<Group> bulist = [select Id,Name from Group where Type = 'Queue' and Name like: searchKey];
             system.debug('bulist::: ' + bulist);
             if(bulist <> null && !bulist.isEmpty()){
                  for(Group bu: bulist){
                                MassEmailSenderController.UserLookupResultWrapper wrap = new MassEmailSenderController.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }
        else if(searchType == 'User'){                       
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                MassEmailSenderController.UserLookupResultWrapper wrap = new MassEmailSenderController.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }       
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
    }
    
    
    /*********************************************************************************************
    * @Description : Method to fetch lookup values for subject.                                  *
    * @Params      : String,String,String													     *
    * @Return      : List<String>                                                                *
    *********************************************************************************************/
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
    
    
    //Wrapper Class for User Lookup
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