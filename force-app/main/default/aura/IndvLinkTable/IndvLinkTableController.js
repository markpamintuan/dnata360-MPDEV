({
	doInit: function(component, event, helper) {
        // Fetch the cbigObject list from the Apex controller
        helper.getIndvLnks(component, event, helper);
        
      },
})