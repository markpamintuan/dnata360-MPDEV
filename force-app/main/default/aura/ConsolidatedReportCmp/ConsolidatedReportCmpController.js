({
    
	getReports : function(component, event, helper) {
        
        // below helper method will call the apex class to get displayed report
        component.get("v.Spinner",true);
		helper.getReports(component, event, helper);
        
        // adding value to query field
        component.set("v.queryFields",component.get("v.linkingfield")); 
	},
    
    handleAction : function(component, event, helper) {   
        debugger;
        var linkedFieldValue = component.get("v.linkedFieldValue");
        var selRec = component.get("v.selectedRecord");
        alert('Report Clicked <b>'+ selRec.Name + '</b> Linking Field value <b>'+linkedFieldValue+'</b>');
    }
})