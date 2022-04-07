({
	GetMessagesHelper : function(component, event, helper) {       
        
        try{
        var action = component.get("c.getAllMessages");
        console.log(component.get("v.recordId"));
        action.setParams({ "caseID" : component.get("v.recordId") });
  
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('--response--');
            if (state === "SUCCESS") {
                
                //response.getReturnValue();
                component.set("v.testconversation",response.getReturnValue());
                setTimeout(function(){ 
                    component.set("v.spinner",false);
                    try{
                    component.find('scrollerTop').scrollTo("bottom",0,0);   
                    }catch(e){
                        
                    }
                }, 1000);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        component.set("v.spinner",false);
                        
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
        }catch(e){
            console.log(e);
            }
	},
    
    SendMessageHelper : function(component, event, helper) {
		//console.log("doInitHelper called..");
		var textarea = component.find("AccName"); 
        textarea.set("v.disabled",true);      
        var action = component.get("c.SaveAgentMessage");
        var sendingSMS = false;
        if(component.get('v.isChanged') == true){
            sendingSMS = component.get('v.SendSMS');
        }else{
            sendingSMS = component.get('v.caseRecord.Receive_Text_Messages__c');
        }
        
        action.setParams({
            "caseID" : component.get("v.recordId"),
            "responseRequiredChbx" : component.get("v.ResponseRequired"),
            "replyMsgText" : component.get("v.ReplyText"),
            "sendSMS": sendingSMS
        });
        textarea.set("v.value","");
        action.setCallback(this, function(response) {
            var state = response.getState();
            textarea.set("v.disabled",false);
            console.log('--entry in render--- ');
            if (state === "SUCCESS") {
               
                /**** set variables to default ****/
                component.set("v.ReplyText", undefined);
                component.set("v.ResponseRequired", false);
                /*** Refersh all Messages List by getting new Messages ***/
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The message has been sent successfully.",
                    "type":"success"
                });
                toastEvent.fire();
                helper.GetMessagesHelper(component, event, helper);                
            }
            else if (state === "ERROR") {
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
	},
    getHeight: function(component) {
    var el = document.getElementById(component.getGlobalId() + '-textarea');
    // compute the height difference which is caused by border and outline
    var outerHeight = parseInt(window.getComputedStyle(el).height, 10);
    //3 pix is just a tiny static extra buffer. Adjust if necessary
    var diff = (outerHeight - el.clientHeight) + 3;
 
    // set the height to 0 incase it needs to be set smaller
    el.style.height = 0;
 
    // set the correct height
    // el.scrollHeight is the full height of the content, not just the visible part
    el.style.height = Math.max(60, el.scrollHeight + diff) + 'px';
	},
    stepOneNext : function(component, event, helper) {
        //debugger;
        var textMessage = component.get("v.TempText");
        console.log('textMessage : '+textMessage);
        var agentName = component.get('v.caseRecord.Contact.FirstName');
        var customerName = component.get('v.caseRecord.Account_Name__c');
        console.log(agentName);
        console.log(customerName);
        
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
            component.set('v.currentStep','1');
        }
        else{
            //Error
            helper.showErrorToast(component, event, helper, "Please fill the text input field.");
        }
    },
    stepSecondNext : function(component, event, helper) {
        debugger;
        var isValid = true;
        var lstObj = component.get("v.lstObj");
        var allEles = component.find('valField');
        
        var agentName = component.get('v.userInfo');//component.get('v.caseRecord.Agent_Name__c');
        var customerName = component.get('v.caseRecord.Contact.FirstName');
        console.log(agentName);
        console.log(customerName);
       
        
        
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
                 component.set('v.currentStep','2');
                var textMessage = component.get("v.TempText"); 
                component.set("v.textMessage",textMessage);
                var appendName = 'Dear ' + customerName + '\n \n';
                
                textMessage = appendName + textMessage ;
                textMessage = textMessage.replace('[[[AgentName]]]',agentName);
                component.set("v.textMessage",textMessage);
                component.set('v.currentStep','2');
            }
            
            else{
                var textMessage = component.get("v.TempText"); 
                var lstObj = component.get("v.lstObj");
                
                for(var i=0;i<lstObj.length;i++){
                    var replaceString = "<<<"+lstObj[i].Label +">>>";
                    textMessage = textMessage.replace(new RegExp(replaceString, 'g'), lstObj[i].Value);
                }
                component.set("v.textMessage",textMessage);
                var appendName = 'Dear ' + customerName + '\n \n';
                
                textMessage = appendName + textMessage ;
                textMessage = textMessage.replace('[[[AgentName]]]',agentName);
                component.set("v.textMessage",textMessage);
                component.set('v.currentStep','2');
                
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
    
})