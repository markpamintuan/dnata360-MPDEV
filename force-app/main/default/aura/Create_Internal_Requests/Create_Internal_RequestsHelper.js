({
	getBookings: function (cmp,event,bookingId) {
        var action = cmp.get("c.getBookings");
        console.log(bookingId);
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": bookingId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.bookings',data);
                var myArray = cmp.get('v.bookings');
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
					console.log(cmp.get('v.bookingValue'));
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },
    createMapOfBookingType: function(bookedItems) {
        debugger;
        for (var bookingHeader in bookedItems) {
            var masterListBookingHeader = [];
            var mainMap = {}; //This will keep the overall track of the new object

            for (var val in bookedItems[bookingHeader].Bookings__r) {
                var newBookingsValuesArray = []; //This intialises the value as a list

                if (!mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c]) {
                    newBookingsValuesArray.push(bookedItems[bookingHeader].Bookings__r[val]);
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c] = newBookingsValuesArray;
                } else {
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c].push(bookedItems[bookingHeader].Bookings__r[val]);
                }
            }
            
            //BReak out into another method
            for (var valueInTempMap in mainMap) {
                var objDef = { bookingtype: '', records: [] };
                var valuesList = mainMap[valueInTempMap];               
                objDef.bookingtype = valueInTempMap;
                objDef.records = valuesList;
                masterListBookingHeader.push(objDef);
            }          
            console.log(masterListBookingHeader);
            bookedItems[bookingHeader].Bookings__r = masterListBookingHeader;
        }
        return bookedItems;
    },
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
   
     insertInternal:function(component,event,helper,bookingid){
        console.log('reached here');
        
        var internal = component.get('v.data');
        var issues = component.get('v.issueList');
        var action = component.get('c.createInternalRequest');
         var caseId = component.get('v.recordId');
         action.setParams({
            "InternalList":JSON.stringify(internal),
            "bookingid":bookingid,
             "caseId":caseId
        });
        action.setCallback(this, function(response) {
           component.set('v.isLoading','false');
            var state = response.getState();
            console.log('called action');
            console.log(response.getReturnValue());	
            if (state === "SUCCESS") {
                component.set('v.isLoading','false');
                var recID = response.getReturnValue();
               
              	/*var workspaceAPI = component.find("workspace");
                 workspaceAPI.getFocusedTabInfo().then(function(response) {
                            //alert('Testing tab'+sforce.console.getPrimaryTabIds(response.tabId));
                            var tabIdToUse = '';
                     		console.log(response.tabId );
                     		console.log(response.parentTabId);
                            if(response.isSubtab){
								tabIdToUse = response.parentTabId
                            }else{
                                tabIdToUse = response.tabId 
                            }
                            workspaceAPI.openSubtab({
                                parentTabId: tabIdToUse,
                                url:'/lightning/r/Case/'+recID+'/view',
                                focus: true
                            }).then(function(response) {
                                
                            });                    
                        })
                        .catch(function(error) {
                            console.log(error); 
                        });
                */
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     message: "Success",
                     type: 'success',
                    
                });
                toastEvent.fire();
            }else{
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
    
    insertInternalfinal:function(component,event,helper,bookingid){
        console.log('reached here');
        
        var internal = component.get('v.data');
        var issues = component.get('v.issueList');
        var action = component.get('c.createInternalRequest');
         var caseId = component.get('v.recordId');
         action.setParams({
            "InternalList":JSON.stringify(internal),
            "bookingid":bookingid,
             "caseId":caseId
        });
        action.setCallback(this, function(response) {
           component.set('v.isLoading','false');
            var state = response.getState();
            console.log('called action');
            console.log(response.getReturnValue());	
            if (state === "SUCCESS") {
                component.set('v.isLoading','false');
                var recID = response.getReturnValue();
                component.set('v.isOpen','false'); 
              	/*var workspaceAPI = component.find("workspace");
                 workspaceAPI.getFocusedTabInfo().then(function(response) {
                            //alert('Testing tab'+sforce.console.getPrimaryTabIds(response.tabId));
                            var tabIdToUse = '';
                     		console.log(response.tabId );
                     		console.log(response.parentTabId);
                            if(response.isSubtab){
								tabIdToUse = response.parentTabId
                            }else{
                                tabIdToUse = response.tabId 
                            }
                            workspaceAPI.openSubtab({
                                parentTabId: tabIdToUse,
                                url:'/lightning/r/Case/'+recID+'/view',
                                focus: true
                            }).then(function(response) {
                                
                            });                    
                        })
                        .catch(function(error) {
                            console.log(error); 
                        });
                */
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     message: "Success",
                     type: 'success',
                    
                });
                toastEvent.fire();
            }else{
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
    }
})