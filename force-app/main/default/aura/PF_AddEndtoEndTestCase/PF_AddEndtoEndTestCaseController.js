({
	doInit : function(component, event, helper) {
	 	var storyID = component.get("v.recordId");
        var storyName = component.get("v.recordName");
        var checkInvoked = component.get("v.invoked");
        
        if(checkInvoked == 'worktask'){
            var taskAction = component.get("c.getStoryData");
            taskAction.setParams ({
            	TaskId :component.get("v.recordId")               
        	})
            taskAction.setCallback(component, function(response) {
                if(response.getState() === 'SUCCESS'){
                   component.set("v.Storysearchtext",response.getReturnValue().PF_Story__r.Name);
                   component.find("Story").set("v.value",response.getReturnValue().PF_Story__r.Name);
                   component.set("v.Tasksearchtext",storyName);
        		   component.find("Task").set("v.value",storyName);
                   component.set("v.newtestcase.PF_Story__c",response.getReturnValue().PF_Story__c);
                   component.set("v.newtestcase.PF_Task__c",response.getReturnValue().Id);
                }
                
            });
        }else {
            component.set("v.Storysearchtext",storyName);
        	component.find("Story").set("v.value",storyName);
        }
        
        var recordTypeAction = component.get("c.getRecordType");
        recordTypeAction.setParams ({
            RECTYPE :component.get("v.invoked")                    
        })
        
        var checkPageAccess = component.get("c.checkPageAccess");
		checkPageAccess.setCallback(component, function(a) {
            console.log(a.getReturnValue());                
            component.set("v.notHavingAccess", a.getReturnValue());
        });
 		
        var picklist_fields = ['PF_Status__c','PF_Type__c'];
        var cmp_attributes = ["v.Status","v.Type"];
        var action = component.get("c.getPicklist");
         action.setCallback(this, function(response) {
		    var state = response.getState();
             if(state==='SUCCESS'){
             	var values = response.getReturnValue();
                 //fetch all the values of picklist fields
                for(var k=0;k < picklist_fields.length;k++){
                    var picklist_field_values = values.optionsMap[picklist_fields[k]];
                    var picklist_values=[];
                    console.log(picklist_fields[k]);
                    if(picklist_fields[k] != 'PF_Status__c'){
                        picklist_values.push({value: '', label: '--None--'});
                    }
                    for(var i=0;i< picklist_field_values.length;i++){
                        var value = picklist_field_values[i];                        
                        picklist_values.push({value: value, label: value});
                    }
                    component.set(cmp_attributes[k], picklist_values);
                    //component.find(cmp_attributes[k]).set(cmp_attributes[k], picklist_values);
                }
             }
         });
        
        recordTypeAction.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
               component.set("v.recordTypeName",response.getReturnValue().Name);
                component.set("v.newtestcase.recordTypeId",response.getReturnValue().Id);
            
            }
            
        });
        checkPageAccess.setCallback(component, function(a) {             
            component.set("v.notHavingAccess", a.getReturnValue());
        });
        $A.enqueueAction(action);
        $A.enqueueAction(recordTypeAction);
        $A.enqueueAction(checkPageAccess);
        if(checkInvoked == 'worktask'){
            $A.enqueueAction(taskAction);
        }
	},
    workTaskSearch : function(component, event, helper) {
        var tasklookupView = component.find("Task").get("v.value");
        if(tasklookupView!=''){
            component.set("v.Tasksearchstrp",tasklookupView);
            component.set("v.searchstrp",'');
            component.set("v.Storysearchstrp",'');
            component.set("v.isLookup",true);
        }
    },
    
    storySearch : function(component, event, helper) {
        var storylookupView = component.find("Story").get("v.value");
        if(storylookupView!=''){
            component.set("v.Storysearchstrp",storylookupView);
            component.set("v.searchstrp",'');
            component.set("v.Tasksearchstrp",'');
            component.set("v.isLookup",true);
        }
    },
    
    searchstring : function(component, event, helper) {
        var testCaselookupView = component.find("PredecessorTestCase").get("v.value");
        if(testCaselookupView!=''){
            component.set("v.searchstrp",testCaselookupView);
            component.set("v.Storysearchstrp",'');
            component.set("v.Tasksearchstrp",'');
            component.set("v.isLookup",true);
        }
    },
    setValues : function(component,event){
        var name = event.getParam("selectedvalue");
     	var id = event.getParam("selectedId");
        var selObj = event.getParam("selectedField");
		
        if(selObj == 'PF_TestCases__c'){
            component.find("PredecessorTestCase").set("v.value",name);
            component.set("v.newtestcase.PF_Predecessor_Test_Case__c",id);
        }
        if(selObj == 'PF_Stories__c'){
        	component.find("Story").set("v.value",name);
            //component.set("v.newtestcase.PF_Story__c",id); 	   
        }
        if(selObj == 'PF_Tasks__c'){
        	component.find("Task").set("v.value",name);
            //component.set("v.newtestcase.PF_Task__c",id); 	   
        }
        component.set("v.isLookup",false);
        
    },
    Save : function(component, event, helper) {
        var tcName = component.get("v.newtestcase.Name");
        var tcType = component.get("v.newtestcase.PF_Type__c");
        var tcStatus = component.get("v.newtestcase.PF_Status__c");
        var tcStory = component.get("v.newtestcase.PF_Story__c");
        var tcDesc = component.get("v.newtestcase.PF_Description__c");
        var tcTask = component.get("v.newtestcase.PF_Task__c");
		
        if(!tcName || !tcType || !tcDesc){
            alert('Please Populate all Mandatory Fields!!!');
            return;
        }
        
        
        var testCaseRec = component.get("v.newtestcase");
        var action = component.get("c.createNewTestCase");
        action.setParams({                
                "thetestCaseRec": JSON.stringify(testCaseRec),
            	"recordId" : component.get("v.recordId")
         });
        action.setCallback(component, function(a) {
            if(a.getState() === "SUCCESS"){
                
                if( typeof(sforce) != 'undefined'){
                    sforce.one.navigateToURL("/"+a.getReturnValue());
                }else{
                    window.location.href = "/" + a.getReturnValue();
                }   
            }
        })
        $A.enqueueAction(action);
    },
    Cancel : function(component, event, helper) {
    	if( typeof(sforce) != 'undefined'){
                    sforce.one.navigateToURL("/"+component.get("v.recordId"));
                }else{
                    window.location.href = "/" + component.get("v.recordId");
                }     
    },
    showpopover : function(component, event, helper) {
        var t = component.get("v.name");
        alert(t);
    }
})