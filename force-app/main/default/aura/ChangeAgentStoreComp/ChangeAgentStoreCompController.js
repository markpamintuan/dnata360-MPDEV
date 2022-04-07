({
	doInit : function(component, event, helper) {
		//helper.getUserList(component, event);
	},
    
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var sellkptype = component.get("v.selLookupType");
            helper.searchHelper(component,event,getInputkeyWord,sellkptype);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
		heplper.clear(component,event,heplper);
    },
     onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show'); 
        helper.getUserRoleBySelectedUser(component, event,selectedAccountGetFromEvent);
                
    },
    
    saveUser : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        var userId = component.get("v.selectedRecord");
        var userRoleId = component.get("v.selectedRole");
        if(userId && userRoleId){
        var action = component.get("c.updateUserRole");
        action.setParams({
            'userId': userId.rid,
            'roleId':userRoleId
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen. 
                if (storeResponse.length == 0) {
                     var noResult = 'No Result Found....';
                     helper.showSuccessToast(component, event, helper,noResult,'error');
                } else {
                     helper.showSuccessToast(component, event, helper,storeResponse,'success');
                }
            } else {
                var storeResponse = response.getReturnValue();
                helper.showSuccessToast(component, event, helper,storeResponse,'error');
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
        } else {
             helper.hideSpinner(component, event, helper);
             var noData = 'Please fill all the fields.';
             helper.showSuccessToast(component, event, helper,noData,'error');
        }
    }
})