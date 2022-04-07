trigger CaseTrigger on Case (before insert, 
                            after insert, 
                            before update, 
                            after update, 
                            before delete, 
                            after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore){ 
        CaseTriggerHandler.populateHotelName(trigger.new);
        CaseTriggerHandler.OnBeforeInsert(Trigger.new);
        if(Label.MessagingUserTurnedOn == 'TRUE'){
            CaseTriggerHandler.populateMessagingUserLookup(Trigger.new,Trigger.newMap);//v1.64 
        }
        
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        CaseTriggerHandler.onAfterInsert(Trigger.new);
        //CaseTriggerHandler.getExistingAccounts(trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        CaseTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        CaseTriggerHandler.populateHotelName(trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        //CaseTriggerHandler.getExistingAccounts(trigger.new);
        CaseTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
     
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        //CaseTriggerHandler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        CaseTriggerHandler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isUnDelete){
        //CaseTriggerHandler.onUndelete(Trigger.new);
    } 
}