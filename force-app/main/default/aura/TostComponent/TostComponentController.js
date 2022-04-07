({
    displayTost : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": component.get("v.title"),
            "message": component.get("v.Message"),
            "type" : component.get("v.type")
        });
        
        // firing the event
        if(component.get("v.displayTostMsg")){ 
            toastEvent.fire();
            
            // setting variable to false
            component.set("v.displayTostMsg",false); 
        }
    }
})