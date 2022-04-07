({
    processRecords : function(component, event, helper, selectedRecs){
        debugger;            
        
        // making instance
        var action = component.get("c.processRecords");

        // setting parameters
        action.setParams({
            "selectedRecords" : JSON.stringify(selectedRecs)            
        });
        
        // method when apex method is called
        action.setCallback(this, function(response) {
            debugger;
            //hide Spinner
            component.set("v.showSpinner", false);
            
            var state = response.getState();
            //(state);
            
            if (state === "SUCCESS") { 
                
                //var res = response.getReturnValue();  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": "The records selected are being processed."              
                    
                });
                toastEvent.fire();


            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //component.set("v.stepNumber", 1);
                        this.showToast(component, event, helper, errors[0].message, 'error');
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    //component.set("v.stepNumber", 1);
                    this.showToast(component, event, helper, 'Unknown Error', 'error');
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    
})