({
	 doInit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var parentId = component.get('v.recordId'); 
        var action = component.get('c.runBatch');
        action.setParams({ "recordId":parentId }); 
        action.setCallback(this, function(response) {
                    debugger;
            		$A.get("e.force:closeQuickAction").fire();
                    if (response.getState() == "SUCCESS") { 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message:"Success",
                            type: "success"
                        });
                        toastEvent.fire();
                    }else{
                        var errors = response.getError();
                       if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                    }
                });
                $A.enqueueAction(action);
         

         
				
 }  
})