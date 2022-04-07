trigger CSRTrigger on CSR__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        CSRTriggerHandler.onBeforeInsert(trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        CSRTriggerHandler.onBeforeUpdate(trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        CSRTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
 /*   else if(Trigger.isDelete && Trigger.isBefore){
        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        
    }
    else if(Trigger.isUnDelete){
        
    }*/
}