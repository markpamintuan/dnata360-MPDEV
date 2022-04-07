({
	getLinkedRecords : function(component) {
		debugger;        
        
    	var recId = component.get("v.recordId");        
		var displayFieldSet = component.get("v.displayFieldSet");
        var linkingField = component.get("v.linkingfield");
        
        //get instance of server side method
		var action = component.get('c.fetchLinkedRecords');
        
        //show spinner
        component.set("v.Spinner",true);
        
        //pass account Id to controller method
        action.setParams({
            recordId : recId,
            displayFieldSetName : displayFieldSet,
            fieldName : linkingField
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {            
			var state = response.getState();
            if (state === "SUCCESS") {            
                debugger;                
                var result = response.getReturnValue(); 
                component.set("v.SearchedRecords",result);
                component.set("v.Spinner",false);
            }else{
                /*
                var showToast = $A.get("e.force:showToast"); 
                    showToast.setParams({ 
                        title : 'Error!', 
                        message : 'Error in calling Server Method',
                        type: 'error',
                    }); 
                 showToast.fire();
                 */
            }
        });
        
        //adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
})