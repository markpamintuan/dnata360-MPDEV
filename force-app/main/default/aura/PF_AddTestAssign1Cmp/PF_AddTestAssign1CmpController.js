({
	doInit : function(component, event, helper) {        
        var Id = "a08P0000002wUK3IAM";//component.get("v.recordId");
        component.set("v.TCSteps",{'sobjectType':'PF_Test_Case_Step__c',
                                   'PF_Step_Description__c': '',
                                   'PF_Expected_Result__c': '',
                                   'PF_Actual_Result__c' : '',
                                   'PF_Test_Case__c' : Id} );
        var action = component.get("c.getRecords");
        action.setParams({       
            "testCase": Id
        });
        
        action.setCallback(component, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") { 
                var TCstepData = helper.helperMethod1(a.getReturnValue()); 
                var values = a.getReturnValue();
                console.log ('Values --> ' + values);
                if(!$A.util.isEmpty(values)){
                   
                	component.set("v.TCSteps", TCstepData);
            }
            }
        });
        
        
        $A.enqueueAction(action);  
    },
})