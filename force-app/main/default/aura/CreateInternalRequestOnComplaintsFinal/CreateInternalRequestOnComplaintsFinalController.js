({	
    init: function (component, event, helper) {
        var actions = helper.getRowActions.bind(this, component);
        var delId = component.get("v.bookings");       
        console.log('[+]Calling fetch Data from init using id ' + delId);
        helper.fetchData(component,event,delId); 
        helper.fetchIssues(component,event,delId);     
        component.set('v.Status','In Progress');
    },
    openModal: function(component, event, helper) {
        component.set('v.currentStep','1');      
        helper.init(component,event,helper);
        component.set("v.isOpen", true);
        var actions = helper.getRowActions.bind(this, component);        
        var caseRecord = component.get('v.caseRecord');                   
        var recId = component.get('v.recordId');
        console.log('[+]Record Id on opening modal : ' + recId);       
        var action = component.get("c.getAllRelatedBookings");                 
        action.setParams({ 
            "caseId" : recId 
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();            
            if(state === 'SUCCESS' && component.isValid()){                   
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
                console.log('[+]Booking List found on opening modal : ' + cleanedUp);                    
                component.set("v.casebookingList",response.getReturnValue()); 
                component.set('v.Status','In Progress');
            }else{
                component.set('v.casebookingList',null);
                alert('ERROR...');
            	}
       	});
        $A.enqueueAction(action);            
   },
  /* closeModal: function(component, event, helper) {
       component.set('v.isOpen',false);
   },*/
   onCheck : function(component,event,helper){
       var actions = helper.getRowActions.bind(this, component);
       var selectedRec = event.getSource().get("v.value");
       var getSelectedNumber = component.get("v.steps");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.steps", getSelectedNumber);
        var getAllId = component.find("checkbox");
        var delId = [];
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                delId.push(getAllId.get("v.text"));
            }
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    delId.push(getAllId[i].get("v.text"));
                }
            }
        } 
        console.log(delId);
        component.set("v.selectedBookings",delId);
        console.log(component.get("v.bookings"));        
        helper.getBookings(component,event,delId);
    },
    moveNext : function(component,event,helper){
      var getCurrentStep = component.get("v.currentStep");
      var getStep = component.get("v.steps");      
      if(getCurrentStep == "1"){
          component.set('v.isLoading',true);
            component.set("v.currentStep", "2");
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
                        console.log('lableshere');
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
                
                    }else{
                        console.log(response2.getReturnValue());
                        alert('failed'); 
                    }
            
        })
        
        $A.enqueueAction(action2);
        	component.set("v.bookings", list);
        }
      if(getCurrentStep == "2"){
          component.set("v.currentStep", "3");
          if(component.get('v.currentInternalRequest') != 'New'){
             
              helper.fetchCurrentData(component,event,component.get('v.currentInternalRequest')); 
              
          }else{
              component.set('v.Subject','');
              component.set('v.Responsible','');
              component.set('v.Status','In Progress');
              component.set('v.Owner','');
             
              component.set('v.Description','');
             
              var caseRecordOwnerId = component.get('v.caseRecord.OwnerId');     
              var caseRecordOwnerName = component.get('v.caseRecord.Org_Owner_Name__c');     
              var selectedRecord = '{"rid":"'+caseRecordOwnerId+'","rname":"'+caseRecordOwnerName+'"}';
              
              var selectedObj = JSON.parse(selectedRecord);
              component.set('v.selectedRecord',selectedObj);
              console.log(selectedRecord); 
              var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');
              
              //helper.clear(component,event,helper);
          }
      }
      if(getCurrentStep == "3"){
          component.set('v.isLoading',true);
          var bookingid = component.get('v.bookingValue');
          helper.InsertOrUpsertInternal(component,event,helper,bookingid['Id']);          
      }
        
    },
    onCheckHeader : function(component,event,helper){      
       var selectedRec = event.getSource().get("v.text");       
       console.log('[+]selected Record ' +selectedRec);      
       component.set('v.currentInternalRequest',selectedRec);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
     onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
         if(selectedSearchType == 'Queue'){
             component.set('v.Status','New');
         }
         if(selectedSearchType == 'User'){
             component.set('v.Status','In Progress');
         }
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
    addIssue: function(component, event, helper){
          component.set('v.isLoading',true);
      	  
          var bookingid = component.get('v.bookingValue');
          helper.insertIssue(component,event,helper,bookingid['Id']);
         
          
        
    },
    
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "4"){
            component.set('v.currentStep','3');
            
        }
            
         if(getCurrentStep == "3"){
             
            component.set("v.currentStep", "2");
            component.set('v.Subject','');
              component.set('v.Responsible','');
              component.set('v.Status','');
              component.set('v.Owner','');
              component.set('v.selectedRecord',{});
              component.set('v.Description','');
              helper.clear(component,event,helper);
             
         }
        
    },
    moveNextandNew : function(component,event,helper){
        component.set('v.isLoading',true);
        component.set('v.currentStep','2');
        var bookingId = component.get('v.bookingValue');
        helper.fetchData(component,event,bookingId['Id']);  
    	helper.fetchIssues(component,event,bookingId['Id']); 
        component.set('v.currentInternalRequest','');
        component.set('v.Subject','');
        component.set('v.Status','');
        component.set('v.Owner','');
        component.set('v.Responsible','');
        component.set('v.Description','');
        component.set('v.selectedRecord',{});
        component.set('v.Status','In Progress');
        
    },
    moveNextandNextBooking : function(component,event,helper){
		component.set('v.isLoading',true);        
        component.set('v.currentInternalRequest','');
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
               }else{
               	   console.log(response2.getReturnValue());
                   alert('Error : ' +JSON.stringify(response2.getReturnValue())); 
                    }
            
        })
        component.set('v.Status','In Progress');
        $A.enqueueAction(action2);   
        console.log('Booking Id ' + bookingId);
        helper.fetchData(component,event,bookingId);  
    	helper.fetchIssues(component,event,bookingId); 
        component.set("v.bookings", list);
        component.set('v.currentStep','2');
                
                
                
    },
    accessArray : function(component) {
        var myArray = component.get('v.bookings');
        var index = component.get('v.currentBooking');
        component.set('v.bookingValue', myArray[index-1]);
	},
    closeModal: function(component,event,helper){
        component.set('v.isOpen',false);
        component.set('v.isLoading',false);
        component.set('v.bookings',[]);
        component.set('v.currentStep','1');
        component.set('v.bookingValue',{});
        component.set('v.data',[]);
        component.set('v.dataCurrent',[]);
        component.set('v.currentBooking',1);
        component.set('v.currentInternalRequest','');
        component.set('v.supplierlist','');
        component.set('v.supplierlistissues','');
        component.set('v.Subject','');
        component.set('v.Status','');
        component.set('v.Owner','');
        component.set('v.Responsible','');
        component.set('v.Description','');
        component.set('v.selectedRecord',{});
        component.set('v.Issue__c','');
        component.set('v.Issue_Type__c','');
        component.set('v.IssueSupplierName','');
        component.set('v.YalagoProvider','');
        component.set('v.IssueDescription','');
        component.set('v.tempInternalList','');
        component.set('v.tempIssueList','');
        $A.get('e.force:refreshView').fire();
        
        
    }
})