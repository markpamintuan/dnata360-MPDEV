({
	doInit: function(component,event,helper){
        debugger;
        var accountId = component.get('v.recordId');
        var action = component.get('c.getHistoricalBookingsWithLineItems');
        
        action.setParams({ "accId" : accountId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var cleanedUp = [];
                cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                console.log('### response returned value: ' + response.getReturnValue());
                console.log('### response returned value: ' + response.getReturnValue());
                component.set('v.bookingList', cleanedUp);                
            }
        });
        $A.enqueueAction(action);
    },

    //get id of parent tab first
    openTabWithSubtab : function(component, event, helper) {        
        debugger;
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