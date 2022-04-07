trigger MessagingSessionTrigger on MessagingSession(before insert, after insert, before update, after update) {
     
   if(Trigger.isInsert && Trigger.isBefore){ 
       system.debug('before insert - ' + trigger.new);
       MessagingSessionTriggerHandler.linkOutboundMessageNotificationToCase(Trigger.new, Trigger.newMap); 
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        system.debug('After Insert - ' + trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        system.debug('before update - ' + trigger.new);
        MessagingSessionTriggerHandler.createNewCase(Trigger.new, Trigger.newMap); 
    }
    else if(Trigger.isUpdate && Trigger.isAfter){

    }
    else if(Trigger.isDelete && Trigger.isBefore){

    }
    else if(Trigger.isDelete && Trigger.isAfter){

    }
    else if(Trigger.isUnDelete){

    } 
}