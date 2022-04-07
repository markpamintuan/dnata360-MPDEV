({
    closeModal: function(component, event, helper) {
      component.set("v.isOpen", false); 
   }, 
   openModal: function(component, event, helper) {
      component.set("v.buttonId", event.target.id); 
      component.set("v.isOpen", true);
   },
    doInit: function(component, event, helper) {
        helper.checkCaseOwnerForAccept(component, event, helper);
        helper.displayBookingButton(component, event, helper);       
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        var recId = component.get("v.recordId");
        var getSobjType = component.get("c.getSobjectType");
        getSobjType.setParams({
            "objId": recId
        });
        
        getSobjType.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.objectType", storeResponse);
            }
        });
        
        $A.enqueueAction(getSobjType);
        
        var getSobjRecord = component.get("c.getObjectRecord");
        getSobjRecord.setParams({
            "objId": recId
        });
        
        getSobjRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.obj", storeResponse);
            }
        });
        
        $A.enqueueAction(getSobjRecord);
        
        
        //fetch case complaint recordtypes
          var actionComplaint = component.get("c.fetchCaseComplaintRecordTypeValues"); 
          actionComplaint.setCallback(this, function(response) {
             component.set("v.lstOfCaseComplaintRecordType", response.getReturnValue());
          });
          $A.enqueueAction(actionComplaint);
        var actionCommendation = component.get("c.fetchCaseCommendationRecordTypeValues");
          actionCommendation.setCallback(this, function(response) {
             component.set("v.lstOfCaseCommendationRecordType", response.getReturnValue());
          });
          $A.enqueueAction(actionCommendation);
        var actionGeneralEnquiry = component.get("c.fetchCaseGeneralEnquirytRecordTypeValues"); 
          actionGeneralEnquiry.setCallback(this, function(response) {
             component.set("v.lstOfCaseGeneralEnquiryRecordType", response.getReturnValue());
          });
          $A.enqueueAction(actionGeneralEnquiry);
    },
    cownerchange : function(component, event, helper) {
        var resultVal = confirm("Please click OK to proceed");
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
    openReassignOwnerModal: function(component, event, helper) {
        component.set("v.selLookupType", "Queue"); // default
        component.set("v.isCaseRTChangeBoxOpen", true);
    },
    closeChangeRTModal: function(component, event, helper) {
        component.set("v.isCaseRTChangeBoxOpen", false);        
    },
    onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
        //do something else
        component.set("v.selLookupType", selectedSearchType);
        //if(selectedSearchType == "Queue"){
            //component.set("v.sendEmailNotification", false);
        //}
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
        var getInputkeyWord = component.get("v.SearchKeyWord");
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
    
    
    
    newQuote : function(component, event, helper) {
        var recId = component.get("v.recordId")
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {          
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (!response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/apex/NewQuoteCC?Id='+recId,
                        focus: true
                    }).then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "New Quote"
                        });
                    });
                }
                else {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/NewQuoteCC?Id='+recId,
                        focus: true
                    }).then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "New Quote"
                        });
                    });
                }
            });
            
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
                if (!response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/apex/NewBookingCC?Id='+recId,
                        focus: true
                    }).then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "New Booking"
                        });
                    });
                }
                else {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/NewBookingCC?Id='+recId,
                        focus: true
                    }).then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "New Booking"
                        });
                    });
                }
            });
            
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    viewBookingConfirmation : function(component, event, helper) {
        var recId = component.get("v.recordId")
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (!response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/apex/NewBookingPDFCC?oId='+recId,
                        focus: true
                    })                    
                    .then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "Booking Confirmation"
                        });
                    });
                } else {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/NewBookingPDFCC?oId='+recId,
                        focus: true
                    })
                    .then(function(tabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "Booking Confirmation"
                        });
                    });
                }
            });
            
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    viewQuotePDF : function(component, event, helper) {
        var recId = component.get("v.recordId")
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
            
            workspaceAPI.isSubtab({
                tabId: tabId
            }).then(function(response) {
                if (!response) {
                    //confirm("This tab is a subtab.");
                    workspaceAPI.openTab({
                        //parentTabId: tabId,
                        url: '/apex/NewQuotePDFCC?qId='+recId,
                        focus: true
                    })                    
                    .then(function(subTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "Quote View"
                        });
                    });
                } else {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: '/apex/NewQuotePDFCC?qId='+recId,
                        focus: true
                    })
                    .then(function(tabId) {
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "Quote View"
                        });
                    });
                }
            });
            
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    updateBookingPage : function(component, event, helper) {
        
        
        var recId = component.get("v.recordId")     
        var getParentCase = component.get("c.getParentId");
        getParentCase.setParams({
            "objId": recId
        });        
        getParentCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    workspaceAPI.isSubtab({
                        tabId: tabId
                    }).then(function(response) {
                        if (!response) {
                            workspaceAPI.openTab({
                                //parentTabId: tabId,
                                url: '/apex/NewBookingCC?id='+storeResponse+'&oId='+recId,
                                focus: true
                            });
                        }
                        else {
                            workspaceAPI.openSubtab({
                                parentTabId: tabId,
                                url: '/apex/NewBookingCC?id='+storeResponse+'&oId='+recId,
                                focus: true
                            });
                        }
                    });
                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
        
        $A.enqueueAction(getParentCase);
        
    },
    
    updateQuotePage : function(component, event, helper) {
        
        
        var recId = component.get("v.recordId")     
        var getParentCase = component.get("c.getParentIdFromQuote");
        getParentCase.setParams({
            "objId": recId
        });        
        getParentCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    workspaceAPI.isSubtab({
                        tabId: tabId
                    }).then(function(response) {
                        if (!response) {
                            workspaceAPI.openTab({
                                //parentTabId: tabId,
                                url: '/apex/NewQuoteCC?id='+storeResponse+'&qId='+recId,
                                focus: true
                            });
                        }
                        else {
                            workspaceAPI.openSubtab({
                                parentTabId: tabId,
                                url: '/apex/NewQuoteCC?id='+storeResponse+'&qId='+recId,
                                focus: true
                            });
                        }
                    });
                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
        
        $A.enqueueAction(getParentCase);
        
    },
    
    convertQuoteToBooking : function(component, event, helper) {
        
        
        var recId = component.get("v.recordId")     
        var getParentCase = component.get("c.getParentIdFromQuote");
        getParentCase.setParams({
            "objId": recId
        });        
        getParentCase.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    workspaceAPI.isSubtab({
                        tabId: tabId
                    }).then(function(response) {
                        if (!response) {
                            workspaceAPI.openTab({
                                //parentTabId: tabId,
                                url: '/apex/NewBookingCC?id='+storeResponse+'&qId='+recId,
                                focus: true
                            });
                        }
                        else {
                            workspaceAPI.openSubtab({
                                parentTabId: tabId,
                                url: '/apex/NewBookingCC?id='+storeResponse+'&qId='+recId,
                                focus: true
                            });
                        }
                    });
                    
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
        
        $A.enqueueAction(getParentCase);
        
    },
    
    
    
    
    
    
    newAfterSales : function(component, event, helper) {
        
        var recId = component.get("v.recordId");   
        var getParentCase = component.get("c.getAfterSalesRT"); 
        getParentCase.setParams({
            "objId": recId
        });        
        getParentCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse1 = response.getReturnValue();    
                var getSobjRecord = component.get("v.obj");
                var getSobjRecordAcc = component.get("c.getObjectRecord");
                
                getSobjRecordAcc.setParams({
                    "objId": getSobjRecord.AccountId
                });        
                getSobjRecordAcc.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //var storeResponse2 = response.getReturnValue();
                        //component.set("v.acc", storeResponse2);                         
                        var createCase = $A.get("e.force:createRecord");
                        createCase.setParams({
                            "entityApiName": "Case",
                            "recordTypeId": storeResponse1,
                            "defaultFieldValues": {
                                'Order__c' : recId,
                                'AccountId' : response.getReturnValue().Id,
                                'ContactId' : response.getReturnValue().PersonContactId
                            }
                        });
                        createCase.fire();
                        
                    }
                });                
                $A.enqueueAction(getSobjRecordAcc);
            }
        });        
        $A.enqueueAction(getParentCase);
    },
    
    newComplaints : function(component, event, helper) {
        
        var recId = component.get("v.recordId");   
        var getParentCase = component.get("c.getComplaintsRT");  
        getParentCase.setParams({
            "objId": recId
        });        
        getParentCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse1 = response.getReturnValue();    
                var getSobjRecord = component.get("v.obj");
                var getSobjRecordAcc = component.get("c.getObjectRecord");
                
                getSobjRecordAcc.setParams({
                    "objId": getSobjRecord.AccountId
                });        
                getSobjRecordAcc.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //var storeResponse2 = response.getReturnValue();
                        //component.set("v.acc", storeResponse2);                         
                        var createCase = $A.get("e.force:createRecord");
                        createCase.setParams({
                            "entityApiName": "Case",
                            "recordTypeId": storeResponse1,
                            "defaultFieldValues": {
                                'Order__c' : recId,
                                'AccountId' : response.getReturnValue().Id,
                                'ContactId' : response.getReturnValue().PersonContactId
                            }
                        });
                        createCase.fire();
                        
                    }
                });                
                $A.enqueueAction(getSobjRecordAcc);
            }
        });        
        $A.enqueueAction(getParentCase);
    },
 
    
    newCaseFromAccount : function(component, event, helper) {
 
      component.set("v.isOpen", true); 
      
      var action = component.get("c.getRecTypeId");
      var recordTypeLabel = component.find("selectid").get("v.value");
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID  = response.getReturnValue();
            var objAcc = component.get("v.obj");
            createRecordEvent.setParams({
               "entityApiName": 'Case',
               "recordTypeId": RecTypeID,
                "defaultFieldValues": {
                                'AccountId' : objAcc.Id,
                                'ContactId' : objAcc.PersonContactId
                            }
            });
            createRecordEvent.fire();
             
         } else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
      });
      $A.enqueueAction(action);
    },
    
    
    onTabRefreshed : function(component, event, helper) { 
        
        
        setTimeout(function(){
            try{
                var refreshedTabId = event.getParam("tabId");
                var workspaceAPI = component.find("workspace");
                var caseRecord = component.get('v.caseRecord'); 
                //var status = caseRecord.Org_Case_Status__c;
                //var brand = caseRecord.Org_Brand__c;
                
            }catch(err) {
                console.log('@@@@ err: ' + err); 
            }
            
        }, 1000);
    }
    
})