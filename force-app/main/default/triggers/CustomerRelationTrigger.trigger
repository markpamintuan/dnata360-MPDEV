trigger CustomerRelationTrigger on Relation__c (before insert,after insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        
     CustomerRelationTriggerHandler.onBeforeInsert(Trigger.new);
    }
     else if(Trigger.isInsert && Trigger.isAfter){
        CustomerRelationTriggerHandler.onAfterInsert(trigger.new);
    }
}