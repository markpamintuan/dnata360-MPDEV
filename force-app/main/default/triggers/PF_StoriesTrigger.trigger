trigger PF_StoriesTrigger on PF_Stories__c (after  insert,after update, after delete, after undelete) {
    
    if(trigger.isinsert){
        PF_StoriesTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isupdate){
        PF_StoriesTriggerHandler.onAfterUpdate(trigger.new);
    }
    if(trigger.isdelete){
        PF_StoriesTriggerHandler.onAfterDelete(trigger.old);
    }
}