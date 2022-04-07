trigger ReconciliationTrigger on Reconciliation__c (after update) {
	 if(trigger.isAfter
        && trigger.isUpdate){        
			ReconciliationTriggerHelper.scheduleBatch(trigger.new);
            
    }
}