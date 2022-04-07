({
	getIndvLnks: function(component, event, helper) {
		var mergeId = component.get("v.mergeId");
        var action = component.get("c.getIndvLinks");
    	action.setParams({
			mergeId : mergeId
		});
    	action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                
                var conts = response.getReturnValue(); 
                console.log(conts);
                component.set("v.wrapperList",conts);
             }
			else {
				console.log("Failed with state: " + state);
			}
		});
       
		$A.enqueueAction(action);
       
	},
})