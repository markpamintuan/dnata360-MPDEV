public class EmailRuleTriggerHelper {

    
    public static void updateSoqlDetails(List<Email_Rule__c> rulesList){
        //Calling Utility
        RulesUtility.updateSoqlDetails(rulesList);
    }
}