trigger SurveySentTrigger on Survey_Sent__c (
    before insert, before update, before delete, 
    after insert, after update, after delete, after undelete) {  
        
        
    if(Trigger.isAfter) {
        if(Trigger.isInsert){
            SurveySentTriggerHandler.onAfterInsert(Trigger.newMap);
        }else if(Trigger.isUpdate){
            SurveySentTriggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);   
        }     
     }
        
        

}