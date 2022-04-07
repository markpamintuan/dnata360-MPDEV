/* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS     
* v1.1        Maruf           07-Mar-2018     Uncommented code for checking case owner to show and hide accept case button
* v1.2        Mark            03-Jul-2019     updated fetchLookUpValues method to search queue by brand instead of business unit
* v1.3        Evendo          12-June-2019    get the record type id to create a case (TR)
* v1.4        Sri Bala        6-July-2019     To change the record type from Internal request to Service Request (TR)
* v1.5        Sri Bala        8-July-2019     Case owner look up on Pup and Navl Buttons on Internal Request (TR)
* v1.6        Kaavya          10-July-2019    Fix for business unit test method error
* v1.7        Sri Bala        18-July-2019    Create Follow up for TRP Service Request
* v1.8        Sri Bala        18-July-2019    Get the existing automated follow up customer communications (TR)
* v1.9        Sri Bala        19-July-2019    Delete the automated follow up customer communications (TR)
* v1.10       Mark            23-Jul-2019     T-00605 - added logic to set Email from customer to false when using clone case button
* v1.11       Evendo          8-Feb-2020      Updated the method deletefollowup to set status of Customer Communications to 'Cancelled'
* v1.12       Evendo          25-Feb-2020     PoC - Get Messaging Templates and MessagingUserID
* v1.13       Evendo          18-Mar-2020     Marking Customer Communication Pending as True on Case Button.
* v1.14       Mark            27-Apr-2021     updated fetchLookUpValues method to search user by brand instead of business unit
* v1.15       Mark            28-Jul-2021     added method updateGroupsEnquiryEmailSent
**************************************************************************************************/
public without sharing class CaseButtonsController {
   /**************************************************************************************************
* Name               : isTeamLeadRole 
* Description        : Returns boolean based on the logged in user Role 
* Params             : -
* Return             : Boolean
**************************************************************************************************/ 
    @AuraEnabled
    public static boolean isTeamLeadRole(){
        boolean isTL = false; 
        String uRoleId = UserInfo.getUserRoleId();
        if(uRoleId != null && uRoleId != ''){
            UserRole ur = [select id, name, developername from UserRole where id=: uRoleId];
            if(ur <> null && ur.developername <> null && ur.developername.contains('Team_Lead')){
                isTL = true;
            }
        }
        return isTL;
    }
/**************************************************************************************************
* Name               : isNonAAAgent 
* Description        : Returns boolean based on the logged in user 
* Params             : -
* Return             : Boolean
**************************************************************************************************/
    @AuraEnabled
    public static boolean isNonAAAgent(){
        boolean nonAAAgent = false;
        String uRoleId = UserInfo.getUserRoleId();
        if(uRoleId != null && uRoleId != ''){
            UserRole ur = [SELECT DeveloperName FROM UserRole WHERE Id=: uRoleId];  
            if(ur <> null && ur.DeveloperName <> null && ur.DeveloperName != 'AA_Agent'){
                nonAAAgent = true;
            }
        }
        return nonAAAgent;
    }
/**************************************************************************************************
* Name               : displayNewBookingButton 
* Description        : Returns boolean based in the logged user
* Params             : -
* Return             : Boolean
**************************************************************************************************/
    @AuraEnabled
    public static boolean displayNewBookingButton(){
        /*set<String> profileNames = new set<String>{ 'System Administrator', 
                                                    'dTME - Retail Agent', 
                                                    'dTME - Retail Manager'};   */   

       User usr = [ SELECT  Id, Profile.Name FROM User WHERE Id=:Userinfo.getUserId() limit 1];
        
        return true;

    }
    /**************************************************************************************************
    * Name               : fetchMessagingTemplate
    * Description        : Returns Messaging Templates
    * Params             : -
    * Return             : Map<String,String>
    **************************************************************************************************/
    //1.12     
    @AuraEnabled 
    public static Map<string,string> fetchMessagingTemplate(String caseId){
        system.debug(caseId);
        Case casewithchannel = [Select Messaging_User__r.MessagingChannelId from Case where id = :CaseId];
        String channelid = casewithchannel.Messaging_User__r.MessagingChannelId;
        Map<String,String> templateMap = new Map<String,String>();
        for(Messaging_Template__mdt mtmdt: [select master_label__c,developer_name__c from Messaging_Template__mdt where ChannelId__c =:channelid]){
            templateMap.put(mtmdt.master_label__c,mtmdt.developer_name__c);
        }
        
        return templateMap;
    }
    
    /**************************************************************************************************
    * Name               : getTemplateBody
    * Description        : Returns Messaging Template Body
    * Params             : String
    * Return             : String
    **************************************************************************************************/   
    //1.12 
    @AuraEnabled 
    public static String getTemplateBody(String templateName){
        String templateBody = '';
        if(templateName != ''){
            templateBody = [select messaging_body__c from Messaging_Template__mdt where Developer_name__c = :templatename].messaging_Body__C;
        }
        
        return templateBody;
    }
    
    
    /**************************************************************************************************
    * Name               : updateTemplateOnCase
    * Description        : updates the templatename on case
    * Params             : String,String
    * Return             : String
    **************************************************************************************************/ 
    //1.12 
    @AuraEnabled 
    public static String updateTemplateOnCase(String templateName,String caseId){
        Case c = [select id,Messaging_Template_Name__c,Send_Messaging_Notification__c from Case where id =:caseId];
        c.Messaging_Notification_Last_Sent_Date__c = datetime.now();
        c.Messaging_Template_Name__c = templateName;
        update c;
        
        return 'Success';
    }
   
    /**************************************************************************************************
    * Name               : fetchUserId 
    * Description        : Returns logged in user id
    * Params             : -
    * Return             : String
    **************************************************************************************************/    
    @AuraEnabled 
    public static string fetchUserId(){
       return userinfo.getUserId();
    }
    
    /**************************************************************************************************
    * Name               : markCCPTrue 
    * Description        : Sets Customer Communication Pending to true
    * Params             : -
    * Return             : String
    **************************************************************************************************/    
    //v1.13    
    	@AuraEnabled 
        public static void markCCPTrue(String caseid){
           Case c = [Select id,Customer_Communication_Pending__c from Case where id = :caseid];
            c.Customer_Communication_Pending__c = true;
            update c;
        }
    
/**************************************************************************************************
* Name               : fetchUser 
* Description        : Returns logged in user profile name
* Params             : -
* Return             : String
**************************************************************************************************/    
    @AuraEnabled 
    public static string fetchUser(){
       List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
       String MyProflieName = PROFILE[0].Name;
       return MyProflieName;
    }
/**************************************************************************************************
* Name               : fetchUser2 
* Description        : Returns logged in user first name
* Params             : -
* Return             : String
**************************************************************************************************/    
    @AuraEnabled 
    public static string fetchUser2(){
       //List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
       //String MyProflieName = PROFILE[0].Name;
        return userinfo.getFirstName() ;
    }
/**************************************************************************************************
* Name               : getDerwentLookupCode 
* Description        : Returns lookup code 
* Params             : String
* Return             : String
**************************************************************************************************/    
    @AuraEnabled 
    public static String getDerwentLookupCode(string typeString){
        system.debug('### Entering getDerwentLookupCode with typeString: ' + typeString);
        string tempInput = '%' + typeString + '%';
     
        try{
            Lookup__c lu = new Lookup__c();
            lu = [SELECT Name, Code__c FROM Lookup__c WHERE Name LIKE :tempInput limit 1];
            system.debug('### lu: ' + lu);
            if(lu.Code__c != null){
                return lu.Code__c;  
            }else{
                return null;
            } 
        }catch(Exception e){
            system.debug('### getDerwentLookupCode Exception: ' + e);  
            return null;
        }
    }
    /**************************************************************************************************
* Name               : getRecordTypeId 
* Description        : Returns case record type id 
* Params             : String
* Return             : String
**************************************************************************************************/
    //v1.3
    //Get Record Type ID
    @AuraEnabled 
    public static String getRecordTypeId(string recordTypeName) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return devRecordTypeId;
    }
    //v1.4
    //Added by SB
    /**************************************************************************************************
* Name               : updateCaseRecordType 
* Description        : creates a customer communication and updates case record type to service request
* Params             : Case,Boolean,String,String,Boolean,String,String
* Return             : Case
**************************************************************************************************/
     @AuraEnabled 
    public static Case updateCaseRecordType(Case caseRec,Boolean isPuP,String TempText,String seluserorqueue,Boolean sendSMS,String subject, String category) {
        try{
            system.debug('brand @@'+caseRec.Org_Brand__c);
            system.debug('TempText'+TempText);
            system.debug('seluserorqueue'+seluserorqueue);
            Customer_Communication__c custCom = new Customer_Communication__c();
            custCom.Service_Request__c = caseRec.Id;
            custCom.Response_Required__c = true;
            custCom.Send_SMS__c = sendSMS;
            custCom.Message__c = TempText;
            
            string recordTypeName = 'Travel Republic - Service Request';
            
            caseRec.Subject = subject;//'Please contact us regarding your booking - ' + caseRec.Org_Booking__r.Name;
            if(isPuP)
                caseRec.Category__c = 'Price Up (PUP)';
            else 
                caseRec.Category__c = 'Not Available (NAVL)';
            if(seluserorqueue <> null || seluserorqueue <> ''){        
                caseRec.OwnerId = seluserorqueue;
            }
            caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            system.debug('caseRec.RecordTypeId '+caseRec.RecordTypeId);
            insert custCom;
            update caseRec; 
            system.debug('caseRec'+caseRec);
            return caseRec;
        }
        catch(Exception e){
            system.debug('Exception'+e);
            System.debug('Error Line Number ==> '+e.getLineNumber());
            return null;
        }
    }
  /**************************************************************************************************
* Name               : createFollowUp 
* Description        : creates a scheduled customer communication
* Params             : Case,Datetime,String,Boolean
* Return             : String
**************************************************************************************************/  
    //v1.7
    @AuraEnabled
    public static String createFollowUp(Case caseRec,Datetime followUpDate,string description,Boolean sendSMS){
        system.debug(caseRec);
        system.debug(followupDate);
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Service_Request__c = caseRec.id;
        cc.Message__c = description;
        cc.Follow_Up_Date__c = followUpDate;
        cc.Send_SMS__c = sendSMS;
        
        cc.Response_Required__c = true;
        cc.Status__c = 'Scheduled';
        insert cc;
        
        return cc.id;
    } 
    /**************************************************************************************************
* Name               : updateFollowUp 
* Description        : update Follow up date on customer communication
* Params             : Datetime,String,String
* Return             : String
**************************************************************************************************/
    //v1.9
    @AuraEnabled
    public static String updateFollowUp(Datetime followUpDate,string description,string custComm){
        Customer_Communication__c cc = [Select Id,Service_request__c,Status__c,Message__c,Follow_Up_Date__c from Customer_Communication__c where Id =: custComm];
        cc.Follow_Up_Date__c = followUpDate;
        cc.Message__c = description;
       
        try{
            update cc;
            return cc.id;
        }
        catch(Exception e){
            return null;
        }
    }
   /**************************************************************************************************
* Name               : deleteFollowUp 
* Description        : updates the status of customer communication to cancelled
* Params             : String
* Return             : String 
**************************************************************************************************/ 
    //v1.10
    //v1.11
    @AuraEnabled
    public static String deleteFollowUp(string custComm){
        List<Customer_Communication__c> cc = [Select Id,Service_request__c,Status__c,Message__c,Follow_Up_Date__c from Customer_Communication__c where Id =: custComm];
        List<Customer_Communication__c> cctoupdate = new List<Customer_Communication__c>();
        for(Customer_Communication__c ccs : cc){
            ccs.Status__c = 'Cancelled';
            cctoupdate.add(ccs);
        }
        try{
            if(cctoupdate.size()>0)
                update cctoupdate;
            return null;
        }
        catch(Exception e){
            return null;
        }
    }
    //v1.8
    /**************************************************************************************************
* Name               : getFollowUpCustomerCommunication 
* Description        : Queries scheduled customer communication
* Params             : String
* Return             : Customer_Communication__c
**************************************************************************************************/
    @AuraEnabled
    public static Customer_Communication__c getFollowUpCustomerCommunication(String caseRec){
        system.debug('caseRec'+caseRec);
        Customer_Communication__c cc =[Select Id,Service_request__c,Status__c,Message__c,Follow_Up_Date__c from Customer_Communication__c where Service_request__c =: caseRec and Status__c = 'Scheduled' LIMIT 1];
        return cc;
    
    }
    /**************************************************************************************************
* Name               : fetchLookUpValuesTR 
* Description        : Returns list of all the open cases linked to the account
* Params             : String,String,String
* Return             : List<CaseButtonsController.UserLookupResultWrapper>
**************************************************************************************************/
     //v1.5   
    @AuraEnabled
    public static list <CaseButtonsController.UserLookupResultWrapper > fetchLookUpValuesTR(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < CaseButtonsController.UserLookupResultWrapper > returnWrapperList = new list < CaseButtonsController.UserLookupResultWrapper > ();
        String searchKey = '%' + searchKeyWord + '%';
        string bunit = 'TRP';
            
                    
                    system.debug('searchType2::' + searchType);
                    if(searchType == 'Queue'){
                        system.debug('enter3::');
                        
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
  
    //end
 /**************************************************************************************************
* Name               : createCaseTest 
* Description        : create child case and links to the existing parent case
* Params             : String
* Return             : String
**************************************************************************************************/  
    @AuraEnabled 
    public static String createCaseTest(string caseId){
        system.debug('###Case Id Recieved' + caseId);
   
        try{
            Case originalcase = new Case();
          //  originalcase = [SELECT Id,RecordTypeId,Org_Business_Unit_Text__c FROM Case WHERE Id = :caseId];
            string ReqQuery = getCreatableFieldsSOQL('Case');
            
            ReqQuery+=' where Id = :caseId';
            originalcase = database.query(ReqQuery);
            system.debug('### case: ' + originalcase);
            if(originalcase.Id != null){
                Case newcase = new Case();
                //newcase.Org_Booking__c = originalcase.Org_Booking__c;
                newcase.Subject = 'Issue Regarding ' + originalcase.CaseNumber;
                //newcase.RecordTypeId = [select Id from RecordType where developername = 'Travel_Republic_Issue'].id;               
                newcase.ParentId = originalcase.Id;
                newcase.AccountId = originalcase.AccountId;
                newcase.Org_Current_Team_Name__c = originalcase.Org_Current_Team_Name__c;
                newcase.Org_Original_Team_Name__c = originalcase.Org_Original_Team_Name__c;
                insert newcase;
                system.debug('new issue case : ' + newcase);
                return newcase.Id;  
            }else{
                return null;
            } 
        }catch(Exception e){
            system.debug('### getDerwentLookupCode Exception: ' + e);  
            return null;
        }
    }
    
/**************************************************************************************************
* Name               : cloneCaseTest 
* Description        : Clones the existing case and returns the case id
* Params             : String
* Return             : String
**************************************************************************************************/    
     @AuraEnabled 
    public static String cloneCaseTest(string caseId){
        system.debug('###Case Id Recieved' + caseId);
   
        try{
            Case originalcase = new Case();
          //  originalcase = [SELECT Id,RecordTypeId,Org_Business_Unit_Text__c FROM Case WHERE Id = :caseId];
            string ReqQuery = getCreatableFieldsSOQL('Case');
            
            ReqQuery+=' where Id = :caseId';
            originalcase = database.query(ReqQuery);
            system.debug('### case: ' + originalcase);
            if(originalcase.Id != null){
                Case newcase = originalcase.clone();
                newcase.Org_Booking__c = null;
                newcase.ParentId = originalcase.Id;
                newcase.Org_Current_Team_Name__c = originalcase.Org_Current_Team_Name__c;
                newcase.Org_Original_Team_Name__c = originalcase.Org_Original_Team_Name__c;
                newcase.IsClone__c = true;
                newcase.Org_Email_From_Customer__c = false; //v1.10
                insert newcase;
                system.debug('new clone case : ' + newcase);
                return newcase.Id;  
            }else{
                return null;
            } 
        }catch(Exception e){
            system.debug('### getDerwentLookupCode Exception: ' + e);  
            return null;
        }
    }
 /**************************************************************************************************
* Name               : getCreatableFieldsSOQL 
* Description        : Returns the fields that are writable seggregated by ,
* Params             : String
* Return             : String
**************************************************************************************************/   
     public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                // if (fd.isCreateable()){ // field is creatable
                selectFields.add(fd.getName());
                //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
        
    }
    
 /**************************************************************************************************
* Name               : caseOwnerNotMatching 
* Description        : Returns boolean if the case owner is not matching
* Params             : String
* Return             : Boolean
**************************************************************************************************/     
    @AuraEnabled
        public static boolean caseOwnerNotMatching(string cid){
        boolean notmatched = true;
        if(cid <> null && cid <> ''){
            
            string uid = userinfo.getUserId();
            case cse = [select id, ownerid from case where id=: cid];
            //uncommented code in  v1.1
            if(cse <> null){
                if(uid <> cse.ownerid){
                    notmatched = true;
                }
                else{
                    notmatched = false;
                }
            } 
        }
        system.debug('notmatched:::' + notmatched);
        return notmatched;
    }
 /**************************************************************************************************
* Name               : getselectOptions 
* Description        : Returns list of options of the selected field
* Params             : String
* Return             : List<String>
**************************************************************************************************/   
    @AuraEnabled
    public static List < String > getselectOptions(string fld) {
        //system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = Schema.Case.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
/**************************************************************************************************
* Name               : changeCaseOwner 
* Description        : updates the case with new case owner Id
* Params             : String
* Return             : -
**************************************************************************************************/    
    @AuraEnabled
    public static void changeCaseOwner(string cid) {
        if(cid <> null && cid <> ''){
            
            string uid = userinfo.getUserId();
            case cse = [select id, ownerid from case where id=: cid];
            if(cse <> null){
                cse.OwnerId = uid;
                update cse;
            }
        }
    }
/**************************************************************************************************
* Name               : changeOwner_RT 
* Description        : updates the case owner on accepting the case
* Params             : String,String,String
* Return             : -
**************************************************************************************************/    
    @AuraEnabled 
    public static void changeOwner_RT(string cid, string seluserorqueue, string selrt){
        system.debug('seluserorqueue:::' + seluserorqueue);
        system.debug('selrt:::' + selrt);
        if(cid <> null && cid <> ''){
            case cse = [select id, ownerid, recordtypeid from case where id=: cid];
            if(cse <> null){
                if(seluserorqueue <> null && seluserorqueue <> ''){
                    cse.ownerid = seluserorqueue;
                }
                if(selrt <> null && selrt != ''){
                    cse.recordtypeid = selrt;
                }
                update cse;
            }
        }
    }  
/**************************************************************************************************
* Name               : reassignOwner 
* Description        : reassigns the case owner and updates the case with new owner Id
* Params             : String,String,String,Boolean
* Return             : -
**************************************************************************************************/    
    @AuraEnabled 
    public static void reassignOwner(string cid, string seluserorqueue, string selrt, Boolean sendEmail){
        system.debug('seluserorqueue:::' + seluserorqueue);
        system.debug('selrt:::' + selrt);
        system.debug('sendEmail:::' + sendEmail);
        if(cid <> null && cid <> ''){
            case cse = [select id, ownerid, recordtypeid from case where id=: cid];
            if(cse <> null){
                if(seluserorqueue <> null && seluserorqueue <> ''){
                    cse.ownerid = seluserorqueue;
                    cse.Send_Notification_Email__c = sendEmail;
                }
                if(selrt <> null && selrt != ''){
                    cse.recordtypeid = selrt;
                }
                update cse;
            }
        }
    }  
/**************************************************************************************************
* Name               : fetchCaseRTValues 
* Description        : Returns list CaseButtonsController.CaseRTWrapper
* Params             : -
* Return             : List<CaseButtonsController.CaseRTWrapper>
**************************************************************************************************/    
    @AuraEnabled
    public static list < CaseButtonsController.CaseRTWrapper > fetchCaseRTValues(){
        list < CaseButtonsController.CaseRTWrapper > returnWrapperList = new list < CaseButtonsController.CaseRTWrapper > ();
        List<SelectOption> recordTypes = new List<SelectOption>();
        returnWrapperList.add(new CaseButtonsController.CaseRTWrapper('', '--None--'));
        for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable() && info.getName() <> 'Master') {
                returnWrapperList.add(new CaseButtonsController.CaseRTWrapper(info.getRecordTypeId(), info.getName()));
            }
        }
        
        return returnWrapperList;
    }
