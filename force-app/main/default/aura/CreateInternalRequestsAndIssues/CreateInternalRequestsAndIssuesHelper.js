({
	fetchData: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllCase");
        console.log(getCaseId);
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": getCaseId,
            "complaintId": cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.data',data);
                if(data == null || data == ''){
                    cmp.set('v.data',[]);
                    cmp.set('v.dataToPush',[]);
                                    }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        
        $A.enqueueAction(action);
    },
    fetchIssues: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllIssues");
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
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
                }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        
        $A.enqueueAction(action);
    },
    
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
    insertInternalAndIssue:function(component,event,helper,bookingid){
        console.log('reached here');
        var internal = component.get('v.dataToPush');
        var issues = component.get('v.issueList');
        var action = component.get('c.saveAll');
        console.log(JSON.stringify(internal));
        action.setParams({
            "InternalList":JSON.stringify(internal),
            "IssueList":JSON.stringify(issues),
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,
            "noBookingHeader" : component.get('v.noBookingHeader'),
            "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading','false');
            var state = response.getState();
            console.log('called action');
            console.log(response.getReturnValue());
            component.set('v.isLoading','false');
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     type: 'success',
                    message: 'Success!'
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
    insertInternal:function(component,event,helper,bookingid){
        console.log('[+]Entered insertInternalHelper');
        var internal = component.get('v.dataToPush');
        console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
        var action = component.get('c.saveAll');
        action.setParams({
            "InternalList":JSON.stringify(internal), 
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,
            "noBookingHeader" : component.get('v.noBookingHeader'),
            "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading','false');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showIssues',true);
                console.log('[+]insertInternal => callback response => ' + response.getReturnValue());
                var tempList = component.get('v.tempInternalList');
                tempList.push(response.getReturnValue());
                component.set('v.tempInternalList',tempList);
                console.log('[+]TempList => '+ tempList);
                console.log('[+]v.tempInternalList => ' + component.get('v.tempInternalList') );
                component.set('v.internalRecordId',response.getReturnValue());
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
    },
    insertInternalAndNew:function(component,event,helper,bookingid){
        console.log('[+]Entered insertInternalAndNewHelper');
        var internal = component.get('v.dataToPush');
        console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
        var action = component.get('c.saveAll');
        action.setParams({
            "InternalList":JSON.stringify(internal), 
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,
            "noBookingHeader" : component.get('v.noBookingHeader'),
            "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading','false');
            var state = response.getState();
            if (state === "SUCCESS") {
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
        action.setParams({
            "InternalId":component.get('v.internalRecordId'),
            "IssueList":JSON.stringify(issueList),
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,
            "noBookingHeader" : component.get('v.noBookingHeader'),
            "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
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
    
    insertInternalAndIssuefinal:function(component,event,helper,bookingid){
        console.log('reached here');
        var internal = component.get('v.dataToPush');
        var issues = component.get('v.issueList');
        var action = component.get('c.saveAll');
        action.setParams({
            "InternalList":JSON.stringify(internal),
            "IssueList":JSON.stringify(issues),
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,
            "noBookingHeader" : component.get('v.noBookingHeader'),
            "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
        });
        action.setCallback(this, function(response) {
            var state = response.getState();      
            if (state === "SUCCESS") {
                component.set("v.isOpen", 'false'); 
                component.set('v.isLoading','false');
                component.set("v.bookings",[]);
                component.set("v.currentStep", "1");
                component.set('v.currentBooking',1);
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
                     message: 'Please contact your system administrator.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);                   
    },
    fetchBookingItems:function(component,event,helper){
        		 component.set('v.currentStep','1');
                 
                 var recId = component.get('v.recordId');//added as part of v1.1
                 console.log(recId + '$%^&*');
                 var action = component.get("c.getAllRelatedBookings");
                 
                 //action.setParams({ "accId" : accountId });//changed as part of v1.1
                 action.setParams({ 
                     "caseId" : recId,
                     "noBookingHeader" : component.get('v.noBookingHeader'),
                     "bookingHeaderId" : component.get('v.bookingHeaderId').toString()
                    
                 }); //added as part of v1.1     
                 action.setCallback(this, function(response){
                 var state = response.getState();
                 console.log(state);
                 if(state === 'SUCCESS' && component.isValid()){
                    //get booking list
                    var cleanedUp = [];
                    cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                    console.log('@@@ response returned value: ' + response.getReturnValue());
                    console.log('@@@ response returned value: ' + response.getReturnValue());
                    //console.log('reponse is ' + JSON.stringify(response.getReturnValue()));
                    component.set("v.casebookingList",response.getReturnValue());
                
            	}else{
                    component.set('v.casebookingList',null);
                    alert('ERROR...' + JSON.stringify(response.getError()[0].message));
            	}
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
    searchHelper2 : function(component,event,getInputkeyWord) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValuesForSubject");
      // set param to method  
     var cserecid = component.get("v.recordId");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'cid' : cserecid,
          });
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner2"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                //debugger;
                console.log(response.getReturnValue());
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message2", 'No Result Found....');
                } else {
                    component.set("v.Message2", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords2", storeResponse);
            }
 
        });
      // enqueue the Action  
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
	init: function (component, event, helper) {
      var delId = component.get("v.bookings");
        component.set('v.columns', [            
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},
            {label: 'Type', fieldName: 'Org_Type__c', type: 'picklist' ,editable: false},
            {label: 'Status', fieldName: 'Status', type: 'picklist' ,editable: false},
             {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
            
        ]);
        
        component.set('v.issueColumns', [
            {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
            {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
            {label: 'Issue Type', fieldName: 'Issue_Type__c', type: 'picklist' ,editable: false},
          
           
            
        ]);
        
           helper.getSavepoint(component,event,helper);
           helper.fetchData(component,event,delId); 
           helper.fetchIssues(component,event,delId); 
     
        
    },
    getRowActions: function(component, row, cb) {
        var actions = [];
        /*actions.push({
            label: "Delete", 
            name: "del",
            
            disabled: row.Id != null });*/
        actions.push({
            label: "Edit", 
            name: "edit" });
        cb(actions);
    },
    getSavepoint: function(component,event,helper){
            },
    revertSavepoint: function(component,event,helper){
        var action = component.get('c.deleteAll');
        action.setParams({
            "InternalList":component.get('v.tempInternalList'),
            "IssueList":component.get('v.tempIssueList')
        })
        action.setCallback(this, function(response) {         
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.tempInternalList',[]);
                component.set('v.tempIssueList',[]);
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