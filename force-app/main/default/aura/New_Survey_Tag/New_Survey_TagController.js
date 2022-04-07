({
    doInit : function(component, event, helper) {
        debugger;       
        var parentId = component.get('v.recordId'); 
        var brand ='';      
        var customerJourney = '';
       if(parentId.startsWith("500")){
            component.set("v.showCase", true);           
        }
 
        if(parentId.startsWith($A.get("$Label.c.SurveyResponseTagPrefix"))){
            component.set("v.showSurveyResponse", true); 
            console.log(parentId);
             setTimeout(function(){	
                console.log(parentId);
            	if(parentId.startsWith($A.get("$Label.c.SurveyResponseTagPrefix"))){
                console.log(parentId);
				customerJourney = component.get("v.surveyResponserecordInfo.Org_Customer_Journey__c");
                brand = component.get("v.surveyResponserecordInfo.Brand__c"); 
                console.log(brand + ' '+ customerJourney);
                console.log(component.get('v.recordId'));
				var action = component.get("c.getCaseRecordTypeId");
            	action.setParams({ "brand" : brand , "actiontype" : "Tag" ,"customerJourney" : customerJourney});
                action.setCallback(this, function(response) {
                    debugger;
                    if (response.getState() == "SUCCESS") { 
                        debugger;
                        var caseCompRecTypeId = response.getReturnValue();                        
                        console.log(parentId);
							var createRecordEvent = $A.get("e.force:createRecord");
							console.log('createRecordEvent '+createRecordEvent);
							//console.log(recTypeId);
							createRecordEvent.setParams({
								"entityApiName": "Tag__c",
								"recordTypeId": caseCompRecTypeId,
								"defaultFieldValues": {
									"Org_Survey_Response__c": component.get('v.recordId')
									
								}
							});
							
							createRecordEvent.fire();
						} 
                	else{
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
            
        }, 1000); 
        }
        
          
        $A.get("e.force:closeQuickAction").fire();
 },
    createSurveyTag : function(component, event, helper){
        var parentId = component.get('v.recordId'); 
        var brand ='';      
        var customerJourney = '';
        setTimeout(function(){	 
            if(parentId.startsWith("500")){
                customerJourney = component.get('v.recordInfo.Org_Customer_Journey_Point__c');
                console.log(customerJourney);
                if(customerJourney == 'In Resort' || customerJourney == 'No Booking')
                    customerJourney = 'Post Booking';
                console.log(customerJourney);
                brand = component.get('v.recordInfo.Org_Brand__c'); 
                console.log('Brand'+brand);
				var action = component.get('c.getCaseRecordTypeId');
            	action.setParams({ "brand" : brand , "actiontype" : "Tag" ,"customerJourney" : customerJourney});
                action.setCallback(this, function(response) {
                    debugger;
                    if (response.getState() == "SUCCESS") { 
                        debugger;
                        var caseCompRecTypeId = response.getReturnValue();                        
                        console.log(parentId);
							var createRecordEvent = $A.get("e.force:createRecord");
							
							//console.log(recTypeId);
							createRecordEvent.setParams({
								"entityApiName": "Tag__c",
								"recordTypeId": caseCompRecTypeId,
								"defaultFieldValues": {
									"Case__c": component.get('v.recordId')
									
								}
							});
							
							createRecordEvent.fire();
						} 
                	else{
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
            }},1000);
    }
})