({
	doInit : function(component, event, helper) {
		debugger;
        //alert(component.get("v.recordId"));
        helper.doInitHelper(component, event, helper);
	},
    
     upsertRule : function(component, event, helper) {
		debugger;
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            //inputCmp.reportValidity();
           // inputCmp.focus();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            helper.upsertRuleHelper(component, event, helper);
        } else {
            helper.showErrorToast(component, event, helper, 'Please update the invalid form entries and try again.');
        }
        
	},
    
    cancel : function(component, event, helper) {
		debugger;
        
        if (!$A.util.isUndefinedOrNull(component.get("v.ruleObj.recID"))) {
            helper.gotoRecordDetailPage(component, event, helper, component.get("v.ruleObj.recID"));
        }else{
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Email_Rule__c"
            });
            homeEvt.fire();

        }
        
    },
})