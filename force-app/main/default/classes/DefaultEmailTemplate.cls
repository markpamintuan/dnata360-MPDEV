global class DefaultEmailTemplate implements Support.EmailTemplateSelector {
    // Empty constructor 
    global DefaultEmailTemplate() {    }

    // The main interface method 
    global ID getDefaultEmailTemplateId(ID caseId) {
        // Select the case we're interested in, choosing any fields that are relevant to our decision
        Case c = [SELECT Org_Type__c,Case_Email_Subject__c FROM Case WHERE Id=:caseId];

        EmailTemplate et;

        if (c.Case_Email_Subject__c.contains('Job Application')) {
            et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'dTME_Auto_Response'];
        } else if(c.Case_Email_Subject__c.contains('Visa')) {
            et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'dTME_Auto_Response'];
        } 
        
        // Return the ID of the template selected
        return et.id;
    }
}