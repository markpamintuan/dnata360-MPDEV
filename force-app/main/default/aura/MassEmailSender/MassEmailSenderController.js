({	
    doInit: function(component,event,helper){
       
        var action = component.get("c.fetchReports");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    
                    lables.push({"label":key.Name ,"value":key.Name	});
                });
                component.set("v.reportList", lables);
               
            }else if (state === "INCOMPLETE") {
                alert("Didnt Work");
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
            
        })      
        $A.enqueueAction(action);
        
        var secondaction = component.get("c.getEmailFolder");
        
        secondaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {                   
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                
                //component.set('v.optionsvalue','Attractions - trp');
                console.log('value');	
                component.set("v.options", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(secondaction); 
        
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
    
    handleChange: function(component,event,helper){
        component.set('v.IsSpinner',true);
        helper.getReportResponse(component);
        
        var reportName = component.get('v.reportName');
        var filters = component.find("fetchFilters");
        var useReport = component.find("useReport");
        var openReport = component.find("checkReport");
        var action = component.get("c.getReportFilters");     
	    action.setParams({ 
	        "reportName": reportName            
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.filterVisibility',true);
                var resp = response.getReturnValue();
                console.log('resp' + JSON.stringify(response.getReturnValue()));
                component.set('v.filters',resp);
                component.set('v.IsSpinner',false)
            }else if (state === "INCOMPLETE") {
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
        /*var action = component.get("c.getReportRecords");
        action.setParams({ ReportName : "ItineraryDetails" });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                //console.log('response to this is '+ response.getReturnValue());                
                component.set("v.bookingRecords",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                alert("Didnt Work");
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
        $A.enqueueAction(action);*/
    },
    handlefolderChange_r : function(component,event,helper) {
        var folderField = component.find('folder_r');
        var folder = folderField.get('v.value');
      	component.set('v.CSRFolder',folder);
        
        var action = component.get("c.getEmails");
        action.setParams({ 
            "foldername":folder
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var templateField = component.find("template_r");
                templateField.set('v.disabled',false);
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    console.log('developername ' + key.DeveloperName); 
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.templateoptions", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(action);
        
        
    },
    handletemplatechange_r:function(component,event,helper){
        var templateField = component.find('template_r');
        var template = templateField.get('v.value');
      	component.set('v.CSRTemplate',template);
        console.log(template);
        
       var action = component.get("c.getEmailContents");
	    action.setParams({ 
            "templatename":template
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                var descriptionfield = component.find('tempText_r');
                
                descriptionfield.set('v.value',resp);
            }
            
        })
        
        $A.enqueueAction(action);
    },
    handlefolderChange_m : function(component,event,helper) {
        var folderField = component.find('folder_m');
        var folder = folderField.get('v.value');
      	component.set('v.CSRFolder',folder);
        
        var action = component.get("c.getEmails");
        action.setParams({ 
            "foldername":folder
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var templateField = component.find("template_m");
                templateField.set('v.disabled',false);
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    console.log('developername ' + key.DeveloperName); 
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.templateoptions", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(action);
        
        
    },
    handletemplatechange_m:function(component,event,helper){
        var templateField = component.find('template_m');
        var template = templateField.get('v.value');
      	component.set('v.CSRTemplate',template);
        console.log(template);
        
       var action = component.get("c.getEmailContents");
	    action.setParams({ 
            "templatename":template
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                var descriptionfield = component.find('tempText_m');
                descriptionfield.set('v.value',resp);
            }
            
        })
        
        $A.enqueueAction(action);
    },
	sendEmail : function(component, event, helper) {
        var action = component.get("c.sendMassEmail");
        var reportName = component.get("v.reportName");
        action.setParams({ ReportName : reportName });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {            
                alert("Emails Sent Successfully.");
            }
            else if (state === "INCOMPLETE") {
                alert("Didnt Work");
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
	},
    
    
	createCase : function(component, event, helper) {
        if(component.get('v.manualentry') == '0'){
            helper.showSpinner(component);
        
            
            if(component.get('v.recordtypename') == 'Travel Republic - Service Request'){
                var descriptionField = component.find("description_r");
                 description =  descriptionField.get("v.value");
                 var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                 description = appendName + description;
        }else{
            var descriptionField = component.find("description_internal_r");
                 description =  descriptionField.get("v.value");
        }
            
           
            
            
            
    
            var categoryfield = component.find("category_r");
            var category = categoryfield.get("v.value");
            
            var statusfield = component.find("status_r");
            var status = categoryfield.get("v.value");
            
            var seluserorqueue = component.get("v.selectedRecord.rid");
            console.log(seluserorqueue);
            
            //var publicField = component.find("ispublic");
            //var ispublic = publicField.get("v.value");
            
            var templateField = component.find('template_r');
            var folderField = component.find('folder_r');
         	var recordTypeLabel = component.find("selectid_r").get("v.value");
            var action = component.get("c.saveCase");
            
            var subject = '';
            if(component.get('v.newCaseSubject') != ''){
                subject = component.get('v.newCaseSubject');
            }
            console.log('new');
            console.log(fileContents);
            
              var fileInput = component.find("fuploader").get("v.files");
            var file = fileInput[0];
            var self = this;
            var objFileReader = new FileReader();
            var fileContents;
            objFileReader.onload = $A.getCallback(function() {
                fileContents = objFileReader.result;
                
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                console.log('File Contents');
                console.log(fileContents);
                
                 action.setParams({ 
                "description": description,
                "category":category,
                
                "seluserorqueue":seluserorqueue,
                "recordtypename":recordTypeLabel,
                "status":status,
                
                "subject":subject,
                "SendSMS":component.get('v.SendSMS'),
                "fileContents":encodeURIComponent(fileContents)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                helper.hideSpinner(component);
                if (state === "SUCCESS") {
               	if(component.get('v.recordtypename') == 'Travel Republic - Service Request'){
                    descriptionField.set('v.value','');
                }
                    categoryfield.set('v.value','');
                    //publicField.set('v.value','');
                    
                   
                    var TRrecordID = response.getReturnValue();
                    console.log(TRrecordID);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message:" The process is initiated. You will be notified once cases are created succesfully.",
                        type: "success"
                    });
                    toastEvent.fire();
                    location.reload();
                  
                }
                else if (state === "INCOMPLETE") {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: response,
                            type: "error",
                             mode: 'sticky'
                        });
                        toastEvent.fire();
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: "The following error occured :" + errors[0].message + " No Service Requests have been created" ,
                            type: "error"
                        });
                        toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
                
            });
             //objFileReader.readAsDataURL(file);
            objFileReader.readAsText(file);
            
           
            console.log('End of createCase');
        }else{
            
            helper.showSpinner(component); 
    	
		var suppliers =  component.get("v.SupplierList");
            var description = '';
        if(component.get('v.recordtypename') == 'Travel Republic - Service Request'){
                var descriptionField = component.find("description_m");
                 description =  descriptionField.get("v.value");
            var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                 description = appendName + description;
        }else{
            var descriptionField = component.find("description_internal_m");
                 description =  descriptionField.get("v.value");
             
        }
            
        var subject = '';
            if(component.get('v.newCaseSubject') != ''){
                subject = component.get('v.newCaseSubject');
            }
            
        var categoryfield = component.find("category_m");
        var category = categoryfield.get("v.value");
        
        //var publicField = component.find("ispublic");
        //var ispublic = publicField.get("v.value");
        
        var templateField = component.find('template_m');
        var folderField = component.find('folder_m');
     
        var action = component.get("c.saveCaseManual");
        var seluserorqueue = component.get("v.selectedRecord.rid");
            
            var recordTypeLabel = component.find("selectid_m").get("v.value");
            var statusfield = component.find("status_m");
            var status = categoryfield.get("v.value");
	    action.setParams({ 
	        "description": description,
            "category":category,
            //"ispublic":ispublic,
            "BookingIdList":suppliers,
            "seluserorqueue":seluserorqueue,
            "recordtypename":recordTypeLabel,
            "status":status,
            "subject":subject,
            "sendSMS":component.get('v.SendSMS')
	    });
	    action.setCallback(this, function(response) {
            var state = response.getState();
            helper.hideSpinner(component);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp.indexOf('Success') == -1){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                            title: "Error!",
                            message: "The following Booking Ids were not found " + resp + ".\nNo Service Request will be created until these Ids are resolved.",
                            type: "error",
                            duration:"15000"
                        });
                        toastEvent.fire();
                    }else{
                // var count = resp.replace('Success','');
                
               
                //var TRrecordID = response.getReturnValue();
                //console.log(TRrecordID);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "The process is initiated. You will be notified once cases are created succesfully",
                    type: "success"
                });
                toastEvent.fire();
                        
              location.reload();
                    }
                /*var workspaceAPI = component.find("workspace");
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
            });*/
            }
            else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: response,
                    type: "error"
                });
                toastEvent.fire();
                console.log(response);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: "The following error occured :" + errors[0].message + " No Service Requests have been created" ,
                            type: "error"
                        });
                        toastEvent.fire();
                            }
                } else {
                    console.log("Unknown error");
                }
            }
        });
	    $A.enqueueAction(action);
		console.log('End of createCase');
        }
		
	},
    setReports: function(component,event,helper){
        component.set('v.option','0');
        var booking = document.getElementsByClassName("bookingList");
        var supplier = document.getElementsByClassName("supplierList");
        //var container= document.getElementsByClassName("container");
        var manualButton = component.find('entry_22');
        var reportButton = component.find('reports_11');
        component.set('v.manualentry','0');
        //container[0].style.display = 'block';
        booking[0].style.display = 'block';
        supplier[0].style.display = 'none';
        $A.util.addClass(reportButton, 'colorBlue');
        $A.util.removeClass(manualButton, 'colorBlue');
        var isClicked = $A.util.hasClass(manualButton, "slds-button_inverse");
        if(!isClicked){
        	$A.util.toggleClass(manualButton, 'slds-button_inverse');
            var isClicked2 = $A.util.hasClass(reportButton, "slds-button_inverse");
            if(isClicked2){
            $A.util.toggleClass(reportButton, 'slds-button_inverse');
            }
        }
        
        
        
    },
    setManual: function(component,event,helper){
        component.set('v.option','1');
        var booking = document.getElementsByClassName("bookingList");
        var supplier = document.getElementsByClassName("supplierList");
        //var container= document.getElementsByClassName("container");
        var reportButton = component.find('reports_11');
        var manualButton = component.find('entry_22');
        component.set('v.manualentry','1');
        //container[0].style.display = 'block';
        booking[0].style.display = 'none';
        supplier[0].style.display = 'block';
        $A.util.addClass(manualButton, 'colorBlue');
        $A.util.removeClass(reportButton, 'colorBlue');
        var isClicked = $A.util.hasClass(reportButton, "slds-button_inverse");
        if(!isClicked){
            $A.util.toggleClass(reportButton, 'slds-button_inverse');
            var isClicked2 = $A.util.hasClass(manualButton, "slds-button_inverse");
            if(isClicked2){
        	$A.util.toggleClass(manualButton, 'slds-button_inverse');
            }
        }
    },
    openReport : function(component, event, helper) { 
        var workspaceAPI = component.find("workspace");    
        var reportName = component.get('v.reportName');
        var action = component.get("c.getReportID");    
        var filters = component.get('v.filters');
	    action.setParams({ 
	        "reportName": reportName            
	    });
	    action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                var filterslength = filters.length;
                var urladd = '?';
                for(var i = 0 ; i < filterslength;i++){
                    urladd = urladd + 'fv' + i + '=' + filters[i].value;
                    urladd += '&';
                }
        		workspaceAPI.openTab({
                    url: '/one/one.app#/sObject/'+ resp +'/view' + urladd,
                    focus: true
                });
            }else if (state === "INCOMPLETE") {
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
       
       
    },   
    getNewReportResponseController:function(component,event,helper){ 
        helper.showSpinner(component);
        helper.getNewReportResponse(component);
    },
    useReport : function(component,event,helper){
        var action = component.get("c.fetchRecordTypeValues");
          action.setCallback(this, function(response) {
             component.set("v.lstOfRecordType", response.getReturnValue());
          });
          $A.enqueueAction(action);
        component.set('v.reportSet',true);
        
        
    },
    checkbookings : function(component,event,helper){
        var action = component.get("c.checkBookingIdList");    
        var suppliers =  component.get("v.SupplierList");
        if(suppliers == '' || suppliers == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                            title: "Error!",
                            message: "Booking Id Search Box is Empty",
                            type: "error",
                            duration:"3000"
                        });
                        toastEvent.fire();
        }else{
	    action.setParams({ 
	        "BookingIdList":suppliers         
	    });
	    action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp.indexOf('Success') == -1){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                            title: "Error!",
                            message: "The following Booking Ids were not found " + resp + ".\nNo Service Request will be created until these Ids are resolved.",
                            type: "error",
                            duration:"15000"
                        });
                        toastEvent.fire();
                    }else{
                        var action = component.get("c.fetchRecordTypeValues");
                          action.setCallback(this, function(response) {
                             component.set("v.lstOfRecordType", response.getReturnValue());
                          });
                          $A.enqueueAction(action);
                        component.set('v.validBookings',true);
                        
                       
                    }
            }else if (state === "INCOMPLETE") {
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
        }
    },
    resetFilters: function(component,event,helper){
        component.set('v.IsSpinner',true);
        component.set('v.hasFilters',false);
        helper.getReportResponse(component);
        
        var reportName = component.get('v.reportName');
        var filters = component.find("fetchFilters");
        var useReport = component.find("useReport");
        var openReport = component.find("checkReport");
        var action = component.get("c.getReportFilters");     
	    action.setParams({ 
	        "reportName": reportName            
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.filterVisibility',true);
                var resp = response.getReturnValue();
                console.log('resp' + JSON.stringify(response.getReturnValue()));
                component.set('v.filters',resp);
                component.set('v.IsSpinner',false)
            }else if (state === "INCOMPLETE") {
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
    },
    reset:function(component,event,helper){
        $A.get('e.force:refreshView').fire();
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
    onblur_m : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes_m");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onSelectChange_m : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype_m").get("v.value");
        //do something else
        component.set("v.selLookupType", selectedSearchType);
    },
    keyPressController_m : function(component, event, helper) {
        debugger;
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes_m");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var sellkptype = component.get("v.selLookupType");
            helper.searchHelper(component,event,getInputkeyWord,sellkptype);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes_m");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    handleComponentEvent_m : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill_m");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes_m");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField_m");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
    clear_m :function(component,event,helper){
        var pillTarget = component.find("lookup-pill_m");
        var lookUpTarget = component.find("lookupField_m"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    handleRecordTypeChange: function(component,event,helper){
        component.set("v.recordtypeset",'true');
        component.set('v.recordtypename',component.find('selectid_r').get('v.value'));
        if(component.get('v.recordtypename') == 'Travel Republic - Service Request'){
        	component.set('v.displayDescription__r',true);
            component.set('v.recordtypeid','0122X000000oqlUQAQ');
        }else{
            	component.set('v.displayDescription__r',false);	
            component.set('v.recordtypeid','0122X000000oqleQAA');
        }
        var resetFilters = component.find("resetFilters");
        var useReport = component.find("useReport");
        var openReport = component.find("checkReport");
        var name = component.find("name");
        try{useReport.set('v.disabled','true');}catch(err){console.log(err);}
        try{openReport.set('v.disabled','true');}catch(err){console.log(err);}
        try{
        //resetFilters.set('v.disabled','true');
        }catch(err){
            console.log(err);
        }
        try{name.set('v.disabled','true');}catch(err){console.log(err);}
    },
    handleRecordTypeChange_m: function(component,event,helper){
        component.set("v.recordtypeset_m",'true');
      
        component.set('v.recordtypename',component.find('selectid_m').get('v.value'));
         console.log(component.get('v.recordtypename'));
        if(component.get('v.recordtypename') == 'Travel Republic - Service Request'){
        	component.set('v.displayDescription',true);				
            component.set('v.recordtypeid','0122X000000oqlUQAQ');
        }else{
            	component.set('v.displayDescription',false);	
            component.set('v.recordtypeid','0122X000000oqleQAA');
        }
         var checkbookings = component.find('usebookings_1');
                        var suppliers = component.find('suppliers');
                        suppliers.set('v.disabled',true);
                        checkbookings.set('v.disabled',true);
                        
    },
    openModal_m: function(component,event,helper){
        component.set('v.isManualOpen',true);
    },
    saveText_m: function(component,event,helper){
       
        component.find('description_m').set('v.value',component.get('v.textMessage_m'));
        component.set("v.isManualOpen", false);
        
    },
     moveBack_m : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep_m'),10);
        v = v - 1;
        component.set('v.currentStep_m',v.toString());
    },
    moveNext_m : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep_m'),10);
        if(v == 0){
            helper.stepOneNext_m(component,event,helper);
        }else if(v == 1){
            helper.stepSecondNext_m(component,event,helper);
        }else{
            v = v + 1;   
            component.set('v.currentStep_m',v.toString());
        }
    },
    closeModal_m: function(component,event,helper){
        component.set('v.isManualOpen',false);
    },
     openModal_r: function(component,event,helper){
        component.set('v.isReportOpen',true);
    },
    saveText_r: function(component,event,helper){
       
        component.find('description_r').set('v.value',component.get('v.textMessage_r'));
        component.set("v.isReportOpen", false);
        
    },
     moveBack_r : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep_r'),10);
        v = v - 1;
        component.set('v.currentStep_r',v.toString());
    },
    moveNext_r : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep_r'),10);
        if(v == 0){
            helper.stepOneNext_r(component,event,helper);
        }else if(v == 1){
            helper.stepSecondNext_r(component,event,helper);
        }else{
            v = v + 1;   
            component.set('v.currentStep_r',v.toString());
        }
    },
    closeModal_r: function(component,event,helper){
        component.set('v.isReportOpen',false);
    },
    onblur2_m : function(component,event,helper){       
        component.set("v.listOfSearchRecords2", null );
        var forclose = component.find("searchRes2_m");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
keyPressController2_m : function(component, event, helper) {
        
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.newCaseSubject");
        debugger;
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes2_m");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
           
            helper.searchHelper2(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords2", null ); 
            var forclose = component.find("searchRes2_m");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

clear2_m :function(component,event,helper){
        
        var lookUpTarget = component.find("lookupField_m"); 
        
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    onblur2_r : function(component,event,helper){       
        component.set("v.listOfSearchRecords2", null );
        var forclose = component.find("searchRes2_r");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
keyPressController2_r : function(component, event, helper) {
        
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.newCaseSubject");
        debugger;
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes2_r");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
           
            helper.searchHelper2(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords2", null ); 
            var forclose = component.find("searchRes2_r");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
clear2_r :function(component,event,helper){
        
        var lookUpTarget = component.find("lookupField_r"); 
        
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    handleComponentEvent2 : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("stringEvent");
        console.log('selectedAccountGetFromEvent ' + selectedAccountGetFromEvent);
        component.set("v.newCaseSubject" , selectedAccountGetFromEvent); 
        
        if(component.get('v.option') == '1'){
            var forclose = component.find("searchRes2_m");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
    	}else{
            var forclose = component.find("searchRes2_r");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
		}
        /*
        var lookUpTarget = component.find("lookupField2");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        */
    },
    handleCheckTask: function(component,evt,helper){
         var checkbox = evt.getSource();
        console.log(checkbox.get("v.value"));
        component.set('v.SendSMS',checkbox.get('v.value'));
    },
    handleFilesChange : function(component, event, helper) {
        debugger;
        helper.uploadHelper(component, event);
        /*var files = event.getSource().get("v.files");
        console.log('number of files :: '+files.length);
        console.log('files : '+files[0].name);
        console.log('files type : '+files[0].type);
        //console.log('files size : '+blobToString(files[0].size));
        component.set("v.blobData", files[0]);
        console.log("blob : "+component.get("v.blobData"));
        component.set("v.fileName", files[0].name);
        component.set("v.fileType", files[0].type);
        console.log(files);
        
        
        
        helper.sendFileToController(component, event, helper);*/
        
        /*var reader = new FileReader();
        reader.readAsDataURL(files[0]); 
        reader.onloadend = function() {
             base64data = reader.result;                
            console.log("base64data :::: "+base64data);
            
        }
        console.log("base64data 222 :::: "+base64data);
        component.set("v.base64Data", base64data);
            console.log("data set ");*/
    },
    
    /*handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },*/
    
    handleSave: function(component, event, helper) {
        if (component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    setSubject: function(component,event,helper){
        component.set('v.newCaseSubject',component.get('v.newCase.Category__c'));
    }
    
    
    

})