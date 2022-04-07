({
    addRecord : function(component, event, helper) {
        try {
            console.log('----- Entered addRecord method');
            var records = component.get("v.testCaseOnload");
            var Id = component.get("v.recordId");
            var targetDate = component.get("v.PFTargetCompletion");
            console.log(records);    
            records.unshift({'sobjectType':'PF_TestCaseExecution__c',
                          'PF_Assigned_To__c': '',
                          'PF_Target_Completion_Date__c': targetDate,
                          'PF_Test_Case__c' : Id,
                          'PF_Status__c' : 'Not Started'});
            console.log('check updated---'+records);
            component.set("v.testCaseOnload", records);
        } catch (e) { 
            console.log(e.message);
        }
    },    
    Save : function(component, event, helper) {
		var  valueEntered = true;
        console.log('----- Entered save method');
        var records = component.get("v.testCaseOnload");
        var delRecords = component.get("v.delAssId");         
        var Id = component.get("v.recordId");
        for (var i = 0; i < records.length; i++) {
            records[i].sObjectType = 'PF_TestCaseExecution__c';
            if(records[i].PF_Assigned_To__c =='' || records[i].PF_Target_Completion_Date__c =='')
                valueEntered = false;
        }
        if(valueEntered){
       	var action = component.get("c.saveRecords");
        
        action.setParams({                
            "testCases": records,
            "delAssigne":delRecords
        });
        
        action.setCallback(component, function(a) {
            console.log('a.getReturnValue() ' + a.getReturnValue()); 
            
            if(a.getState() === "SUCCESS"){
                
                if( typeof(sforce) != 'undefined'){
                    sforce.one.navigateToURL("/"+Id);
                }else{
                    window.location.href = "/" + Id;
                }   
            }
            else{
                
            }               
        });
         
        
        $A.enqueueAction(action); 
        }else{
         	component.set("v.valueEntered",true);   
        }
    },
    
    removeAssignTestCase : function(component, event) {
        var recordNo = component.get("v.testCaseOnload");
        var index = event.getParam("removedIndex");
        
        recordNo.splice(index, 1);
        component.set("v.testCaseOnload", recordNo);
        
        var delResId = event.getParam("removedId");
        var records = component.get("v.delAssId");
        records.push(delResId);
        console.log('rrrrr----'+records);
        component.set("v.delAssId", records);
    },
    
    doInit: function(component, event, helper) {
        console.log('----- Entered doInit method');
        var checkPageAccess = component.get("c.checkPageAccess");
        var testCaseid = component.get("v.recordId");
        var records = component.get("v.testCaseOnload");

        var action = component.get("c.getRecords");
        action.setParams({                
            "testCase": testCaseid               
        });
        
        action.setCallback(component, function(a) {
            console.log(a.getReturnValue());                
            component.set("v.testCaseOnload", a.getReturnValue());
        });
        var action1 = component.get("c.getCurrentDate");
        action1.setParams({                
        });
        action1.setCallback(component, function(a) {
            console.log(a.getReturnValue());                
            component.set("v.PFTargetCompletion", a.getReturnValue());
        });
        checkPageAccess.setCallback(component, function(a) {             
            component.set("v.notHavingAccess", a.getReturnValue());
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        $A.enqueueAction(checkPageAccess);
    },
    Cancel : function(component, event, helper) {
        var Id = component.get("v.recordId");
        if( typeof(sforce) != 'undefined'){
            sforce.one.navigateToURL("/"+Id);
        }else{
            window.location.href = "/" + Id;
        }                  
    },
    closePopup :  function(component,event,helper){
    	component.set("v.valueEntered",false);
        component.set("v.openPopup",false);
        component.set("v.isSelected",false);
    },
    MassDelete : function(component, event, helper) {
        var isSelected = false;
        var childComp = component.find("childComp");
        for(var i=0;i<childComp.length;i++){
            if(childComp[i].find("boxPack").get("v.value")){
            	isSelected = true;    
            }    
        }
        if(isSelected){
        	component.set("v.openPopup",true);
        }else{
            component.set("v.isSelected",true);
        }
    },
    allSelect : function(component, event, helper) {
        var childComp = component.find("childComp");
        var checked = event.getSource().get("v.value");

        if(checked){
            for(var i=0;i<childComp.length;i++){
                childComp[i].find("boxPack").set("v.value",true);    
            }
        }else{
        	for(var i=0;i<childComp.length;i++){
                childComp[i].find("boxPack").set("v.value",false);    
            } 
        }
    },
        
    deleteRecs : function (component, event, helper) {
        var childComp = component.find("childComp");
        var selRestoDelete = [];
        var testCaseid = component.get("v.recordId");
        
		for(var i=0;i<childComp.length;i++){
        	var selRec = childComp[i].find("boxPack").get("v.value");
            if(selRec){
            	selRestoDelete.push(childComp[i].find("boxPack").get("v.text"));    
            }
        }
        var action= component.get("c.massDeleteExecutionRecs");
            action.setParams({                
            "recsToDelete":selRestoDelete
        	});
        var action1 = component.get("c.getRecords");
        action1.setParams({                
            "testCase": testCaseid               
        });
        action1.setCallback(component, function(a) {
            console.log(a.getReturnValue());
            component.set("v.testCaseOnload", a.getReturnValue());
        });
		$A.enqueueAction(action);
		$A.enqueueAction(action1);        
    }
})