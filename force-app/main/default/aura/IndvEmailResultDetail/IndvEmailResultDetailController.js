({
	init : function(component, event, helper) 
    {
		
        var pageReference = component.get("v.pageReference");
        console.log('################## pageReference insid ',JSON.stringify(pageReference));
		component.set("v.MergeID", pageReference.state.c__MergeID);
        component.set("v.RelObjID", pageReference.state.c__RelObjID);
        component.set("v.RelSendID", pageReference.state.c__RelSendID);
        helper.fetchEmailHelper(component, event, helper);
       
	}
})