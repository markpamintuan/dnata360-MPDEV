/**************************************************************************************************
* Name               : EmailMessageTriggerHandler 
* Description        : This is the handler class for EmailMessage trigger         
* Created Date       : 08-Aug-2018                                                                                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        N/A          08-Aug-2018    Initial version
* v1.1        Keith        08-Aug-2018    Update Status change            
* v1.2        Keith        08-Aug-2018    Removing extra email address for mailbox only   
* v1.3        Kaavya       05-Dec-2018    Removing Re-opened status for dnata and null check for To address  
* v1.4        Keith        11-Dec-2018    Adding method to determine which email-to-case email is on an email message
* v1.5        Mark         21-Feb-2019    Added method to update marhaba Case status to Reopened once received a reply     
* v1.6        Sri Bala     24-Feb-2019    T-00419 - when an email was sent by keeping 3 mailboxes, create 3 cases
* v1.7        Sri Bala     07-Mar-2019    routing incoming email fix
* v1.8        Mark         12-Mar-2019    Added condition to exclude marhaba Cases on setting In Progress status
* v1.9        Mark         26-Mar-2019    Added method to populate Account and Contact Id for Arabian Adventures business Accounts
* v1.10       Mark         31-Mar-2019    Added method to set Arabian Adventures parent case status to Reopened and In Progress
* v1.11       Mark         23-May-2019    Added checking if SuppliedName is not populated and SuppliedName is only a 1 word string
* v1.12       Merul        28-Jul-2019    If 'To' address only have one email and Still emailToUseToFindQueue not set.
* v1.13       Keith        27-Oct-2019    Adding a check to emailmessagerecord.
* v1.14       Sri Bala     25-Nov-2019    If 'To Address' have more than one email check if it's seggregated by (',') and FromAddress null check.
* v1.15       Sri Bala     11-Dec-2019    Updating v1.13 as a part of NullPointerException fix (T-00880).
* v1.16       Sri Bala     19-Dec-2019    Update is incoming email on case irrespective of the email from supplier/customer.
* v1.17       Sri Bala     31-Dec-2019    T-00908 - Brand gets updated if To Address is an email-to-case
* v1.18       Sri Bala     01-Jan-2020    Commenting v1.17
* v1.19       Sri Bala     05-Jan-2020    Uncommenting v1.17
* v1.20       Keith        05-Jan-2020    Adding email delete logic
* v1.21       Jed          23-Feb-2020    Adding email validation logic to validate email sender with the custom meta data mapping
* v1.22       Sri Bala     24-Feb-2020    Email Headers - populate Mailbox on Email Message
* v1.24       Ravi         20-Feb-2020    Added the logic to update Orgin to Email for Email-to-Case & Case Reopening Logic
* v1.25       Mark         29-Mar-2020	  commented out getBusinessAccount method for it was already covered on B2B Account fix
* v1.26       Mark         13-Jul-2020    Added checking to only update case brand if it is blank
* v1.27       Mark         22-Nov-2020    Added checking to only update emailmessage if EmailToCaseMailbox__c field is blank
* v1.28       Mark         21-Mar-2021	  03027108 - business unit optimization
* v1.29       Mark         20-Apr-2021	  03060455 - added logic to reassign open case to omni queue when incoming email is received
**************************************************************************************************/
public class EmailMessageTriggerHandler {
	
	public static string EmailHeaderConfigAttribute = 'X-SFDC-Original-RCPT:';
	public static map<string, string> mapQueueIds = new map<string, string>();
	static Map<Id,Case> mCaseIdToCaseToUpdate = new Map<Id,Case>(); //Keeps track of case Id for updating
	static List<Case> lCasesToUpdate = new List<Case>();
	static Set<Id> setCaseIdsAggregate = new Set<Id>();
	static String dateformat = 'yyyy-MM-dd HH:mm:ss:sssZ';
	//static User runningUser = [SELECT Id, UserRole.Name FROM User WHERE Id=: UserInfo.getUserId()];
	static string useRole ='';
	static string userName ='';
	Static set<string> casId ;
	static Map<Id,Case> caseWebEmailAddressMap = new Map<Id,Case>(); //v1.16
	static List<userrole> usrRole;
	static map<id,case> casMap;
	static List<EmailMessage> eMessageToUpdate = new List<EmailMessage>(); //v1.22
	public static void onBeforeInsert(List<EmailMessage> msgs){
        
		//v1.24
		CaseTriggerHandler.getCaseConfigs();
		getQueueDetails();
		validateEmail(msgs); //v1.21        
		List<EmailMessage> lEmailMessagesToUpdate = new List<EmailMessage>();
		BusinessUnitMappingUtility.populateBusinessQueueMap();
		casId = new set<string>();
		usrRole = new List<userrole>();
		for(EmailMessage ms:msgs){
			casId.add(ms.parentId);
		}
        
		casMap = new map<id,case>([select id,ownerid,owner.name,owner.userrole.name from case where id in:casId ]);
        
		useRole=UserInfo.getUserRoleId();
		usrRole=[select id,name from userrole where id=:useRole];
		userName = UserInfo.getUserId();
        
        
		for(EmailMessage msg : msgs){            
			populateEmailSLA(msg);  
			msg.Org_Case_Current_Team_Name_Text__c = msg.Org_Case_Current_Team_Name__c;
			populateSLATargetCompleteDate(msg);
			createListEmailsToUpdate(msg, lEmailMessagesToUpdate);
			//v1.24
			if(msg.Headers != null) {
				string caseLongEmail = getRoutingAddress(msg.Headers);
				if(caseLongEmail != null && string.isNotBlank(caseLongEmail)) {
					for(Case_Email_Configuration__c objConfig : CaseTriggerHandler.mapCaseEmailConfigs.values()) {
						if(caseLongEmail == objConfig.Email_Routing_Address__c) {
							msg.EmailToCaseMailbox__c = objConfig.Email_to_Case_Address__c;
						}
					}
				}
			}//end of v1.24
		}
		if(lEmailMessagesToUpdate.size()>0) update lEmailMessagesToUpdate;
	}
    
