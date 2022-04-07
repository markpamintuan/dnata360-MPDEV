trigger ItineraryTrigger on Itinerary__c (  before insert, 
                                            after insert, 
                                            before update, 
                                            after update, 
                                            before delete, 
                                            after delete) {
    if(Label.RunItineraryDetailsTrigger == 'TRUE'){
            if(Trigger.isInsert && Trigger.isBefore){
                ItineraryTriggerHandler.OnBeforeInsert(Trigger.new);
            }
            else if(Trigger.isInsert && Trigger.isAfter){
                ItineraryTriggerHandler.onAfterInsert(Trigger.new);
            }
            else if(Trigger.isUpdate && Trigger.isBefore){
                ItineraryTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
                
            }
            else if(Trigger.isUpdate && Trigger.isAfter){
                ItineraryTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);     
            }
         /*   else if(Trigger.isDelete && Trigger.isBefore){

            }
            else if(Trigger.isDelete && Trigger.isAfter){
                ItineraryTriggerHandler.onAfterDelete(Trigger.old, Trigger.oldMap);
            }
            else if(Trigger.isUnDelete){

            } */   
    }

}