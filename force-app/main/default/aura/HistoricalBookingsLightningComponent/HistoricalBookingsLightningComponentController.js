({    
    doInit: function(component,event,helper){
        var accountId = component.get('v.recordId');
        var action = component.get('c.getHistoricalBookings');
        action.setParams({ "accId" : accountId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                //get contact list
                console.log(response);
                component.set('v.caseList', response.getReturnValue());
            }else{
                alert('ERROR...');
            }
        });
        $A.enqueueAction(action);
    },
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
        acc.forEach(function(element) {
            $A.util.toggleClass(element, "slds-hide");
        });
        $A.util.addClass(event.target, "slds-show");
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