({

    newCommendations : function (component, event, helper) {
        debugger;
        var parentRecordDetails = component.get("v.recordInfo");
        
        //console.log(JSON.stringfy(parentRecordDetails));
        //console.log(parentRecordDetails.Id);
        
        var parentId = component.get('v.recordId');
        console.log(parentId);
        var caseRecTypeId = $A.get("$Label.c.dTME_Commendations_Case_Record_Type_ID");
        //var bkgCSRRecType = $A.get("$Label.c.CSR_Record_Type_Id"); 
        console.log(caseRecTypeId);
        debugger;
        console.log(parentRecordDetails.Id);
        console.log(parentRecordDetails.PersonContactId);
        if(parentId.startsWith("001")){
            console.log(parentId);
            var createRecordEvent = $A.get("e.force:createRecord");
            
            //console.log(recTypeId);
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": caseRecTypeId,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Id,
                    "ContactId": parentRecordDetails.PersonContactId,
                    "Subject": "New Booking for " + parentRecordDetails.Name
                }
            });
                        
            createRecordEvent.fire();
            //var popupWindow = window.open($A.get("$Label.c.ADT_Customer_Page"), "_blank");
        } else if(parentId.startsWith("a09")){
            
            console.log(parentId);
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": caseRecTypeId,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Account_Name__c,
                    "ContactId": parentRecordDetails.Person_Account_Contact_Id__c,
                    "Booking__c": parentRecordDetails.Id
                }
            });
            createRecordEvent.fire();
            //var popupWindow = window.open($A.get("$Label.c.ADT_Customer_Page"), "_blank");
        }
        
        
        
        
        var a = component.get('c.defaultCloseAction');
        $A.enqueueAction(a);
        
    },
    defaultCloseAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            var a = component.get('c.newCommendations');
            $A.enqueueAction(a);
            
        } 
    }
})