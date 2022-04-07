({
    doInit : function(component, event, helper) {
        debugger;       
        var parentId = component.get('v.recordId');   
        //var whichOne = event.getSource().get('v.id');
        //var whichOne2 = event.getSource().get('v.name');
        //var whichname = event.getSource();
        //var whichname1 = event.getName();

        var parentRecordDetails ='';
        var brand ='';
        var actionAPI = component.find("quickActionAPI");

        //Need to delay until modal opens
        setTimeout(function(){				       
				
				console.log(parentId);
                parentRecordDetails = component.get("v.recordInfo");
            	brand = parentRecordDetails.Org_Brand__c; 
				var action = component.get('c.getCaseRecordTypeId');
				action.setParams({ "brand" : brand , "actiontype" : "Groups Enquiry" });
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
									"Subject": "Groups Enquiry for " + parentRecordDetails.Name
								}
							});
							
							createRecordEvent.fire();
						}
                        
                    }else{
                        console.log('#### Error: ')
                    }
                });
                $A.enqueueAction(action);
            
        }, 100);     
        
	} 
})