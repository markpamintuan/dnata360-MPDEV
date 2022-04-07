({
	doInit : function(component, event, helper) {
		debugger;
		console.log('### calling doINit for BookedItems Controller. Re group records here using helper');
		console.log('### Records: ' + JSON.stringify(component.get('v.bookedItems')));

	},

	 //get id of parent tab first
    openTabWithSubtab : function(component, event, helper) {    	
    	var currentTargetId = event.currentTarget.dataset.value;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                url: '#/sObject/'+currentTargetId+'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error); 
        });
    }
})