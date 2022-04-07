trigger CustomerCommunicationTrigger on Customer_Communication__c (after insert,after update) {
    
    if(trigger.isAfter
        && trigger.isInsert){        
        Customer_CommunicationHelper.SendDetails(trigger.new);
    }
    
    if(trigger.isAfter
        && trigger.isUpdate){        
        Customer_CommunicationHelper.markCancelled(trigger.new);
    }
    
    
   
 
}