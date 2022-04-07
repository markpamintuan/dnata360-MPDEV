({
		getBig: function(component, event, helper) {
		var AccId = component.get("v.recordId");
        console.log(AccId);
        var action = component.get("c.getBigObject");
    	action.setParams({
			AccountId : AccId
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