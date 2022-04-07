trigger EmailRuleTrigger  on Email_Rule__c (Before insert, Before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            EmailRuleTriggerHelper.updateSoqlDetails(Trigger.new);
        }
    }
}