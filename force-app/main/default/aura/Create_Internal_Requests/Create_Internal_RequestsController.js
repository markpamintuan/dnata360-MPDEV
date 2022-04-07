({
	      openModal: function(component, event, helper) {
              var actions = helper.getRowActions.bind(this, component);
      // for Display Model,set the "isOpen" attribute to "true"
          component.set("v.isOpen", true);
          component.set("v.showspinner",false);
          var caseRecord = component.get('v.caseRecordTR');
           console.log(component.get('v.caseRecordTR'));
          console.log('caseRecord:' +component.get('v.caseRecord.Org_Booking__c'));//added as part of v1.1
            var recId = component.get('v.caseRecordTR.Org_Booking__c');  
              console.log(recId);
        var action = component.get("c.getAllBookings");
        console.log(action + ' %&^*@!(');
        //action.setParams({ "accId" : accountId });//changed as part of v1.1
        action.setParams({ 
            "lstRecordId" : recId 
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
                console.log('component ' + component.get('v.caseRecordTR.Org_Booking__r.Name'));
                
                
            }else{
                component.set('v.casebookingList',null);
                alert('ERROR...');
            }
        });
       $A.enqueueAction(action);
   },
    
    init: function (component, event, helper) {

var actions = helper.getRowActions.bind(this, component);
      var delId = component.get("v.casebookingList");
        component.set('v.columns', [
            {label: 'Category', fieldName: 'Category__c', type: 'picklist' ,editable: false},
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},            
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            { type: "action", typeAttributes: { rowActions: actions}},
            
            
        ]);
        component.set("v.showspinner",false);
        helper.fetchData(component,event,delId); 
            component.set('v.Status','New');

        
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
           {label: 'Category', fieldName: 'Category__c', type: 'picklist' ,editable: false},
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},            
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            { type: "action", typeAttributes: { rowActions: actions}},
            
            
        ]);
        
        helper.getBookings(component,event,delId);
   

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
                     
                }
                console.log(v.selected);
                console.log(i);
                console.log(v);
            }
            
        );
        component.set("v.bookings", items);
    },
    addInternalRequest : function(component , event, helper){ 
            component.set('v.isLoading',true);
            var count = component.get('v.InternalRequestCount');
                		count = count + 1;
                		component.set('v.InternalRequestCount',count);
         setTimeout(function(){
            var actions = helper.getRowActions.bind(this, component);
         component.set('v.columns', [
            {label: 'Category', fieldName: 'Category__c', type: 'picklist' ,editable: false},
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},            
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            { type: "action", typeAttributes: { rowActions: actions}},
            
        ]);
        var myData = component.get("v.data"); 
        var type = component.find("type").get("v.value");
        var status = component.find("status").get("v.value");
        var subject = component.find("subject").get("v.value");
        var description = component.find("description").get("v.value");
        var seluserorqueue = component.get("v.selectedRecord.rid"); 
        myData.push(
            {
                Subject:subject,
                Category__c:type,
                Org_Case_Status__c:status,
                Description:description,
                OwnerId:seluserorqueue
            });
        component.set("v.data", myData);     
           
        $A.get('e.force:refreshView').fire();
        component.set('v.isLoading',false);
         var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         title: 'Success',
                         message: "Internal Request added to the bottom of the list.",
                         type: 'success',
                        
                    });
                    toastEvent.fire();
        component.find("type").set("v.value",'');
        		component.find("status").set("v.value",'');
     			component.find("subject").set("v.value",'');
             var a = component.get('c.clear');
         $A.enqueueAction(a);  
    }, 1000);
        },
    moveNext : function(component,event,helper){
     // control the next button based on 'currentStep' attribute value    
     // control the next button based on 'currentStep' attribute value    
      var getCurrentStep = component.get("v.currentStep");
      var noBookingHeader = component.get('v.noBookingHeader');
      var getStep = component.get("v.steps");
       
        
        if(getCurrentStep == "1"){
            component.set("v.currentStep", "2");
            var list = component.get('v.bookings');
            var v = list[0];
       		v.selected = true;
 			var bookingId = v.Id;               
            helper.fetchData(component,event,bookingId); 
        	
        	component.set("v.bookings", list);
        }
        else if(getCurrentStep == 2){
            	component.set('v.isLoading','true');
    			var bookingid = component.get('v.bookingValue');
    			console.log('bkid' + bookingid['Id']);
    			helper.insertInternal(component,event,helper,bookingid['Id']);
                component.set("v.currentStep", "2");
            component.set('v.InternalRequestCount',0);	
            component.set('v.Status','New');
    		
                var currentBooking = component.get('v.currentBooking');
                component.set("v.currentBooking",currentBooking + 1);
                var list = component.get('v.bookings');
                var v = list[currentBooking];
                v.selected = true;
                var prev = list[currentBooking-1];
                prev.selected = false;
                var bookingId = v.Id;               
                helper.fetchData(component,event,bookingId);  
    			 
                component.set("v.bookings", list);
            	component.find("type").set("v.value",'');
        		component.find("status").set("v.value",'');
     			component.find("subject").set("v.value",'');
             var a = component.get('c.clear');
        $A.enqueueAction(a);
                
            }
    },
    
    closeModal: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
      component.find("type").set("v.value",'');
        		component.find("status").set("v.value",'');
     			component.find("subject").set("v.value",'');
             var a = component.get('c.clear');
        component.set('v.Status','New');
        component.set('v.currentStep','1');
        $A.enqueueAction(a);  
        component.set('v.bookings',[]);
       		 component.set('v.currentBooking',1);
        component.set('v.InternalRequestCount',0);
      component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
   },
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
         if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
         }
    },
    
    finish : function(component,event,helper){
        
      // on last step show the alert msg, hide popup modal box and reset the currentStep attribute  
        component.set('v.isLoading','true');
        var bookingid = component.get('v.bookingValue');
        console.log('bkid' + bookingid);
        helper.insertInternalfinal(component,event,helper,bookingid['Id']);
        component.find("type").set("v.value",'');
        		component.find("status").set("v.value",'');
     			component.find("subject").set("v.value",'');
         var a = component.get('c.clear');
        $A.enqueueAction(a);
        
       
        component.set('v.Status','New');
        component.set('v.currentStep','1');
      
        component.set('v.bookings',[]);
       		 component.set('v.currentBooking',1);
        component.set('v.InternalRequestCount',0);
      component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        location.reload();
        
        
    },
   
   
    showForm : function(component,event,helper){
        component.set("v.show",true);
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
    handleAction: function(component, event, helper) {
        console.log('handling action');
        var action = event.getParam("action"),
            row = event.getParam("row"),
            data = component.get("v.data"),
            
            rowIndex = data.indexOf(row);
           
        switch(action.name) {
            case 'del': data.splice(rowIndex, 1);
                		var count = component.get('v.InternalRequestCount');
                		count = count - 1;
                		component.set('v.InternalRequestCount',count);
                break;
        }
        component.set("v.data", data);
    },
    itemsChange : function(component,event,helper){
        component.set('v.Subject',component.get('v.Org_Type__c'));
    }
})