({
    initializeMethod : function(component, event, helper) {       
        helper.setHasRecords(component);
    },
    
    handleAction : function(component, event, helper) {         
        // checking what is the action based upon that different method will be called
        
         if(component.get("v.actionName") == 'link'){
            component.set("v.Spinner",true);
            helper.linkRecord(component, event, helper);
             component.set("v.Spinner",false);
        }
        
       // checking what is the action based upon that different method will be called
        if(component.get("v.actionName") == 'view'){
            helper.openRecord(component, event, helper);
        } 
    },
    
    refreshPossibleSection : function(component, event, helper) {   
    	debugger;
    }
})