({
    openReport : function(component, event, helper) {        
        debugger;        
        var currentTargetReportId = ''
        var parameter0 = '';
        var workspaceAPI = component.find("workspace");
        //setTimeout(function(){
        
       	parameter0 = component.get("v.reportParameter0");
        	//var recId = component.get("v.recordId");
        	//console.log('### recId: ' + recId);
            //console.log('### parameter0: ' + parameter0);
            //console.log('### parameter0: ' + JSON.stringify(parameter0));
        
        //}, 2000);
        currentTargetReportId = event.currentTarget.dataset.value;
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                url: '/one/one.app#/sObject/'+ currentTargetReportId +'/view?fv0=' + parameter0,
                //url: '/one/one.app#/sObject/'+ currentTargetReportId +'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error); 
        });
    }
})