/**************************************************************************************************
* Name               : fetchLookUpValues 
* Description        : Returns list of UserLookupResultWrapper 
* Params             : String,String,String
* Return             : list < CaseButtonsController.UserLookupResultWrapper >
**************************************************************************************************/    
    @AuraEnabled
    public static list < CaseButtonsController.UserLookupResultWrapper > fetchLookUpValues(String searchKeyWord, String cid, String searchType) {
        system.debug('searchType:::::' + searchType);
        
        list < CaseButtonsController.UserLookupResultWrapper > returnWrapperList = new list < CaseButtonsController.UserLookupResultWrapper > ();
        String searchKey = '%' + searchKeyWord + '%';
        //string bunit = '';
        string brand = ''; //v1.2
        system.debug('cid::: ' + cid);
        system.debug(cid);
        if(cid <> null && cid <> ''){
            Case cse = [select id, RecordTypeId, RecordType.Name, Org_Business_Unit__c, Org_Brand__c from Case where id=: cid];
            system.debug('cse.Org_Brand__c::: ' + cse.Org_Brand__c);
            if(cse <> null && cse.Org_Brand__c <> null){
                system.debug('enter1::');
                brand = cse.Org_Brand__c; //v1.2
                system.debug(brand);
                if(brand <> ''){
                    system.debug('enter2::');
                    system.debug('searchType2::' + searchType);
                    if(searchType == 'Queue'){
                        system.debug('enter3::');
                        list<Business_Unit__c> bulist = [SELECT Id,
                                                                Queue_ID__c,
                                                                Org_Queue_Name__c, 
                                                                Org_Business_Unit_Team__c,
                                                                Org_Business_Unit_Team__r.name
                                                            FROM Business_Unit__c
                                                            WHERE RecordType.Name = 'Team'
                                                            AND Org_Brand__c =: brand
                                                            AND Org_Queue_Name__c like: searchKey
                                                            AND IsActive__c = true]; //v1.2
                        system.debug('bulist::: ' + bulist);
                        if(bulist <> null && !bulist.isEmpty()){
                            for(Business_Unit__c bu: bulist){
                                CaseButtonsController.UserLookupResultWrapper wrap = new CaseButtonsController.UserLookupResultWrapper(bu.Queue_ID__c, bu.Org_Queue_Name__c);
                                returnWrapperList.add(wrap);
                            }
                        }
                        
                    
                    }
                    else if(searchType == 'User'){
                        string bunit=cse.Org_Business_Unit__c; //v1.6 variable for business unit
                        string soql = 'SELECT Id, Name, Business_Unit__c FROM User WHERE Name LIKE: searchKey and Brand__c = \'' + brand + '\''; //v1.14
                        list<User> usrs = (list<User>)Database.query(soql);
                        if(usrs <> null && !usrs.isEmpty()){
                            for(User u: usrs){
                                CaseButtonsController.UserLookupResultWrapper wrap = new CaseButtonsController.UserLookupResultWrapper(u.Id, u.Name);
                                returnWrapperList.add(wrap);
                            }
                        }
                    }
                    
                }
            }
            
        }
        
        system.debug('returnWrapperList::::::' + returnWrapperList);
        return returnWrapperList;
    }
    
 /**************************************************************************************************
* Name               : getEmailFolder 
* Description        : Returns list of all trp email folder 
* Params             : -
* Return             : List<Folder>
**************************************************************************************************/   
    //Added By Evendo for TR Case Creation from Internal Requests
    @AuraEnabled 
    public static List<Folder> getEmailFolder(){
        String foldername = '%' + Label.Template_Name_TRP + '%';
        return [SELECT Id,Name,Developername,Type FROM Folder where developername like :foldername and Type = 'Email'];
    }
