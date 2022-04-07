({
	fetchData: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllCase");
        console.log(getCaseId);
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": getCaseId
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.data',data);
                if(data == null || data == ''){
                    cmp.set('v.data',[]);
                    }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });        
        $A.enqueueAction(action);
    },
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
         $A.get('e.force:refreshView').fire();
		
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    searchHelper : function(component,event,getInputkeyWord,sellkptype) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues2");
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
    getRowActions: function(component, row, cb) {
        var actions = [];
        actions.push({
            label: "Delete", 
            name: "del",
            // allow three increments per row
            disabled: row.Id != null });
        cb(actions);
    },
    insertInternalAndIssuefinal:function(component,event,helper,bookingid){
        console.log('reached here');
        var internal = component.get('v.dataToPush');
        var action = component.get('c.saveAll');
        action.setParams({
            "InternalList":JSON.stringify(internal),
            "bookingid":bookingid,         
        });
        action.setCallback(this, function(response) {
            var state = response.getState();      
            if (state === "SUCCESS") {
                component.set("v.isOpen", 'false'); 
                component.set('v.isLoading','false');
                var workspaceAPI = component.find("workspace");
                console.log('workspace' + workspaceAPI);
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.refreshTab({
                              tabId: focusedTabId,
                              includeAllSubtabs: true
                     });
                })
                .catch(function(error) {
                    console.log('error' + error);
                });
                var type = component.find("category").set("v.value",'');
                var status = component.find("status").set("v.value",'');
                var subject = component.find("subject").set("v.value",'');
                var description = component.find("description").set("v.value",'');
                helper.clear(component,event,helper);
                helper.refreshFocusedTab(component,event,helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     type: 'success',
                    message: 'Success!'
                });
                toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
            }else{
                component.set('v.isLoading','false');
                console.info('response', response.getError() );
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                     message: response.getError()[0]
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);                   
    },
    clear :function(component,event,helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
})