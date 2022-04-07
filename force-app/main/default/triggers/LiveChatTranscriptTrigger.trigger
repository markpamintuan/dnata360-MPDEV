trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert, after insert, before update, after update) {
    system.debug('CASE - ' + trigger.new);
    system.debug('Before ' + trigger.isBefore);
    system.debug('After ' + trigger.isAfter);
    system.debug('Update ' +trigger.isUpdate);
    system.debug('Insert ' + trigger.isInsert);
    if(trigger.isBefore && (trigger.isInsert )){
      LiveChatTranscriptTriggerHandler.getExistingAccountsforMissedChats(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        LiveChatTranscriptTriggerHandler.createNewCase(trigger.new); //trp only. TR should switch live chat code to reduce triggers
        //LiveChatTranscriptTriggerHandler.getExistingAccountsforMissedChats(trigger.new);
    }

    if(trigger.isAfter && trigger.isUpdate){
        LiveChatTranscriptTriggerHandler.createCaseOnEmailUpdate(trigger.new,trigger.oldMap); //This only runs for TRP TR should switch live chat code to reduce triggers
        
        
    }

    if(trigger.isBefore && trigger.isUpdate){
       LiveChatTranscriptTriggerHandler.populateAccountCaseOnChatTranscript(trigger.new); //This is for all brands
        LiveChatTranscriptTriggerHandler.updateAccountAndContact(trigger.newMap, trigger.oldMap); //This only runs for TRP TR should switch live chat code to reduce triggers
       
    }
}