/**************************************************************************************************
* Name               : getEmails 
* Description        : queries all the email templates in the folder and returns all the templates
* Params             : String
* Return             : List<EmailTemplate>
**************************************************************************************************/    
    //Added By Evendo for TR Case Creation from Internal Requests
    @AuraEnabled 
    public static List<EmailTemplate> getEmails(String foldername){
        return [select id,Name,Folder.DeveloperName,DeveloperName from emailtemplate where Folder.DeveloperName = :foldername order by Name];
    }
/**************************************************************************************************
* Name               : getEmailContent 
* Description        : queries email template and returns body
* Params             : String
* Return             : String
**************************************************************************************************/    
    
    //Added By Evendo for TR Case Creation from Internal Requests
     @AuraEnabled 
    public static String getEmailContent(String templatename){
        return [select Body from emailtemplate where Developername = :templatename].Body;
    }
    
/**************************************************************************************************
* Name               : createParentCaseController 
* Description        : creates parent case and links it to the child case
* Params             : String,String,String,String,String,String
* Return             : String
**************************************************************************************************/    
    //Added By Evendo
    @AuraEnabled
    public static String createParentCaseController(string subject, string status, string description, string caseOwner,string childCaseId, string type){
        Case c = new Case();
        String recordTypeId = [Select id from RecordType where developername = 'Travel_Republic_Service_Request'].id;
        c.RecordTypeId = recordTypeId;
        c.Org_Case_Status__c = status;
        c.Subject = subject;
        c.Description = description;
        c.Category__c = type;
        c.OwnerId = caseOwner;
        insert c;
        
        Case childcase = [select id,parentid,Category__c,Org_Booking__c,AccountId from Case where id = :childCaseId];
        childcase.ParentId = c.id;
        childcase.Category__c = type;
        update childcase;
        try{
            c.Org_Booking__c = childcase.Org_Booking__c;
            
            update c;
        }catch(exception e){
            
        }
        
        try{
            c.AccountId = childcase.AccountId;
            
            update c;
        }catch(exception e){
            
        }
        
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Service_Request__c = c.id;
        cc.Message__c = description;
        insert cc;
        
        return c.id;
    }
