({
	      openModal: function(component, event, helper) {
              var actions = helper.getRowActions.bind(this, component);
              helper.init(component,event,helper);
             var caseRecord = component.get('v.caseRecord');
             console.log('caseRecord:' +  caseRecord["Org_Booking__c"]);
             component.set("v.isOpen", true);
             if(caseRecord["Org_Booking__c"] == null){
                 component.set('v.currentStep','0');
                 component.set('v.noBookingHeader','true'); 
                 var recId = component.get('v.recordId');          
                 var action = component.get("c.getAllRelatedBookingHeaders");
                 action.setParams({ 
                     "caseId" : recId
                 });
                 action.setCallback(this, function(response){
                     var state = response.getState();
                     console.log(state);
                     if(state === 'SUCCESS' && component.isValid()){                        
                        var cleanedUp = [];
                         if(response.getReturnValue() == null || response.getReturnValue() == ''){
                         var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                             title: 'Error',
                             type: 'error',
                             message: 'No Bookings could be retrieved for that account.',
                            mode:'sticky'
                            
                        });
                        toastEvent.fire();
                    }
                        cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                        console.log('@@@ response returned value: ' + response.getReturnValue());
                        console.log('@@@ response returned value: ' + response.getReturnValue());
                        //console.log('reponse is ' + JSON.stringify(response.getReturnValue()));
                        component.set("v.casebookingHeaderList",response.getReturnValue());
                
            		}else{
                        component.set('v.casebookingHeaderList',null);
                        alert('ERROR...');
            	}
       	     });
       		 $A.enqueueAction(action);
             }else{
                 component.set('v.currentStep','1');
                 component.set('v.noBookingHeader','false');    
                 var recId = component.get('v.recordId');//added as part of v1.1
                 console.log(recId + '$%^&*');
                 var action = component.get("c.getAllRelatedBookings");
                 console.log(action + ' %&^*@!(');
                 //action.setParams({ "accId" : accountId });//changed as part of v1.1
                 action.setParams({ 
                     "caseId" : recId 
                 }); //added as part of v1.1     
                 action.setCallback(this, function(response){
                 var state = response.getState();
                 console.log(state);
                 if(state === 'SUCCESS' && component.isValid()){
                    //get booking list
                    var cleanedUp = [];
                    if(response.getReturnValue() == null || response.getReturnValue() == ''){
                         var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                             title: 'Error',
                             type: 'error',
                             message: 'No Bookings could be retrieved for that account.'
                        });
                        toastEvent.fire();
                    }
                    cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                    console.log('@@@ response returned value: ' + response.getReturnValue());
                    console.log('@@@ response returned value: ' + response.getReturnValue());
                    //console.log('reponse is ' + JSON.stringify(response.getReturnValue()));
                    component.set("v.casebookingList",response.getReturnValue());
                
            	}else{
                    component.set('v.casebookingList',null);
                    alert('ERROR...');
            	}
       	     });
       		 $A.enqueueAction(action);
            }
   },
    
    init: function (component, event, helper) {
        var actions = helper.getRowActions.bind(this, component);
      var delId = component.get("v.bookings");
        component.set('v.columns', [            
          	
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false}, 
            {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},    
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
            { type: "action", typeAttributes: { rowActions: actions }}
            
        ]);
        
        component.set('v.issueColumns', [
            {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
             {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
                        {label: 'Issue Type', fieldName: 'Issue_Type__c', type: 'picklist' ,editable: false},
                         {label: 'Description', fieldName: 'Description__c', type: 'text' ,editable: false},
                        {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},
                         { type: "action", typeAttributes: { rowActions: actions}},
                                    
            
        ]);
           console.log('fetchData ' + delId);
           helper.fetchData(component,event,delId); 
           helper.fetchIssues(component,event,delId); 
        console.log(delId);
        
     
        
    },
    onCheck : function(component,event,helper){
        var actions = helper.getRowActions.bind(this, component);
       var selectedRec = event.getSource().get("v.value");
       console.log(selectedRec);
       var getSelectedNumber = component.get("v.steps");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.steps", getSelectedNumber);
        console.log(getSelectedNumber);
        // get all checkboxes 
        var getAllId = component.find("checkbox");
        console.log(getAllId);
        // If the local ID is unique[in single record case], find() returns the component. not array
        var delId = [];
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                delId.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    delId.push(getAllId[i].get("v.text"));
                }
            }
        } 
        console.log(delId);
        component.set("v.selectedBookings",delId);
        console.log(component.get("v.bookings"));
        component.set('v.columns', [
             
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false}, 
            {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},    
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
            
            { type: "action", typeAttributes: { rowActions: actions }}
            
        ]);

		component.set('v.issueColumns', [
            {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
             {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
                        {label: 'Issue Type', fieldName: 'Issue_Type__c', type: 'picklist' ,editable: false},
                         {label: 'Description', fieldName: 'Description__c', type: 'text' ,editable: false},
                        {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},
                         { type: "action", typeAttributes: { rowActions: actions}},
                         
           
                      
        ]);

        
        helper.getBookings(component,event,delId);
   

    },
    onCheckHeader : function(component,event,helper){
      
       var selectedRec = event.getSource().get("v.text");
       
       console.log('selected Record ' +selectedRec);
       /*var getSelectedNumber = component.get("v.steps");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.steps", getSelectedNumber);
        console.log("selected Number "  + getSelectedNumber);
        
        var getAllId = component.find("radiobox");
        console.log('id ' + getAllId);
        // If the local ID is unique[in single record case], find() returns the component. not array
        var delId = [];
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                delId.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    delId.push(getAllId[i].get("v.text"));
                }
            }
        } 
        */
        component.set('v.bookingHeaderId',selectedRec);
        
   		

    },
    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        var action = cmp.get("c.updateCase");
        action.setParams({"updatedCaseList" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            $A.get('e.force:refreshView').fire();
            setTimeout(function(){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Message',
                        message: 'This Case is updated',               
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }, 1000);
            
        });
        $A.enqueueAction(action);
        
    },
    setIndex: function(component, event, helper) {
        var items = component.get("v.bookings");
        items.forEach(
            function(v, i) {
                v.selected = event.target.dataset.index == i;
                var bookingId = v.Id;
                if(v.selected == true){
                   helper.fetchData(component,event,bookingId);  
                    helper.fetchIssues(component,event,bookingId); 
                }
                console.log(v.selected);
                console.log(i);
                console.log(v);
            }
            
        );
        component.set("v.bookings", items);
    },
    addInternalRequest : function(component , event, helper){
      	 var actions = helper.getRowActions.bind(this, component);
         component.set('v.columns', [ 
           
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false}, 
            {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},    
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
            
            { type: "action", typeAttributes: { rowActions: actions }}
            
             
        ]);
        var myData = component.get("v.data"); 
        var myDataToPush = component.get('v.dataToPush');
        var status = component.find("status").get("v.value");
        var subject = component.find("subject").get("v.value");
        var seluserorqueue = component.get("v.selectedRecord.rid"); 
        var endprovidername = component.find("endprovidername").get("v.value");
        myData.push(
            {
                Subject:subject,                
                Org_Case_Status__c:status,
                OwnerId:seluserorqueue,
                End_Provider_Name__c:endprovidername
            });
        myDataToPush.push(
            {
                Subject:subject,                
                Org_Case_Status__c:status,
                OwnerId:seluserorqueue,
                End_Provider_Name__c:endprovidername
            });
             
        component.set("v.data", myData);
             component.set("v.dataToPush", myDataToPush);
        
        console.log(myDataToPush);
        //component.set("v.classname","tabelTR");
           
        $A.get('e.force:refreshView').fire();
        },
    saveAndNew: function(component,event,helper){
         component.set('v.isLoading',true);
         if(component.get('v.internalRecordId') == ''){
                 var actions = helper.getRowActions.bind(this, component);
                 component.set('v.columns', [            
                    
                    {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false}, 
                    {label: 'End Provider Name', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},    
                    {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
                     {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
                    
                    { type: "action", typeAttributes: { rowActions: actions }}
                    
                     
                ]);
                var myData = component.get("v.data"); 
                var myDataToPush = component.get('v.dataToPush');
                var status = component.find("status").get("v.value");
                var subject = component.find("subject").get("v.value");
                var seluserorqueue = component.get("v.selectedRecord.rid"); 
                var endprovidername = component.find("endprovidername").get("v.value");
                myData.push(
                    {
                        Subject:subject,                
                        Org_Case_Status__c:status,
                        OwnerId:seluserorqueue,
                        End_Provider_Name__c:endprovidername
                    });
                myDataToPush.push(
                    {
                        Subject:subject,                
                        Org_Case_Status__c:status,
                        OwnerId:seluserorqueue,
                        End_Provider_Name__c:endprovidername
                    });
                     
                component.set("v.data", myData);
                component.set("v.dataToPush", myDataToPush);
             	var bookingid = component.get('v.bookingValue');                
                helper.insertInternalAndNew(component,event,helper,bookingid['Id']);    
         }else{
             var bookingid = component.get('v.bookingValue')
              helper.updateInternal(component,event,helper,bookingid['Id']);
         }
    },
    addIssue: function(component, event, helper){
          component.set('v.isLoading',true);
      	  var myData = [];
          var issue = component.find("issue").get("v.value");
          var issuetype = component.find("issuetype").get("v.value");
          var endprovidername = component.get('v.IssueSupplierName');
                      
          myData.push(
             {
             	Issue__c:issue,
             	Issue_Type__c:issuetype,
                End_Provider_Name__c : endprovidername
            });
          var bookingid = component.get('v.bookingValue');
          helper.insertIssue(component,event,helper,myData,bookingid['Id']);
         
          
        
    },    
    addIssues : function(component , event, helper){
        component.set('v.isLoading',true);
         setTimeout(function(){
       var actions = helper.getRowActions.bind(this, component);
         component.set('v.issueColumns', [
             {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
             {label: 'Issue', fieldName: 'Issue__c', type: 'picklist' , editable: false},
                        {label: 'Issue Type', fieldName: 'Issue_Type__c', type: 'picklist' ,editable: false},
                         {label: 'Description', fieldName: 'Description__c', type: 'text' ,editable: false},
                        {label: 'End Provider Name', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},
                         { type: "action", typeAttributes: { rowActions: actions}},
                         
        ]);
        var myData = component.get("v.issueList"); 
        
        var issue = component.find("issue").get("v.value");
        var issuetype = component.find("issuetype").get("v.value");
              var endprovidername = component.find("endprovidername").get("v.value");
                         var description = component.find("description").get("v.value");
        myData.push(
            {
             Issue__c:issue,
             Issue_Type__c:issuetype,
             Description__c : description,
                         End_Provider_Name__c : endprovidername
            });
        component.set("v.issueList", myData);  
        //component.set("v.issueClassname","tabelTR");
           component.find("issue").set("v.value",'');
        	 component.find("issuetype").set("v.value",'');
             component.find("endprovidername").set("v.value",'');
             component.find("description").set("v.value",'');
        $A.get('e.force:refreshView').fire();
             component.set('v.isLoading',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         title: 'Success',
                         message: "Issue added to the bottom of the list.",
                         type: 'success',
                        
                    });
                    toastEvent.fire();
             
              },1000);      
        },
    closeModal: function(component, event, helper) {
         var tempInternals = component.get('v.tempInternalList');
         var tempIssues = component.get('v.tempIssueList');  
         console.log('closing modal');
         console.log(typeof(tempInternals) + ' ' + typeof(tempIssues));
             console.log(tempInternals + ' : ' + tempIssues);
             
             console.log(tempInternals.length);
             console.log(tempIssues.length);
         	 console.log('closing modal');
             if(tempInternals.length == 0 && tempIssues.length == 0){
             		 console.log('nothing there to remove');
      				 component.set("v.isOpen", false);
             		 component.set('v.bookings',[]);
                     component.set('v.currentBooking',1);
                     component.find("subject").set("v.value",'');
                     component.find("status").set("v.value",'');
                     component.find("endprovidername").set("v.value",'');   
             	     component.set('v.internalRecordId','');
             		component.set('v.showIssues','false');
                     helper.revertSavepoint(component,event,helper);
      				 $A.get('e.force:refreshView').fire();
        			 helper.refreshFocusedTab(component,event,helper);
         }else{
                     console.log('prompt loading');
                     var result = confirm('Cancelling will revert all changes made. Would you like to proceed ?');
                     if(result){
                         component.set("v.isOpen", false);
                         component.set('v.bookings',[]);
                         component.set('v.currentBooking',1);
                         component.find("subject").set("v.value",'');
                         component.find("status").set("v.value",'');
                         component.find("endprovidername").set("v.value",'');   
                         component.set('v.internalRecordId','');
                         component.set('v.showIssues','false');
                        
                         helper.revertSavepoint(component,event,helper);
                         $A.get('e.force:refreshView').fire();
                         helper.refreshFocusedTab(component,event,helper);
                     }else{
                         
                     }
              }
   },
    moveNext : function(component,event,helper){
     // control the next button based on 'currentStep' attribute value    
      var getCurrentStep = component.get("v.currentStep");
      var noBookingHeader = component.get('v.noBookingHeader');
      var getStep = component.get("v.steps");
       
        if(getCurrentStep == '0'){
             component.set('v.currentStep','1');
             helper.fetchBookingItems(component,event,helper);
        }
        if(getCurrentStep == "1"){
            component.set("v.currentStep", "3");
            var list = component.get('v.bookings');
            var v = list[0];
       		v.selected = true;
 			var bookingId = v.Id;               
            helper.fetchData(component,event,bookingId); 
            console.log('fetchdataagain ' + bookingId);
        	helper.fetchIssues(component,event,bookingId); 
            var action = component.get("c.getSupplierName");
                action.setParams({
                    "bookingid":bookingId
                })
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                       
                        let resp =response.getReturnValue() ;
                        let lables= [] ; 
                        resp.forEach(function(key) {                   
                            lables.push({"label":key  ,"value":key 	});
                        });
                        component.set("v.supplierlist", lables);
                        console.log('lables');
                        console.log(lables);
                //   cmp.set("v.contactList", response.getReturnValue());
                    }else{
                        alert(response.getError()[0].message); 
                    }
            
        })
        
        $A.enqueueAction(action);
            
            var action2 = component.get("c.getSupplierNameIssues");
                action2.setParams({
                    "bookingid":bookingId
                })
                action2.setCallback(this, function(response2) {
                    var state = response2.getState();
                    if (state === "SUCCESS") {
                       
                        let resp =response2.getReturnValue() ;
                        let lables= [] ; 
                        resp.forEach(function(key) {                   
                            lables.push({"label":key  ,"value":key 	});
                        });
                        component.set("v.supplierlistissues", lables);
                        console.log('lables2');
                        console.log(resp);
                //   cmp.set("v.contactList", response.getReturnValue());
                    }else{
                        console.log(response2.getReturnValue());
                        alert('failed'); 
                    }
            
        })
        
        $A.enqueueAction(action2);
        	component.set("v.bookings", list);
        }
        else if(getCurrentStep == 2){
            component.set("v.currentStep", "3");
            var json = component.get('v.data');
            var finalJson = [];
            for(var i = 0; i < json.length; i++) {
    			var obj = json[i];
                if(!obj.hasOwnProperty('Id')){
                    finalJson.push(obj);
                }
            }
            console.log(JSON.stringify(finalJson));
            component.set('v.dataToPush',finalJson);
        }
            else if(getCurrentStep == 3){
                component.set('v.isLoading','true');
                 component.set('v.internalRecordId','');
                component.find("status").set("v.value",'');
                component.find("subject").set("v.value",'');
                component.set("v.selectedRecord",{}); 
                helper.clear(component,event,helper);
                component.find("endprovidername").set("v.value",'');
                component.set('v.showIssues','false');
        		component.set('v.tempInternalList',[]);
                component.set('v.tempIssueList',[]);
                
    			var bookingid = component.get('v.bookingValue');
    			console.log('bkid' + bookingid['Id']);
    			//helper.insertInternalAndIssue(component,event,helper,bookingid['Id']);
                
                /*component.find('subject').set('v.value','');
                component.find('type').set('v.value','');
                component.find('status').set('v.value','');
                helper.clear(component,event,helper);*/ 
                component.set("v.currentStep", "3");
                
    		
                var currentBooking = parseInt(component.get('v.currentBooking'));
                component.set("v.currentBooking",currentBooking + 1);
                var list = component.get('v.bookings');
                var v = list[currentBooking];
                v.selected = true;
                var prev = list[currentBooking-1];
                prev.selected = false;
                var bookingId = v.Id;    
                var action = component.get("c.getSupplierName");
                action.setParams({
                    "bookingid":bookingId
                })
                action.setCallback(this, function(response) {
                    component.set('v.isLoading',false);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                       
                        let resp =response.getReturnValue() ;
                        let lables= [] ; 
                        resp.forEach(function(key) {                   
                            lables.push({"label":key  ,"value":key 	});
                        });
                        component.set("v.supplierlist", lables);
                        console.log('lables');
                        console.log(lables);
                //   cmp.set("v.contactList", response.getReturnValue());
                    }else{
                        alert('failed'); 
                    }
                    
                
            
        })
        
        $A.enqueueAction(action);
                
                var action2 = component.get("c.getSupplierNameIssues");
                action2.setParams({
                    "bookingid":bookingId
                })
                action2.setCallback(this, function(response2) {
                    var state = response2.getState();
                    if (state === "SUCCESS") {
                       
                        let resp =response2.getReturnValue() ;
                        let lables= [] ; 
                        resp.forEach(function(key) {                   
                            lables.push({"label":key  ,"value":key 	});
                        });
                        component.set("v.supplierlistissues", lables);
                        console.log('lables2');
                        console.log(resp);
                //   cmp.set("v.contactList", response.getReturnValue());
                    }else{
                        console.log(response2.getReturnValue());
                        alert('failed'); 
                    }
            
        })
        
        $A.enqueueAction(action2);
                
                
                
                helper.fetchData(component,event,bookingId);  
    			helper.fetchIssues(component,event,bookingId); 
                component.set("v.bookings", list);
                
                
                
                
            }
    },
    
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "1" && (component.get('v.noBookingHeader') == 'true')){
            component.set('v.currentStep','0');
            component.set('v.bookings',[]);
        }
            
         if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
            
             
         }
         else if(getCurrentStep == 3){
            component.set("v.currentStep", "1");
         }
    },
    
    finish : function(component,event,helper){
      // on last step show the alert msg, hide popup modal box and reset the currentStep attribute  
        
        component.set('v.internalRecordId','');
                component.find("status").set("v.value",'');
                component.find("subject").set("v.value",'');
                component.set("v.selectedRecord",{}); 
                helper.clear(component,event,helper);
                component.find("endprovidername").set("v.value",'');
                component.set('v.showIssues','false');
        		component.set('v.tempInternalList',[]);
                component.set('v.tempIssueList',[]);
        		component.set('v.isOpen',false);
                
              	component.set('v.IssueSupplierName','');
                component.set("v.dataToPush", []);
        var bookingid = component.get('v.bookingValue');
        console.log('bkid' + bookingid);
        //helper.insertInternalAndIssuefinal(component,event,helper,bookingid['Id']);
        
    },
   
   // when user click direactly on step 1,step 2 or step 3 indicator then showing appropriate step using set 'currentStep'   
    selectFromHeaderStep1 : function(component,event,helper){
        component.set("v.currentStep", "1");
    },
    selectFromHeaderStep2 : function(component,event,helper){
        component.set("v.currentStep", "2");
        component.set("v.currentStep", "a");
        
    },
    selectFromHeaderStep3 : function(component,event,helper){
        component.set("v.currentStep", "a");
    },
    showForm : function(component,event,helper){
        component.set("v.show",true);
    },
    accessArray : function(component) {
        var myArray = component.get('v.bookings');
        var index = component.get('v.currentBooking');
        component.set('v.bookingValue', myArray[index-1]);
},
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
     onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
        //do something else
        component.set("v.selLookupType", selectedSearchType);
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
	handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log('selectedAccountGetFromEvent ' + JSON.stringify(selectedAccountGetFromEvent));
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
    onblur2 : function(component,event,helper){       
        component.set("v.listOfSearchRecords2", null );
        var forclose = component.find("searchRes2");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    }, 
    
    handleComponentEvent2 : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("stringEvent");
        console.log('selectedAccountGetFromEvent ' + selectedAccountGetFromEvent);
        component.set("v.newCaseSubject" , selectedAccountGetFromEvent); 
        
        
        var forclose = component.find("searchRes2");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        /*
        var lookUpTarget = component.find("lookupField2");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        */
    },
     clear2 :function(component,event,helper){
        
        var lookUpTarget = component.find("lookupField"); 
        
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    onchange : function(component,event,helper){
        component.set('v.Subject',component.get('v.Org_Type__c'));
    },
    handleAction: function(component, event, helper) {
        console.log('handling action');
        var action = event.getParam("action"),
            row = event.getParam("row"),
            data = component.get("v.data"),
            dataToPush = component.get("v.dataToPush"),
            rowIndex = data.indexOf(row),
            rowIndexPushed = dataToPush.indexOf(JSON.stringify(data[rowIndex]));
        switch(action.name) {
            //case 'del': data.splice(rowIndex, 1);
              //  break;
            case 'edit': 
                component.find("status").set("v.value",'');
                component.find("subject").set("v.value",'');
                component.set("v.selectedRecord.rid",'');                 
                component.find("endprovidername").set("v.value",'');
                component.find("status").set("v.value",row.Org_Case_Status__c);
                component.find("subject").set("v.value",row.Subject);
                var selectedRecord = '{"rid":"'+row.Owner.Id+'","rname":"'+row.Owner_Name__c+'"}';
                var selectedObj = JSON.parse(selectedRecord);
                
                console.log(JSON.stringify(selectedObj));
                component.set("v.selectedRecord",selectedObj);
                
                component.find("endprovidername").set("v.value",row.End_Provider_Name__c);
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');  
                
                component.set('v.internalRecordId',row.Id);
                var childCmp = component.find("cComp");
                    childCmp.refreshIssue();
        }
        component.set("v.data", data);
    },
    handleActionIssue: function(component, event, helper) {
        console.log('handling action');
        var action = event.getParam("action"),
            row = event.getParam("row"),
            data = component.get("v.issueList"),            
            rowIndex = data.indexOf(row)
            
        switch(action.name) {
            case 'del': data.splice(rowIndex, 1);
                break;
        }
        component.set("v.issueList", data);
    },
        toggleIssues: function(component,event,helper){
            component.set('v.isLoading',true);
            if(component.get('v.internalRecordId') == ''){
                var actions = helper.getRowActions.bind(this, component);
                component.set('v.columns', [            
                    
                    {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false}, 
                    {label: 'Responsible', fieldName: 'End_Provider_Name__c', type: 'text' ,editable: false},    
                    {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
                    {label: 'Owner', fieldName: 'Owner_Name__c', type: 'text' ,editable: false},
                    
                    { type: "action", typeAttributes: { rowActions: actions }}
                    
                     
                ]);
                var myData = component.get("v.data"); 
                var myDataToPush = component.get('v.dataToPush');
                var status = component.find("status").get("v.value");
                var subject = component.find("subject").get("v.value");
                var seluserorqueue = component.get("v.selectedRecord.rid"); 
                var endprovidername = component.find("endprovidername").get("v.value");
                myData.push(
                    {
                        Subject:subject,                
                        Org_Case_Status__c:status,
                        OwnerId:seluserorqueue,
                        End_Provider_Name__c:endprovidername
                    });
                myDataToPush.push(
                    {
                        Subject:subject,                
                        Org_Case_Status__c:status,
                        OwnerId:seluserorqueue,
                        End_Provider_Name__c:endprovidername
                    });
                     
                component.set("v.data", myData);
                component.set("v.dataToPush", myDataToPush);
                var bookingid = component.get('v.bookingValue');                
                helper.insertInternal(component,event,helper,bookingid['Id']);    
            }else{
                component.set('v.isLoading',false);
                component.set('v.showIssues','true'); 
            }
          },
          unToggleIssues: function(component,event,helper){
              component.set('v.showIssues','false');
              
          }
})