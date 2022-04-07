/**************************************************************************************************
* Name               : ActiveBookingsLightningComponentController.js 
* Description        : This is a controller used for ActiveBookingLightningComponents        
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Anil Valluri                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Anil             08-Aug-2018    Initial version                                                  
* v1.1        Kaavya           01-Nov-2018    T-00254 - Active Bookings component change                                                                             
**************************************************************************************************/
({    
    doInit: function(component,event,helper){
        debugger;
        //var accountId = component.get('v.recordId'); //changed as part of v1.1
        var recId = component.get('v.recordId');//added as part of v1.1
        var action = component.get('c.getActiveBookings');
        //action.setParams({ "accId" : accountId });//changed as part of v1.1
        action.setParams({ "recId" : recId , "recno" : "All"}); //added as part of v1.1     
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                //get contact list
                console.log('reponse is ' + response.getReturnValue());
                component.set('v.caseList', response.getReturnValue());
            }else{
                component.set('v.caseList',null);
                //alert('ERROR...');
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
    
     recordUpdated : function(component, event, helper) {  //added as part of v1.1
        //helper.recordUpdated(component, event, helper);
    },
    
    //View all Bookings //added as part of v1.1       
    gotoAllBooking : function (component, event, helper) { 
        debugger;
        /*
        var recId = component.get('v.recordId');        
        
        var action = component.get('c.getActiveBookings');
        var cmp1= component.find('ActiveBookingsCmp');
        action.setParams({ "recId" : recId ,"recno" : "All"});        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                //get contact list
                console.log('reponse is ' + response.getReturnValue());
                component.set('v.caseList', response.getReturnValue());                
            }else{
                component.set('v.caseList',null);
                //alert('ERROR...');
            }
        });
        $A.enqueueAction(action); */
        //cmp1.focus();
        component.set('v.end', null); 
        
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