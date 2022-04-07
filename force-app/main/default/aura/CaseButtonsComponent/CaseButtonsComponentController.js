({
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        //var currcasestatus = component.get("v.caseRecord.Status");
        component.set("v.showCloseCaseButton", true);
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.showCloseCaseButton", true);
        component.set("v.isOpen", false);
        //$A.get('e.force:refreshView').fire();
    },
    
    openChangeOwnerRTModal: function(component, event, helper) {
        
        //var currcasestatus = component.get("v.caseRecord.Status");
        component.set("v.showRTPicklist", true);
        component.set("v.selLookupType", "Queue"); // default
        component.set("v.isCaseRTChangeBoxOpen", true);
    },
    
    openReassignOwnerModal: function(component, event, helper) {
        debugger;
        //var currcasestatus = component.get("v.caseRecord.Status");
        component.set("v.showRTPicklist", false);
        component.set("v.selLookupType", "Queue"); // default
        component.set("v.isCaseRTChangeBoxOpen", true);
    },
    
    closeChangeRTModal: function(component, event, helper) {
        
        //component.set("v.showCloseCaseButton", true);
        component.set("v.isCaseRTChangeBoxOpen", false);
        //$A.get('e.force:refreshView').fire();
        
    },
    
    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        //alert('test');
        component.set("v.isOpen", false);
    },
    
    saveCase : function(component, event, helper) {
        debugger;
        helper.saveCase(component, event, helper);
        component.set("v.showCloseCaseButton", false);
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        
    },
    recordUpdated : function(component, event, helper) {
        helper.recordUpdated(component, event, helper);
        console.log(component.get('v.caseRecord.RecordType.Name'));
        //Added by Evendo on 4/1/2019
        var caseRecord = component.get('v.caseRecord');
        var cid = component.get("v.recordId");
        var recordtype = component.get("v.caseRecord.RecordType.Name");
        
        var ContactName = component.get("v.caseRecord.Contact.FirstName"); //KR
        console.log('ContactName: ' + ContactName); //KR
        
        console.log(caseRecord);
        console.log(recordtype);
        console.log('cid'+cid);
        console.log(component.get('v.userInfo'));
        console.log(component.get('v.recordId'));
        //console.log(caseRecord.Org_Type__c);
          //console.log(caseRecord.Id);
        if(recordtype == 'Travel Republic - Booking Enquiry'){
          var openedInDanube = component.get("v.caseRecord.Opened_In_Danube__c");
          //console.log('Opened in Opened_In_Danube__c => ' + openedInDanube);
          if(!openedInDanube){
            //helper.updateVisitedPage(component,event,helper);
            component.set('v.caseRecord.Opened_In_Danube__c',true);
            component.find('caseRec').saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
            var DerwentId = component.get("v.caseRecord.Org_Derwent_Customer_No__c");
              if(DerwentId =='' || DerwentId == null){
                $A.get("e.force:closeQuickAction").fire();
                setTimeout(function(){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'This account is not Derwent yet! Please try again in a few moments',               
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }, 1000);
            }
            else{
            console.log("Derwent ID " + DerwentId);
                if(caseRecord.Org_Type__c == 'Booking Enquiry' && caseRecord.Org_Brand__c == 'trp' && caseRecord.Org_Type__c != null){
            		window.open($A.get("$Label.c.PPTRWebsite")  + '1/' + DerwentId + '?trackingTag=' + cid , "_blank");  
                }
            }
            }
          // 
        }
    },
    
    doInit: function(component, event, helper) {
        debugger;    
        //helper.fetchPickListVal(component, 'Reason', 'cseReason');
       	var childComponent = component.find("child");
        helper.fetchRTPickListVal(component, event, helper);
        helper.checkCaseOwnerForAccept(component, event, helper);
        helper.checkIsTeamLead(component, event, helper);   
        helper.displayBookingButton(component, event, helper);
        helper.checkIsNonAAAgent(component, event, helper);//MPamintuan
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        var action2 = component.get("c.fetchUserId");
        action2.setCallback(this, function(response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                var userinfoid = response2.getReturnValue();
                component.set("v.userInfoId", userinfoid);
                console.log('userid : '  + userinfoid);
            }
        });
        $A.enqueueAction(action2);
    },
    cownerchange : function(component, event, helper) {
        var resultVal = confirm("Please click OK to proceed");
        console.log(resultVal);
       	if(resultVal == true){
            helper.chngCaseOwner(component, event, helper);
       }
       $A.get('e.force:refreshView').fire();
    },
    cownerRTchange : function(component, event, helper) {
        helper.chngCaseOwner_RT(component, event, helper);
        component.set("v.isCaseRTChangeBoxOpen", false);
        $A.get('e.force:refreshView').fire();
    },
    redirectToExtPageDanube : function(component, event, helper) {
        var cid = component.get("v.recordId");
        var derwentCustomerId = component.get("v.caseRecord.Org_Derwent_Customer_No__c");
        window.open($A.get("$Label.c.Danube_Booking_Page") + $A.get("$Label.c.ekh_Tenant_Id") + '/' + derwentCustomerId + '?trackingTag=' + cid , "_blank");
    },
    
    viewAgentModeBooking : function(component, event, helper) {
        debugger;
        var bookingId = component.get("v.caseRecord.Org_Booking_Id__c");

       
        if(bookingId != null){
            window.open('https://www.dnata-agents.com/v2/update_booking/' + $A.get("$Label.c.dnata_Tenant_Id")+ '/' + bookingId, "_blank");
        }    
        },
    
    viewDanubeBooking : function(component, event, helper) {
        debugger;
        var bookingId = component.get("v.caseRecord.Org_Booking_Id__c");
        var derwentCustomerId = component.get("v.caseRecord.Org_Derwent_Customer_No__c");
        if(bookingId != null){
                window.open($A.get("$Label.c.View_Danube_Booking") + $A.get("$Label.c.ekh_Tenant_Id") + '/'+ bookingId, "_blank");
        }
    },
    
    //https://pp2.dnataagentdesktop.com/update_booking/{!TenantID}/{BookingId}
    
    redirectToExtPageADT : function(component, event, helper) {
        var cid = component.get("v.recordId");
        var derwentCustomerId = component.get("v.caseRecord.Org_Derwent_Customer_No__c");
        // Added on Dec4th,2018 - Kaavya - Condition added for Derwent ID error message
        if(derwentCustomerId =='' || derwentCustomerId == null){
                $A.get("e.force:closeQuickAction").fire();
                setTimeout(function(){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'This account is not Derwent yet! Please try again in a few moments',               
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }, 1000);
            }
            else{
                if(derwentCustomerId !='' && derwentCustomerId != null){
                    window.open($A.get("$Label.c.ADT_Customer_Page") + $A.get("$Label.c.dnata_Tenant_Id")+ '/'+ derwentCustomerId.toUpperCase() +'?trackingTag=' + cid, "_blank");   
                }
            }
        
    },
    //Travel Republic Redirect
    redirectToExtPageADTForTR : function(component, event, helper) {
         var recordtype = component.get('v.caseRecord.RecordType.Name');
       if(recordtype == 'Travel Republic - Booking Enquiry'){
        var cid = component.get("v.recordId");
        var derwentCustomerId = component.get("v.caseRecord.Org_Derwent_Customer_No__c");
        if(derwentCustomerId =='' || derwentCustomerId == null){
                $A.get("e.force:closeQuickAction").fire();
                setTimeout(function(){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'This account is not Derwent yet! Please try again in a few moments',               
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }, 1000);
            }
            else{
                if(derwentCustomerId !='' && derwentCustomerId != null){
                     window.open($A.get("$Label.c.PPTRWebsite")  + '1/' + derwentCustomerId + '?trackingTag=' + cid , "_blank");   
                }
            }
       }
    },
    viewBookingRedirectToDerwentPage : function(component, event, helper) {
        console.log('#### comp: ' + component.get('v.caseRecord.Org_Booking_Id__c'));
        var windowURL = $A.get("$Label.c.Derwent_Booking_Page")+"?BookingID="+component.get('v.caseRecord.Org_Booking_Id__c');
        var popupWindow = window.open(windowURL, "_blank");
    },
    
    viewBookingRedirectToDerwentPage : function(component, event, helper) {
        console.log('#### comp: ' + component.get('v.caseRecord.Org_Booking_Id__c'));
        var windowURL = $A.get("$Label.c.Derwent_Booking_Page")+"?BookingID="+component.get('v.caseRecord.Org_Booking_Id__c');
        var popupWindow = window.open(windowURL, "_blank");
    },
    
     viewBookingRedirectToDerwentPageEkuk : function(component, event, helper) {
        console.log('#### comp: ' + component.get('v.caseRecord.Org_Booking_Id__c'));
        var windowURL = $A.get("$Label.c.Derwent_Booking_Page_ekuk")+"?BookingID="+component.get('v.caseRecord.Org_Booking_Id__c');
        var popupWindow = window.open(windowURL, "_blank");
    },
    viewBookingRedirectToDerwentPagedTME : function(component, event, helper) {
        console.log('#### comp: ' + component.get('v.caseRecord.Org_Booking_Id__c'));
        var windowURL = $A.get("$Label.c.Derwent_Booking_Page_dTME")+"?BookingID="+component.get('v.caseRecord.Org_Booking_Id__c');
        console.log('url : ' + windowURL );
        var popupWindow = window.open(windowURL, "_blank");
    },
    
    
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        var sellkptype = component.get("v.selLookupType");
        helper.searchHelper(component,event,getInputkeyWord, sellkptype);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        debugger;
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
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
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
     raiseAQuestion:function(component, event, helper) {
         var Callurl = "https://pp.uk.derwent.travelrepublic.com/CSR/CSRQuestionEditor.aspx?TaskID=809046&TaskQuestionId=0";
        // alert(Callurl);
    	//var popupWindow = window.open("pp.uk.derwent.travelrepublic.com/CSR/CSRQuestionEditor.aspx?TaskID=809046&TaskQuestionId=0", "_blank");
   		 window.open(Callurl,'popUpWindow','height=500,width=500,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no, status=yes');
	},
    
    internalCSRRedirectToDerwentPage : function(component, event, helper) {
        debugger;
        
        var caseRecord = component.get('v.caseRecord');
        var bookingId = caseRecord.Org_Booking_Id__c;
        var subj = caseRecord.Subject;
        var type = caseRecord.Type;
        var caseId = component.get("v.recordId");
        var action = component.get("c.getDerwentLookupCode");
        action.setParams({
            "typeString": type
            
        });
        action.setCallback(this, function(response) {
            debugger;            
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                var popupWindow = window.open($A.get("$Label.c.Derwent_CSR_Page") + bookingId + '&Pub=0&trackingTag=' + caseId + '&subject='+subj+ '&category='+res, "_blank");
            }else{
                var popupWindow = window.open($A.get("$Label.c.Derwent_CSR_Page") + bookingId + '&Pub=0&trackingTag=' + caseId + '&subject='+subj, "_blank");
            }
        });
        $A.enqueueAction(action);
        
    },
     publicCSRRedirectToDerwentPage : function(component, event, helper) {
        debugger;
        
        var caseRecord = component.get('v.caseRecord');
        var bookingId = caseRecord.Org_Booking_Id__c;
        var subj = caseRecord.Subject;
        var type = caseRecord.Type;
        var caseId = component.get("v.recordId");
        var action = component.get("c.getDerwentLookupCode");
        action.setParams({
            "typeString": type
            
        });
        action.setCallback(this, function(response) {
            debugger;            
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                var popupWindow = window.open($A.get("$Label.c.Derwent_CSR_Page") + bookingId + '&Pub=1&trackingTag=' + caseId + '&subject='+subj+ '&category='+res, "_blank");
            }else{
                var popupWindow = window.open($A.get("$Label.c.Derwent_CSR_Page") + bookingId + '&Pub=1&trackingTag=' + caseId + '&subject='+subj, "_blank");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    agentModeCSRRedirectToDerwentPage : function(component, event, helper) {
        debugger;
        var caseRecord = component.get('v.caseRecord');
        var bookingId = caseRecord.Org_Booking_Id__c;
         var brand = caseRecord.Org_Brand__c;
        var subj = caseRecord.Subject;
        var type = caseRecord.Type;
        var caseId = component.get("v.recordId");
        var action = component.get("c.getDerwentLookupCode");
        action.setParams({
            "typeString": type
            
        });
        action.setCallback(this, function(response) {
            debugger;            
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                if(brand == 'dnata'){
                	var popupWindow = window.open('https://www.dnata-agents.com/v2/raise_csr/'+$A.get("$Label.c.dnata_Tenant_Id")+'/' +bookingId + '?trackingTag=' + caseId + '&categoryId='+res, "_blank");
                }else{
                    var popupWindow = window.open('https://www.dnata-agents.com/v2/raise_csr/'+$A.get("$Label.c.ekh_Tenant_Id")+'/'+bookingId + '?trackingTag=' + caseId + '&categoryId='+res, "_blank");
                }
            }else{
                var popupWindow = window.open('https://www.dnata-agents.com/v2/raise_csr/2/' + bookingId + '&trackingTag=' + caseId , "_blank");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
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
    
    onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
        //do something else
        component.set("v.selLookupType", selectedSearchType);
        if(selectedSearchType == "Queue"){
            component.set("v.sendEmailNotification", false);
        }
    },
    
    onSelectChange_RT : function(component, event, helper) {
        debugger;
        //component.find("cseRT").set("v.value")
        var selectedRT = component.find("cseRT").get("v.value");
        //do something else
        component.set("v.selRecordType", selectedRT);
        //component.find("cseRT").set("v.selRecordType");
    },
    
    newQuote : function(component, event, helper) {
    	document.getElementById("newQuoteButtonId").disabled = true;
    	setTimeout(function(){document.getElementById("newQuoteButtonId").disabled = false;},3000);        
        var recId = component.get("v.recordId")
        var nights = component.get("v.caseRecord.Org_Number_of_Nights__c")
        var adults = component.get("v.caseRecord.Org_No_of_Adults_Travelling__c")
        var traveldate = component.get("v.caseRecord.Org_Departure_Date__c")
        var producttype = component.get("v.caseRecord.Org_Product_Type__c")
        var destination = component.get("v.caseRecord.Org_Destinations__c")
        var travellertype = component.get("v.caseRecord.Org_Traveller__c")
        var recordTypeName = component.get("v.caseRecord.RecordType.Name")	
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            if(destination == null){ alert('Please Enter Destination to proceed.')}
            else if(adults == null && recordTypeName != 'Duty Travel - New Enquiry'){ alert('Please Enter Number of Adults to proceed.')}
            else if(traveldate == null && recordTypeName != 'Duty Travel - New Enquiry'){ alert('Please Enter The Travel Date to proceed.')}
            else if(producttype == null && recordTypeName != 'Duty Travel - New Enquiry'){ alert('Please Enter Product Type to proceed.')}
            else if(nights == null && recordTypeName != 'Duty Travel - New Enquiry'){ alert('Please Enter Number of Nights to proceed.')}
            else if(travellertype == null && recordTypeName != 'Duty Travel - New Enquiry'){ alert('Please Enter Traveller Type to proceed.')}
                else {  
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/apex/Quotes?Id='+recId,
                        focus: true
                    });
                }
                else {
                    //confirm("This tab is not a subtab.");
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/Quotes?Id='+recId,
                        focus: true
                    });
                }
            });
            
                }
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    newBookingPage : function(component, event, helper) {
        var recId = component.get("v.recordId")
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
                        url: '/apex/NewBookingPage?Id='+recId,
                        focus: true
                    });
                }
                else {
                    //confirm("This tab is not a subtab.");
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/NewBookingPage?Id='+recId,
                        focus: true
                    });
                }
            });
            
            
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    cloneCase : function(component, event, helper) {
        
        
        var caseRecord = component.get('v.caseRecord');
        var bookingId = caseRecord.Org_Booking_Id__c;
        var subj = caseRecord.Subject;
        var type = caseRecord.Type;
        var caseId = component.get("v.recordId");
        var action = component.get("c.cloneCaseTest");
        console.log(caseId);
        action.setParams({
            "caseId": caseId
            
        });
        action.setCallback(this, function(response) {
            debugger;            
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
        /*workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/lightning/r/Case/'+res+'/view',
                        focus: true
                    });
                }
                else {
                    //confirm("This tab is not a subtab.");
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/lightning/r/Case/'+res+'/view',
                        focus: true
                    });
                }
            });
            
            
        })
        .catch(function(error) {
            console.log(error);
        });*/
            
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                            //alert('Testing tab'+sforce.console.getPrimaryTabIds(response.tabId));
                            var tabIdToUse = '';
                            if(response.isSubtab){
                                tabIdToUse = response.parentTabId
                            }else{
                                tabIdToUse = response.tabId 
                            }
                            workspaceAPI.openSubtab({
                                parentTabId: tabIdToUse,
                                recordId: res,
                                focus: true
                            }).then(function(response) {
                                setTimeout(function(){
                                    var editRecordEvent = $A.get("e.force:editRecord");
                                    editRecordEvent.setParams({
                                        "recordId": res
                                    });
                                    editRecordEvent.fire();
                                }, 500);
                            });                    
                        })
                        .catch(function(error) {
                            console.log(error); 
                        });
                
                
                
                
            }else{
             	alert("failure")   
            }
        });
        $A.enqueueAction(action);
        
    },
    
    onTabRefreshed : function(component, event, helper) {
        debugger;
        
        setTimeout(function(){
            try{
                var refreshedTabId = event.getParam("tabId");
                var workspaceAPI = component.find("workspace");
                var caseRecord = component.get('v.caseRecord');
                var status = caseRecord.Org_Case_Status__c;
                var brand = caseRecord.Org_Brand__c;
                if(status == 'Closed' && brand != 'rehlaty' && brand != 'EKH'){ // Added on Nov 14,2018 - disabling tab auto-closure for rehlaty
                    //workspaceAPI.closeTab({tabId: refreshedTabId}); //Commented out on Dec 12,2018 - to prevent tab closing issue 
                } 
            }catch(err) {
                console.log('@@@@ err: ' + err); 
            }

        }, 1000);
    },
    onTabFocused : function(component, event, helper) {
        console.log("Tab Focused");
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");     
        var caseRecord = component.get('v.caseRecord');
        var openedInDanube = component.get("v.caseRecord.Opened_In_Danube__c");
         },
    
     doneRendering: function(cmp, event, helper) {
        if(!cmp.get("v.isDoneRendering")){
           
          cmp.set("v.isDoneRendering", true);
          console.log('finished rendering');
             
           
        }
      },
    onCheck: function(cmp, evt) {
		 var checkCmp = cmp.find("checkbox");
		 cmp.set('v.sendEmailNotification',checkCmp.get("v.value"));
	 },
    PoCClick : function(component,event,helper) {
        var action = component.get("c.fetchMessagingTemplate");    
        var caseId = component.get("v.recordId");
        console.log(caseId);
        action.setParams({
            "caseId": caseId   
        });
        action.setCallback(this, function(response) {
            debugger;            
            if (response.getState() == "SUCCESS") {
                var custs = [];
                var res = response.getReturnValue();
                var none = "";
                custs.push(none);
                for(var key in res){
                    custs.push({value:key, key:res[key]});
                }
                console.log('custs');
                console.log(custs);
                component.set('v.templateOptions',custs);
               
                component.set('v.openNotifModal','true');
            }else{
                console.log('');
            }
        });
        $A.enqueueAction(action);
       
    },
    closePoCClick : function(component,event,helper) {
        component.set('v.templateBody','');
       component.set('v.openNotifModal','false');
    },
    setTemplateName: function(component,event,helper){
        component.set('v.selectedTemplate',component.find('templates').get('v.value'));
        var action = component.get('c.getTemplateBody');
         action.setParams({
            "templateName": component.find('templates').get('v.value')           
        });
        action.setCallback(this, function(response) {
            console.log(response);
            debugger;            
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                console.log('template body');
                console.log(res);
                component.set('v.templateBody',res);
            }
        });
        $A.enqueueAction(action);
    },
    sendNotification: function(component,event,helper){
        var r = confirm("You cannot revert this action. Proceed ?");
        if(r == true){
            component.set('v.openNotifModal','false');
            component.set('v.isSendingNotif','true');
            var action = component.get('c.updateTemplateOnCase');
            var caseId = component.get("v.recordId");
             action.setParams({
                "templateName": component.find('templates').get('v.value'),
                 "caseId":caseId
            });
            action.setCallback(this, function(response) {
                console.log(response);
                debugger;            
                if (response.getState() == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Messaging Notification has been sent successfully',               
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success'
                            
                        });
                        toastEvent.fire();   
                    component.set('v.templateBody','');
                    
                    component.set('v.isSendingNotif','false');
                }else{
                    component.set('v.isSendingNotif','false');
                }
            });
            $A.enqueueAction(action);
        }
    },
    markCCPendingTrue: function(component,event,helper){     
            var action = component.get('c.markCCPTrue');
            var caseId = component.get("v.recordId");
             action.setParams({                
                 "caseid":caseId
            });
            action.setCallback(this, function(response) {
                console.log(response);
                debugger;            
                if (response.getState() == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Success',               
                            duration:'2000',
                            key: 'info_alt',
                            type: 'success'
                            
                        });
                        toastEvent.fire();   
                }
            });
            $A.enqueueAction(action);
        },
        sendEnquiryForm : function(component, event, helper) {
            var resultVal = confirm("This will send the Groups Enquiry form to customer");
            console.log(resultVal);
            if(resultVal == true){
                var action = component.get('c.updateGroupsEnquiryEmailSent');
                var caseId = component.get("v.recordId");
                 action.setParams({                
                     "caseId":caseId
                });
                action.setCallback(this, function(response) {
                    console.log(response);
                    debugger;            
                    if (response.getState() == "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Groups Enquiry Form link sent to customer',               
                                duration:'2000',
                                key: 'info_alt',
                                type: 'success'
                                
                            });
                            toastEvent.fire();   
                    }
                });
                $A.enqueueAction(action);
           }
           $A.get('e.force:refreshView').fire();
        },
        goToGroupsEnquiryForm : function(component, event, helper) {
            debugger;
            var caseId = component.get("v.caseRecord.Id");
            var caseBrand = component.get("v.caseRecord.Org_Brand__c");
            var caseOrigin = component.get("v.caseRecord.Origin");
            var caseDomainId = component.get("v.caseRecord.Customer_DomainId_On_Account__c");
            window.open($A.get("$Label.c.EKH_Groups_Enquiry_Site") + '?brand=' + caseBrand.toLowerCase() + '&reqOrigin=' + caseOrigin + '&domainId=' + caseDomainId + '&caseId=' + caseId, "_blank");
        }  
})