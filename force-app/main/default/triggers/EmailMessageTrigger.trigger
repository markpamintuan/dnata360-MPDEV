trigger EmailMessageTrigger on EmailMessage(before insert, 
											after insert, 
											before update, 
											after update, 
											before delete, 
											after delete) {


    if(Trigger.isInsert && Trigger.isBefore){
        EmailMessageTriggerHandler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        EmailMessageTriggerHandler.onAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        EmailMessageTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        EmailMessageTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        EmailMessageTriggerHandler.onBeforeDelete(Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        EmailMessageTriggerHandler.onAfterDelete(Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUnDelete){
        EmailMessageTriggerHandler.onUndelete(Trigger.new);
    }


    //try{
    //    if(Trigger.isAfter && Trigger.isInsert){
    //        //EmailMessageTriggerHandler.populateEmailIdOnCase(trigger.new);
    //    }        

    //} catch(Exception ex){
    //    system.debug(ex);
    //    throw ex;
    //}
}