/**************************************************************************************************
* Name               : createParentCaseNewController 
* Description        : creates a parent case and links it to the child case.
* Params             : String,String,String,Boolean,String
* Return             : String
**************************************************************************************************/    
    
    //Added By Evendo
    @AuraEnabled
    public static String createParentCaseNewController(string subject, string description, string childCaseId,Boolean sendSMS,String category){
        Case c = new Case();
        String recordTypeId = [Select id from RecordType where developername = 'Travel_Republic_Service_Request'].id;
        c.RecordTypeId = recordTypeId;
        //c.Org_Case_Status__c = 'Pending Response';
        c.Subject = subject;
        c.Description = description;
        c.Category__c = category;
        insert c;
        
        Case childcase = [select id,parentid,Category__c,Org_Booking__c,AccountId from Case where id = :childCaseId];
        childcase.ParentId = c.id;   
        update childcase;
        try{
            c.Org_Booking__c = childcase.Org_Booking__c;
            
            update c;
        }catch(exception e){
            
        }
        
        try{
            c.AccountId = childcase.AccountId;
            
            update c;
        }catch(exception e){
            
        }
        
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Service_Request__c = c.id;
        cc.Message__c = description;
        cc.Send_SMS__c = sendSMS;
        insert cc;
        
        return c.id;
    }
