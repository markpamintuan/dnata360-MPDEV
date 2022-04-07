trigger ItineraryDetailTrigger on Itinerary_Detail__c ( before insert, 
                                                        after insert, 
                                                        before update, 
                                                        after update, 
                                                        before delete, 
                                                        after delete) {
    if(Label.RunItineraryDetailsTrigger == 'TRUE'){
        if(Trigger.isInsert && Trigger.isBefore){
            ItineraryDetailTriggerHandler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            ItineraryDetailTriggerHandler.onAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            ItineraryDetailTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            ItineraryDetailTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
         
        }
        else if(Trigger.isDelete && Trigger.isBefore){
           
        }
        else if(Trigger.isDelete && Trigger.isAfter){
            ItineraryDetailTriggerHandler.onAfterDelete(Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUnDelete){

        }
    } 
}