    public static void onAfterInsert(List<EmailMessage> msgs){
        system.debug('### EmailMessage onAfterInsert 1 with msgs.size()' + msgs.size());
        system.debug('### EmailMessage onAfterInsert 1 with msgs' + msgs);
        
        //Added as a part of v1.16
        /* 1.24 RB List<Case> cslist = new List<case>();
		   if(casId.size() > 0)
		    cslist = [Select SuppliedEmail,Id,Org_Incoming_Emails_Count__c from Case where Id IN: casId];
		   if(cslist.size() > 0) {
		    for(Case cs : cslist ) {
		        caseWebEmailAddressMap.put(cs.Id,cs);
		    }
		   }*/
		//RB - 1.24
		if(casId != null && !casId.isEmpty())
			caseWebEmailAddressMap = new map<Id, Case>([SELECT Id, SuppliedEmail, Org_Incoming_Emails_Count__c, Org_Brand__c FROM Case WHERE Id IN: casId]); //v1.26 added Org_Brand__c on query

		//end
        populateEmailIdOnCase(msgs);    
        BusinessUnitMappingUtility.populateBusinessQueueMap();
        Set<Id> sCaseIds = new Set<Id>();
        list<EmailMessage> marhabaEmails = new list<EmailMessage>(); //v1.5
        list<EmailMessage> aaBackOfficeEmails = new list<EmailMessage>(); //v1.9
        list<EmailMessage> aaEmails = new list<EmailMessage>(); //v1.10         
        
        for(EmailMessage msg : msgs){
            setCaseIdsAggregate.add(msg.ParentId);
            createListCasesToUpdate(msg);
            createSetCasesIds(msg, sCaseIds);
            //v1.5
            if(msg.isMarhabaEmail__c){
                marhabaEmails.add(msg);
            }
            
            //v1.9
            if(string.IsNotEmpty(msg.AA_Back_Office__c)){
                aaBackOfficeEmails.add(msg);
            }
            
            //v1.10
            if(msg.isAAEmail__c){
                aaEmails.add(msg);
            }           
        }
        completeCaseMilestones(sCaseIds);
        populateEmailCountOnCase();
        updateCases();
        
        //v1.5
        if(marhabaEmails.size() > 0){
            setReopenedLastEmailReplied(marhabaEmails);
        }
        
        //v1.9
        if(aaBackOfficeEmails.size() > 0){
            //getBusinessAccount(aaBackOfficeEmails); //v1.25
        }
        
        //v1.10
        if(aaEmails.size() > 0){
            setStatusReopenedOrInProgress(aaEmails);
        }       
        
        if(Label.EmailDeleteRulesActivated == 'TRUE'){
            //Thjis should only enter for received emails.
            RulesUtility.deleteFiltersQuery('EmailMessage', Trigger.newMap.keySet(),msgs); //KR * v1.20       
        }
        
        
        system.debug('### EmailMessage onAfterInsert End');
        
    }
    
    public static void onBeforeUpdate(  List<EmailMessage> oldEmailList, 
                                      List<EmailMessage> newEmailList, 
                                      Map<Id, EmailMessage> newEmailMessageMap){
                                          system.debug('### onBeforeUpdate');
                                          casId = new set<string>();
                                          usrRole = new List<userrole>();
                                          for(EmailMessage ms:newEmailList){
                                              casId.add(ms.parentId);
                                          }
                                          
                                          casMap = new map<id,case>([select id,ownerid,owner.name,owner.userrole.name from case where id in:casId]);
                                          
                                          useRole=UserInfo.getUserRoleId();
                                          usrRole=[select id,name from userrole where id=:useRole];
                                          userName = UserInfo.getName();
                                          for(EmailMessage msg : newEmailList){  
                                              populateEmailSLA(msg);  
                                          }
                                          //Sri Bala
                                          
                                          
                                      }
    
    public static void onAfterUpdate(   List<EmailMessage> oldEmailList, 
                                     List<EmailMessage> newEmailList, 
                                     Map<Id, EmailMessage> newEmailMessageMap){
                                         
                                     }
    
    public static void onBeforeDelete(  Map<Id, EmailMessage> oldEmailMessageMap,
                                      Map<Id, EmailMessage> newEmailMessageMap){
                                          
                                      }
    
    public static void onAfterDelete(   Map<Id, EmailMessage> oldEmailMessageMap,
                                     Map<Id, EmailMessage> newEmailMessageMap){
                                         
                                     }
    
    public static void onUndelete(List<EmailMessage> msgs) {
        
    }
    
