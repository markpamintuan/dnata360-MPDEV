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
        var myArray = cmp.get('v.bookings');
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": getCaseId,
            "complaintId": cmp.get('v.complaintId')
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.data',data);
                if(data == null || data == ''){
                    cmp.set('v.data',[]);
                    var myArray = cmp.get('v.bookings');
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
                                    }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        
        $A.enqueueAction(action);
    },
    fetchIssues: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllIssues");
        var myArray = cmp.get('v.bookings');
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
        console.log(getCaseId);
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": getCaseId
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.issueList',data);
                if(data == null || data == ''){
                    cmp.set('v.issueList',[]);
                    var myArray = cmp.get('v.bookings');
                    console.log(myArray);
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
                    console.log(cmp.get('v.bookingValue'));
                }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
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
            label: "Edit", 
            name: "edit" });
        cb(actions);
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
    contains : function(arr, key, val) {
    for (var i = 0; i < arr.length; i++) {
        if(arr[i][key] === val) return true;
    }
    return false;
},
    insertInternal:function(component,event,helper,bookingid){
        console.log('[+]Entered insertInternalHelper');
        if(component.get('v.complaintId') == ''){
            var mainAction = component.get('c.createComplaint');
            mainAction.setParams({ 
            	"bookingid":bookingid,           
        	});
            mainAction.setCallback(this, function(mainresponse) {
                var mainstate = mainresponse.getState();
                if (mainstate === "SUCCESS") {
                    component.set('v.complaintId',mainresponse.getReturnValue());
                	var internal = component.get('v.dataToPush');
                    console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
                    var action = component.get('c.saveAll');
                    action.setParams({
                        "InternalList":JSON.stringify(internal), 
                        "bookingid":bookingid,
                        "complaintId":component.get('v.complaintId')
                    });
                    action.setCallback(this, function(response) {
                        component.set('v.isLoading','false');
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.showIssues',true);
                            console.log('[+]insertInternal => callback response => ' + JSON.stringify(response.getReturnValue()));
                            component.set('v.internalRecordId',response.getReturnValue());
                            var tempList = component.get('v.tempInternalList');
                            tempList.push(response.getReturnValue());
                            component.set('v.tempInternalList',tempList);		
                            //component.set('v.complaintId',response.getReturnValue());
                            helper.fetchData(component,event,bookingid);
                        }else{
                            console.info('response', response.getError() );
           
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Error',
                                 type: 'error',
                                 message: 'Please contact your system administrator.'
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);                   
            	}else{
                    console.info('response', mainresponse.getError() );
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         title: 'Error',
                         type: 'error',
                         message: 'Please contact your system administrator.'
                    });
                	toastEvent.fire();
            }
        });
        	$A.enqueueAction(mainAction);   
        }else{
            var internal = component.get('v.dataToPush');
            console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
            var action = component.get('c.saveAll');
            action.setParams({
                        "InternalList":JSON.stringify(internal), 
                        "bookingid":bookingid,
                        "complaintId":component.get('v.complaintId')
                    });
            action.setCallback(this, function(response) {
                        component.set('v.isLoading','false');
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.showIssues',true);
                            console.log('[+]insertInternal => callback response => ' + JSON.stringify(response.getReturnValue()));
                            
                          component.set('v.internalRecordId',response.getReturnValue());
                            var tempList = component.get('v.tempInternalList');
                tempList.push(response.getReturnValue());
                component.set('v.tempInternalList',tempList);
                            //component.set('v.complaintId',response.getReturnValue());
                            helper.fetchData(component,event,bookingid);
                        }else{
                            console.info('response', response.getError() );
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Error',
                                 type: 'error',
                                 message: 'Please contact your system administrator.'
                            });
                            toastEvent.fire();
                        }
                    });
            $A.enqueueAction(action);      
        }
    },
    insertInternalAndNew:function(component,event,helper,bookingid){
        console.log('[+]Entered insertInternalHelper');
        if(component.get('v.complaintId') == ''){
            var mainAction = component.get('c.createComplaint');
            mainAction.setParams({ 
            	"bookingid":bookingid,           
        	});
            mainAction.setCallback(this, function(mainresponse) {
                var mainstate = mainresponse.getState();
                if (mainstate === "SUCCESS") {
                    component.set('v.complaintId',mainresponse.getReturnValue());
                	var internal = component.get('v.dataToPush');
                    console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
                    var action = component.get('c.saveAll');
                    action.setParams({
                        "InternalList":JSON.stringify(internal), 
                        "bookingid":bookingid,
                        "complaintId":component.get('v.complaintId')
                    });
                    action.setCallback(this, function(response) {
                        component.set('v.isLoading','false');
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.showIssues',true);
                            console.log('[+]insertInternal => callback response => ' + JSON.stringify(response.getReturnValue()));
                            component.set('v.internalRecordId',response.getReturnValue());
                             component.set('v.internalRecordId','');
                            component.find("status").set("v.value",'');
                            component.find("subject").set("v.value",'');
                            component.set("v.selectedRecord",{}); 
                            component.find("endprovidername").set("v.value",'');
                            component.set('v.showIssues','false');
                            
                            component.set('v.IssueSupplierName','');
                            component.set("v.dataToPush", []);
                            var tempList = component.get('v.tempInternalList');
                            tempList.push(response.getReturnValue());
                            component.set('v.tempInternalList',tempList);
                            helper.fetchData(component,event,bookingid);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Success',
                                 type: 'success',
                                 message: 'Internal Request has been saved successfully.'
                            });
                            toastEvent.fire();
                          
                            //component.set('v.complaintId',response.getReturnValue());
                            helper.fetchData(component,event,bookingid);
                        }else{
                            console.info('response', response.getError() );
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Error',
                                 type: 'error',
                                 message: 'Please contact your system administrator.'
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);                   
            	}else{
                    console.info('response', mainresponse.getError() );
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         title: 'Error',
                         type: 'error',
                         message: 'Please contact your system administrator.'
                    });
                	toastEvent.fire();
            }
        });
        	$A.enqueueAction(mainAction);   
        }else{
            var internal = component.get('v.dataToPush');
            console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
            var action = component.get('c.saveAll');
            action.setParams({
                        "InternalList":JSON.stringify(internal), 
                        "bookingid":bookingid,
                        "complaintId":component.get('v.complaintId')
                    });
            action.setCallback(this, function(response) {
                        component.set('v.isLoading','false');
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.showIssues',true);
                            console.log('[+]insertInternal => callback response => ' + JSON.stringify(response.getReturnValue()));
                            
                          component.set('v.internalRecordId',response.getReturnValue());
                            //component.set('v.complaintId',response.getReturnValue());
                             component.set('v.internalRecordId','');
                            component.find("status").set("v.value",'');
                            component.find("subject").set("v.value",'');
                            component.set("v.selectedRecord",{}); 
                            helper.clear(component,event,helper);
                            component.find("endprovidername").set("v.value",'');
                            component.set('v.showIssues','false');
                            
                            component.set('v.IssueSupplierName','');
                            component.set("v.dataToPush", []);
                            var tempList = component.get('v.tempInternalList');
                            tempList.push(response.getReturnValue());
                            component.set('v.tempInternalList',tempList);
                            helper.fetchData(component,event,bookingid);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Success',
                                 type: 'success',
                                 message: 'Internal Request has been saved successfully.'
                            });
                            toastEvent.fire();
                            helper.fetchData(component,event,bookingid);
                        }else{
                            console.info('response', response.getError() );
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                 title: 'Error',
                                 type: 'error',
                                 message: 'Please contact your system administrator.'
                            });
                            toastEvent.fire();
                        }
                    });
            $A.enqueueAction(action);      
        }		        
    },
    updateInternal:function(component,event,helper,bookingid){
        console.log('[+]Entered updateInternalHelper');
        var internal = [];
        var status = component.find("status").get("v.value");
        var subject = component.find("subject").get("v.value");
        var seluserorqueue = component.get("v.selectedRecord.rid"); 
        var endprovidername = component.find("endprovidername").get("v.value");
        internal.push({
            Org_Case_Status__c:status,
            Subject:subject,
            OwnerId:seluserorqueue,
            End_Provider_Name__c:endprovidername
        })
        console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
        console.log('[+]Internal Id ==> ' + component.get('v.internalRecordId'));
        var action = component.get('c.updateAll');
        action.setParams({
            "InternalList":JSON.stringify(internal), 
            "InternalId":component.get('v.internalRecordId')
                    
        });
        action.setCallback(this, function(response) {
            helper.fetchData(component,event,bookingid);
            component.set('v.isLoading','false');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.internalRecordId','');
                component.find("status").set("v.value",'');
                component.find("subject").set("v.value",'');
                component.set("v.selectedRecord",{}); 
                helper.clear(component,event,helper);
                component.find("endprovidername").set("v.value",'');
                component.set('v.showIssues','false');
                
              	component.set('v.IssueSupplierName','');
                component.set("v.dataToPush", []);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     type: 'success',
                     message: 'Internal Request has been saved successfully.'
                });
                toastEvent.fire();
            }else{
                console.info('response', response.getError() );
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                     message: 'Please contact your system administrator.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);                   
    },
    insertIssue:function(component,event,helper,issueList,bookingid){

        var action = component.get('c.saveAllIssues');
        console.log('[+]Adding Issues : '+ component.get('v.complaintId'));
        action.setParams({
            "InternalId":component.get('v.internalRecordId'),
            "IssueList":JSON.stringify(issueList),
            "bookingid":bookingid,
            "complaintId":component.get('v.complaintId')
            
        });
        action.setCallback(this, function(response) {
            
            component.set('v.isLoading',false);
            var state = response.getState();      
            if (state === "SUCCESS") {
                    var tempList = component.get('v.tempIssueList');
                    tempList.push(response.getReturnValue());
                    component.set('v.tempIssueList',tempList);
                	component.find("issue").set("v.value",'');
             		component.find("issuetype").set("v.value",'');
                	component.set('v.showIssues','false');
              		component.set('v.IssueSupplierName','');
                    var childCmp = component.find("cComp");
                    childCmp.refreshIssue();
                helper.fetchData(component,event,bookingid);
                var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     title: 'Success',
                     type: 'success',
                     message: 'Issue has been added.'
                });
                toastEvent.fire();
            }else{
                
                console.info('response', response.getError() );
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                     message: 'Please contact your system administrator.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);                   
    },
    revertSavepoint: function(component,event,helper){
        var action = component.get('c.deleteAll');
        action.setParams({
            "InternalList":component.get('v.tempInternalList'),
            "IssueList":component.get('v.tempIssueList'),
            "complaintId":component.get('v.complaintId')
        })
        action.setCallback(this, function(response) {         
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.tempInternalList',[]);
                component.set('v.tempIssueList',[]); 
                component.set('v.complaintId','');
            }else{
                console.log(response.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                     message: 'Please contact your system administrator.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
})