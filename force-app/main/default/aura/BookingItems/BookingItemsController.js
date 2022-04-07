({
    doInit : function(component, event, helper) {
        debugger;
        var accountId = component.get('v.recordId');
        console.log(accountId);
        var action = component.get('c.getActiveBookingsWithLineItems');
        console.log("action");
        action.setParams({ "recId" : accountId });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("test");
            if(state === 'SUCCESS' && component.isValid()){
                var cleanedUp = [];
                
                cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                console.log(cleanedUp);
                console.log('### response returned value: ' + response.getReturnValue());
                console.log('### response returned value: ' + response.getReturnValue());
                component.set('v.bookingList', cleanedUp);                
            }
        });
        $A.enqueueAction(action);
        console.log('### calling doINit for BookedItems Controller. Re group records here using helper');
        
        
    },
    
    //get id of parent tab first
    openTabWithSubtab : function(component, event, helper) {    
        debugger;
        var currentTargetId = event.currentTarget.dataset.value;
        var workspaceAPI = component.find("workspace");
        var tabID = '';
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('### response: ' + JSON.stringify(response));
            if(response.parentTabId == null){
                console.log('### Entering parent');
                tabID = response.tabId; 
            }else{
                console.log('### Entering child');
                tabID = response.parentTabId;
            }
            console.log('### tabID: ' + tabID);
            console.log('### tabID: ' + tabID);
            workspaceAPI.openSubtab({
                
                parentTabId: tabID,
                url: '#/sObject/'+currentTargetId+'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error); 
        });
    }
})