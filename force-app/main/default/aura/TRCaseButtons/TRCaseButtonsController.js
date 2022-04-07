({
	
        recordUpdated : function(component, event, helper) {
            debugger;
        console.log('records updated');
        console.log(component.get('v.caseRecordTR.IsParentCase__c'));
        helper.recordUpdated(component, event, helper);
        
    },
    
     viewBookingInDerwent : function(component, event, helper) {
        console.log('#### comp: ' + component.get('v.caseRecordTR.Org_Booking_Id__c'));
        var windowURL = $A.get("$Label.c.Derwent_Booking_Page_trp")+"?BookingID="+component.get('v.caseRecordTR.Org_Booking_Id__c');
        var popupWindow = window.open(windowURL, "_blank");
    },
    
     //Travel Republic Redirect
    redirectToExtPageADTForTR : function(component, event, helper) {
        debugger;
        var cid = component.get("v.recordId");
         console.log(' ### cid: ' + cid);
        var derwentCustomerId = component.get("v.caseRecordTR.Org_Derwent_Customer_No__c");
        console.log(' ### derwentCustomerId: ' + derwentCustomerId);
        
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
        
    },
     newQuote : function(component, event, helper) {
        var recId = component.get("v.recordId")
        var nights = component.get("v.caseRecordTR.Org_Number_of_Nights__c")
        var adults = component.get("v.caseRecordTR.Org_No_of_Adults_Travelling__c")
        var traveldate = component.get("v.caseRecordTR.Org_Departure_Date__c")
        var producttype = component.get("v.caseRecordTR.Org_Product_Type__c")
        var destination = component.get("v.caseRecordTR.Org_Destinations__c")
        var travellertype = component.get("v.caseRecordTR.Org_Traveller__c")
        var recordTypeName = component.get("v.caseRecordTR.RecordType.Name")	
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
 
      openModal: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
          component.set("v.isOpen", true);
          component.set("v.isPuP",false);
          var booking  = component.get('v.caseRecordTR.Org_Booking_Id__c');
          var subj = 'Please contact us regarding your recent booking request';
          var message = 'Dear customer, Please advise how you would like to proceed so that we can process your booking request accordingly. Kind Regards, Specialist Sales Team '
          component.set('v.subject',subj);
          component.set('v.TempText',message);
      
   },
     openModalPuP: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
          component.set("v.isOpen", true);
          component.set("v.isNAVL",false);
          var booking  = component.get('v.caseRecordTR.Org_Booking_Id__c');
          var subj = 'Please contact us regarding your recent booking request'
          var message = 'Dear customer, Please advise how you would like to proceed so that we can process your booking request accordingly. Kind Regards, Specialist Sales Team'
          component.set('v.subject',subj);
          component.set('v.TempText',message);
      
   },
    
    closeModal: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
    changeRecordType:function(component, event, helper) {
        var action = component.get("c.updateCaseRecordType");
        var seluserorqueue = component.get("v.selectedRecord.rid"); 
         var caseOwner = component.find("caseOwner").get("v.value");
         if (caseOwner == '' || caseOwner == null){   
            var message = 'This field is required.';	
             component.set("v.errorMessage",message);
             console.log(component.set("v.errorMessage",message));
        	 component.set('v.showspinner',false);
        }
        else{
            action.setParams({
                "caseRec": component.get("v.caseRecordTR"),
                "isPuP":component.get("v.isPuP"),
                "TempText":component.get("v.TempText"),
                "seluserorqueue":seluserorqueue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == "SUCCESS"){
                    var c = response.getReturnValue();
                    console.log(c);
                    component.set("v.caseRecordTR", c);
                    var isPuP = component.get('v.isPuP');
                    if(isPuP){
                        setTimeout(function(){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Message',
                                message: 'Case converted to PuP',               
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }, 1000);
                    }
                    else
                    {
                        setTimeout(function(){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Message',
                                message: 'Case converted to NAVL',               
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }, 1000);
                    }
                    
                    
                }
                else {
                    console.log('There was a problem : '+response.getError());
                }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
       component.set("v.isOpen", false);
         
        }    
          
    },
   	createInternalRequest : function(component,event,helper) {
              
        var caseRecord = component.get('v.caseRecordTR');
        var recordType = component.get('v.caserecordTR.RecordType.Name');
        
        var bookingId = component.get('v.caserecordTR.Org_Booking__c');
        var subj = caseRecord.Subject;
        var type = caseRecord.Type;
        var caseId = component.get("v.recordId");
        var action = component.get("c.getRecordTypeId");
        var recID = component.get('v.caseRecordTR.RecordType.Id');
        var parentCaseNumber = component.get("v.caseRecordTR.CaseNumber");
            console.log('parentCaseNumber '+parentCaseNumber);
        console.log('booking Id'+bookingId);
        console.log(recID);
            action.setParams({
            "recordTypeName": 'Travel Republic - Internal Request'           
        });
        var TRrecordID = '';
        action.setCallback(this, function(response) {          
            if (response.getState() == "SUCCESS") {
                var TRrecordID = response.getReturnValue();
                console.log('record id '+TRrecordID);
                var createAcountContactEvent = $A.get("e.force:createRecord");
                createAcountContactEvent.setParams({
                    "entityApiName": "Case",
                    'recordTypeId' : TRrecordID,
                    "defaultFieldValues": {
                        'ParentId' : component.get('v.caseRecordTR.Id'),
                        'ContactId' : component.get('v.caseRecordTR.ContactId'),
                        'Org_Booking__c':component.get('v.caseRecordTR.Org_Booking__c'),
                        'Subject'   : 'Internal request for - '+ parentCaseNumber,
                        'Description' : component.get('v.caseRecordTR.Description')
                        
                    }
                });
                 createAcountContactEvent.fire();
            }else{
                alert(response.getState());
            }
        });
        

        $A.enqueueAction(action);
        
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
    
    
})