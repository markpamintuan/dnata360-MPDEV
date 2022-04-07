/**************************************************************************************************
* Name               : SendQuotationController 
* Description        : This is the class for emailing the quotation when Send button is clicked           
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Evendo
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS                
* v1.0        Evendo          08-Aug-2018     Initial version
* v1.1        Kaavya          01-Oct-2018     T-00223 - Fix for quote email thread id                                                
* v1.2		  Sri Bala 		  19-02-2018	  Quote Email THread ID  
* v1.3        Sri Bala        22-Aug-2019     Org Wide address for TRP
* v1.4		  Mark			  11-Mar-2020	  T-00970
* v1.5        PwC             19-Mar-2020     Quote PDF for TRP
* v1.6        Mark            25-Nov-2020     changed default sender for all dnata quotes to a specific mailbox
**************************************************************************************************/
global class SendQuotationController {
    
    webservice static String sendQuote(String qId, String accId, String caseId, String title){
        return sendQuoteToCustomer( qId, accId, caseId, title, null);
    }
    
/**************************************************************************************************
* Name               : sendQuoteToCustomer 
* Description        : 
* Params             : String,String,String,String,String
* Return             : String
**************************************************************************************************/
    public static String sendQuoteToCustomer(String qId, String accId, String caseId, String title, String emailText){
    
        map<string,string> orgwideMap = new map<string,string>();
        map<Id,String> caseMap = new Map<Id,String>();
        List<Business_Unit__c> busUnitList  = new List<Business_Unit__c>();
         List<Case> caseList = new List<Case>(); //v1.3 

        caseList = [Select Id,Org_Brand__c from Case where Id =:caseId]; //v1.3
        if(caseList.size() > 0){
            for(Case cs : caseList){
                caseMap.put(cs.Id,cs.Org_Brand__c);
            }
        }
		// Query all the org-wide email address
        for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) {
        // add to the map   
        orgwideMap.put(owa.Address,owa.id);
        system.debug('### orgwideMap: ' + orgwideMap);
        }
		//query the user based on logged in userinfo
        List<user> userList=[select id,Team_Name__c, Store__c from user where id=:userinfo.getUserId()];
		// get record type id
        Id quoteRecordTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Quote - Email Addresses').getRecordTypeId();
        system.debug('### userList: ' + userList);
        system.debug('### quoteRecordTypeId: ' + quoteRecordTypeId);

        if(userList.size() > 0){
       // query business unit 
        busUnitList = [select Org_Team_Name__c,Org_Email__c from Business_Unit__c where Org_Team_Name__c =:userList[0].Team_Name__c and recordtypeid=:quoteRecordTypeId];
        system.debug('### busUnitList: ' + busUnitList);
        
        }
  		// query email template
        EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Booking_Quote'];
 
		//v1.4
        map<String,String> storeNameEmailMap = new map<String,String>();
        for(User_Role_And_Store_Map__mdt customMetadataType : [SELECT Store_Name__c, Store_Contact_Number__c, Store_Email__c FROM User_Role_And_Store_Map__mdt]){
            if(customMetadataType.Store_Email__c != ''){
            	storeNameEmailMap.put(customMetadataType.Store_Name__c,customMetadataType.Store_Email__c);
            }
        }        
        //End - v1.4                  
        
		system.debug('### emailTemplate: ' + emailTemplate);
        
      
        String htmlBody = emailText;
        system.debug('before modifying@@@'+caseId);
        system.debug('threadid@@@'+getThreadId(caseId));
        system.debug('htmlBody'+htmlBody);
        
        htmlBody = htmlBody+ getThreadId(caseId);
        PageReference pdf;
        if(caseMap.get(caseId) == 'trp')
             pdf = Page.TRP_Quote_PDF;
        else
             pdf = Page.Quote;
        pdf.getParameters().put('Id', qId);

        if(accId.startsWith('001')){
            Account a = [Select Id, PersonContactId From Account Where Id = :accId];
            accId = a.PersonContactId;
        }
        //Blob.valueOf(pdf.getContentAsPDF());
        
        Attachment attach;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(title+'.pdf');
        if(Test.isRunningTest()){
            efa.setBody(Blob.valueOf('Test'));
        }
        else{
            efa.setBody(pdf.getContentAsPDF());
        }
        //Creating an email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        //Assigning list of attachments to email
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); 
        email.targetObjectId  = accId;
        email.setSubject(title);
        email.setWhatId(caseId);

        //v1.6
        if(caseMap.get(caseId) == 'dnata'){
            if(orgwideMap.containsKey(Label.dnata_Travel_Email)){
                email.setOrgWideEmailAddressId(orgwideMap.get(Label.dnata_Travel_Email));
            }
        } else {
        //End v1.6
            if(busUnitList.size() > 0){
                if(orgwideMap.get(busUnitList[0].Org_Email__c) != null){
                  email.setOrgWideEmailAddressId(orgwideMap.get(busUnitList[0].Org_Email__c));
                }
            //v1.4
            } else {
                if(storeNameEmailMap.containsKey(userList[0].Store__c)){
                    String storeEmail = storeNameEmailMap.get(userList[0].Store__c);
                    if(orgwideMap.containsKey(storeEmail)){
                        email.setOrgWideEmailAddressId(orgwideMap.get(storeEmail));
                    }
                }
            }
        }
        
        email.setSaveAsActivity(true);
        if(caseMap.get(caseId) != 'trp')
            email.setCcAddresses(new List<String> {UserInfo.getUserEmail()});

        email.setHtmlBody(htmlBody);
        
         emails.Add(email);
        
        //Sending emails
        Messaging.SendEmailResult [] results = Messaging.sendEmail(emails);  
        //Getting error messages if they are
        if (!results.get(0).isSuccess()) {
        system.debug('error'+results.get(0).getErrors()[0].getMessage());
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            String errorMessage = results.get(0).getErrors()[0].getMessage();
            return errorMessage;
        }
        
        return 'OK';
    }
        
        public static String getThreadId(String caseId){
            return '[ ref:_'
                + UserInfo.getOrganizationId().left(5)
                + UserInfo.getOrganizationId().mid(10,5) + '._' // v1.1 - correcting the thread id- changed from UserInfo.getOrganizationId().mid(11,4)
                + caseId.left(5)
                + caseId.mid(9,6) + ':ref ]'; //v1.2 - correcting the thread id - changed from caseId.mid(10,5)
        }
    }