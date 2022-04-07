/**************************************************************************************************
* Name               : UserTrigger 
* Description        : This is a trigger for user       
* Created Date       : 01-April-2019                                                                 
* Created By         : Maruf Bagwan                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION      AUTHOR               DATE             COMMENTS                
* v1.0        Maruf Bagwan     01-April-2019      Initial version                                                                                                                             
**************************************************************************************************/
trigger UserTrigger on User (before insert, before update, after insert, after update, before delete) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        UserTriggerHelper.updateUserStore(Trigger.New,Trigger.oldMap,Trigger.isInsert);
    }
}