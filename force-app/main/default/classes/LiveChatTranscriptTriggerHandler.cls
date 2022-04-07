/**************************************************************************************************
* Name               : CaseTriggerHandler 
* Description        : This is the handler class for Case trigger         
* Created Date       : 08-Oct-2018                                                                 
* Created By         : Rahul                                                      
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Rahul        08-Aug-2018    Initial version
* v1.1        Sri Bala     10-Jul-2019    Should not create a case and an account if the email is blank for TRP
* v1.2        Sri Bala     17-Jul-2019    Create a case for live chat TRP
* v1.3        Sri Bala     27-Feb-2020    Create a person account for dnata missed chats
**************************************************************************************************/
public class LiveChatTranscriptTriggerHandler {

    //Added as a part of v1.2
    static integer runTimes = 0;
    /*********** @@ Solution : >>>>>>  On After Insert of a chat transcript create a case <<<<<<<<<<<<
                                >>  When a chat is inserted check whether the brand is dnata or trp
                            >>  If the brand is dnata
                                >> Insert a case by mapping all the required values.
                                    >> If the live chat type = New Booking, it creates a booking enquiry case.
                                    >> Else if live chat type = Existing Booking, it creates a After Sales case.
                                    >> Else if live chat type = General Booking,it creates a Generic case.
                                >> Assignment rules are fired and based on language and brand the case is assigned 
                                    to its queue respectively.
                            >> If the brand is trp
                                >> Insert a case by mapping all the required values.
                                    >> If contact Email != null, then create a booking enquiry case.
                                    >> If the contact Email = null case is not created.
                                >> Assignment rules are fired based on brand.
                            >> After inserting the case the live chat transcript is updated with the newly inserted case.          
    *********************************************************************************************************************/
    public static void createNewCase(List<LiveChatTranscript> newTranscripts){
        List<Case> caseToInsert = new List<Case>();
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
         List<LiveChatTranscript> transcriptsListToUpdate = new List<LiveChatTranscript>();
        
        for(LiveChatTranscript lct: newTranscripts){
            system.debug('Chat Transcript = ' + lct);
            
            if(lct.Contact_Email__c != null && lct.Contact_Brand__c == 'trp'){
                Case c = new Case();
                c.SuppliedName = lct.Contact_First_Name__c + ' ' + lct.Contact_Last_Name__c;
                c.SuppliedEmail = lct.Contact_Email__c;
                c.SuppliedPhone = lct.Contact_Phone_Number__c;
                c.Org_Brand__c = lct.Contact_Brand__c;
                c.Subject = 'Booking Enquiry for - ' + lct.Contact_First_Name__c + ' ' + lct.Contact_Last_Name__c;
                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Booking Enquiry').getRecordTypeId();   
                c.Origin = 'Live Chat';  
                caseToInsert.add(c);
                c.setOptions(dmlOpts);
            }
        }
        try{
            system.debug('caseToInsert'+caseToInsert);
            if(caseToInsert.size() >0){
                insert caseToInsert;
                List<Case> cs = [Select Id from case where Id =: caseToInsert[0].Id];
                for(LiveChatTranscript lct: newTranscripts){
                    LiveChatTranscript t = new LiveChatTranscript(Id=lct.id);
                    t.caseId = cs[0].id;
                    transcriptsListToUpdate.add(t);
                    runtimes++;
                }
            }
            system.debug('transcriptsListToUpdate'+transcriptsListToUpdate);
            if(transcriptsListToUpdate.size()>0 && runtimes < 2 )
                update transcriptsListToUpdate;
           
        }catch(Exception ex){
            system.debug('Exception at Line Number - ' + ex.getLineNumber() + ' : ' + ex.getMessage());
        }
    }
    /*********** @@ Solution : >>>>>>  On After Update of email on chat transcript create a case <<<<<<<<<<<<
                                >>  When a chat is inserted check whether the contact email is null
                            >> If the brand is trp
                                    >> Insert a case by mapping all the required values.
                                    >> If contact Email = null and then Contact email is updated with some value,
                                       then a booking enquiry case is created.
                                >> Assignment rules are fired based on brand.
                                >> RunTime is to stop infinte looping
                            >> After inserting the case the live chat transcript is updated with the newly inserted case.          
    *********************************************************************************************************************/
    public static void createCaseOnEmailUpdate(List<LiveChatTranscript> newTranscripts,Map<Id,LiveChatTranscript> oldTranscripts){
        List<Case> caseToInsert = new List<Case>();
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
         List<LiveChatTranscript> transcriptsListToUpdate = new List<LiveChatTranscript>();
        for(LiveChatTranscript lct: newTranscripts){
            system.debug('Chat Transcript = ' + lct);
            if(oldTranscripts.get(lct.Id).Contact_Email__c == null && lct.Contact_Email__c != null && lct.Contact_Brand__c == 'trp' ){
                Case c = new Case();
                c.SuppliedName = lct.Contact_First_Name__c + ' ' + lct.Contact_Last_Name__c;
                c.SuppliedEmail = lct.Contact_Email__c;
                c.SuppliedPhone = lct.Contact_Phone_Number__c;
                c.Org_Brand__c = lct.Contact_Brand__c;
                c.Subject = 'Booking Enquiry for - ' + lct.Contact_First_Name__c + ' ' + lct.Contact_Last_Name__c;
                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Booking Enquiry').getRecordTypeId();   
                c.Origin = 'Live Chat';  
                caseToInsert.add(c);
                c.setOptions(dmlOpts);
            }
        }
        try{
            system.debug('caseToInsert'+caseToInsert);
            if(caseToInsert.size() >0){
                insert caseToInsert;
                List<Case> cs = [Select Id from case where Id =: caseToInsert[0].Id];
                for(LiveChatTranscript lct: newTranscripts){
                    LiveChatTranscript t = new LiveChatTranscript(Id=lct.id);
                    t.caseId = cs[0].id;
                    transcriptsListToUpdate.add(t);
                    runtimes++;
                }
            }
            system.debug('transcriptsListToUpdate'+transcriptsListToUpdate);
            if(transcriptsListToUpdate.size()>0 && runtimes < 2 )
                update transcriptsListToUpdate;
           
        }catch(Exception ex){
            system.debug('Exception at Line Number - ' + ex.getLineNumber() + ' : ' + ex.getMessage());
        }
    }