    /******* Helper methods should be placed below this line ******/
    /**************************************************************************************************
    * Name               : populateEmailIdOnCase
    * Description        : populate the Mailbox Email,Brand,Business unit on Case and updating case
    * Params             : List<EmailMessage>
    * Return             :
    **************************************************************************************************/    
    //This method will be used to populate the email id on the cases created via Email-to-case
    public static void populateEmailIdOnCase(List<EmailMessage> msgs){
        
        try{ 
            BusinessUnitMappingUtility.populateBusinessQueueMap();           
            List<Case> lstCasesToUpdate = new List<Case>();
            Map<String, String> mapEmailDetails = new Map<String, String>();
            
            //Fetch BU records, based on the Email record type
            //And prepare a map of BU and associated Email address
            String recTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            for(Business_Unit__c bu : [Select Id, Name, Org_Email__c From Business_Unit__c Where RecordTypeId = :recTypeId]){
                mapEmailDetails.put(bu.Org_Email__c, bu.Name);
            }
            
            //Once you have the email addresses
            //iterate over the email messages and get the case id
            //update the cases with Mailbox, To Address on the case
            
            
            
            for(EmailMessage msg : msgs){ //v1.2  for AMI cases, removing email address to identify mailbox
                //String strToEmailAddress = msg.ToAddress; // commented out as part of v1.3 
                
                //v1.24 //commented out as part of v1.27
                /*
                if(msg.EmailToCaseMailbox__c != null ) {
                    continue;
                }*/
                
                EmailMessage em = new EmailMessage(); //v1.22
                em.Id = msg.ID; //v1.22
                //v1.3 If to address is blank, setting the ccaddress as the toemailaddress                
                String emailToUseToFindQueue = findBusinessEmailOnMessage(msg);  //v1.4
                 /*****************************Added as a part of v1.22****************************************/
				
				Case parentCase = new Case(); //v1.26
                 
                if(Label.Enable_MessageHeaders == 'TRUE'){
                    if(emailToUseToFindQueue != ''){ //v1.22
                        if(String.isNotBlank(msg.ParentId) 
                           && BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue) != null
                           && !msg.Org_Auto_Response_Sent_From_Case__c//){ //v1.4 Org_Mailbox_Email__c = emailToUseToFindQueue removed for an instance
                           && msg.Incoming && (caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == 0 || caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == null)){  // Added as a part of v1.17 //Commented as a part of v1.18
                            //v1.26
							parentCase.Id = msg.ParentId;
                            if(string.IsEmpty(caseWebEmailAddressMap.get(msg.ParentId).Org_Brand__c)){
                                parentCase.Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c;
                            }
                            parentCase.Org_Mailbox_Email__c = emailToUseToFindQueue;
                            parentCase.Org_Business_Unit_dropdown__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name;
                            parentCase.Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c;
                            parentCase.Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue);
                            lstCasesToUpdate.add(parentCase);                               
                            /*   
                            lstCasesToUpdate.add(new Case(  Id = msg.ParentId, 
                                                             Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c,
                                                             Org_Mailbox_Email__c = emailToUseToFindQueue,
                                                             Org_Business_Unit_dropdown__c= BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name, 
                                                             Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c, //v1.13 
                                                             Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue))); //v1.4
                            */
                            //End v1.26                                  
						}
						
                        if(string.IsEmpty(msg.EmailToCaseMailbox__c)){ //v1.27
                            em.EmailToCaseMailbox__c = emailToUseToFindQueue; //v1.22
                            eMessageToUpdate.add(em); //v1.22
                        }
                    }
                   
                    
                    if(emailToUseToFindQueue == ''){
                        
                        emailToUseToFindQueue = findEmailAddressOnMessage(msg);
                        system.debug('emailToUseToFindQueue @@@ >'+emailToUseToFindQueue);
                        if(String.isNotBlank(msg.ParentId) 
                           && BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue) != null
                           && !msg.Org_Auto_Response_Sent_From_Case__c//){ //v1.4 Org_Mailbox_Email__c = emailToUseToFindQueue removed for an instance
                           && msg.Incoming && (caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == 0 || caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == null)){
                            //v1.26
							parentCase.Id = msg.ParentId;
                            if(string.IsEmpty(caseWebEmailAddressMap.get(msg.ParentId).Org_Brand__c)){
                                parentCase.Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c;
                            }
                            parentCase.Org_Mailbox_Email__c = emailToUseToFindQueue;
                            parentCase.Org_Business_Unit_dropdown__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name;
                            parentCase.Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c;
                            parentCase.Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue);
                            lstCasesToUpdate.add(parentCase);                           
                           /*
                           lstCasesToUpdate.add(new Case(  Id = msg.ParentId, 
                                                             Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c,
                                                             Org_Mailbox_Email__c = emailToUseToFindQueue,
                                                             Org_Business_Unit_dropdown__c= BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name, 
                                                             Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c, //v1.13 
                                                             Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue)));
                           */
                           //End v1.26 
						}
                        
                        if(string.IsEmpty(msg.EmailToCaseMailbox__c)){//v1.27
                            em.EmailToCaseMailbox__c = emailToUseToFindQueue; //v1.22
                            eMessageToUpdate.add(em); //v1.22
                        }
                        
                    }
                    
                }
                /*****************************End of v1.22****************************************/
                else{
                    if(String.isNotBlank(msg.ParentId) 
                       && BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue) != null
                       && !msg.Org_Auto_Response_Sent_From_Case__c//){ //v1.4 Org_Mailbox_Email__c = emailToUseToFindQueue removed for an instance
                       && msg.Incoming && (caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == 0 || caseWebEmailAddressMap.get(msg.ParentId).Org_Incoming_Emails_Count__c == null)){  // Added as a part of v1.17 //Commented as a part of v1.18
                        //v1.26
                        parentCase.Id = msg.ParentId;
                        if(string.IsEmpty(caseWebEmailAddressMap.get(msg.ParentId).Org_Brand__c)){
                            parentCase.Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c;
                        }
                        parentCase.Org_Mailbox_Email__c = emailToUseToFindQueue;
                        parentCase.Org_Business_Unit_dropdown__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name;
                        parentCase.Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c;
                        parentCase.Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue);
                        lstCasesToUpdate.add(parentCase);                   	
                    	/*
                    	lstCasesToUpdate.add(new Case(  Id = msg.ParentId, 
                                                             Org_Brand__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Brand__c,
                                                             Org_Mailbox_Email__c = emailToUseToFindQueue,
                                                             Org_Business_Unit_dropdown__c= BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Org_Business_Unit_Email__r.name, 
                                                             Case_Domain__c = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Domain__c, //v1.13 
                                                             Org_Mailbox__c = mapEmailDetails.get(emailToUseToFindQueue))); //v1.4
                        */
                        //End v1.26
 					}
 					
                    if(string.IsEmpty(msg.EmailToCaseMailbox__c)){//v1.27
                        em.EmailToCaseMailbox__c = emailToUseToFindQueue; //v1.22
                        eMessageToUpdate.add(em); //v1.22
                    }
                    
                }
                System.debug('###'+lstCasesToUpdate);
                
            }
            //v1.22
            if(!eMessageToUpdate.isEmpty()){
                system.debug('eMessageToUpdate >>>>. '+eMessageToUpdate);
                update eMessageToUpdate;
            }  //end of v1.22
            //update the case records
            if(!lstCasesToUpdate.isEmpty()){
                update lstCasesToUpdate;
            }
            
        } catch(Exception ex){
            throw ex;
        }
    } 
    
    //KR
    /**************************************************************************************************
    * Name               : updateCases
    * Description        : updates Case
    * Params             :
    * Return             :
    **************************************************************************************************/
    private static void updateCases(){
        system.debug('### Entering updateCases with lCasesToUpdate: ' + lCasesToUpdate);
        system.debug('### Entering updateCases with mCaseIdToCaseToUpdate: ' + mCaseIdToCaseToUpdate);
        try{
            lCasesToUpdate.add(mCaseIdToCaseToUpdate.values());
            system.debug('### updateCases lCasesToUpdate: ' + lCasesToUpdate);
            if(lCasesToUpdate.size()>0){
                update lCasesToUpdate;
                system.debug('### updateCases after lCasesToUpdate: ' + lCasesToUpdate);
            }
        }catch(Exception e){
            system.debug('### updateCases Exception: ' + e);
        }
        
    }
    
    //v1.22
    /****************************************************************************************************
	* @Version : v1.22        																			*
	* @Parmas  : EmailMessage																			*
	* @Return	: String																				*
	* @Description : Finds if the email message headers contains the business unit routing address
						and returns the email address of the routing email.								*
	***************************************************************************************************/ 
    private static String findEmailAddressOnMessage(EmailMessage msg){
        System.debug('### Entering findEmailAddressOnMessage msg: ' + msg);
        String emailToUseToFindQueue = '';
        if(BusinessUnitMappingUtility.mEmailToEmailRoutingRecord.size() > 0){
            for(String routingEmail :  BusinessUnitMappingUtility.mEmailToEmailRoutingRecord.keyset()){
                if(msg.Headers != null && routingEmail != null){
                    if(msg.Headers.contains(routingEmail)){
                        emailToUseToFindQueue = BusinessUnitMappingUtility.mEmailToEmailRoutingRecord.get(routingEmail);
                        break;
                    }
                }
            }
        }
        return emailToUseToFindQueue;
    }
    
    /**************************************************************************************************
	* Name               : findBusinessEmailOnMessage 
	* Description        : Returns the email address if the Business Unit contains to/cc/bcc address in the email message
	* Params             : String
	* Return             : EmailMessage
	**************************************************************************************************/  
    //KR v1.4 This method is find if any part of the email contains one of the business email-to-case emails
    private static String findBusinessEmailOnMessage(EmailMessage msg){
        System.debug('### Entering findBusinessEmailOnMessage msg: ' + msg);
        String emailToUseToFindQueue = '';
        //added as a part of v1.6 & v1.7
        List<String> sToAddress = new List<String>();
        List<String> sCCAddress = new List<String>();
        List<String> sBccAddress = new List<String>();
        if(msg.ToAddress != null && msg.ToAddress != '')
            sToAddress = msg.ToAddress.replace(',',';').split(';'); //modified as a part of v1.14
        if(msg.CcAddress != null && msg.CcAddress != '')
            sCCAddress = msg.CCAddress.replace(',',';').split(';'); //modified as a part of v1.14
        if(msg.BccAddress != null && msg.BccAddress != '')
            sBccAddress = msg.BccAddress.replace(',',';').split(';'); //modified as a part of v1.14
        system.debug('sToAddress'+sToAddress);
        system.debug('sCCAddress'+sCCAddress);
        system.debug('sBccAddress'+sBccAddress);
        
        for(String strTo:sToAddress)
        {
        	system.debug('\n\n\n !!!!!!!! LOOP TO ADDRESSES !!!!!!!!!\n\n\n ');
            String queueName = '';
            String brandName = '';
            String teamName = '';
            strTo = strTo.trim();
            system.debug('$$$$$ BusinessUnitMappingUtility.mEmailToEmailRecord  '+BusinessUnitMappingUtility.mEmailToEmailRecord);
            /*
            if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(strTo)){
                queueName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(strTo).Org_Queue_Name__c;
                brandName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(strTo).Org_Brand__c;
            }
            
            if(brandName=='dnata' && queueName!=null && BusinessUnitMappingUtility.mQueueToTeamRecord.containskey(queueName)){
                teamName = BusinessUnitMappingUtility.mQueueToTeamRecord.get(queueName).Org_Team_Name__c;
            }
            
            if(msg.Org_Case_Current_Team_Name__c == teamName || msg.Org_Case_Current_Team_Name__c == queueName){
                emailToUseToFindQueue = strTo;
                break;
            }*/
            
            if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(strTo)){
                emailToUseToFindQueue = strTo;
                break;				
            }            
        }
        
        
        for(string strCc:sCCAddress){
        	system.debug('\n\n\n !!!!!!!! LOOP CC ADDRESSES !!!!!!!!!\n\n\n ');
            String queueName = '';
            String brandName = '';
            String teamName = '';
            strCc = strCc.trim();
            /*
            if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(strCc)){
                queueName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(strCc).Org_Queue_Name__c;
                brandName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(strCc).Org_Brand__c;
                
            }
            if(brandName=='dnata' && queueName!=null && BusinessUnitMappingUtility.mQueueToTeamRecord.containskey(queueName)){
                teamName = BusinessUnitMappingUtility.mQueueToTeamRecord.get(queueName).Org_Team_Name__c;
            }
            
            if(msg.Org_Case_Current_Team_Name__c == teamName || msg.Org_Case_Current_Team_Name__c == queueName){
                emailToUseToFindQueue = strCc;
                break;
            }
            */
            if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(strCc)){
                emailToUseToFindQueue = strCc;
                break;                
            }            
        }
        
        
        
        for(string strBCc:sBccAddress){
        	system.debug('\n\n\n !!!!!!!! LOOP BCC ADDRESSES !!!!!!!!!\n\n\n ');
            strBCc = strBCc.trim();
            emailToUseToFindQueue = mapEmailtoQueue(strBCc,msg);
            break;
        }
        
        
        //commented as a part of v1.7
        /*if(sToAddress.contains(email) ||sCCAddress.contains(email)||sBccAddress.contains(email)){
emailToUseToFindQueue = email;
System.debug('###  ForLoop emailToUseToFindQueue: ' + emailToUseToFindQueue);
break;
}*/
        
        // Merul: if 'To' address only have one email and Still emailToUseToFindQueue not set. 
        if(Label.Enable_MessageHeaders != 'TRUE'){ // Added as a part of v1.22
            if(
                emailToUseToFindQueue == '' 
                && sToAddress != NULL
                && sToAddress.size() == 1
            )
            {
                emailToUseToFindQueue = sToAddress[0];
            }
        }
        
        system.debug('emailToUseToFindQueue'+emailToUseToFindQueue);
        return emailToUseToFindQueue;
    }  
    
    private static String mapEmailtoQueue(String str,EmailMessage msg)
    {
        String queueName = '';
        String brandName = '';
        String teamName = '';
        String emailToUseToFindQueue ='';
        /*
        if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(str)){
            queueName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(str).Org_Queue_Name__c;
            brandName = BusinessUnitMappingUtility.mEmailToEmailRecord.get(str).Org_Brand__c;
            
        }
        if(brandName=='dnata' && queueName!=null && BusinessUnitMappingUtility.mQueueToTeamRecord.containskey(queueName)){
            teamName = BusinessUnitMappingUtility.mQueueToTeamRecord.get(queueName).Org_Team_Name__c;
        }
        
        if(msg.Org_Case_Current_Team_Name__c == teamName || msg.Org_Case_Current_Team_Name__c == queueName){
            emailToUseToFindQueue = str;
            
        }
        */
        if(BusinessUnitMappingUtility.mEmailToEmailRecord.containskey(str)){
            emailToUseToFindQueue = str;
        }        
        return emailToUseToFindQueue;
    }
    
    /**************************************************************************************************
    * Name               : createListCasesToUpdate
    * Description        : List of cases to update if the email message is incoming
    * Params             : EmailMessage
    * Return             :
    **************************************************************************************************/    
    //KR
    private static void createListCasesToUpdate(EmailMessage msg){
        //need to add case status here. If closed, then update 
         
        Case cse = new Case();

		if(msg.Incoming && msg.Org_Case_Current_Team_Name__c == 'dTME - Product Support Queue' && msg.Org_Case_Record_Type__c == 'dTME_After_Sales' && msg.Case_Status__c != 'Closed' && msg.Case_Status__c != 'New') {
			cse.Org_Case_Status__c = 'In Progress';
		}

		if(msg.Incoming) { //v1.13
			system.debug('### cse.Org_Email_From_Customer__c  1111111  : ' + cse.Org_Email_From_Customer__c ); //v1.13
			if(msg.FromAddress == caseWebEmailAddressMap.get(msg.ParentId).SuppliedEmail) // Added as a part of v1.16 Added "caseWebEmailAddressMap.get(msg.ParentId)" to not to update Org_Email_From_Customer__c if the email is from other mail address
				cse.Org_Email_From_Customer__c = true; //v1.13
			cse.Is_Incoming_Email__c = true; // Added as a part of v1.16
			cse.Id = msg.ParentId; //KR added this
		} //v1.13


		if(msg.Incoming && !msg.Email_Message_On_Case__c && msg.IsFromCustomer__c) {
			system.debug('### createListCasesToUpdate update Cases 1: ');
			cse.Id = msg.ParentId;

			if(mCaseIdToCaseToUpdate.get(cse.Id) != null) {
				cse = mCaseIdToCaseToUpdate.get(cse.Id);
			}
			system.debug('### createListCasesToUpdate Org_Email_From_Customer__c true: ');
			cse.Org_Email_From_Customer__c = true;
			cse.Org_Open_Email_Message_Id__c = msg.Id;

		}

		if(!msg.Incoming &&
		   msg.Org_Case_Current_Team_Name__c == 'dTME - Product Support Queue'
		   && msg.ToAddress != null && String.valueOf(msg.ToAddress).toLowerCase() == Label.AcknowledgementFromProduct) {
			cse.Id = msg.ParentId;
			cse.Org_Acknowledgement_From_Product_Support__c = true;
		}

		//do the check for autoresponse in an formula field on emailmessage
		String sEmailsToIgnore = Label.Emails_To_Ignore;

		if(!msg.Incoming  &&
		   UserInfo.getUserType() == 'Standard' && !sEmailsToIgnore.contains(msg.FromAddress) && msg.FromAddress != null) { //!sEmailsToIgnore.contains(msg.FromAddress) modified as a part of v1.14
			system.debug('### createListCasesToUpdate update Cases 3: ');
			cse.Id = msg.ParentId;

			if(mCaseIdToCaseToUpdate.get(cse.Id) != null) {
				cse = mCaseIdToCaseToUpdate.get(cse.Id);
			}
			system.debug('### createListCasesToUpdate Org_Email_From_Customer__c false: ');
			if(msg.IsSentToCustomer__c )    // Added as a part of v1.16
				cse.Org_Email_From_Customer__c = false;
			cse.Is_Incoming_Email__c = false;    //v1.16
			cse.Org_Open_Email_Message_Id__c = '';
		}

		//v 1.1
		if((msg.Case_Status__c == 'Closed') && msg.Incoming && cse.Reason != 'Spam' && !msg.isMarhabaEmail__c && !msg.isAAEmail__c) { //v1.8 Added condition to check if marhaba or Arabian Adventures email/case
			cse.Reopened__c = true;
			cse.Id = msg.ParentId;
			cse.Org_Case_Status__c = 'In Progress'; // v1.3 in progress status for all brands
		}

		//reassign for any incoming email on case

		if(msg.Incoming && !msg.isMarhabaEmail__c && !msg.isAAEmail__c) {

			//1.24
			Boolean isConfig = false;
			string caseOwnerId;
			string caseLongEmail = getRoutingAddress(msg.Headers);
			if(caseLongEmail != null && string.isNotBlank(caseLongEmail) && cse.Reopened__c) {
				for(Case_Email_Configuration__c objConfig : CaseTriggerHandler.mapCaseEmailConfigs.values()) {
					if(caseLongEmail == objConfig.Email_Routing_Address__c) {
						if(objConfig.Queue_Developer_Name__c != null && mapQueueIds.containsKey(objConfig.Queue_Developer_Name__c.toLowerCase()))
							caseOwnerId = mapQueueIds.get(objConfig.Queue_Developer_Name__c.toLowerCase());
						break;
					}
				}
			}
			System.debug('caseOwnerId is : '+caseOwnerId);
			if(caseOwnerId != null) {
				cse.OwnerId = caseOwnerId;
				cse.Id = msg.ParentId;
			}else{ //1.24
				String emailToUseToFindQueue = findBusinessEmailOnMessage(msg);  //v1.4
				System.debug('### emailToUseToFindQueue: ' + emailToUseToFindQueue);

				if(emailToUseToFindQueue != null && emailToUseToFindQueue != '') { // added as a part of v1.15
					if(BusinessUnitMappingUtility.mEmailToEmailRecord.containsKey(emailToUseToFindQueue)) { //MPamintuan 11.3.2019 - added map checking
						Business_Unit__c emailBU = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue); //v1.29
						if(emailBU.Omni_Queue__c){ //v1.29 - Added if statement to check if the mailbox is setup with omni
							cse.OwnerId = emailBU.Queue_ID__c;
						} else {
							if(cse.Reopened__c == true) {
								cse.OwnerId = emailBU.Queue_ID__c;
							}							
						}

						cse.Id = msg.ParentId;
						
						//Commented as part of v1.28						
						/*
						//v1.13 KR add
						if( sQueueNameForEmail != null && BusinessUnitMappingUtility.mQueueNameToQueueId.containsKey(sQueueNameForEmail)) { //MPamintuan 11.3.2019 - added map checking
							String sQueueIdForEmail = BusinessUnitMappingUtility.mQueueNameToQueueId.get(sQueueNameForEmail);

							if(cse.Reopened__c == true) {//Added as a part of v1.6
								if(msg.Org_Brand_On_Case__c != 'ekh') { //v1.13 use the new structure for EKH. The rest of the structure remains the same
									cse.OwnerId = sQueueIdForEmail;
								}
							}
							cse.Id = msg.ParentId;
						}
						//Added as a part of v1.15
						if(cse.Reopened__c == true) {
							if(msg.Org_Brand_On_Case__c == 'ekh') { //v1.13 use the new structure for EKH. The rest of the structure remains the same //Added emailToUseToFindQueue != null as a part of v1.15
								String sQueueIdForEmailEKH = BusinessUnitMappingUtility.mEmailToEmailRecord.get(emailToUseToFindQueue).Queue_ID__c; //v1.13
								if(sQueueIdForEmailEKH != null)         //Added as a part of v1.15
									cse.OwnerId = sQueueIdForEmailEKH;
							}
						}
						*/
					}
				}
			}//end of else - 1.24
		}
		system.debug('### Exiting createListCasesToUpdate with cse: ' + cse);
		if(cse.Id != null) mCaseIdToCaseToUpdate.put(cse.Id, cse);
    } 
    
    //KR
    private static void createSetCasesIds(EmailMessage msg, Set<Id> sCasesIds){ 
        system.debug('### entering createSetCasesIds with msg.Incoming: ' + msg.Incoming);
        system.debug('### entering createSetCasesIds with msg.IsSentToCustomer__c: ' + msg.IsSentToCustomer__c);
        system.debug('### entering createSetCasesIds with msg.FromAddress: ' + msg.FromAddress);
        
        system.debug('### entering createSetCasesIds with sCasesIds: ' + sCasesIds);
        String sEmailsToIgnore = Label.Emails_To_Ignore;
        if(!msg.Incoming && msg.IsSentToCustomer__c && !sEmailsToIgnore.contains(msg.FromAddress) && msg.FromAddress != null ) sCasesIds.add(msg.ParentId); // modified as a part of v1.14
        
        system.debug('### Exiting createSetCasesIds with sCasesIds: ' + sCasesIds);
    } 
    
    //KR: 
    private static void completeCaseMilestones(Set<Id> sCaseIds){
        
        List<CaseMilestone> lCaseMilestonesToUpdate = [SELECT Id, CompletionDate
                                                       FROM CaseMilestone 
                                                       WHERE CaseId IN :sCaseIds 
                                                       AND MilestoneType.Name = 'Email Response' 
                                                       AND CompletionDate = NULL];
        
        if(lCaseMilestonesToUpdate != null && lCaseMilestonesToUpdate.size()>0){
            for(CaseMilestone cm: lCaseMilestonesToUpdate){
                cm.CompletionDate = Datetime.valueOf( system.now().format(dateformat,''+userinfo.getTimeZone()));
            }
            update lCaseMilestonesToUpdate; 
        }
    } 
    
    
    //KR
    private static void populateEmailSLA(EmailMessage msg){
        system.debug('### msg.Email_Message_On_Case__c: ' + msg.Email_Message_On_Case__c);
        system.debug('### msg.SLA_Violated__c: ' + msg.SLA_Violated__c);
        system.debug('### msg.Email_SLA_Status__c: ' + msg.Email_SLA_Status__c);
        system.debug('### msg.SLA_Completion_Date__c: ' + msg.SLA_Completion_Date__c);
        system.debug('### msg.Incoming: ' + msg.Incoming);
        
        //v1.1
        if(msg.Org_EntitlementIdOnCase__c == null){
            system.debug('### After IF STATEMENT BEFORE return: ');
            return;
        }
        system.debug('### After return: ');
        if(msg.Email_Message_On_Case__c && msg.Incoming && msg.Email_SLA_Status__c != 'SLA Not Met') {
            msg.Email_SLA_Status__c = 'SLA Invalid';
            //  msg.Org_Role__c 
            //  msg.Org_Agent_Name__c
        }
        
        if(!msg.Email_Message_On_Case__c && msg.Incoming && msg.IsFromCustomer__c
           && msg.Email_SLA_Status__c != 'SLA Not Met') {
               msg.Email_SLA_Status__c = 'Within SLA';
               if(usrRole.size() > 0){
                   msg.Org_Role__c = usrRole[0].name;
               }
               //msg.Org_Agent_Name__c = UserInfo.getUserId();
           }
        
        if(msg.Incoming && msg.SLA_Completion_Date__c != null 
           && msg.Email_SLA_Status__c != 'SLA Not Met') {
               msg.Email_SLA_Status__c = msg.SLA_Violated__c ? 'SLA Not Met' : 'SLA Met';
               if(casMap.containskey(msg.parentId)){
                   msg.Org_Role__c  = casMap.get(msg.parentId).owner.userrole.name;
                   string st=casMap.get(msg.parentId).ownerId;
                   // if(st.startsWith('00G')){
                   //msg.adderror('Kindly accept the case before editing it' );
                   // }
                   
                   if(!st.startsWith('00G')){
                       msg.Org_Agent_Name__c = casMap.get(msg.parentId).ownerId;
                   }
                   
               }
           }
        
        
    } 
    
    //KR
    private static void populateSLATargetCompleteDate(EmailMessage msg){   
        if(msg.Incoming  && !msg.Email_Message_On_Case__c && msg.IsFromCustomer__c){      
            
            //v1.1
            if(msg.Org_EntitlementIdOnCase__c == null){
                return;
            }
            
            try{
                if(string.IsNotEmpty(msg.Case_Current_Queue_ID__c) && BusinessUnitMappingUtility.queueIdToSLARecord.get(msg.Case_Current_Queue_ID__c) != null){ //v1.28
                    Integer iSLAMinutes = Integer.valueOf(BusinessUnitMappingUtility.queueIdToSLARecord.get(msg.Case_Current_Queue_ID__c).Org_SLA_Mins__c);
                    Integer slaTime = iSLAMinutes*60000;                    
                    
                    msg.SLA_Target_Time__c = BusinessHours.add(msg.Business_Hours_Id__c, 
                                                               System.now(), 
                                                               slaTime);     
                }
                
            }catch(Exception e){
                system.debug('#### populateSLATargetCompleteDate exception: ' + e);
            }   
            
        }
        
    }
    
    //KR
    private static void createListEmailsToUpdate(EmailMessage msg, List<EmailMessage> lEmailsToUpdate){
        system.debug('### createListEmailsToUpdate with msg: ' + msg);
        if(!msg.Incoming && msg.IsSentToCustomer__c && 
           UserInfo.getUserType() == 'Standard' && 
           msg.EmailMessageIdOnCase__c !=null){
               
               EmailMessage emailMsg = new EmailMessage();
               emailMsg.Id = msg.EmailMessageIdOnCase__c;
               emailMsg.SLA_Completion_Date__c = System.now();
               
               if(msg.Org_Current_Case_Owner_Id__c != null && msg.Org_Current_Case_Owner_Id__c.startsWith('005')){
                   emailMsg.Org_Agent_Name__c = msg.Org_Current_Case_Owner_Id__c;
                   emailMsg.Org_Role__c = msg.Org_Current_Case_Owner_Role__c;  
               }
               emailMsg.Org_Case_Current_Team_Name_Text__c = msg.Org_Case_Current_Team_Name__c;
               lEmailsToUpdate.add(emailMsg);
               
           }
        system.debug('### createListEmailsToUpdate with lEmailsToUpdate: ' + lEmailsToUpdate);
        
    }
    
    public static void populateEmailCountOnCase(){
        AggregateResult[] groupedResults = [SELECT ParentId, Count(Id) 
                                            FROM EmailMessage
                                            WHERE ParentId IN: setCaseIdsAggregate
                                            AND Incoming = true
                                            AND IsFromCustomer__c = true
                                            GROUP BY ParentId];                                
        
        
        
        try{
            for(AggregateResult ar : groupedResults){
                Case cse = new Case();
                cse.Id = String.valueOf(ar.get('ParentId'));
                if(mCaseIdToCaseToUpdate.get(cse.Id) != null){
                    cse = mCaseIdToCaseToUpdate.get(cse.Id);
                }
                cse.Org_Incoming_Emails_Count__c = Integer.valueOf(ar.get('expr0'));
                mCaseIdToCaseToUpdate.put(cse.Id, cse);
                //lCasesToUpdate.add(cse);
            }
            
        }catch(Exception e){
            system.debug('### populateEmailCountOnCase Exception: ' + e);
        }
        
    }
    
    /**
* @author: Mark Anthony Pamintuan
* @date: 21 February 2019
* @description: set marhaba Email Parent Case Status to 'Reopened' and Last Email Replied
* @history:                
*/
    private static void setReopenedLastEmailReplied(list<EmailMessage> lstEmailMessages){
        
        list<Case> lstCasesToUpdate = new list<Case>();
        list<EmailMessage> lstEmails = new list<EmailMessage>();
        set<Id> parentIDs = new set<Id>();
        map<Id,Case> caseIdMap = new map<Id,Case>();
        
        for(EmailMessage em : lstEmailMessages){
            if(em.ParentId != null){
                parentIDs.add(em.ParentId); 
                lstEmails.add(em);          
            }
        }
        
        for(Case cse : [SELECT Id, Org_Case_Status__c,
                        Org_Reopened_Date__c,
                        Last_Email_Replied__c,
                        Recordtype.Name,
                        AccountId,
                        Status 
                        FROM Case 
                        WHERE Id IN: parentIDs]){
                            caseIdMap.put(cse.Id,cse);
                        }
        
        for(EmailMessage email : lstEmails){
            if(caseIdMap.containsKey(email.ParentId)){
                Case parentCase = caseIdMap.get(email.ParentId);
                if(parentCase.Recordtype.Name == 'marhaba - Email'){
                    if(email.Incoming && (parentCase.Org_Case_Status__c == 'Closed' || parentCase.Org_Case_Status__c == 'Converted' || parentCase.Org_Case_Status__c == 'Spam/NA' || parentCase.Org_Case_Status__c == 'In Progress' ) && parentCase.AccountId != Label.Marhaba_SPAM_Account_ID){
                        parentCase.Org_Case_Status__c = 'Reopened';
                        parentCase.Org_Reopened_Date__c = system.now();
                    }
                    if(email.Incoming && (email.Status == '0' || email.Status == '1' || email.Status == '5')){
                        parentCase.Last_Email_Replied__c = false;
                    } else if(!email.Incoming && (email.Status == '2' || email.Status == '3' || email.Status == '4')){
                        parentCase.Last_Email_Replied__c = true;
                    }
                    
                    lstCasesToUpdate.add(parentCase);
                }
            }                   
        }
        
        if(lstCasesToUpdate.size() > 0){
            try{
                system.debug('@!@!@@!' + lstCasesToUpdate);
                update lstCasesToUpdate;
            } catch(exception e){
                system.debug('!!!Exception: ' + e.getMessage());
            }
        }
        
    }
    
    /**
	* @author: Mark Anthony Pamintuan
	* @date: 26 March 2019
	* @description: Populate Account and Contact ID for AA Business Account Cases
	* @history:                
	*//* v1.25
    private static void getBusinessAccount(list<EmailMessage> lstEmailMessages){
        
        set<Id> setParentIDs = new set<Id>();
        set<String> setFromAddress = new set<String>();
        map<Id,Case> idCaseMap = new map<Id,Case>();
        map<String,Contact> emailContactMap = new map<String,Contact>();
        list<Case> lstCaseToUpdate = new list<Case>();
        map<String,Contact> newEmailContactMap = new map<String,Contact>();
        list<Contact> lstNewContacts = new list<Contact>();
        
        Id aaekhukRectypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('AA - EKHUK').getRecordTypeId();
        Id aaStellaRectypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('AA - Stella').getRecordTypeId();
        map<String,Id> recordtypeIdNameMap = new map<String,Id>{'AA - EKHUK' => aaekhukRectypeID, 'AA - Stella' => aaStellaRectypeID};
            
            for(EmailMessage em : lstEmailMessages){
                setParentIDs.add(em.ParentId);
                if(em.FromAddress!= null) //v1.14
                    setFromAddress.add(em.FromAddress);
            }
        
        for(Contact con : [SELECT Id, Email, AccountId, RecordtypeId FROM Contact WHERE Email IN: setFromAddress AND (RecordtypeId =: aaekhukRectypeID OR RecordtypeId =: aaStellaRectypeID)]){
            emailContactMap.put(con.Email + ' - ' + con.RecordtypeId,con);
        }
        
        for(Case parentCase : [SELECT Id, AccountId, ContactId FROM Case WHERE Id IN: setParentIDs]){
            idCaseMap.put(parentCase.Id,parentCase);           
        }
        
        for(EmailMessage email : lstEmailMessages){         
            if(idCaseMap.containsKey(email.ParentId)){
                Case parent = idCaseMap.get(email.ParentId);
                String backOffice = recordtypeIdNameMap.get(email.AA_Back_Office__c);
                if(emailContactMap.containsKey(email.FromAddress + ' - ' + backOffice)){
                    parent.AccountId = emailContactMap.get(email.FromAddress + ' - ' + backOffice).AccountId;
                    parent.ContactId = emailContactMap.get(email.FromAddress + ' - ' + backOffice).Id;
                    lstCaseToUpdate.add(parent);
                } else {
                    Contact newContact = new Contact();
                    newContact.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(email.AA_Back_Office__c).getRecordTypeId();
                    newContact.Email = email.FromAddress;
                    if(email.AA_Back_Office__c == 'AA - Stella'){
                        newContact.AccountId = Label.AA_Stella_Account_ID;
                    } else if(email.AA_Back_Office__c == 'AA - EKHUK'){
                        newContact.AccountId = Label.AA_EKHUK_Account_ID;
                    }
                    if(email.FromName.split(' ').size() > 1){
                        list<String> name = email.FromName.split(' ');
                        String firstName = '';
                        for(integer i = 0; i < name.size() - 1; i++ ){
                            firstName += name[i] + ' ';
                        }
                        newContact.FirstName = firstName;
                        newContact.LastName = name[name.size() - 1];
                    } else if(email.FromName.split(' ').size() == 1){ //v1.11 - MPamintuan  
                        newContact.LastName = email.FromName;
                    } else {
                        newContact.LastName = email.FromAddress;
                    }
                    //End v1.11
                    
                    lstNewContacts.add(newContact);
                    newEmailContactMap.put(newContact.Email + ' - ' + email.AA_Back_Office__c,newContact);                  
                }              
            }
        }
        
        if(lstNewContacts.size() > 0){
            
            //bypass duplicate rule for AA contact creation
            //insert lstNewContacts;
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            list<Database.SaveResult> sr = Database.insert(lstNewContacts, dml);
            
            for(EmailMessage emailMessage : lstEmailMessages){
                if(idCaseMap.containsKey(emailMessage.ParentId)){
                    Case parentCase = idCaseMap.get(emailMessage.ParentId);
                    if(newEmailContactMap.containsKey(emailMessage.FromAddress + ' - ' + emailMessage.AA_Back_Office__c)){
                        if(parentCase.AccountId != newEmailContactMap.get(emailMessage.FromAddress + ' - ' + emailMessage.AA_Back_Office__c).AccountId){
                            parentCase.AccountId = newEmailContactMap.get(emailMessage.FromAddress + ' - ' + emailMessage.AA_Back_Office__c).AccountId;
                            parentCase.ContactId = newEmailContactMap.get(emailMessage.FromAddress + ' - ' + emailMessage.AA_Back_Office__c).Id;
                            lstCaseToUpdate.add(parentCase);
                        }
                    }
                }               
            }   
        } 
        
        if(lstCaseToUpdate.size() > 0){
            update lstCaseToUpdate;
        }       
        
    }*/
    
    /**
* @author: Mark Anthony Pamintuan
* @date: 31 March 2019
* @description: set AA Cases to Reopened or In Progress
* @history:                
*/
    private static void setStatusReopenedOrInProgress(list<EmailMessage> lstEmailMessages){
        
        list<EmailMessage> lstEmails = new list<EmailMessage>();
        set<Id> parentIDs = new set<Id>();
        map<Id,Case> caseIdMap = new map<Id,Case>();
        list<Case> aaCasesToUpdate = new list<Case>();
        
        for(EmailMessage em : lstEmailMessages){
            if(em.ParentId != null && em.Incoming){
                parentIDs.add(em.ParentId); 
                lstEmails.add(em);          
            }
        }
        
        for(Case cse : [SELECT Id, Org_Case_Status__c, Org_Reopened_Date__c, Recordtype.Name FROM Case WHERE Id IN: parentIDs]){
            caseIdMap.put(cse.Id,cse);
        }
        
        for(EmailMessage email : lstEmails){
            if(caseIdMap.containsKey(email.ParentId)){
                Case parentCase = caseIdMap.get(email.ParentId);
                if(parentCase.Recordtype.Name == 'AA - B2C' || parentCase.Recordtype.Name == 'AA - EKHUK' || parentCase.Recordtype.Name == 'AA - Stella'){
                    if(parentCase.Org_Case_Status__c == 'Closed'){
                        parentCase.Org_Case_Status__c = 'Reopened';
                        parentCase.Org_Reopened_Date__c = system.now();
                        aaCasesToUpdate.add(parentCase);
                    } else if(parentCase.Org_Case_Status__c == 'Pending - Customer' || parentCase.Org_Case_Status__c == 'Pending Supplier' ){
                        parentCase.Org_Case_Status__c = 'In Progress';
                        aaCasesToUpdate.add(parentCase);
                    }
                }
            }           
        }
        
        if(aaCasesToUpdate.size() > 0){
            update aaCasesToUpdate;
        }
    }   
    
    
    /**
* @author: Jed Canlas
* @date: 23 Feb 2020
* @description: v1.21 - validate email sender from custom meta data
* @history:              
*/
    public static void validateEmail(List<EmailMessage> newEmail) {
        List<Email_Sender_Mapping__mdt> cmList = [select MasterLabel,Sender_Emails__c from Email_Sender_Mapping__mdt];
        Map<String,Set<String>> orgwideEmailMap = new Map<String,Set<String>>();
        for(Email_Sender_Mapping__mdt cm: cmList){
            orgwideEmailMap.put(cm.MasterLabel,new Set<String>());  
            if(cm.Sender_Emails__c.contains(';')){
                for(String s: cm.Sender_Emails__c.split(';')){
                    orgwideEmailMap.get(cm.MasterLabel).add(s);
                }
            }else{
                orgwideEmailMap.get(cm.MasterLabel).add(cm.Sender_Emails__c);  
            }
            
        } 
        Set<Id> parentIds = new Set<Id>(); 
        for(EmailMessage e: newEmail){
            parentIds.add(e.ParentId);
        }   
        Map<Id,Case> caseMap = new Map<Id,Case>([select id,RecordType.Name from case where id IN: parentIds]);
        for(EmailMessage e: newEmail){
            if(caseMap.containsKey(e.ParentId) && e.Incoming == false){                  
                if(orgwideEmailMap.containsKey(caseMap.get(e.ParentId).RecordType.Name)){// && orgwideEmailMap.get(caseMap.get(e.ParentId).RecordType.Name) != e.FromAddress){
                    if(!orgwideEmailMap.get(caseMap.get(e.ParentId).RecordType.Name).contains(e.ValidatedFromAddress)){
                        e.addError('Please use ' +  orgwideEmailMap.get(caseMap.get(e.ParentId).RecordType.Name) +'  email address for the \' ' + caseMap.get(e.ParentId).RecordType.Name + ' \' recordtype.');   
                    }
                    
                }       
            }
        }
    }
    
    public static string getRoutingAddress(string emHeaders){
		string header = ''; //EmailHeaderConfigAttribute as epecting X-SFDC-Original-RCPT:
		if(emHeaders != null && emHeaders.contains(EmailHeaderConfigAttribute)) {
			header = emHeaders.split(EmailHeaderConfigAttribute)[1];
			header = header.trim();
			header = header.split(' ')[0];
		}
		system.debug('header '+header);
		return header;
	}

	public static void getQueueDetails(){
		if(mapQueueIds.isEmpty()) {
			for(QueueSObject objQ : [SELECT QueueId,Queue.DeveloperName FROM QueueSobject WHERE SobjectType = 'Case']) {
				mapQueueIds.put(objQ.Queue.DeveloperName.toLowerCase(), objQ.QueueId);
			}
		}
	}
    
}