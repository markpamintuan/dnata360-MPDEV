({
	stepOneNext : function(component, event, helper) {
        //debugger;
        var textMessage = component.get("v.newCaseDescription");
        console.log('textMessage : '+textMessage);
        
        var textLst = [];
        var objList = [];
        
        if(!$A.util.isUndefinedOrNull(textMessage) && textMessage.trim() != ''){
            var splitList1 = [];
            splitList1 = textMessage.split('<<<');
            if(!$A.util.isUndefinedOrNull(splitList1) && splitList1.length > 0){
                for(var i=0;i<splitList1.length;i++){
                    if(splitList1[i].includes(">>>")){
                        var splitList2 = [];
                        splitList2 = splitList1[i].split('>>>');
                        if(!$A.util.isUndefinedOrNull(splitList2) && splitList2.length > 0){
                            textLst.push(splitList2[0]);
                        }
                    }
                }
            }
            console.log("textLst : ");
            console.log(textLst);
            console.log(JSON.stringify(textLst));
            
            
            if(!$A.util.isUndefinedOrNull(textLst) && textLst.length > 0){ 
                var textLstSorted = textLst.filter(helper.distinct);
                //textLstSorted = textLstSorted.sort();
                for(var i=0;i<textLstSorted.length;i++){
                    var obj = {
                        Label: textLstSorted[i],
                        Value: ""
                    };
                    objList.push(obj);
                }
                
            }
            
            //console.log("objList ==> "+objList);
            //console.log(JSON.stringify(objList));
            component.set("v.lstObj",objList);
            component.set('v.currentStep','2');
        }
        else{
            //Error
            component.set('v.currentStep','2');
            //helper.showErrorToast(component, event, helper, "Please fill the text input field.");
        }
    },
    stepSecondNext : function(component, event, helper) {
        debugger;
        var isValid = true;
        var lstObj = component.get("v.lstObj");
        var allEles = component.find('valField');
        
        // if value is more then 1 the for loop else we can directly access the elements
        if(lstObj.length > 1){
            for(var ele in lstObj){
                var eleVal  = allEles[ele];
                var eleValue = eleVal.get("v.value");            
                if(!eleVal.get("v.validity").valid) {            	
                    eleVal.showHelpMessageIfInvalid();
                    isValid = false;
                }             
            }
        }
        else if(lstObj.length == 1){
            if(!allEles.get("v.validity").valid) {            	
                allEles.showHelpMessageIfInvalid();
                isValid = false;
            }
        }
        
            else {
                isValid = true;
            }
        
        
        // condition if every thing is good to go
        if (isValid) {
            
            if(lstObj.length == 0){
                 component.set('v.currentStep','3');
                var textMessage = component.get("v.newCaseDescription"); 
                var appendName = 'Dear ' + component.get('v.caseRecordTR.Account_First_Name__c') + '\n \n ';
                if(component.get('v.caseRecordTR.Account_First_Name__c') == null || component.get('v.caseRecordTR.Account_First_Name__c') == '' || component.get('v.caseRecordTR.Account_First_Name__c') == undefined){
                    appendName = 'Dear Customer \n \n';
                }
                var agentname =component.get('v.userInfo');
                
                textMessage = appendName + textMessage;
                textMessage = textMessage.replace('[[[AgentName]]]',agentname);
                component.set("v.textMessage",textMessage);
            }
            
            else{
                var textMessage = component.get("v.newCaseDescription"); 
                var lstObj = component.get("v.lstObj");
                
                for(var i=0;i<lstObj.length;i++){
                    var replaceString = "<<<"+lstObj[i].Label +">>>";
                    textMessage = textMessage.replace(new RegExp(replaceString, 'g'), lstObj[i].Value);
                }
                var appendName = component.get('v.caseRecordTR.Account_First_Name__c') + '\n\n';
                if(component.get('v.caseRecordTR.Account_First_Name__c') == null || component.get('v.caseRecordTR.Account_First_Name__c') == '' || component.get('v.caseRecordTR.Account_First_Name__c') == undefined){
                    appendName = 'Dear Customer \n \n';
                }
                var agentname =component.get('v.userInfo');
                
                textMessage = appendName + textMessage;
                textMessage = 'Dear ' +  textMessage.replace('[[[AgentName]]]',agentname);
                component.set("v.textMessage",textMessage);
                 component.set('v.currentStep','3');
            }
        }
        
        
        
        
       
    },
    showErrorToast : function(component, event, helper, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "ERROR",
            "type": "error",
            "message": errorMessage
        });
        toastEvent.fire();
    },
    distinct : function(value, index, self) {
        return self.indexOf(value) === index;
    },
    searchHelper : function(component,event,getInputkeyWord,sellkptype) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues2");
      // set param to method  
     var cserecid = component.get("v.recordId");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'cid' : cserecid,
            'searchType' : sellkptype
            //'ObjectName' : component.get("v.objectAPIName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                //debugger;
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found....');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    searchHelper2 : function(component,event,getInputkeyWord) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValuesForSubject");
      // set param to method  
     var cserecid = component.get("v.recordId");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'cid' : cserecid,
          });
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner2"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                //debugger;
                console.log(response.getReturnValue());
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message2", 'No Result Found....');
                } else {
                    component.set("v.Message2", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords2", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	}
    
})