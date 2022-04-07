({    
    doInit: function(component,event,helper){
        debugger;
        var accountId = component.get('v.recordId');
        var action = component.get('c.getActiveBookingsWithLineItems');
        action.setParams({ "accId" : accountId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                //get contact list
                console.log('### Success...');
                console.log(response); 
                var cleanedUp = [];
                cleanedUp = helper.createMapOfBookingType(response.getReturnValue());
                console.log('### cleanedUp...' + JSON.stringify(cleanedUp));
                

                component.set('v.bookingList', cleanedUp);
                //var mapRecords = helper.createMapOfBookingType();
                console.log('### Objects...' + JSON.stringify(response.getReturnValue()));
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
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                url: '#/sObject/a090E000001oeKoQAI/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})