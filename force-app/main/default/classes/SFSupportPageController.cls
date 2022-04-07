public class SFSupportPageController{
    
    public Case caseRecord {get; set;}
    public boolean authenticatedUser {get; set;} 
    public boolean isGroupMember {get; set;}
    public boolean isSubmitted {get; set;}
    //public String requestType {get; set;}
    public String userObjStr {get;set;}
    public String userId {get;set;}
    public String caseNumber {get;set;}
    
    public boolean runOnce {get; set;}
    public Attachment attachment {
        get {
            if (attachment == null){
                attachment = new Attachment();
            }    
            return attachment;
        }
        set;   
    }
    
    public Id accSFSupportRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SF Support').getRecordTypeId();
    public Id caseChangeRequestRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Change Request').getRecordTypeId();
    public Id caseGenericRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Generic').getRecordTypeId();
    
    public SFSupportPageController(){
        runOnce = false;
        authenticatedUser = false;
        userObjStr = '';
        userId = '';
        caseNumber = '';
        caseRecord = new Case();
        isSubmitted = false;
        caseRecord.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Change Request').getRecordTypeId();
    }
    

    public pageReference createCase(){
        Account supportAccount = new Account();       
        if(checkExistingAccount(caseRecord.SuppliedEmail) == null){
            if(caseRecord.ss_Requestor_Full_Name__c.split(' ').size() > 1){
                list<String> name = caseRecord.ss_Requestor_Full_Name__c.split(' ');
                String firstName = '';
                for(integer i = 0; i < name.size() - 1; i++ ){
                    firstName += name[i] + ' ';
                }
                supportAccount.FirstName = firstName;
                supportAccount.LastName = name[name.size() - 1];
            } else if(caseRecord.ss_Requestor_Full_Name__c.split(' ').size() == 1){ 
                supportAccount.LastName = caseRecord.ss_Requestor_Full_Name__c;
            } else {
                supportAccount.LastName = caseRecord.ss_Requestor_Full_Name__c;
            }
            
            supportAccount.RecordtypeId = accSFSupportRecTypeId;
            supportAccount.PersonEmail = caseRecord.SuppliedEmail;
            insert supportAccount;
            
        } else {
            supportAccount = checkExistingAccount(caseRecord.SuppliedEmail);            
        }
        
        try {
            caseRecord.AccountId = supportAccount.Id;
            caseRecord.ContactId = supportAccount.PersonContactId;  
            caseRecord.Sprint_Cycle__c = [select id,name from ss_Sprint__c where name = 'To be Planned' limit 1].Id; 
            if(caseRecord.ss_Request_Type__c == 'Enhancement'){
                caseRecord.RecordTypeId = caseChangeRequestRT;
            }else if(caseRecord.ss_Request_Type__c == 'General Enquiry/Suggestion'){
                caseRecord.RecordTypeId = caseGenericRT;
            }
            system.debug(caseRecord);
            insert caseRecord;
            caseNumber = [select id,casenumber from case where id =: caseRecord.Id limit 1].CaseNumber;
            isSubmitted = true;
            if(attachment.Name != ''){
                attachment.ParentId = caseRecord.Id;
                insert attachment;
            }            
        } catch (exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        return null;
    }
    
    public Account checkExistingAccount(String requestorEmail){
        String query = 'SELECT Id, PersonEmail, FirstName, LastName, PersonContactId FROM Account WHERE PersonEmail LIKE \'%' + requestorEmail + '%\' AND RecordtypeId = \'' + accSFSupportRecTypeId + '\'  LIMIT 1 ';
        List<Account> accList = Database.query(query);
        system.debug(accList);
        if(!accList.isEmpty()){
            return accList[0];
        }else{
            return null;
        }
        
    } 
    
    public void validateUser(){
        if(userId != ''){           
            Map<String, Object> userFieldMap = (Map<String, Object>)System.JSON.deserializeUntyped(userObjStr);
            system.debug(userFieldMap.keyset());
            if(!String.isEmpty((String)userFieldMap.get('full_name'))) {
                caseRecord.ss_Requestor_Full_Name__c = (String)userFieldMap.get('full_name');
            }
            if(!String.isEmpty((String)userFieldMap.get('email'))) {
                caseRecord.SuppliedEmail = (String)userFieldMap.get('email'); 
            }
            boolean yammerAcc = [select id,isYammerAccount__c,PersonEmail from account where RecordTypeId =: accSFSupportRecTypeId AND PersonEmail =: caseRecord.SuppliedEmail AND isYammerAccount__c = true limit 1].size() > 0;
            if(yammerAcc){
                authenticatedUser = true; 
                isGroupMember = false;
            }else{
                isGroupMember = true;
            }                
        }else{
            isGroupMember = true;
        }
        
    }
}