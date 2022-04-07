({
    /***
     * When next or back is present from button / footer section  then below method is called
     ***/
	itemsChange : function(component, event, helper) {        
		var step = component.get("v.stepNumber");
        var stepString = step.toString();
        component.set("v.currentNumber",stepString);
	}
})