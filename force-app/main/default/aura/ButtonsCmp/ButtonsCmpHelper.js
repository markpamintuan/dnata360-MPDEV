({
	showToast : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type" : "error"
        });
        toastEvent.fire();
    }
})