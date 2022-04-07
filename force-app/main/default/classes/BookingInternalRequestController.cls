/**************************************************************************************************
* Name               : BookingInternalRequestController                                           * 
* Description        : Controller class for the AddInternalRequestOnBooking Lightning Component.  *
* Created Date       : 23/07/2019                                                                 *
* Created By         : PWC                                                                        *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Evendo    23/07/2019      Initial Draft.  
**************************************************************************************************/
public class BookingInternalRequestController {
     
	/*********************************************************************************************
    * @Description : Get All Internal Request Cases Given a booking id.			                 *
    * @Params      : String                                             	                     *
    * @Return      : List<Case>                                                                  *
    *********************************************************************************************/    
    @AuraEnabled
    public static List<Case> getAllCase(String lstRecordId){
        List<Case> caseList = new List<Case>();
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        caseList =  [Select Id,Org_Case_Status__c,Category__c,Org_Type__c,OwnerId,Owner.Name,Subject from Case 
                        WHERE Org_Booking__r.Id =:lstRecordId and recordtypeid = :recordtypeid 
                        ORDER BY CreatedDate DESC LIMIT 50 ] ;                
        if(caseList.size() >0)
        	return caseList;
        return null;
    }
    
    
    @AuraEnabled
    public static list < BookingInternalRequestController.UserLookupResultWrapper > fetchLookUpValues2(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < BookingInternalRequestController.UserLookupResultWrapper > returnWrapperList = new list < BookingInternalRequestController.UserLookupResultWrapper > ();
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
                                BookingInternalRequestController.UserLookupResultWrapper wrap = new BookingInternalRequestController.UserLookupResultWrapper(bu.id, bu.name);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                       
                        string soql = 'select id, Name, Business_Unit__c from user where Name like: searchKey and Business_Unit__c includes ( :bunit ) ';
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                BookingInternalRequestController.UserLookupResultWrapper wrap = new BookingInternalRequestController.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }       
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
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
    
     /*********************************************************************************************
    * @Description : Insert Cases and Issues.                                                    *
    * @Params      : String , String , String , String , Boolean , String                        *
    * @Return      : String                                                                      *
    *********************************************************************************************/
    @AuraEnabled
    public static String saveAll(String InternalList, string bookingid){
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        List<Case> internalstoinsert = new List<Case>();
        Booking__c bk = [Select Id,Org_Account_Name__c from Booking__c where Id =: bookingid];
        List<Case> internals = (List<Case>)System.JSON.deserializeStrict(InternalList, List<Case>.Class);
        for(Case cs: internals){
            if(cs.id == null){
            cs.AccountId = bk.Org_Account_Name__c;
            cs.Org_Booking__c = bookingid;
            cs.RecordTypeId = recordtypeid;
            internalstoinsert.add(cs);
            }
        }
		upsert internalstoinsert;
              
        return 'Success';
    }
}