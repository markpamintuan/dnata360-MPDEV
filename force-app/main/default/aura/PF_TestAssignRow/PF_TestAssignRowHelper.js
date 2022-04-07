({
	
	removeAssgn : function(component, index) {
        var leads = component.get("v.leads");
        leads.splice(index, 1);
        component.set("v.leads", leads);
    
	}
})