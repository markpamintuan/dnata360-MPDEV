({
	Close : function(component, event, helper) {
        debugger;
        var action = component.get("v.buttonAction");
		component.set("v.buttonAction", 'closeAction');
	},
    
    LikeAndClose : function(component, event, helper) {
		component.set("v.buttonAction", 'likeAndCloseAction');
	},
})