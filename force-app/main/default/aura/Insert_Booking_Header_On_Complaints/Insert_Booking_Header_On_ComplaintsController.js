({
	openModal: function(component, event, helper) {                           
         var caseRecord = component.get('v.caseRecord');
         console.log('caseRecord:' +  caseRecord["Org_Booking__c"]);
         component.set("v.isOpen", true);
         if(caseRecord["Org_Booking__c"] == null){               
              var recId = component.get('v.recordId');          
              var action = component.get("c.getAllRelatedBookingHeaders");
             console.log('action ' + action);
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
                             message: 'No Bookings could be retrieved for that account.',
                            mode:'sticky'
                            
                        });
                        toastEvent.fire();
                    }
                        cleanedUp = helper.createMapOfBookingType(response.getReturnValue()); 
                        console.log('@@@ response returned value: ' + response.getReturnValue());
                        console.log('@@@ response returned value: ' + response.getReturnValue());
                        console.log('reponse is ' + JSON.stringify(response.getReturnValue()));
                        component.set("v.casebookingHeaderList",response.getReturnValue());
                
            		}else{
                        component.set('v.casebookingHeaderList',null);
                        alert('ERROR...');
            	}
       	     });
       		 $A.enqueueAction(action);
             }
   },
    onCheckHeader : function(component,event,helper){      
        var selectedRec = event.getSource().get("v.text");       
        component.set('v.bookingHeaderId',selectedRec);
    },
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    finish : function(component,event,helper){
        component.set('v.isLoading',true);
        var action = component.get("c.insertBookingHeader");
        
        var recId = component.get('v.recordId');    
        var bookingHeaderId = component.get('v.bookingHeaderId');
        console.log('bkheadeerid' + bookingHeaderId);
        action.setParams({ 
            "bookingHeaderId" : bookingHeaderId,
            "complaintId" :recId
        });
        action.setCallback(this, function(response){
                  var state = response.getState();
            	  
                  if(state === 'SUCCESS' && component.isValid()){  
                      $A.get('e.force:refreshView').fire();
                      component.set('v.isLoading',false);
                      var toastEvent = $A.get("e.force:showToast");
                      toastEvent.setParams({
                            "title": "Success!",
                          "type":"Success",
                            "message": "Booking has been added successfully."
                      });
                      toastEvent.fire();
                      component.set("v.isOpen", false);
                      //document.getElementsByClassName('cCreateInternalRequestOnComplaintsFinal')[0].click();
                      
            		}else{                       
                        alert('ERROR...');
            	}
       	});
        $A.enqueueAction(action);
        
    },
    forceRefreshViewHandler : function(cmp, evt, hlp){
    	//setTimeout(function(){ document.getElementsByClassName('cCreateInternalRequestOnComplaintsFinal')[0].click() }, 10000);
	},
})