trigger BookingTrigger on Booking__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(AvoidRecursion.recurRun){
    
    if(Trigger.isInsert && Trigger.isBefore){
        BookingTriggerHandler.onBeforeInsert(trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        BookingTriggerHandler.onAfterInsert(trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        BookingTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);  
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        BookingTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

    }
   /* else if(Trigger.isDelete && Trigger.isBefore){
        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        
    }
    else if(Trigger.isUnDelete){
        
    } */
    }
}