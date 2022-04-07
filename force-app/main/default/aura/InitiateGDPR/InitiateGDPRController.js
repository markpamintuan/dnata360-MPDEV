({
	doInit : function(component, event, helper) {
        // show spinner
        component.set("v.showSpinner", true);
		helper.doInitHelper(component, event, helper);
	}
})