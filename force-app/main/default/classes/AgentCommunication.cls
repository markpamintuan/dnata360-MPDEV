/**************************************************************************************************
* Name               : AgentCommunication 
* Description        : Controller class for AgentCommunication lightning Component
* Created By         : Evendo
* Created Date       : 
---------------------------------------------------------------------------------------------------
*  Version           Date                          Description
* v1.0											   Initial Draft
**************************************************************************************************/
public class AgentCommunication {
    
/**************************************************************************************************
* Name               : getAllMessages 
* Description        : Returns list of customer communications which are not Scheduled linked to the case
* Params             : String
* Return             : List<CommunicationWrapper>
**************************************************************************************************/
    @AuraEnabled
    public static List<CommunicationWrapper> getAllMessages(String caseID){
        List<CommunicationWrapper> cwList = new List<CommunicationWrapper>();
        
        List<Customer_Communication__c> ccList = [SELECT Id,
                                                  Service_Request__c,
                                                  Created_By_Customer__c,
                                                  Message__c,
                                                  Response_Required__c,
                                                  CreatedById,
                                                  CreatedBy.Name,
                                                  Follow_Up_Date__c,
                                                  CreatedDate,
                                                  Status__c,
                                                  Derwent_Type__c
                                                  FROM Customer_Communication__c 
                                                  WHERE Service_Request__c = :caseID AND Status__c != 'Scheduled' and Status__c != 'Cancelled' 
                                                 Order By CreatedDate ASC];
       
        
        if(!ccList.isEmpty()){
            
            for(Customer_Communication__c cc : ccList){
                CommunicationWrapper cw = new CommunicationWrapper();
                cw.ParentID = cc.Service_Request__c;
                cw.Created_by_Customer = cc.Created_by_Customer__c;
                cw.Message = cc.Message__c;
                cw.Response_Required = cc.Response_Required__c;
                try{
                cw.Follow_Up_Date = String.valueOf(cc.Follow_Up_Date__c.formatGMT('MM/dd/yyyy hh:mm a'));
                }catch(Exception e){
                    System.debug('');
                }
                    
                cw.CreatedBy = cc.CreatedBy.Name;
             //   cw.CreatedDate = Date.valueof(cc.CreatedDate);     
                 cw.CreatedDate = cc.CreatedDate.format('MM/dd/yyyy');
                cw.CreatedTime = getCreatedTime(String.valueOf(cc.CreatedDate));
                cw.DerwentType = cc.Derwent_Type__c;
             cwList.add(cw);
            }
          }
        
        System.debug('cwList ==> '+cwList);
      return cwList;
        
    }
/**************************************************************************************************
* Name               : SaveAgentMessage 
* Description        : Creates a customer communication
* Params             : String,String,Boolean,Boolean,Boolean
* Return             : null
**************************************************************************************************/
    
    @AuraEnabled
    public static void SaveAgentMessage(String caseID, String replyMsgText, Boolean responseRequiredChbx,Boolean sendSMS){
        System.debug('caseID ==> '+caseID);
        System.debug('replyMsgText ==> '+replyMsgText);
        System.debug('responseRequiredChbx ==> '+responseRequiredChbx);
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Service_Request__c = caseID;
        cc.Message__c = replyMsgText;
        cc.Response_Required__c = responseRequiredChbx;
        cc.Send_SMS__c = sendSMS;
       
        
        try{
            insert cc;
        }
        catch(Exception ex){
            System.debug('Error Message ==> '+ex.getMessage());
            System.debug('Error Line Number ==> '+ex.getLineNumber());
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(ex.getMessage());
        }
            
    }
    
/**************************************************************************************************
* Name               : getCreatedTime 
* Description        : Return created time to the MYB Component
* Params             : String
* Return             : String
**************************************************************************************************/
    public static String getCreatedTime(String datetimeString){
        String newTimeString;
        if(datetimeString != null && datetimeString.trim() != ''){
            List<String> splitList = datetimeString.split(' ');
            List<String> splitTime = splitList[1].split(':');
            
            Integer hours = Integer.valueOf(splitTime[0]);
            if(hours >= 12){
                newTimeString = (hours - 12) + ':' + splitTime[1] + ' ' + 'PM';
            }
            else{
                newTimeString = hours + ':' + splitTime[1] + ' ' + 'AM';
            }
        }
        
        return newTimeString;
    }
    
 /**************************************************************************************************
* Name               : CommunicationWrapper 
* Description        : Wrapper class for getAllMessages()
**************************************************************************************************/   
    
    public class CommunicationWrapper {
        @AuraEnabled
        public String ParentID;
        @AuraEnabled
        public Boolean Created_by_Customer;
        @AuraEnabled
        public String Message;
        @AuraEnabled
        public String CreatedBy;
        @AuraEnabled
        public Boolean Response_Required;
        @AuraEnabled
        public String CreatedDate;
        @AuraEnabled
        public String CreatedTime;
        @AuraEnabled
        public String DerwentType;
        @AuraEnabled
        public String Follow_Up_Date;
    }
    
/**************************************************************************************************
* Name               : getEmailFolder
* Description        : Returns list of Email Folders
* Params             : -
* Return             : List<Folder>
**************************************************************************************************/
     @AuraEnabled 
    public static List<Folder> getEmailFolder(){
        String foldername = '%' + Label.Template_Name_TRP + '%';
        return [SELECT Id,Name,Developername,Type FROM Folder where developername like :foldername and Type = 'Email'];
    }
    
/**************************************************************************************************
* Name               : getEmails 
* Description        : Returns list of email templates in the selected folder
* Params             : String
* Return             : List<EmailTemplate>
**************************************************************************************************/  
    @AuraEnabled 
    public static List<EmailTemplate> getEmails(String foldername){
        return [select id,Name,Folder.DeveloperName,DeveloperName from emailtemplate where Folder.DeveloperName = :foldername order by Name ASC];
    }
    
/**************************************************************************************************
* Name               : getEmailContents
* Description        : Returns the body of the selected email template
* Params             : String
* Return             : String
**************************************************************************************************/
    @AuraEnabled 
    public static String getEmailContents(String templatename){
        return [select Body from emailtemplate where Developername = :templatename].Body;
    }
    
/**************************************************************************************************
* Name               : fetchUser 
* Description        : Returns logged in user information
* Params             : -
* Return             : Stirng
**************************************************************************************************/
     @AuraEnabled 
    public static string fetchUser(){
       //List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
       //String MyProflieName = PROFILE[0].Name;
        return userinfo.getFirstName() ;
    }
    

}