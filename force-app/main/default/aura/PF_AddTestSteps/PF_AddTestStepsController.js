({
    addRecord : function(component, event, helper) {
        console.log('----- Entered addRecord method');
        var records = component.get("v.TCSteps");
        var Id = component.get("v.recordId");
        
        records.push({'sobjectType':'PF_Test_Case_Step__c',
                      'PF_Step_Description__c': '',
                      'PF_Expected_Result__c': '',
                      'PF_Actual_Result__c' : '',
                      'PF_Test_Case__c' : Id,
                      'PF_Step_Number__c' : ''});
        
        
        component.set("v.TCSteps", records);
    },
    addRecordPos : function(component, event, helper) {
        console.log('----- Entered addRecord method');
        var records = component.get("v.TCSteps");
        var Id = component.get("v.recordId");
        var index = parseInt(event.currentTarget.getAttribute("data-selected-Index"));
        console.log(index, typeof(index));
        records.splice(index+1, 0, {'sobjectType':'PF_Test_Case_Step__c',
                                    'PF_Step_Description__c': '',
                                    'PF_Expected_Result__c': '',
                                    'PF_Actual_Result__c' : '',
                                    'PF_Test_Case__c' : Id,
                                    'PF_Step_Number__c' : ''});
        component.set("v.TCSteps", records);
    },
    swapUp : function(component, event, helper) {
        console.log('----- Entered addRecord method');
        var records = component.get("v.TCSteps");
        var Id = component.get("v.recordId");
        var index = parseInt(event.currentTarget.getAttribute("data-selected-Index"));
        console.log(index, typeof(index));
        var b = records[index];
        var c = records[index-1]
        records[index-1] = b;
        records[index] = c;
        /*records.splice(index+1, 0, {'sobjectType':'PF_Test_Case_Step__c',
                      'PF_Step_Description__c': '',
                      'PF_Expected_Result__c': '',
                      'PF_Actual_Result__c' : '',
                      'PF_Test_Case__c' : Id,
                      'PF_Step_Number__c' : ''});*/
        component.set("v.TCSteps", records);
    },
    swapDown : function(component, event, helper) {
        console.log('----- Entered addRecord method');
        var records = component.get("v.TCSteps");
        var Id = component.get("v.recordId");
        var index = parseInt(event.currentTarget.getAttribute("data-selected-Index"));
        console.log(index, typeof(index));
        var b = records[index];
        var c = records[index+1]
        records[index+1] = b;
        records[index] = c;
        component.set("v.TCSteps", records);
    },
    upsertRecord: function(component,event,helper)
    {
        console.log('----- Entered save method');
        var records = component.get("v.TCSteps");
        var isEntered = true;
        var delRecords = component.get("v.delAssId");         
        var Id = component.get("v.recordId");
        for (var i = 0; i < records.length; i++) {
            if(records[i].PF_Step_Description__c =='' || records[i].PF_Expected_Result__c==''){
               isEntered = false; 
            }
            records[i].sObjectType = 'PF_Test_Case_Step__c';
            records[i].PF_Step_Number__c = i+1;
        }
        if(isEntered){
        var action = component.get("c.upsertTestCaseSteps");
        action.setParams({                
            "testCaseStps": records,
            "delAssigne":delRecords
        });
        
        action.setCallback(component, function(a) {
            console.log('a.getReturnValue() ' + a.getReturnValue()); 
            
            if(a.getReturnValue() === "SUCCESS"){
                
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
    
    removeTestStep: function(component,event)
    {
        var recordNo = component.get("v.TCSteps");
        var index = event.currentTarget.getAttribute("data-selected-Index");
        var recIdDel = event.currentTarget.getAttribute("data-id");
        recordNo.splice(index, 1);
        component.set("v.TCSteps", recordNo);
        var records = component.get("v.delAssId");
        records.push(recIdDel);
        component.set("v.delAssId", records);
        if(recordNo.length == 0){
        component.set("v.selectAllChk",true);
        }
    },
    
    doInit : function(component, event, helper) {        
        var checkPageAccess = component.get("c.checkPageAccess");
		checkPageAccess.setCallback(component, function(a) {
            console.log(a.getReturnValue());                
            component.set("v.notHavingAccess", a.getReturnValue());
        });
        var Id = component.get("v.recordId");
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
                
                var values = a.getReturnValue();
                console.log ('Values --> ' + values);
                if(!$A.util.isEmpty(values)){
                   
                	component.set("v.TCSteps", values);
                 	component.set("v.selectAllChk",false);
            }
            }
        });
        checkPageAccess.setCallback(component, function(a) {             
            component.set("v.notHavingAccess", a.getReturnValue());
        });
        
        $A.enqueueAction(action);  
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
    checkboxSelect : function(component, event, helper) {
		var recSize = component.get("v.TCSteps").length;
    	var index = parseInt(event.currentTarget.getAttribute("data-selected-Index"));
        var recIdDel = event.currentTarget.getAttribute("data-id");
        var recId = component.find("boxPack")[index].get("v.text");
        var records=[];
        if(component.find("boxPack")[index].get("v.value")){
        	records.push(recIdDel);
          	component.set("v.delAssId", records);     
        }
        console.log(component.find("boxPack")[index].get("v.value"),'JJJJJJJJJJJJJJJJJ',index);
        
       /* if(index==0){
            
            if(component.find("boxPack")[index].get("v.value")){
                component.set("v.disableMoveup",true);
            }else{
                component.set("v.disableMoveup",false);
            }
        }*/
    },
    allSelect: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("boxPack");
        var records = component.get("v.delAssId");
        if (selectedHeaderCheck == true) {
            for (var i = 0; i < getAllId.length; i++) {
                component.find("boxPack")[i].set("v.value", true);
                //component.set("v.selectedCount", getAllId.length);
                //records.push(recIdDel);
                //component.set("v.delAssId", records);
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                component.find("boxPack")[i].set("v.value", false);
                //component.set("v.selectedCount", 0);
            }
        }
    },
    deleteSlctd : function(component,event,helper) {
        var getCheckAllId = component.find("boxPack");
        var Id = component.get("v.recordId");
        //var selctedRec = [];
        var selctedRec = component.get("v.delAssId");
        for (var i = 0; i < getCheckAllId.length; i++) {
            
            if(getCheckAllId[i].get("v.value") == true )
            {
                selctedRec.push(getCheckAllId[i].get("v.text")); 
            }
        }
        
        
        var action = component.get("c.deleteSeleted");
        action.setParams({                
            "testStpsDel":selctedRec
        });
        
        action.setCallback(component, function(a) {
            console.log('a.getReturnValue() ' + a.getReturnValue()); 
            if(a.getReturnValue() === "SUCCESS"){
            	window.location.reload();
            	/*$A.get('e.force:refreshView').fire();
                if( typeof(sforce) != 'undefined'){
                 	window.location.reload();
                 	//sforce.one.navigateToURL("/"+Id);
                }else{
                 	window.location.reload();
                 	//window.location.href = "/" + Id;
                }*/   
            }
            else{
                
            }             
        });
        
        $A.enqueueAction(action);
        //helper.deleteSelected(component,event,selctedRec);
    },
    MoveUp : function (component, event, helper){
		var records = [];
    	records = component.get("v.TCSteps");
        var swapRecs = [];
        var selRecs =[];
        var nonSelRecs = [];
		for(var i=0;i<records.length;i++){
            var selectedRec = component.find("boxPack")[i].get("v.value");
            if(selectedRec){
                selRecs.push(i);
            }else{
            	nonSelRecs.push(i);   
            }
        }
        console.log(selRecs,'TTTTTTTTTTTTTTT',nonSelRecs);
        for(var row in records){
            swapRecs.push(records[row]);
        }
        for (var row in selRecs) {
  			records[row] = swapRecs[selRecs[row]];
           // swapRecs.push(records[selRecs[row]]);	
		}
        var j=0;
        for (var row in nonSelRecs) {
            console.log(nonSelRecs[row]);
            var index =parseInt(selRecs.length) + parseInt(j);
  			records[index] = swapRecs[nonSelRecs[row]];
            j = j + 1;
		}
        component.set("v.TCSteps",records);
        component.set("v.disableMoveup",true);
    },
    MoveDown : function (component,event,helper){
    	var records = [];
    	records = component.get("v.TCSteps");
        var swapRecs = [];
        var selRecs =[];
        var nonSelRecs = [];
		for(var i=0;i<records.length;i++){
            var selectedRec = component.find("boxPack")[i].get("v.value");
            if(selectedRec){
                selRecs.push(i);
            }else{
            	nonSelRecs.push(i);   
            }
        }
        for(var row in records){
            swapRecs.push(records[row]);
        }
        console.log(selRecs,'TTTTTTTTTTTTTTT',nonSelRecs);
        var j=1;
        for (var row in selRecs) {
  			records[(records.length-1)-j] = swapRecs[selRecs[row]];
            j = j - 1;	
		}
        for (var row in nonSelRecs) {
  			records[row] = swapRecs[nonSelRecs[row]];
		}
        component.set("v.TCSteps",records); 
        component.set("v.disableMovedown",true);
    },
    closePopup : function (component,event,helper){
        component.set("v.valueEntered",false);
    }
})