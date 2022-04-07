({
    init : function(component, event, helper) {
    	var action = component.get("c.getEmailFolder");
        var firstFolder = '';
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
        component.set('v.firstFolder',firstFolder);
        component.set('v.newCaseStatus','In Progress');
        component.set('v.newCaseSubject',"");
       component.set('v.statusfield',"");
       component.set('v.Type',"");
       component.set("v.textMessage","");
        component.set("v.caseOwner","");
        
         component.set('v.currentStep','0');
        
        var action2 = component.get("c.fetchUserInfo");
         action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp.rid);
                console.log(resp.rname);
                 var selectedRecord = '{"rid":"'+resp.rid+'","rname":"'+resp.rname+'"}';
              
              var selectedObj = JSON.parse(selectedRecord);
                
                
               component.set("v.selectedRecord" , selectedObj); 
                console.log('success');
                console.log(resp);
               
        
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');  
            }
            
        })
        
        $A.enqueueAction(action2);
        
        
        var thirdaction = component.get("c.fetchUser");
        
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
         var action2 = component.get("c.fetchUserInfo");
         action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp.rid);
                console.log(resp.rname);
                 var selectedRecord = '{"rid":"'+resp.rid+'","rname":"'+resp.rname+'"}';
              
              var selectedObj = JSON.parse(selectedRecord);
                
                
               component.set("v.selectedRecord" , selectedObj); 
                console.log('success');
                console.log(resp);
               
        
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');  
            }
            
        })
        
        $A.enqueueAction(action2);
	},
    closeModal : function(component,event,helper) {
        component.set('v.isOpen','false'); 
         var a = component.get('c.init');
        component.set('v.newCaseType','');
        component.set('v.newCaseSubject','');
        component.set('v.newCaseStatus','');
        component.set('v.newCaseDescription','');
        component.set('v.newCaseOwner','');
        component.set('v.selectedRecord','');
        component.set('v.SearchKeyWord',''); 
        component.set("v.lstObj",[]);
        $A.enqueueAction(a);
    },
    moveBack : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
        v = v - 1;
        component.set('v.currentStep',v.toString());
    },
    moveNext : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
        
        if(v == 1){
            helper.stepOneNext(component,event,helper);
        }else if(v == 2){
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
                descriptionfield.set('v.value',resp);
            }
            
        })
        
        $A.enqueueAction(action);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onblur2 : function(component,event,helper){       
        component.set("v.listOfSearchRecords2", null );
        var forclose = component.find("searchRes2");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
        if(selectedSearchType == 'Queue'){
             component.set('v.newCaseStatus','New');
         }
         if(selectedSearchType == 'User'){
             component.set('v.newCaseStatus','In Progress');
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
    keyPressController2 : function(component, event, helper) {
        
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.newCaseSubject");
        debugger;
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes2");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
           
            helper.searchHelper2(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords2", null ); 
            var forclose = component.find("searchRes2");
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
    clear :function(component,event,helper){
        component.set('v.selectedRecord','');
        component.set('v.SearchKeyWord',''); 
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
         component.set('v.selectedRecord','');
        component.set('v.SearchKeyWord',''); 
    },
    clear2 :function(component,event,helper){
        
        var lookUpTarget = component.find("lookupField"); 
        
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    createServiceRequest :function(component,event,helper){
        component.set('v.showspinnermain','true');
        console.log('this is called');
        var subject = component.get('v.newCaseSubject');
        var status = component.find('statusfield').get('v.value');
        var type = component.find('Type').get('v.value');
        var description = component.get('v.textMessage');
        var caseOwner = component.find("caseOwner").get("v.value");
         var seluserorqueue = component.get("v.selectedRecord.rid"); 
        var action = component.get("c.createServiceRequestController");   
        action.setParams({ 
            "subject":subject,
            "status":status,
            "description":description,
            "caseOwner":seluserorqueue,
            "bookingId":component.get('v.recordId'),
            "accountId":component.get('v.caseRecordTR.Org_Account_Name__c'),
            "type":type,
            "sendSMS":component.get('v.SendSMS')
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
                    message: "Service Request Created.",
                    type: "success"
                });
                toastEvent.fire();
                component.set('v.newCaseType','');
                component.set('v.newCaseSubject','');
                component.set('v.newCaseStatus','');
                component.set('v.newCaseDescription','');
                component.set('v.newCaseOwner','');
                component.set('v.selectedRecord','');
                component.set('v.SearchKeyWord',''); 
                component.set("v.lstObj",[]);
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                console.log(tabId);
                
                workspaceAPI.isSubtab({
                    tabId: tabId
                }).then(function(response) {
                    if (response) {
                        //confirm("This tab is a subtab.");
                        workspaceAPI.openTab({
                            //parentTabId: tabId,
                            url: '/lightning/r/Case/'+TRrecordID+'/view',
                            focus: true
                        });
                    }
                    else {
                        //confirm("This tab is not a subtab.");
                        workspaceAPI.openSubtab({
                            parentTabId: tabId,
                            url: '/lightning/r/Case/'+TRrecordID+'/view',
                            focus: true
                        });
                    }
                });
                
                
            })
            .catch(function(error) {
                console.log(error);
            });
            }
            else if (state === "INCOMPLETE") {
                console.log(response);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
    	});
        
        $A.enqueueAction(action);
         var a = component.get('c.init');
             $A.enqueueAction(a);
        },
    itemsChange: function(component,event,helper){
        component.set('v.newCaseSubject',component.get('v.newCaseType'));
    },
    handleCheckTask: function(component,evt,helper){
         var checkbox = evt.getSource();
        console.log(checkbox.get("v.value"));
        component.set('v.SendSMS',checkbox.get('v.value'));
    }
})