({
    doInit : function(component, event, helper) {
        debugger;
        var accid = component.get("v.recordId"); 
        var acc = '';
        var derwentCustomerId = '';

        //Need to delay until modal opens
        setTimeout(function(){
            acc = component.get("v.accountRecord");
            derwentCustomerId = acc.Org_Derwent_Customer_No__c;
        if(derwentCustomerId =='' || derwentCustomerId == null){
        $A.get("e.force:closeQuickAction").fire();
            setTimeout(function(){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'This account is not Derwent yet! Please try again in a few moments',               
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }, 1000);
        }else{
            
            
            var action = component.get("c.autoCreateCase");
            
            var rtid = $A.get("$Label.c.EKUK_Enquiry_Case_Record_Type_ID");
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
                    
                    window.open($A.get("$Label.c.Danube_Booking_Page") + $A.get("$Label.c.ekh_Tenant_Id") + '/' + derwentCustomerId + '?trackingTag=' + cid , "_blank");
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
            
        }, 1000);
        

    }
})