/**************************************************************************************************
* Name               : fetchUserInfo 
* Description        : Returns CaseButtonsController.UserLookupResultWrapper based on logged in user info
* Params             : -
* Return             : CaseButtonsController.UserLookupResultWrapper
**************************************************************************************************/    
    //Added By Evendo
     @AuraEnabled
    public static CaseButtonsController.UserLookupResultWrapper fetchUserInfo(){
        CaseButtonsController.UserLookupResultWrapper wrap = new CaseButtonsController.UserLookupResultWrapper(userInfo.getUserId(), userInfo.getFirstName() + ' ' + userInfo.getLastName());
        return wrap;
    }
    
/**************************************************************************************************
* Name               : getOpenCases 
* Description        : Queries all the business unit and return user
* Params             : String,String,String
* Return             : list <CaseButtonsController.UserLookupResultWrapper >
**************************************************************************************************/    
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
    
/**************************************************************************************************
* Name               : fetchLookUpValuesForSubject 
* Description        : Returns list of subject based on search word and category id
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
* Name               : CaseRTWrapper 
* Description        : Wrapper Class
* Params             : -
* Return             : -
**************************************************************************************************/    
    public class CaseRTWrapper{
        @AuraEnabled
        public string rtid {get; set;}
        @AuraEnabled
        public string rtname {get; set;}
        
        public CaseRTWrapper(string rtid, string rtname){
            this.rtid = rtid;
            this.rtname = rtname;
        }
    }
/**************************************************************************************************
* Name               : UserLookupResultWrapper 
* Description        : Wrapper class
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

    //v1.15
    @AuraEnabled
    public static void updateGroupsEnquiryEmailSent(string caseId) {

        if(caseId <> null && caseId <> ''){
            Case cse = [SELECT Groups_Enquiry_Email_Sent__c FROM Case WHERE Id=: caseId];
            if(cse <> null){
                cse.Groups_Enquiry_Email_Sent__c = true;
                update cse;
            }
        }
        
    }
    
}