({
    doInitHelper : function(component, event, helper) {
        debugger;            
        
        // making instance
        var action = component.get("c.startValidateProcess");
        
        // setting parameters
        action.setParams({
            "trackerId" : component.get("v.recordId")            
        });
        // method when apex method is called
        action.setCallback(this, function(response) {
            debugger;
            //hide Spinner
            component.set("v.showSpinner", false);
            
            var state = response.getState();
            //(state);
            
            if (state === "SUCCESS") { 
                $A.get("e.force:closeQuickAction").fire();
                helper.successShowToast(component, event, helper,"The process is initiated.");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.errorShowToast(component, event, helper,errors[0].message);
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    helper.errorShowToast(component, event, helper,"Unknown Error!");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    successShowToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type":"success",
            "message": msg
        });
        toastEvent.fire();
    },
    
    errorShowToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type":"error",
            "message": msg
        });
        toastEvent.fire();
    },
})