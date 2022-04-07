({
    doInit : function(component, event, helper) {
        debugger;
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.fetchChildRecords");
        action.setParams({ objId : component.get("v.recId") });
        var recId = component.get("v.recId");

        console.log('£££ recId: ' + recId);
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            debugger;
            component.set("v.showSpinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                component.set("v.childObjDetails",response.getReturnValue())
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
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
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    cancel : function(component, event, helper) {
    	component.set("v.displayChildRecordsModal",false);
    },
    
    openSubtab: function(component, event, helper) {
    	debugger;
        component.set("v.showSpinner",true);
        // calling method to hide it
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner",false);
                //component.set("v.displayChildRecordsModal",false);
            }), 1000
        );
        var objName = component.get("v.sObjectName");
        var recId = component.get("v.recId");
        
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.isConsoleNavigation().then(function(response) {
            
            if(response){
                workspaceAPI.openTab({
                    url: '/lightning/n/GDPR_Process',
                    focus: true
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/lightning/r/'+objName+'/'+recId+'/view',
                        focus: true
                    });
                })
            }
            else{
                var navService = component.find("navService");
                var pageReference = {    
                    "type": "standard__recordPage", 
                    "attributes": {
                        "recordId": recId, 
                        "actionName": "view"
                    }
                }
                
                navService.generateUrl(pageReference)
                .then($A.getCallback(function(url) {                    
                    window.open(url,'_blank'); //this opens your page in a seperate tab here
                }), 
                      $A.getCallback(function(error) {
                          console.log('error: ' + error);
                      }));
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})