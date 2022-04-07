({
   	openRecord : function(component, event, helper) {
		var sobjectEvent=$A.get("e.force:navigateToSObject");
        sobjectEvent.setParams({            
            "recordId": component.get("v.selectedRecord").Id            
        });
        sobjectEvent.fire();
	},
    
	linkRecord : function(component) {
        debugger;
    	var recId = component.get("v.recordId");        
		var displayFieldSet = component.get("v.displayFieldSet");
        var linkingField = component.get("v.linkingfield");
        var selectedRecord = component.get("v.selectedRecord").Id;
        var initialField = component.get("v.InitalvalueToUse");
        
        //get instance of server side method
		var action = component.get('c.linkRecords');
        
        //show spinner
        component.set("v.Spinner",true);
        
        //pass account Id to controller method
        action.setParams({
            recordId : recId,
            displayFieldSetName : displayFieldSet,
            fieldName : linkingField,
            deLinkRecId : selectedRecord,
            initalField : initialField,
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {            
			var state = response.getState();
            if (state === "SUCCESS") {            
                debugger;                
                var result = response.getReturnValue(); 
                //alert('new');
                component.set("v.searchRecords",true);
                /**
                component.set("v.headers",result.lstHeaders);
                component.set("v.duplicateRecords",result.lstDuplicateRecs);
                **/
                //component.set("v.Spinner",false);
                
                // fire search event
                this.fireRefereshEvent(component);
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
        createEvent.setParams({ "message": 'refreshlinkedrecords' });
        createEvent.fire();
	}
})