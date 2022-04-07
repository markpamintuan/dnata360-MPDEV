/**
 * @author: Mark Anthony Pamintuan
 * @date: 30 April 2019
 * @description: This trigger is used to handle different events for the Task Object
 * @history:                
 */
trigger TaskTrigger on Task (before insert, before update, after insert, after update, before delete,after delete) {

    if(trigger.IsBefore && trigger.IsInsert){

        TaskTriggerHandler.onBeforeInsert(trigger.New);
   
    }

    if(trigger.IsBefore && trigger.IsUpdate){

        TaskTriggerHandler.onBeforeUpdate(trigger.Old, trigger.New, trigger.OldMap, trigger.NewMap);
  
    }

    if(trigger.IsAfter && trigger.IsInsert){

        TaskTriggerHandler.onAfterInsert(trigger.New);
   
    }    

    if(trigger.IsAfter && trigger.IsUpdate){

        TaskTriggerHandler.onAfterUpdate(trigger.Old, trigger.New, trigger.OldMap, trigger.NewMap);
   
    }
    
    //Added by Sri Bala
    if(trigger.IsAfter && trigger.IsDelete){
        TaskTriggerHandler.onAfterDelete(trigger.Old);
    }
    
}