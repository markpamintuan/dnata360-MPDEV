({
    init: function (component, event, helper) {
        var actions = helper.getRowActions.bind(this, component);
        var delId = component.get("v.bookings");
        
        console.log('[+]Calling fetch Data from init using id ' + delId);
        helper.fetchData(component,event,delId); 
        helper.fetchIssues(component,event,delId);        
    },
	fetchData: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllCase");
        console.log('[+]Case Id Passed to fetchData : ' + getCaseId);        
        action.setParams({
            "lstRecordId": getCaseId,
            "complaintId": cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {           
            var state = response.getState();
            var newData = [];
            cmp.set('v.isLoading',false);
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                console.log('data '+ data);
                if(data != null){
                    //var newData = '{"CaseNumber":"'+'New'+'","Id":"'+'New'+'"}';
                    //data.push(newData);
                    newData.push({
                        CaseNumber:'New Internal Request',
                        Id:'New'
                    });
                    for (var prop in data) {  
                        	console.log('prop'); 
                       		console.log(data[prop]);
                            newData.push(data[prop]);                       
                    }
                    
                }else{
                    newData.push({
                        CaseNumber:'New Internal Request',
                        Id:'New'
                    });

                }
                console.log('[+]Data ' + JSON.stringify(newData));
                cmp.set('v.data',newData);
                
            }
            
        });       
        $A.enqueueAction(action);
    },
    fetchIssues: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllIssues");
        console.log('[+]Case Id Passed to FetchIssues : ' + getCaseId);        
        action.setParams({
            "lstRecordId": getCaseId
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.issueList',JSON.stringify(data));
                /*if(data == null || data == ''){
                    cmp.set('v.issueList',[]);
                    var myArray = cmp.get('v.bookings');
                    var index = cmp.get('v.currentBooking');
                    cmp.set('v.bookingValue', myArray[index-1]);
                }*/
            }            
        });        
        $A.enqueueAction(action);
    },
    getRowActions: function(component, row, cb) {
        var actions = [];       
        actions.push({ label: "Edit", name: "edit" });
        cb(actions);
    },
    createMapOfBookingType: function(bookedItems) {
        
        for (var bookingHeader in bookedItems) {
            var masterListBookingHeader = [];
            var mainMap = {};
            for (var val in bookedItems[bookingHeader].Bookings__r) {
                var newBookingsValuesArray = []; 
                if (!mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c]) {
                    newBookingsValuesArray.push(bookedItems[bookingHeader].Bookings__r[val]);
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c] = newBookingsValuesArray;
                } else {
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c].push(bookedItems[bookingHeader].Bookings__r[val]);
                }
            }           
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
    fetchCurrentData: function (cmp,event,getCaseId) {
        var action = cmp.get("c.getAllCurrentCase");
        console.log('[+]Case Id Passed to fetchData : ' + getCaseId);        
        action.setParams({
            "lstRecordId": getCaseId,
        });
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('[+]Data ' + data);
                cmp.set('v.dataCurrent',data);
                cmp.set('v.Subject',data.Subject);
                cmp.set('v.Responsible',data.End_Provider_Name__c);
                cmp.set('v.Status',data.Org_Case_Status__c);
                cmp.set('v.Owner',data.Owner_Name__c);
                cmp.set('v.YalagoProvider',data.Yalago_Provider__c);
                cmp.set('v.Description',data.Description);
                var selectedRecord = '{"rid":"'+data.OwnerId+'","rname":"'+data.Owner_Name__c+'"}';
                var selectedObj = JSON.parse(selectedRecord);
                
                console.log(JSON.stringify(selectedObj));
                cmp.set("v.selectedRecord",selectedObj);
                var forclose = cmp.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = cmp.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = cmp.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');
               
                if(data == null || data == ''){
                    cmp.set('v.dataCurrent',[]);
                    
                }
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
      
    insertIssue:function(component,event,helper,bookingid){

        console.log('debug');
        console.log(component.get('v.currentInternalRequest'));
        console.log(component.get('v.recordId'));
        console.log(bookingid);
        var action = component.get('c.saveAllIssues');
        var issueList = [];
        issueList.push({
            Issue__c:component.get('v.Issue__c'),
            Issue_Type__c:component.get('v.Issue_Type__c'),
            Description__c:component.get('v.IssueDescription'),
            End_Provider_Name__c:component.get('v.IssueSupplierName')
           
        })
        action.setParams({
            "InternalId":component.get('v.currentInternalRequest'),
            "IssueList":JSON.stringify(issueList),
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid,            
            "description":component.get('v.IssueDescription')
        });
        action.setCallback(this, function(response) {
            
            component.set('v.isLoading',false);
            var state = response.getState();      
            if (state === "SUCCESS") {
                    var tempList = component.get('v.tempIssueList');
                    tempList.push(response.getReturnValue());
                    component.set('v.tempIssueList',tempList);
                	component.set('v.Issue__c','');
                    component.set('v.Issue_Type__c','');
                    component.set('v.IssueDescription','');
             		component.set('v.IssueSupplierName','');
                	
                    var childCmp = component.find("cComp2");
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
                var jsonresponse = JSON.parse(response.getError()[0].message);
                console.info('response', response.getError() );
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                    message: 'Error :' +jsonresponse
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);                   
    },
    InsertOrUpsertInternal:function(component,event,helper,bookingid){
        console.log('[+]Entered insertInternalHelper');
        var internal = component.get('v.dataToPush');
        console.log('[+]Internal Request ==> ' +  JSON.stringify(internal));
        var action = component.get('c.saveAll');
        action.setParams({
            "InternalRequest":component.get('v.currentInternalRequest'),
            "Subject":component.get('v.Subject'),
            "Status":component.get('v.Status'),
            "Responsible":component.get('v.Responsible'),
            "Yalago_Provider":component.get('v.YalagoProvider'),
            
            "Description":component.get('v.Description'),
            "OwnerId":component.get('v.selectedRecord.rid'),
            "CaseId":component.get('v.recordId'),
            "bookingid":bookingid
                                
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading','false');
            var state = response.getState();
            if (state === "SUCCESS") {                
                console.log('[+]insertInternal => callback response => ' + response.getReturnValue());
                var tempList = component.get('v.tempInternalList');
                tempList.push(response.getReturnValue());
                component.set('v.tempInternalList',tempList);
                console.log('[+]TempList => '+ tempList);
                console.log('[+]v.tempInternalList => ' + component.get('v.tempInternalList') );
                component.set('v.currentInternalRequest',response.getReturnValue());
                component.set("v.currentStep", "4");
                component.set('v.isLoading',false);
            }else{
                var jsonresponse = JSON.parse(response.getError()[0].message);
                console.info('response', response.getError()[0].message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Error',
                     type: 'error',
                    message: 'Error : '+ jsonresponse["message"]
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