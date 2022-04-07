({
	Save : function(component, event, helper) {
        
        var btn = event.getSource();
        var theDefect = component.get("v.newDefect");
        var action = component.get("c.createDefect");
        var Id = component.get("v.recordId");     
        
        var dname = component.get("v.newDefect.Name");   
        var dSeverity = component.get("v.newDefect.PF_Severity__c");   
        var dStatus = component.get("v.newDefect.PF_Status__c"); 
        var dType =  (component.get("v.newDefect.PF_Type__c") != "") ? component.get("v.newDefect.PF_Type__c") : 'Defect';   
        var dDesc = component.get("v.newDefect.PF_Description__c");   
        var dReproduce = component.get("v.newDefect.PF_Steps_to_Reproduce__c"); 
        var resType = component.get("v.newDefect.PF_Resolution_Type__c"); 
        var priority = component.get("v.newDefect.PF_Priority__c"); 
        var resDetails = component.get("v.newDefect.PF_Resolution_Details__c"); 
        var planFixDate =  component.get("v.newDefect.PF_Planned_Fixed_Date__c"); 
        
        if(!dname || !dSeverity || !dType || !dDesc || !dReproduce ){ //|| !dStatus 
            alert('Please populate all the Mandatory Fields !!!');
            return;
        }   
        
        console.log("DStatus " + dStatus);
        action.setParams({                
                "theDefect": JSON.stringify(theDefect),
                "recordId": Id                
         });
        
        action.setCallback(component, function(a) {
                if(a.getReturnValue() === "SUCCESS"){                      
                    
                    //alert("Defect sucessfully created");                     
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent) {
                        $A.get("e.force:closeQuickAction").fire();
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Defect sucessfully created",
                            "duration": 2000
                        });
                        toastEvent.fire();  
                    }
                    else{
                        alert("Defect sucessfully created");
                        
                        window.location.href = "/" + Id;
                    }
                }
                else{
                    alert("error occured while creating Defect/nError Message --> " + a.getReturnValue());
                }                
            });
            
        $A.enqueueAction(action);            
        
        component.set("v.newDefect", theDefect);
		
	},
    Cancel : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var Id = component.get("v.recordId");  
        if(toastEvent) {
             $A.get("e.force:closeQuickAction").fire();
        }
        else{
           window.location.href = "/" + Id;
        }
        
        
    },
    doInit : function(component, event, helper) {
        var checkPageAccess = component.get("c.checkPageAccess");
		checkPageAccess.setCallback(component, function(a) {
            console.log(a.getReturnValue());                
            component.set("v.notHavingAccess", a.getReturnValue());
        });
        
        //console.log ("URL -->" + URL.getSalesforceBaseUrl().toExternalForm());
        var picklist_fields = ['PF_Severity__c','PF_Status__c','PF_Type__c','PF_Resolution_Type__c','PF_Priority__c'];

        //var cmp_attributes = ["v.newDefect.PF_Severity__c","v.newDefect.PF_Status__c","v.newDefect.PF_Type__c"];
        var cmp_attributes = ["v.Severity","v.Status","v.Type","v.ResType","v.Priority"];
		
        var action = component.get("c.getPicklist");
        action.setCallback(this, function(response) {
			
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                var values = response.getReturnValue();
                
                //fetch all the values of picklist fields
                for(var k=0;k < picklist_fields.length;k++){
                    var picklist_field_values = values.optionsMap[picklist_fields[k]];
                    var picklist_values=[];
                    //console.log(k);
                    //console.log(picklist_fields);
                    //console.log(picklist_field_values);
                    if(!picklist_field_values.includes("Defect")){
                    	picklist_values.push({value: '', label: '--None--'});
                    }
                    //picklist_values.push({value: '', label: '--None--'});
                    for(var i=0;i< picklist_field_values.length;i++){
                        var value = picklist_field_values[i];                        
                        picklist_values.push({value: value, label: value});
                    }
                    //component.set("v.Severity", "Medium");
                    component.set(cmp_attributes[k], picklist_values);
                    //component.find(cmp_attributes[k]).set(cmp_attributes[k], picklist_values);
                }

            } else {
                console.log(state);
            }
		});
        checkPageAccess.setCallback(component, function(a) {             
            component.set("v.notHavingAccess", a.getReturnValue());
        });
		$A.enqueueAction(checkPageAccess);
        $A.enqueueAction(action);
     }
})