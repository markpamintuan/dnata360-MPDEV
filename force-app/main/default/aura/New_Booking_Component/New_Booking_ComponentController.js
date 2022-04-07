({
    
        
    handleSuccess : function(component, event, helper) {
        debugger;
        var caserecId = event.getParams().response.id;
        var workspaceAPI = component.find("workspace");
        var record = component.get("v.recordId");
        var derwentCustomerId = component.get("v.accountRecord.Org_Derwent_Customer_No__c"); 
        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");
        
       
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (response) {
                    //confirm("This tab is not a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/lightning/r/Case/'+caserecId+'/view',
                        focus: true
                    });
                    
                    // Pass the record ID to the event
                    redirect.setParams({
                        "recordId": record
                    });
                    
                    // Open the record
                    redirect.fire();
                    if(derwentCustomerId != null){
                        window.open($A.get("$Label.c.Danube_Booking_Page") + $A.get("$Label.c.ekh_Tenant_Id") + '/' + derwentCustomerId + '?trackingTag=' + caserecId , "_blank");   
                    }
        
                }
                else {
                    //confirm("This tab is  a subtab.");
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/lightning/r/Case/'+caserecId+'/view',
                        focus: true
                    });
                    // Pass the record ID to the event
                    redirect.setParams({
                        "recordId": caserecId
                    });
                    
                    // Open the record
                    redirect.fire();
                    if(derwentCustomerId != null){
                        window.open($A.get("$Label.c.Danube_Booking_Page") + $A.get("$Label.c.ekh_Tenant_Id") + '/' + derwentCustomerId + '?trackingTag=' + caserecId , "_blank");   
                    }
        
                    console.log(recordTypeName);
                    
                }
            });
            
            
        })
        
        .catch(function(error) {
            console.log(error);
        });
        /*component.find('notifLib').showToast({
            "variant": "success",
            "title": "Case Created",
            "message": "Record is Created "
        });*/
        
               
    },
	

    
    handleSubmit : function(component, event, helper) {
        debugger;
        var validate = helper.isFormValid(component, event, helper);
        if(validate && validate.length > 0){
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Required Fields",
                "message": "Please fill all the required fields "
            });
            event.preventDefault();
            return;
        }
    }
})