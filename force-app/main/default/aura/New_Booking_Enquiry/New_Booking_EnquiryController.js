({
    doInit : function(component, event, helper) {
        debugger;       
        var parentId = component.get('v.recordId'); 
        var parentRecordDetails ='';
        var brand ='';      
        
		if(parentId.startsWith("001")){
            component.set("v.showAccount", true);           
        }
        
        if(parentId.startsWith($A.get("$Label.c.BookingRecordIdPrefix"))){
            component.set("v.showBooking", true);           
        }
        //Need to delay until modal opens
        setTimeout(function(){				       
				
				console.log(parentId);
                parentRecordDetails = component.get("v.recordInfo");
            	brand = parentRecordDetails.Org_Brand__c; 
				
				var action = component.get('c.getCaseRecordTypeId');
				action.setParams({ "brand" : brand , "actiontype" : "Booking Enquiry" });
                action.setCallback(this, function(response) {
                    debugger;
                    if (response.getState() == "SUCCESS") { 
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
									"Subject": "Booking Enquiry for " + parentRecordDetails.Name
								}
							});
							
							createRecordEvent.fire();
						} else if(parentId.startsWith($A.get("$Label.c.BookingRecordIdPrefix"))){
							console.log('#### DT: ' + parentId);
							console.log(parentId);
							var createRecordEvent = $A.get("e.force:createRecord");
							createRecordEvent.setParams({
								"entityApiName": "Case",
								"recordTypeId": caseCompRecTypeId,
								"defaultFieldValues": {
									"AccountId": parentRecordDetails.Org_Account_Name__c,
									"ContactId": parentRecordDetails.Org_Person_Account_Contact_Id__c,
									"Org_Booking__c": parentRecordDetails.Id,
                                    "ParentId":parentRecordDetails.Org_SF_Case_Reference__c,
                                    "Rehlaty_Upsell_Booking__c": true,
									"Subject": "Booking Enquiry for " + parentRecordDetails.Org_Account_Name__r.Name
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