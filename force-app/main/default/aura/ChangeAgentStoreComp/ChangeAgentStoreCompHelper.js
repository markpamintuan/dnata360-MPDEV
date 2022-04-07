({
	getUserList : function(component,event) {
		 var action = component.get("c.getUserRoleList");       
        action.setCallback(this, function(response) {
          $A.util.addClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
               var storeResponse = response.getReturnValue();
               component.set('v.roleList',storeResponse); 
            }
        });
      // enqueue the Action  
        $A.enqueueAction(action);
	},
     // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // remove slds-hide class from mainSpinner
        var spinner = component.find("mainSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // add slds-hide class from mainSpinner    
        var spinner = component.find("mainSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
     searchHelper : function(component,event,getInputkeyWord) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'keyword': getInputkeyWord,
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen. 
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found....');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
	},
    showSuccessToast : function(component, event, helper,message,type) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Alert Message',
            message: message,
            duration: '5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
        helper.refreshPage(component, event, helper);
    },
    
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", null ); 
        
        
    },
    
    refreshPage : function(component, event, helper){
        setTimeout(function(){ 
           component.set("v.selectedRole", null );
            helper.clear(component, event, helper);
         }, 1000);
    },
    
    getUserRoleBySelectedUser : function(component,event, selectedAccountGetFromEvent) {
         var userId = component.get("v.selectedRecord");
		 var action = component.get("c.getUserRoleBySelectedUser");  
         action.setParams({
            'userId': selectedAccountGetFromEvent.rid
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var storeResponse = response.getReturnValue();
               component.set('v.roleList',storeResponse); 
            }
        });
        $A.enqueueAction(action);
	}
   
})