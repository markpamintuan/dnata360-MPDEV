({
    init : function(component, event, helper) {
        
    	var action = component.get("c.getEmailFolder");
        $A.get('e.force:refreshView').fire();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    console.log('developername ' + key.DeveloperName); 
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.options", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
         

        $A.enqueueAction(action);
        component.set('v.currentStep','0');
        component.set("v.textMessage","");
        component.set("v.followUpDate","");
        component.set("v.newCaseDescription","");
        var test =component.get("c.getFollowUpCustomerCommunication");
        var caseRec = component.get("v.recordId");
        
        console.log(caseRec);
        test.setParams({ 
            "caseRec":caseRec
	    });
        test.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                var resp =response.getReturnValue() ;
                console.log(resp.Id);
                component.set("v.existingfollowUpDate", resp.Id);
                component.set("v.textMessage",resp.Message__c);
                component.set("v.followUpDate",resp.Follow_Up_Date__c);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
         $A.enqueueAction(test);
        
       var thirdaction = component.get("c.fetchUser2");
        
        thirdaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                console.log('userinfo ' + storeResponse);
            }
             
        });
        $A.enqueueAction(thirdaction);
        
       
    },
	openModal : function(component, event, helper) {
		component.set('v.isOpen','true');
	},
    openEditModal : function(component, event, helper) {
		component.set('v.Edit','true');
        component.set('v.showspinnermain','false');
        
	},
    closeModal : function(component,event,helper) {
        component.set('v.isOpen','false'); 
         component.set('v.Edit','false');
        component.set('v.currentStep','0');
    },
    moveBack : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
        v = v - 1;
        component.set('v.currentStep',v.toString());
    },
    moveNext : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
      
        if(v == 0){
            helper.stepOneNext(component,event,helper);
        }else if(v == 1){
            helper.stepSecondNext(component,event,helper);
        }else{
            v = v + 1;   
            component.set('v.currentStep',v.toString());
        }
    },
    handleChange : function(component,event,helper) {
        var folderField = component.find('folder');
        var folder = folderField.get('v.value');
      	component.set('v.CSRFolder',folder);
        
        var action = component.get("c.getEmails");
        action.setParams({ 
            "foldername":folder
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var templateField = component.find("template");
                templateField.set('v.disabled',false);
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    console.log('developername ' + key.DeveloperName); 
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.templateoptions", lables);
                
            }
            
        })
        
        $A.enqueueAction(action);
        
        
    },
    handletemplatechange:function(component,event,helper){
        var templateField = component.find('template');
        var template = templateField.get('v.value');
      	component.set('v.CSRTemplate',template);
        console.log(template);
        
       var action = component.get("c.getEmailContent");
	    action.setParams({ 
            "templatename":template
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                var descriptionfield = component.find('description');
                component.find('description').set('v.value',resp);
            }
            
        })
        
        $A.enqueueAction(action);
    },
    
     createFollowUpDate :function(component,event,helper){
         component.set('v.showspinnermain','true');
         console.log('this is called');
         
         debugger;
         
         var caseRec = component.get('v.caseRecordTR');
         var description = component.get('v.textMessage');
         var followUp = component.get('v.followUpDate');
         var action = component.get("c.createFollowUp");
         var sendingSMS = false;
        if(component.get('v.isChanged') == true){
            sendingSMS = component.get('v.SendSMS');
        }else{
            sendingSMS = component.get('v.caseRecordTR.Receive_Text_Messages__c');
        }
         console.log(followUp);
             action.setParams({ 
                 "caseRec":caseRec,
                 "followUpDate":followUp,
                 "description":description,
                 "sendSMS":sendingSMS
                 
             });
             action.setCallback(this, function(response) {
                 component.set('v.showspinnermain','false');
                  component.set('v.isOpen','false');
                 var state = response.getState();
                 if (state === "SUCCESS") {
                     var TRrecordID = response.getReturnValue();
                     console.log(TRrecordID);
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         title: "Success!",
                         message: "Scheduled Customer Message Created.",
                         type: "success"
                     });
                     toastEvent.fire();
                    
                 }
                 else {
                     var error = JSON.stringify(response.getError());
                     console.log("Unknown error create: " +error );
                     
                 }
             });
             
             $A.enqueueAction(action); 
			 var a = component.get('c.init');
             $A.enqueueAction(a);

     },
    updateFollowUpDate : function(component,event,helper){
        component.set('v.showspinnermain','true');
        console.log('this is called');
         debugger;
        var caseRec = component.get('v.caseRecordTR');
        var custComm = component.get('v.existingfollowUpDate');
        var description = component.get('v.textMessage');
       	var followUp = component.get('v.followUpDate');
        var action = component.get("c.updateFollowUp");   
        action.setParams({ 
            "followUpDate":followUp,
            "description":description,
            "custComm":custComm
            
	    });
        action.setCallback(this, function(response) {
            component.set('v.showspinnermain','false');
            
            var state = response.getState();
            if (state === "SUCCESS") {
                //close the modal
                //stop the spinner
                //toast 
                component.set('v.Edit','false'); 
        		var TRrecordID = response.getReturnValue();
                console.log(TRrecordID);
           
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Updated Scheduled Customer Message',               
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'dismissible'
                            });
                            toastEvent.fire()
                
            }
            else {
                var error = JSON.stringify(response.getError());
                console.log("Unknown error update " +error );
            }
    	});
        
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        var a = component.get('c.init');
                $A.enqueueAction(a);
    },
    deleteFollowUpDate : function(component,event,helper){
        
        var custComm = component.get('v.existingfollowUpDate');
        var resultVal = confirm("Please confirm if you want to delete this Scheduled Customer Message");
        if(resultVal == true){
        component.set('v.showspinnermain','true');
        var action = component.get("c.deleteFollowUp"); 
        action.setParams({ 
          "custComm":custComm  
	    });
        action.setCallback(this, function(response) {
            component.set('v.showspinnermain','false');
            
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set('v.Edit','false'); 
        		var TRrecordID = response.getReturnValue();
                console.log(TRrecordID);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Scheduled Customer Message Deleted.",
                    type: "success"
                });
                toastEvent.fire();
                component.set("v.existingfollowUpDate", TRrecordID);
                
            }
            else {
                var error = JSON.stringify(response.getError());
                console.log("Unknown error delete " +error );
            }
    	});
        
        $A.enqueueAction(action);
        var a = component.get('c.init');
        $A.enqueueAction(a);
        $A.get('e.force:refreshView').fire();

                
        }
        
		 
    },
    handleCheckTask: function(component,evt,helper){
         var checkbox = evt.getSource();
        console.log(checkbox.get("v.value"));
        component.set('v.SendSMS',checkbox.get('v.value'));
        component.set('v.isChanged',true);
    }
})