({
    /**
     * When next step is clicked
     ***/
	goToNextStep : function(component, event, helper) {
		var step = component.get("v.stepNumber");
        // if current step is 1
        if(step == 1){
        	step = -1;
        }
        
        // if current step 2
        else if(step == 2 || step == 3){
            debugger;
            // checking do we have any selected records
            var allRecs = component.get("v.resultWrapList");
            
            // for each record
            for(var ele in allRecs){
                
                if(allRecs[ele].lstRecords != undefined
                  	&& allRecs[ele].lstRecords.length > 0){
                    
                    // for each record check if any of the record is selected
                    for(var rec in allRecs[ele].lstRecords){
                        
                        // if record is selected then set the step and return
                        if(allRecs[ele].lstRecords[rec].isSelected){
                            step = step + 1;
                            component.set("v.stepNumber",step);
                            
                            // if step is 3 then show spinner then hide it
                            component.set("v.showSpinner",true);
                            
                            // calling method to hide it
                            window.setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.showSpinner",false);
                                }), 1000
                            );                            
                            return;
                        }
                    }
                }
            }
            
            // display a toast message that non of the record is selected
            helper.showToast(component, event, helper,'Please Select a Record ');
            
            
        }
        
        else{
            step = step + 1;
        }        
        component.set("v.stepNumber",step);
	},
    
    /**
     * When previous Step is clicked
     ***/
    goToPreviousStep : function(component, event, helper) {
		var step = component.get("v.stepNumber");
        step = step - 1;
        component.set("v.showSpinner",true);
        
        // calling method to hide it
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner",false);
            }), 1000
        );
        component.set("v.stepNumber",step);
	},
    
    /***
     * When cancel is clicked
     ***/
    cancel : function(component, event, helper) {
        
    }
})