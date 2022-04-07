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
                
                var rtid = $A.get("$Label.c.dTME_Enquiry_Case_Record_Type_ID");
                action.setParams({
                    "accid": accid,
                    "rtid": rtid,
                    "subject": "New Booking for this Account" 
                });
                action.setCallback(this, function(response) {
                    debugger;
                    if (response.getState() == "SUCCESS") { 
                        debugger;
                        var cid = response.getReturnValue();
                        var currentTargetId = cid;
                        if(derwentCustomerId != null && derwentCustomerId !=''){
                            window.open($A.get("$Label.c.ADT_Customer_Page") + $A.get("$Label.c.dnata_Tenant_Id")+ '/'+ derwentCustomerId.toUpperCase() +'?trackingTag=' + cid, "_blank");
                        }
                        
                        //window.open($A.get("$Label.c.ADT_Customer_Page") + $A.get("$Label.c.dnata_Tenant_Id")+ '/'+ derwentCustomerId +'/' + cid, "_blank");
                        var workspaceAPI = component.find("workspace");
                        
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            //alert('Testing tab'+sforce.console.getPrimaryTabIds(response.tabId));
                            var tabIdToUse = '';
                            if(response.isSubtab){
                                tabIdToUse = response.parentTabId
                            }else{
                                tabIdToUse = response.tabId 
                            }
                            workspaceAPI.openSubtab({
                                parentTabId: tabIdToUse,
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
                        
                    }else{
                        console.log('#### Error: ')
                    }
                });
                $A.enqueueAction(action);
            }
        }, 1000);
        
        
    }
})