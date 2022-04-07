({
    doInit : function(component, event, helper) {
        debugger;       
        var parentId = component.get('v.recordId');   
        var parentRecordDetails ='';
        var brand ='';
        
        //Need to delay until modal opens
        setTimeout(function(){				       
            
            console.log(parentId);
            parentRecordDetails = component.get("v.recordInfo");
            brand = parentRecordDetails.Brand_Formula__c; 
            //alert(brand);
            //var caseCompRecTypeId = $A.get("$Label.c.dTME_Case_General_Enquiry_RecordTypeId");
            var action = component.get('c.getCaseRecordTypeId');
            action.setParams({ "brand" : brand , "actiontype" : "Commendation" });
            action.setCallback(this, function(response) {
                debugger;
                if (response.getState() == "SUCCESS") {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    debugger;
                    var caseCompRecTypeId = response.getReturnValue();                        
                    
                    
                    if(parentId.startsWith("001")){
                        console.log(parentId);
                        var createRecordEvent = $A.get("e.force:createRecord");
                        
                        //console.log(recTypeId);
                        createRecordEvent.setParams({
                            "entityApiName": "Case",
                            "recordTypeId": caseCompRecTypeId,
                            "defaultFieldValues": {
                                "AccountId": parentRecordDetails.Id,
                                "ContactId": parentRecordDetails.PersonContactId,
                                "Subject": "Commendation for " + parentRecordDetails.Name
                            }
                        });
                        
                        createRecordEvent.fire();
                    } else if(parentId.startsWith("a0V")){
                        debugger;
                        console.log('#### DT: ' + parentId);
                        console.log(parentId);
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Case",
                            "recordTypeId": caseCompRecTypeId,
                            "defaultFieldValues": {
                                "AccountId": parentRecordDetails.Org_Account__c,
                                "Description": parentRecordDetails.Org_Comments__c,
                                "Org_Case_Status__c":"Closed",
                                "Status":"Closed",
                                "Reason":"No Action Required",
                                "Origin": "NPS",
                                "Survey_Response_Id__c":parentRecordDetails.Id,
                                "Subject": "Commendation "
                            }
                        });
                        createRecordEvent.fire();
                    }
                    
                }else{
                    console.log('#### Error: ')
                }
            });
            $A.enqueueAction(action);
            
        }, 1000);     
        
    }    
})