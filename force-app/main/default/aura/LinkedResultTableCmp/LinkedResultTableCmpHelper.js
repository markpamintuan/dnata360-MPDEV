({
	openRecord : function(component, event, helper) {
		var sobjectEvent=$A.get("e.force:navigateToSObject");
        sobjectEvent.setParams({            
            "recordId": component.get("v.selectedRecord").Id            
        });
        sobjectEvent.fire();
	},
    
    delinkRecord : function(component, event, helper) {
        debugger;
    	var recId = component.get("v.recordId");        
		var displayFieldSet = component.get("v.displayFieldSet");
        var linkingField = component.get("v.linkingfield");
        var initalField = component.get("v.InitalvalueToUse");
        var selectedRecId = component.get("v.selectedRecord").Id;
        
        //get instance of server side method
		var action = component.get('c.deLinkRecord');
        
        //show spinner
        component.set("v.Spinner",true);
        
        //pass account Id to controller method
        action.setParams({
            recordId : recId,
            displayFieldSetName : displayFieldSet,
            fieldName : linkingField,
            deLinkRecId : selectedRecId,
            initField : initalField,
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {            
			var state = response.getState();
            if (state === "SUCCESS") {            
                debugger;                
                var result = response.getReturnValue(); 
                component.set("v.headers",result.lstHeaders);
                component.set("v.records",result.lstRecs);
                component.set("v.hasRecords",result.hasRecords);
                this.fireRefereshEvent(component);
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
    
    fireRefereshEvent : function (component){       
    	var createEvent = component.getEvent("SearchEvent");
        createEvent.setParams({ "message": 'refreshpossiblerecords' });
        createEvent.fire();
	}
})