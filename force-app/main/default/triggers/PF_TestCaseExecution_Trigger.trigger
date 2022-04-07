/****************************************
 * Trigge Name : PF_TestCaseExecution_Trigger 
 * 
 * Description: Used to update First Pass Rate and the status value
 * 
 * Created By : Prasheela
 * ****************************************/

trigger PF_TestCaseExecution_Trigger on PF_TestCaseExecution__c (after insert,after update,after delete) {

  
    if ( trigger.isAfter ) {
    
            if ( trigger.isInsert ) {
                  PF_TestCaseExecution_TriggerHandler.onAfterInsert(trigger.new);
            } else if ( trigger.isUpdate ) {
                 PF_TestCaseExecution_TriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
            }
             else if ( trigger.isDelete ) {
                 PF_TestCaseExecution_TriggerHandler.onAfterDelete(trigger.old, trigger.oldMap);
            }
            
    }
    

}