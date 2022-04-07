({
    
    redirectToDanube : function (component, event, helper) {
        //debugger;
        var parentRecordDetails = component.get("v.recordInfo");
        
        //console.log(JSON.stringfy(parentRecordDetails));
        //console.log(parentRecordDetails.Id);
        
        var parentId = component.get('v.recordId');
        console.log(parentId);
        var caseEnqRecTypeId = $A.get("$Label.c.New_Enquiry_Record_Type_ID");
        var bkgCSRRecType = $A.get("$Label.c.CSR_Record_Type_Id"); 
        console.log(caseEnqRecTypeId);
        
        
        if(parentId.startsWith("001")){
            console.log(parentId);
            var createRecordEvent = $A.get("e.force:createRecord");
            
            //console.log(recTypeId);
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": caseEnqRecTypeId,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Id,
                    "ContactId": parentRecordDetails.PersonContactId,
                    "Subject": "New Booking for " + parentRecordDetails.Name
                }
            });
                        
            createRecordEvent.fire();
            var popupWindow = window.open($A.get("$Label.c.Danube_Booking_Page"), "_blank");
        } else if(parentId.startsWith($A.get("$Label.c.BookingRecordIdPrefix"))){
            
            console.log(parentId);
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": bkgCSRRecType,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Account_Name__c,
                    "ContactId": parentRecordDetails.Person_Account_Contact_Id__c,
                    "Booking__c": parentRecordDetails.Id
                }
            });
            createRecordEvent.fire();
            var popupWindow = window.open($A.get("$Label.c.Danube_Booking_Page"), "_blank");
        }
        
        
        
        
        var a = component.get('c.defaultCloseAction');
        $A.enqueueAction(a);
        
    },
    defaultCloseAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    getAllTabInfo : function(component, event, helper) {

                debugger;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log(response);
       })
        .catch(function(error) {
            console.log(error);
        });
    },

    handleRecordUpdated: function(component, event, helper) {


        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            var a = component.get('c.redirectToDanube');
            $A.enqueueAction(a);
            
        } /*else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }*/
    }
})