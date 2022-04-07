({
    doInitHelper : function(component, event, helper) {
       helper.getMailBoxPicklistAPEX(component, event, helper);
       helper.getDeleteRuleRecordAPEX(component, event, helper);
   },
   
   getDeleteRuleRecordAPEX : function(component, event, helper) {
       var action = component.get("c.getEmailRule");
       
       action.setParams({ "recId" : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            debugger;
           var state = response.getState();
           if (state === "SUCCESS") { 
               console.log("--->>> "+JSON.stringify(response.getReturnValue()));
               component.set("v.ruleObj",response.getReturnValue()); 
           }
           else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log("Error message: " + errors[0].message);
                       helper.showErrorToast(component, event, helper, errors[0].message);
                   }
               } else {
                   console.log("Unknown error");
               }
           }
       });

       $A.enqueueAction(action);
   },
   
   getMailBoxPicklistAPEX : function(component, event, helper) {
       debugger;
       var action = component.get("c.getMailBox_picklist_Values");
       
        action.setCallback(this, function(response) {
            debugger;
           var state = response.getState();
           if (state === "SUCCESS") { 
               component.set("v.mailBoxPicklist",response.getReturnValue()); 
           }
           else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log("Error message: " + errors[0].message);
                       helper.showErrorToast(component, event, helper, errors[0].message);
                   }
               } else {
                   console.log("Unknown error");
               }
           }
       });

       $A.enqueueAction(action);
   },
   
   upsertRuleHelper : function(component, event, helper) {
       debugger;
       
       var action = component.get("c.upsertEmailRule");
       console.log('==>> '+JSON.stringify(component.get("v.ruleObj")));
       action.setParams({ 
           "wrap" : component.get("v.ruleObj") 
       });

        action.setCallback(this, function(response) {
            debugger;
           var state = response.getState();
           if (state === "SUCCESS") { 
               debugger;
               helper.gotoRecordDetailPage(component, event, helper, response.getReturnValue()); 
           }
           else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       //console.log("Error message: " +errors[0].message);
                       helper.showErrorToast(component, event, helper, errors[0].message);
                   }
               } else {
                   console.log("Unknown error");
               }
           }
       });

       $A.enqueueAction(action);
   },
   
   gotoRecordDetailPage : function (component, event, helper, recId) {
       var sObjectEvent = $A.get("e.force:navigateToSObject");
       //console.log("recId :: "+recId);
       sObjectEvent.setParams({
           "recordId": recId,
           "slideDevName": "detail"
       });
       sObjectEvent.fire();
   },
   
   showSuccessToast : function(component, event, helper, successMessage) {
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Success!",
           "type": "success",
           "message": successMessage
       });
       toastEvent.fire();
   },
   
   showErrorToast : function(component, event, helper, errorMessage) {
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": "Error!",
           "type": "error",
           "message": errorMessage
       });
       toastEvent.fire();
   },
})