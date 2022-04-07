trigger SurveyResponseTrigger on Survey_Response__c (before insert, 
                                                        after insert, 
                                                        before update, 
                                                        after update, 
                                                        before delete, 
                                                        after delete){
    if(Trigger.isInsert && Trigger.isBefore){
        SurveyResponseTriggerHandler.onBeforeInsert(trigger.New);
    }

    if(trigger.isAfter && trigger.isInsert){
        SurveyResponseTriggerHandler.onAfterInsert(trigger.New);
    }

}