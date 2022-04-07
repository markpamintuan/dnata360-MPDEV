({
	initializeMethod : function(component, event, helper) {
		component.set("v.Spinner",true);
        helper.getLinkedRecords(component);
	},
    
    handleParentCall : function(component, event, helper) {
    	var params = event.getParam('arguments');       
        
        // checking if the type of method call is refresh then refresh the cmp
        if(!$A.util.isEmpty(params)
          	&& params.eventtype == 'refreshlinkedrecords'){
            helper.getLinkedRecords(component);
        }
    }
    
   
})