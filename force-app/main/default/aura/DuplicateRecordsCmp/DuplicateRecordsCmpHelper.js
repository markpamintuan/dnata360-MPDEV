({
    getDuplicateRecord : function(component) {        
        var recId = component.get("v.recordId");
        var fieldSetName = component.get("v.fieldSetName");
        var lField = component.get("v.linkingfield");
        var initalField = component.get("v.InitalvalueToUse");
        
        //get instance of server side method
        var action = component.get('c.findDuplicates');
        
        //pass account Id to controller method
        action.setParams({
            recId : recId,
            fieldSetName : fieldSetName,
            linkedField : lField,
            initalField : initalField,
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respData = response.getReturnValue();
                
                //set returned duplicate records to attribute
                component.set("v.DuplicateRecords",respData);
                component.set("v.hasRecords",respData.hasRecords);
                component.set("v.linkedRecCount",respData.linkedRecCount);
                component.set("v.linkedFieldValue",respData.linkedFieldValue);
                
                if(!$A.util.isEmpty(respData)
                  	&& !$A.util.isUndefined(respData)){                    
                    component.set("v.possibleRecs",respData.lstRecIds);
                }
                
                // checking for any error if present then show error in Toast Message
                if(respData.isError){
                    var showToast = $A.get("e.force:showToast"); 
                    showToast.setParams({ 
                        title : 'Error!', 
                        message : respData.errorDetails,
                        type: 'error',
                    }); 
                    showToast.fire(); 
                }
                
            }
            // display a Toast for error as Error in calling Server Method
            else{
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