    public static void updateAccountAndContact(Map<Id, LiveChatTranscript> newTranscriptsMap, Map<Id, LiveChatTranscript> oldTranscriptsMap){
        List<Case> csList = new List<Case>();
        
        for(LiveChatTranscript newLct : newTranscriptsMap.values()){

            LiveChatTranscript oldLct = oldTranscriptsMap.get(newLct.Id);
            system.debug('New Case Id = ' + newLct.CaseId);
            system.debug('Old Case Id = ' + oldLct.CaseId);
            
                    
                if(newLct.caseId != oldLct.caseId && newLct.caseId != null && newLct.Contact_Brand__c == 'trp'){
                
                
                Case c = [SELECT Id, ContactId, AccountId, SuppliedEmail FROM Case WHERE Id =: newLct.CaseId];
                newLct.AccountId = c.AccountId;
                newLct.ContactId = c.ContactId;   
            }
        }
        
       
    }

    //KR
    public static void populateAccountCaseOnChatTranscript(List<LiveChatTranscript> newTranscripts){

        List<Id> lCasesId = new List<Id>();
        Map<Id, Case> mCaseIdToCase = new Map<Id, Case>();

        for(LiveChatTranscript newLct : newTranscripts){
            if(newLct.CaseId != null) lCasesId.add(newLct.CaseId);
        }

        for(Case cse: [SELECT Id, ContactId, AccountId, SuppliedEmail FROM Case WHERE Id IN: lCasesId]){
            mCaseIdToCase.put(cse.Id, cse);
        }

        for(LiveChatTranscript newLct : newTranscripts){
            if(newLct.CaseId != null){
                newLct.AccountId = mCaseIdToCase.get(newLct.CaseId).AccountId;
                newLct.ContactId = mCaseIdToCase.get(newLct.CaseId).ContactId;
            }
        }
        
        


    }
    
/**************************************************************************************************
* Version			 : v1.3
* Name               : getExistingAccountsforMissedChats 
* Description        : creates a person account for dnata Missed Chats
* Params             : List<LiveChatTranscript>
* Return             : 
**************************************************************************************************/  
    public static void getExistingAccountsforMissedChats(List<LiveChatTranscript> lstnewTranscripts){
        Set<String> emailIds = new Set<String>();
        Set<String> brandNames = new Set<String>();
        Map<String, LiveChatTranscript> emailWithChatTranscript = new Map<String, LiveChatTranscript>();   
        Map<String, LiveChatTranscript> ChatTranscriptwithoutAccount = new Map<String, LiveChatTranscript>();   
        Map<String, Account> emailWithAccount = new Map<String, Account>();
        
        try {
            
            // Iterate over all the LiveChatTranscript and extract Email, & Brand
            
            
            for(LiveChatTranscript cs : lstnewTranscripts){
                
                if(cs.Status == 'Missed' && cs.Contact_Brand__c == 'dnata'){ 
                    system.debug('Entered >>>>>> Missed Chat Account');
                    brandNames.add(cs.Contact_Brand__c);
                    
                    if(cs.Contact_Email__c != null){
                        emailIds.add(cs.Contact_Email__c+cs.Contact_Brand__c);
                        emailWithChatTranscript.put(cs.Contact_Email__c+cs.Contact_Brand__c, cs);
                        ChatTranscriptwithoutAccount.put(cs.Contact_Email__c+cs.Contact_Brand__c, cs);
                    }
                    
                }
            }
            
            
            //Query on existing accounts to find out if any matching account exists with same Email and Brand 
            //if yes, link the account 
            //else create a new account
            List<Account> lstAccounts = new List<Account>([Select Id, PersonContactId, Org_Brand__c,PersonMobilePhone,MobileBrand__c, PersonEmail,EmailBrand__c From Account Where  (EmailBrand__c IN :emailIds) ]);
            system.debug(' --- ***** ' + lstAccounts);
            set<string> accountString = new set<string>();
            set<account> setAccount = new set<account>();
            
            
            //Finding the chat transcripts which is having account and assign the related account and contact id
            for(account acc: lstAccounts){
                
                if(acc.PersonEmail != null){
                    if(emailWithChatTranscript.containsKey(acc.PersonEmail+ acc.Org_Brand__c)){
                        emailWithChatTranscript.get(acc.PersonEmail+ acc.Org_Brand__c).accountId = acc.Id;
                        emailWithChatTranscript.get(acc.PersonEmail+ acc.Org_Brand__c).contactid = acc.PersonContactId; 
                        // Removing the chat transcripts with account then It will have only the chat transcripts which is not having account
                        ChatTranscriptwithoutAccount.remove(acc.PersonEmail+ acc.Org_Brand__c);
                    }
                }
                
            }
            
            
            
            if(!ChatTranscriptwithoutAccount.isempty()) {
                //create new person account here
                
                Map<String, Account> newChatTranscriptAccount = new Map<String, Account>();
                list<string> emailnew = new list<string>();
                list<string> brandnew = new list<string>();
                list<string> phonenew = new list<string>();
                for(LiveChatTranscript cs : ChatTranscriptwithoutAccount.values()){
                    
                    String name = cs.Contact_First_Name__c + ' ' + cs.Contact_Last_Name__c; 
                    //if(cs.AccountId == null){
                    Account a = new Account();
                    a.PersonEmail = cs.Contact_Email__c;
                    if(cs.Contact_Email__c != null){
                        emailnew.add(cs.Contact_Email__c+cs.Contact_Brand__c);
                    }
                    
                    a.Org_Brand__c = cs.Contact_Brand__c;
                    
                    
                    if(cs.Contact_Last_Name__c == null || cs.Contact_Last_Name__c == ''){
                        a.LastName = '-';
                    }
                    if(cs.Contact_First_Name__c != null || cs.Contact_First_Name__c != '')
                        a.FirstName = cs.Contact_First_Name__c;
                    if(cs.Contact_Last_Name__c != null || cs.Contact_Last_Name__c != '')
                        a.LastName = cs.Contact_Last_Name__c;
                    string brand = cs.Contact_Brand__c.toLowerCase();
                    system.debug('brand >>>>> '+brand);
                    //Person_Account_Record_Types__c par = Person_Account_Record_Types__c.getValues(brand);
                    //system.debug('par >>>>.. '+par);
                    //system.debug('par recordtype >>>>> '+par.Record_Type_Name__c);
                    a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId();
                    
                    if(cs.Contact_Email__c != null){
                        newChatTranscriptAccount.put(cs.Contact_Email__c, a);
                    }
                    system.debug('newCaseAccount@@@@@@@'+newChatTranscriptAccount);
                }
                // creating New Account
                if(!newChatTranscriptAccount.isEmpty()){
                    system.debug('newCaseAccount@@@@@@@'+newChatTranscriptAccount);
                    insert newChatTranscriptAccount.values();
                }
                map<string,account> contactId = new map<string,account>();
                List<account> accList=[select id,PersonContactId,PersonMobilePhone,PersonEmail from Account Where (EmailBrand__c IN :emailnew)];
                
                if(accList.size() > 0){
                    for(account accRef:accList){
                        
                        if(accRef.PersonEmail != null){
                            contactId.put(accRef.PersonEmail,accRef); 
                        }         
                        else{
                            
                            if(accRef.PersonMobilePhone != null){
                                contactId.put(accRef.PersonMobilePhone,accRef); 
                            }
                        }                       
                    }
                }
                
                for(LiveChatTranscript cs : ChatTranscriptwithoutAccount.values()){
                   if(cs.Contact_Email__c != null){
                        cs.AccountId = newChatTranscriptAccount.get(cs.Contact_Email__c).Id;
                        cs.ContactId = contactId.get(cs.Contact_Email__c).PersonContactId;
                    }
                    
                    
                }   
                
                
                
            } 
        }
        
        catch(exception ex){
            system.debug('Exception >> '+ex+'Line Number >>> '+ex.getLineNumber());
        }
    }
    
    
}