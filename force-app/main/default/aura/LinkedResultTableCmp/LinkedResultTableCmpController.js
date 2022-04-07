({
    handleAction : function(component, event, helper) { 
        debugger;
        // checking what is the action based upon that different method will be called
        if(component.get("v.actionName") == 'view'){
            helper.openRecord(component, event, helper);
        }        
        
        else if(component.get("v.actionName") == 'delink'){
            helper.delinkRecord(component, event, helper);
        }
    }
})