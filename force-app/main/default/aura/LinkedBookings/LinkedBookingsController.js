({
	doInit: function(component,event,helper){
        debugger;
        //var accountId = component.get('v.recordId'); //changed as part of v1.1
        var recId = component.get('v.recordId');//added as part of v1.1
        console.log(recId);
        var action = component.get('c.getAllBookingsRelatedToCase');
        //action.setParams({ "accId" : accountId });//changed as part of v1.1
        action.setParams({ 
            "caseID" : recId 
        }); //added as part of v1.1     
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS' && component.isValid()){
                //get booking list
               	var cleanedUp = [];
                cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                console.log('### response returned value: ' + response.getReturnValue());
                console.log('### response returned value: ' + response.getReturnValue());
                //alert('reponse is ' + JSON.stringify(bookinglist));
                component.set("v.casebookingList",response.getReturnValue());
            	
            }else{
                component.set('v.casebookingList',null);
                //alert('ERROR...');
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
    },
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
        acc.forEach(function(element) {
            $A.util.toggleClass(element, "slds-hide");
        });
        $A.util.addClass(event.target, "slds-show");
    },
    
     recordUpdated : function(component, event, helper) {  //added as part of v1.1
        //helper.recordUpdated(component, event, helper);
    }

})