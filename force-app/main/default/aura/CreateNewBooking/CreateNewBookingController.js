({
    doInit : function(component, event, helper) {
        debugger;
        var accid = component.get("v.recordId");        
        var action = component.get("c.autoCreateCase");
        window.open($A.get("$Label.c.Danube_Booking_Page"), "_blank");
        var rtid = $A.get("$Label.c.dTME_Enquiry_Case_Record_Type_ID");
        action.setParams({
            "accid": accid,
            "rtid": rtid,
            "subject": "New Booking for this Account" 
        });
        action.setCallback(this, function(response) {
            debugger;
            if (response.getState() == "SUCCESS") {                
                var cid = response.getReturnValue();
                var currentTargetId = cid;
                var workspaceAPI = component.find("workspace");
               
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response.tabId,
                        recordId: cid,
                        focus: true
                    }).then(function(response) {
                        setTimeout(function(){
                            var editRecordEvent = $A.get("e.force:editRecord");
                            editRecordEvent.setParams({
                                 "recordId": cid
                            });
                            editRecordEvent.fire();
                        }, 500);
                    });                    
                })
                .catch(function(error) {
                    console.log(error); 
                });
           
            }
        });
        $A.enqueueAction(action);
    }
})