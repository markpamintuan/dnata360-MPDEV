/**************************************************************************************************
* Name               : InboundSocialPostHandlerImpl          
* Created Date       : 09-May-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Kaavya        08-Aug-2018    Initial version
* v1.1        Sri Bala      06-Dec-2018    T-00305 - Case Origin change for Other Social Network. 
* v1.2        Sri Bala      14-Aug-2019    Create TRP cases based on classifications
* v1.3        Kaavya        20-Nov-2019    T-00451 - Fix for Twitter direct messages
**************************************************************************************************/



global virtual class InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler {

    final static Integer CONTENT_MAX_LENGTH = 32000;
    Boolean isNewCaseCreated = false;
    
    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 5;
    }
    
    // Create a case if one of these post tags are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }
    
    //***added by Kaavya
    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){
        return true;
    }
    
    global virtual String getDefaultAccountId() {
        return null;
    }

    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
       

            Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
            result.setSuccess(true);
            matchPost(post);
            matchPersona(persona);
            String brand = post.TopicProfileName;
            system.debug('#### handleInboundSocialPost post: ' + post);
            system.debug('#### handleInboundSocialPost persona: ' + persona);
            system.debug('#### handleInboundSocialPost rawData: ' + rawData);
            
            if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
                post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
            }
            
                if (post.Id != null) { 
                    handleExistingPost(post, persona);
                    return result;
                }
                   setReplyTo(post, persona);
                    upsert post;
               
                    buildPersona(post,persona); //**modified by Kaavya -Added post in the method parameter
                Case parentCase = new Case();
                   parentCase = buildParentCase(post, persona, rawData);
                    setRelationshipsOnPost(post, persona, parentCase);
                    setModeration(post, rawData);
                    upsert post;
           
            
            
            
            if(isNewCaseCreated){
                updateCaseSource(post, parentCase);
            }
            
            return result;
        
    }
    
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }
    
    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
    
    }
    
    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        update post;
        if (persona.id != null)
            updatePersona(persona);
    }

    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    private SocialPersona buildPersona(SocialPost post,SocialPersona persona) { //**modified by Kaavya -Added post in the method parameter
        if (persona.Id == null)
            createPersona(post,persona); //**modified by Kaavya -Added post in the method parameter
        else
            updatePersona(persona);
            
        return persona;
    }
    
    private void updatePersona(SocialPersona persona) {
        try{
            update persona;
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }
    
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
                //***Added by kaavya for reassigning back to queue
                //Commented as per defect no 436- reply should not go back to queue
                //Uncommented as per ticket no 179 - reply should go back to queue
                if (getUsingCaseAssignmentRule()){
                    //Find the active assignment rules on case
                    AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
                    if (rules.size() > 0){
                        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                        dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
        
                        //Setting the DMLOption on Case instance
                        parentCase.setOptions(dmlOpts);
                        update parentCase;
                    }
                } 
                
                //*****
                if (!parentCase.IsClosed) {
                    return parentCase;
                }
                else if (caseShouldBeReopened(parentCase)) {
                    reopenCase(parentCase);
                    return parentCase;
                }
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                /* v1.3 Commenting TR changes
                if(post.TopicProfileName.contains('TravelRepublic')) //v1.2
                    return createTRPCase(post,persona);//v1.2
                else */
                    return createCase(post, persona);
            }
        }
        
        return null;
    }
    
    private boolean caseShouldBeReopened(Case c){
        return c.id != null && c.isClosed && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }

    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;
            
            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }
    
    private Case createCase(SocialPost post, SocialPersona persona) {
        system.debug('### Entering createCase with post: ' + post);
        system.debug('### Entering createCase with persona: ' + persona);
        Case newCase = new Case(subject = post.Name);
        if(persona.id!=null)
        newCase.Social_Persona__c=persona.id;
        
        //**commneted by Kaavya
        /*
        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                newCase.AccountId = persona.ParentId;
            }
        }
        
        //Added by Kaavya
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        
        List<Account> custlist = [select id,PersonContactId,firstname,lastname,Org_Business_Unit__c from Account where lastName = :lastName AND firstName = :firstName AND Org_Business_Unit__c='dTME'];
        if(custlist.size()==1){
              newCase.AccountId = custlist[0].id;  
              newCase.ContactId = custlist[0].PersonContactId;

        }
        */
        if(post.Content!=null)
            newCase.Description=post.Content;
        //********
        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider;
            //Added as a part of v1.1
            if(post.Provider == 'Other Media Type')
                newCase.Origin = 'Social Media';
            system.debug('@#$'+newCase.Origin);
        }
        
        system.debug('<<ManagedAccount>>'+post.OutboundSocialAccount);
        system.debug('<<TopicProfile>>'+post.TopicProfileName);
        system.debug('post.TopicType!!!!!!!!!!!!!'+post.TopicType);
        newCase.Topictype__c = post.TopicType;
        newCase.Social_Source__c=getSocialBrand(post.TopicProfileName);
        
        //***Added by kaavya
       // if (getUsingCaseAssignmentRule()){
            //Find the active assignment rules on case
            AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
              system.debug('rules!@@@@@'+rules);
            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                  system.debug('dmlOpts!@@@@@'+dmlOpts);
                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
    //    }
        
        //*****
        insert newCase;
         system.debug('newCase!@@@@@'+newCase);
        return newCase;
    }
    //v1.12
    /* v1.3 Commenting TR changes
       private Case createTRPCase(SocialPost post, SocialPersona persona) {
        system.debug('### Entering createCase with post: ' + post);
        system.debug('### Entering createCase with persona: ' + persona);
        Case newCase = new Case(subject = post.Name);
           if(post.Classification == 'Travel Republic - Complaint')
               newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId();
           else if(post.Classification == 'Travel Republic - Booking Enquiry')
               newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Booking Enquiry').getRecordTypeId();
           else if(post.Classification == 'Travel Republic - Internal Request')
               newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
           
           
        if(persona.id!=null)
        newCase.Social_Persona__c=persona.id;
        
        
        if(post.Content!=null)
            newCase.Description=post.Content;
        //********
        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider;
            //Added as a part of v1.1
            if(post.Provider == 'Other Media Type')
                newCase.Origin = 'Social Media';
            system.debug('@#$'+newCase.Origin);
        }
        
        system.debug('<<ManagedAccount>>'+post.OutboundSocialAccount);
        system.debug('<<TopicProfile>>'+post.TopicProfileName);
        system.debug('post.TopicType!!!!!!!!!!!!!'+post.TopicType);
        newCase.Topictype__c = post.TopicType;
        newCase.Social_Source__c=getSocialBrand(post.TopicProfileName);
        
           AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
              system.debug('rules!@@@@@'+rules);
            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                  system.debug('dmlOpts!@@@@@'+dmlOpts);
                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
  
        insert newCase;
         system.debug('newCase!@@@@@'+newCase);
        return newCase;
    } */
    ///v1.2
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;
        //start of v1.3
        /*  Commented as part of v1.3
        if (post.ReplyTo != null && !isReplyingToAnotherCustomer(post, persona) && !isChat(post)) {
                parentCase = findParentCaseFromPostReply(post);
        }*/
        
        if(Social__c.getInstance().Link_Chat__c){ 
            //Removing condition which checks if the post is private or direct and not link to parent case
            if (post.ReplyTo != null && !isReplyingToAnotherCustomer(post, persona) ) {
                parentCase = findParentCaseFromPostReply(post);
            }
        }
        else{
            //Keep original condition
            if (post.ReplyTo != null && !isReplyingToAnotherCustomer(post, persona) && !isChat(post)) {
                parentCase = findParentCaseFromPostReply(post);
            }
        }
        //End of v1.3
        /* Commented by Kaavya so that new post becomes new case
        if (parentCase == null) {
            parentCase = findParentCaseFromPersona(post, persona);
        }*/
        return parentCase;
    }
    
    private boolean isReplyingToAnotherCustomer(SocialPost post, SocialPersona persona){
        return !post.ReplyTo.IsOutbound && post.ReplyTo.PersonaId != persona.Id;
    }
    
    private boolean isChat(SocialPost post){
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }

    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Org_Case_Status__c, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Org_Case_Status__c, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    private void reopenCase(Case parentCase) {
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Org_Case_Status__c = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }

    private void matchPost(SocialPost post) {
            if (post.Id != null) return;
        
        performR6PostIdCheck(post);
        
        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }
    
    
    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    
    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')){
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null) 
                    return replyTo;
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }

    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

    private void matchPersona(SocialPersona persona) {
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if(persona.Provider != 'Other' && String.isNotBlank(persona.ExternalId)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    Provider = :persona.Provider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    Name = :persona.Name LIMIT 1];
            }
                    
            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }

    private void createPersona(SocialPost post,SocialPersona persona) { //**modified by Kaavya -Added post in the method parameter 
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona))
            return;

        //SObject parent = createPersonaParent(persona); //**modified by Kaavya -Added post in the method parameter        
        persona.ParentId = post.id;  //**modified by Kaavya -//=parent.Id; 
        insert persona;
        post.personaid=persona.id;
        update post;
    }

    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) && 
               String.isNotBlank(persona.Provider) && 
               String.isNotBlank(persona.MediaProvider);
    }
    
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }
    
    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }
    
    private boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }
    
    private Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null)
            postTags.addAll(post.postTags.split(',', 0));
        return postTags;
    }

    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);      
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }
    
    global String getPersonaLastName(SocialPersona persona) {   
        String name = getPersonaName(persona);   
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }
    
    global virtual SObject createPersonaParent(SocialPersona persona) {

        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        
        Contact contact = new Contact(LastName = lastName, FirstName = firstName);
        String defaultAccountId = getDefaultAccountId();
        if (defaultAccountId != null)
            contact.AccountId = defaultAccountId;
        insert contact;
        
        return contact;
    }
    
     //Generic method for getting field look up value from other Lookup
    global String getSocialBrand(String topic){
        topic=topic.toLowerCase();
        Social_Setup__mdt socialset = [select id,developername,label,brand__c from Social_Setup__mdt where label=:topic];
                    system.debug('topic!!!!!!!!!!!!!'+topic);

            system.debug('socialset!!!!!!!!!!!!!'+socialset);
        return socialset.brand__c;
    }


}