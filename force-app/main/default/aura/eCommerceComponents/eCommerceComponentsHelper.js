({

    
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
    
    fetchPickListVal: function(component, fieldName, elementId) { 
        var action = component.get("c.getselectOptions");
        action.setParams({
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            //debugger;
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
 
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    

    displayBookingButton : function(component, event, helper){
        var action = component.get("c.displayNewBookingButton"); 
                
        action.setCallback(this, function(response) {
            //debugger;
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
   				component.set("v.showBookingOtherSystemsButton", res);              
                console.log('### res: ' + res);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    chngCaseOwner : function(component, event, helper){
        var action = component.get("c.changeCaseOwner");
        var cseid = component.get("v.recordId");
        
        action.setParams({
            "cid": cseid
        });
        
        action.setCallback(this, function(response) {
            debugger;
            
            if (response.getState() == "SUCCESS") {
                
                helper.checkCaseOwnerForAccept(component, event, helper);
                //helper.checkIsTeamLead(component, event, helper);
                
            }
        });
        $A.enqueueAction(action);
    },
    checkCaseOwnerForAccept : function(component, event, helper){
        var action = component.get("c.caseOwnerNotMatching");
        var cseid = component.get("v.recordId");
        
        action.setParams({
            "cid": cseid
            
        });
        
        action.setCallback(this, function(response) {
            debugger;
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
   				component.set("v.showAcceptCaseButton", res);
                
                
            }
        });
        
        $A.enqueueAction(action);
    },
    searchHelper : function(component,event,getInputkeyWord,sellkptype) {

	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
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
    
	},
    chngCaseOwner_RT : function(component, event, helper){ 

        var action = component.get("c.reassignOwner");
        var cseid = component.get("v.recordId");
        var seluserorqueue = component.get("v.selectedRecord.rid");
        var selrt = component.get("v.selRecordType");
        var sendEmail = component.get("v.sendEmailNotification");
        action.setParams({
            "cid": cseid,
            "seluserorqueue" : seluserorqueue,
            "selrt" : selrt,
            "sendEmail" : sendEmail
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                helper.checkCaseOwnerForAccept(component, event, helper);
                //helper.checkIsTeamLead(component, event, helper);
                
            }else{
               console.log( '##Error: ' + JSON.stringify(response.getError())); 
                var responseError =response.getError();
                 console.log( '##Error message: ' + JSON.stringify(responseError[0])); 
                if(responseError){
                    if (responseError[0] && responseError[0].pageErrors[0].message) {
                        var message = responseError[0].pageErrors[0].message;
						helper.showToast(component, event, helper,message);
                    }
                }
               
            }
        });
        $A.enqueueAction(action); 
    }
    

    
    
})