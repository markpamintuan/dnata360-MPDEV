({
	recordUpdated : function(component, event, helper){
        var changeType = event.getParams().changeType;
		if (changeType === "CHANGED") {
            component.find("caseRec").reloadRecord();
        }
        
    },
    showToast : function(component, event, helper, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : "Error",
            message: message,
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    saveCase : function(component, event, helper) {
        //var caseRec = component.get("v.caseRec");
        //caseRec.Status = "Closed";
		component.find("caseRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
            } else if (saveResult.state === "INCOMPLETE") {
                component.set("v.recordSaveError","User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") { 
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                component.set("v.recordSaveError", errMsg);
                
            } else {
                component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
			      JSON.stringify(saveResult.error));
            }
        }));
	},
    showSpinner: function (component, event, helper) {
            component.set("v.IsSpinner",true);
    },
     
    hideSpinner: function (component, event, helper) {
       		component.set("v.IsSpinner",false);
    },
     searchHelper : function(component,event,getInputkeyWord,sellkptype) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValuesTR");
      // set param to method  
     var cserecid = component.get("v.recordId");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'cid' : cserecid,
            'searchType' : sellkptype
            //'ObjectName' : component.get("v.objectAPIName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                //debugger;
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
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
    
	}

})