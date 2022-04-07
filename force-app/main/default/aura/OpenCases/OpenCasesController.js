({    
    doInit: function(component,event,helper){
        var accountId = component.get('v.recordId');
        var action = component.get('c.getOpenCases');
        action.setParams({ "accId" : accountId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                //get contact list
                console.log('v.caseList', response.getReturnValue());
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

    
  //   openTabWithSubtab : function(component, event, helper) {
  //       debugger;
  //       var recId = event.target.id;
		// //alert(recId);
  //       //alert(       sforce.console.isInConsole());
  //       if(sforce.console == undefined){
  //           var navEvt = $A.get("e.force:navigateToSObject");
  //           navEvt.setParams({
  //               "recordId": recId,
  //               "slideDevName": "related"
  //           });
  //           navEvt.fire();
  //       }
        
  //       var workspaceAPI = component.find("workspace");
  //       workspaceAPI.openTab({
  //           url: '#/sObject/0010E00000IYq59QAD/view',
  //           focus: true
  //       }).then(function(response) {
  //           workspaceAPI.openSubtab({
  //               parentTabId: response,
  //               url: '#/sObject/005R0000000INjPIAW/view',
  //               focus: true
  //           });
  //       })
  //       .catch(function(error) {
  //           console.log(error);
  //       });
  //   },
    
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
    },
    
    //View all cases       
    gotoRelatedList : function (component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Cases",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
	},
    
    testCloseTab : function() {
        //First find the ID of the current primary tab to close it
        sforce.console.getEnclosingPrimaryTabId(closeSubtab);
    },
    
    closeSubtab : function(result) {
        //Now that we have the primary tab ID, we can close it
        var tabId = result.id;
        sforce.console.closeTab(tabId);
    }
})