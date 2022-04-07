/* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS     
* Intial      Sri Bala    
****************************************************************
* v1.1        Sri Bala        07-07-2019      If the case brand is trp then show the default trp email template 
**************************************************************************************************/

global class CaseDefaultEmailTemplate implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global CaseDefaultEmailTemplate() {
    }
    
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        system.debug('### Entering QuickAction 1');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
        
        

        // Check if the quick action is the standard case feed Send Email action
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
                defaults.get(j).getTargetSObject().getSObjectType() == 
                EmailMessage.sObjectType && 
                (defaults.get(j).getActionName().equals('Case.SendEmail')||defaults.get(j).getActionName().equals('Case.Email') ) && 
                defaults.get(j).getActionType().equals('SendEmail')) {
                    sendEmailDefaults = 
                        (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                    system.debug('@@'+sendEmailDefaults);
                    break;
                }
            system.debug('@@'+ defaults.get(j).getActionName());
            system.debug('@@'+defaults.get(j).getActionType());
        }
        system.debug('### Entering QuickAction 2');
        if (sendEmailDefaults != null) {

            system.debug('### Entering QuickAction 3');

            Case c = [SELECT Status, Org_Type__c, Org_Brand__c,Record_Type_Name__c,Owner.Email,Org_Current_Team_Name__c FROM Case 
                      WHERE Id=:sendEmailDefaults.getContextId()];
            
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();  
            
            /********* Added by Sri Bala *********************/
            /****************** Setting the default from address for the users
             ****************** Defaulted as now solution is to create a metadata type with Team and Default email adress mappings*****************
			******************* Every user will have team populated and based on team name the default email addrss is set*************************/
            if(c.Org_Brand__c == 'trp'){
               EmailMessage.ValidatedFromAddress = getFromAddress(c);

                /************** If its a internal request, the "To address" should be blank and should not populate any email address
                 ************** There is also a validation rule on email message that a child internal request cannot send email to customer
				 ***********************/
                 if(c.Record_Type_Name__c == 'Travel Republic - Internal Request')
                    EmailMessage.ToAddress = '';
                 system.debug('emailMessage.FromAddress'+emailMessage.FromAddress);
                
            }
            /********************** End ********************************************/
            //Set email template by default for different Case Types.
            
            Integer emailCount = [SELECT count() FROM EmailMessage 
                                  WHERE ParentId=:sendEmailDefaults.getContextId()];
           	//Added as a part of v1.1
            if(c.Org_Brand__c == 'trp'){
                 sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('TR_Template_without_email_body'));
                system.debug('TRP Email');
            }
            //end of v1.1
            if (c.Org_Type__c == 'Job Application') {
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('Job_Application'));
                system.debug('Response Email');
            } 
            if(c.Org_Type__c =='Inbound Visa') {
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('Inbound_Visa'));
                system.debug('Default Email');
            }
            if(c.Org_Type__c == 'Outbound Visa')
            {
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('Outbound_Visa'));
                system.debug('Default Email');                    
            }
            if(c.Org_Type__c == 'International Drivers License'){
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('International_Drivers_license'));
                system.debug('Default Email');
            }
            //emailMessage.FromAddress = 'niel.alobaidi@emirates.com'; //KR adding test
            //emailMessage.ValidatedFromAddress = 'niel.alobaidi@emirates.com'; //KR adding test
            system.debug('### emailMessage: ' + emailMessage);
            sendEmailDefaults.setInsertTemplateBody(false);
            sendEmailDefaults.setIgnoreTemplateSubject(false);


        }
        


    }
    
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate 
                          where developername = : templateApiName].id; 
            system.debug('template ID'+templateId);
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + 
                         templateApiName + ' refer to Setup | Classic Email Templates ' 
                         + templateApiName);
        }
        return templateId;
    }
    
   private String getFromAddress(case c){
        /********** @@ Solution : >>>>>> Custom Metadata that manages the default email address based on team name <<<<<<
         *						  >> User is the case owner.
         * 						  >> Querying the User fields based on case ownerid.
         * 						  >> Quering and Mapping all the records from the "Default_Email_Address_Mappings__mdt" custom metadata
         *                        >> if the user's override default email address is not null
         * 									then From Address = override default email address
         * 						  >> else if user's override default email address is null
         * 									 then From Address = default email address based on user's team name from mapping.
		 ***************************************************************************************************************************/                    
         
        String FromAddress;
        List<Default_Email_Address_Mappings__mdt> emailAddress = new List<Default_Email_Address_Mappings__mdt>();
        List<User> userlist = new List<User>();
        
        Map<String,String> emailAddressMap = new Map<String,String>();
        try{
        userlist = [Select Id,Override_Default_Email_Address__c,Team_Name__c from User where Id =: c.OwnerId];
        emailAddress = [Select Id,Default_Email_Address__c,Team_Name__c 
                        from Default_Email_Address_Mappings__mdt
                        where Brand__c= 'trp'];
        if(emailAddress.size() >0){
            for(Default_Email_Address_Mappings__mdt defaultEmail : emailAddress){
                emailAddressMap.put(defaultEmail.Team_Name__c,defaultEmail.Default_Email_Address__c);
            }
        }

        if(userlist.size() > 0){
            for(User usr:userlist){
                if(usr.Override_Default_Email_Address__c != null && usr.Override_Default_Email_Address__c != '')
                    FromAddress = usr.Override_Default_Email_Address__c;
                else if(emailAddressMap.size() > 0)
                    FromAddress = emailAddressMap.get(usr.Team_Name__c);
            }
        }
        
         return FromAddress;
        }
        catch(Exception e){
            system.debug('Exception ::'+e + 'Line Number >>'+e.getLineNumber());
            return null;
        }
        
    }
    
    
}