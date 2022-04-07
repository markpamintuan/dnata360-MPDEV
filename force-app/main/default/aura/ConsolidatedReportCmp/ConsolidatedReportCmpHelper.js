({
    /***
     * Calling apex class method to get the reports to related to folder name
     ***/
	getReports : function(component, event, helper) {
		
        debugger;
        // getting server actions
        var action = component.get('c.getConsolidatedReport');
        
        // setting parameter
        action.setParams({
            folderName : component.get("v.ConsolidatedReportFolder")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state == "SUCCESS"){
                console.log('success');
                console.log(response.getReturnValue());
                component.set("v.ReportList",response.getReturnValue());
            }
            else{
                alert('Error');
            }
            component.get("v.Spinner",false);
        });
        
        $A.enqueueAction(action);
	}
})