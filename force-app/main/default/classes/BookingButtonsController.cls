public class BookingButtonsController {
   //Added By Evendo for TR Case Creation from Internal Requests
    @AuraEnabled 
    public static List<Folder> getEmailFolder(){
        String foldername = '%' + Label.Template_Name_TRP + '%';
        return [SELECT Id,Name,Developername,Type FROM Folder where developername like :foldername and Type = 'Email'];
    }
    
    //Added By Evendo for TR Case Creation from Internal Requests
    @AuraEnabled 
    public static List<EmailTemplate> getEmails(String foldername){
        
        return [select id,Name,Folder.DeveloperName,DeveloperName from emailtemplate where Folder.DeveloperName = :foldername order by Name ASC];
    }
    
    
    //Added By Evendo for TR Case Creation from Internal Requests
     @AuraEnabled 
    public static String getEmailContent(String templatename){
        return [select Body from emailtemplate where Developername = :templatename].Body;
    } 
    
     @AuraEnabled 
    public static string fetchUser(){
       //List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
       //String MyProflieName = PROFILE[0].Name;
        return userinfo.getFirstName();
    }
    
    
    //Added By Evendo
    @AuraEnabled
    public static String createServiceRequestController(string subject, string status, string description, string caseOwner,string bookingId,string accountId, string type, Boolean sendSMS){
        Case c = new Case();
        String recordTypeId = [Select id from RecordType where developername = 'Travel_Republic_Service_Request'].id;
        c.RecordTypeId = recordTypeId;
        c.Org_Case_Status__c = status;
        c.Subject = subject;
        c.Description = description;
        c.AccountId = accountID;
        c.Category__c = type;
        //c.OwnerId = caseOwner;
        c.Org_Booking__c = bookingId;
        insert c;
        
        System.debug('CCDebug');
		System.debug('Case for CC ' + c.id);
        System.debug('description ' + description);
        System.debug('send SMS ' + sendSMS);
        
        
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Service_Request__c = c.id;
        cc.Message__c = description;
        cc.Send_SMS__c = sendSMS;
        insert cc;
        
        c.OwnerId = caseOwner;
        update c;
        
        return c.id;
    }
    
    //Added By Evendo
     @AuraEnabled
    public static BookingButtonsController.UserLookupResultWrapper fetchUserInfo(){
        BookingButtonsController.UserLookupResultWrapper wrap = new BookingButtonsController.UserLookupResultWrapper(userInfo.getUserId(), userInfo.getFirstName() + ' ' + userInfo.getLastName());
        return wrap;
    }
    
    
    //Added By Evendo
    @AuraEnabled
    public static list < CaseButtonsController.UserLookupResultWrapper > fetchLookUpValues2(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < CaseButtonsController.UserLookupResultWrapper > returnWrapperList = new list < CaseButtonsController.UserLookupResultWrapper > ();
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
                                CaseButtonsController.UserLookupResultWrapper wrap = new CaseButtonsController.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                CaseButtonsController.UserLookupResultWrapper wrap = new CaseButtonsController.UserLookupResultWrapper(u.Id, u.Name);
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

}