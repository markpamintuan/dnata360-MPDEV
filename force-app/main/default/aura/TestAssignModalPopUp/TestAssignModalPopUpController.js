({
	closePopUp : function(component, event, helper) {
		var appEvents =$A.get("e.c:TestAssignRowEventApp");
        appEvents.setParams({ "status" :""});
        appEvents.fire();	
    },
    Cancel : function(component, event, helper) {
		var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    }
})