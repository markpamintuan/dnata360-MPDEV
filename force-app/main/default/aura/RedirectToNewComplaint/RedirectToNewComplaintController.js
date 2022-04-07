({
    
    redirectToComplaint : function (component, event, helper) {
        //debugger;
        var parentRecordDetails = component.get("v.recordInfo");
        
        //console.log(JSON.stringfy(parentRecordDetails));
        //console.log(parentRecordDetails.Id);
        
        var parentId = component.get('v.recordId');
        console.log(parentId);
        var caseCompRecTypeId = $A.get("$Label.c.Complaints_Record_Type_ID");
        //var bkgCSRRecType = $A.get("$Label.c.CSR_Record_Type_Id"); 
        console.log(caseCompRecTypeId);
        
        
        if(parentId.startsWith("001")){
            console.log('001:::' + parentId);
            var createRecordEvent = $A.get("e.force:createRecord");
            
            //console.log(recTypeId);
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": caseCompRecTypeId,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Id,
                    "ContactId": parentRecordDetails.PersonContactId,
                    "Subject": "New Complaint for " + parentRecordDetails.Name
                }
            });
            
            createRecordEvent.fire();
        } else if(parentId.startsWith($A.get("$Label.c.BookingRecordIdPrefix"))){
            
            console.log('### 123 a09_parentId:::'+parentId);
            //console.log('a09_parentRecordDetails.Org_Account_Name__r.PersonContactId:::'+parentRecordDetails.Org_Account_Name__r.PersonContactId);
            console.log('a09_parentRecordDetails.Id:::'+parentRecordDetails.Id);
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "recordTypeId": caseCompRecTypeId,
                "defaultFieldValues": {
                    "AccountId": parentRecordDetails.Org_Account_Name__c,
                    "ContactId": parentRecordDetails.Org_Person_Account_Contact_Id__c,
                    "Org_Booking__c": parentRecordDetails.Id,
                    "Subject": "New Complaint for " + parentRecordDetails.Org_Account_Name__r.Name
                }
            });
            createRecordEvent.fire();
        }
        
        
        //var popupWindow = window.open("https://www.google.com?q=salesforce+lightning", "_blank");
        
        //var a = component.get('c.defaultCloseAction');
        //$A.enqueueAction(a);
        
    },
    defaultCloseAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            var a = component.get('c.redirectToComplaint');
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