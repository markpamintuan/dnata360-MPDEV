trigger MessagingEndUserTrigger on MessagingEndUser (before insert, after insert, before update, after update) {

    if(Trigger.isInsert && Trigger.isBefore){ 
    }
    else if(Trigger.isInsert && Trigger.isAfter){

    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        MessagingEndUserTriggerHelper.updateAccount(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        MessagingEndUserTriggerHelper.updateCases(Trigger.new, Trigger.oldMap, Trigger.newMap);
        
    } 
}