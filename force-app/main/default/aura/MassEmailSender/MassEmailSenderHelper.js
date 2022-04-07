({
	getReportResponse : function(component) {
        // Load report data
        var reportname = component.get('v.reportName');
        var action = component.get("c.getReportResponseApex");
        action.setParams({ 'reportName' : reportname });
        var self = this;
        console.log('called getReportResponse');
        action.setCallback(this, function(a){
            var reportResponseObj = JSON.parse(a.getReturnValue()); 
            console.log(reportResponseObj);
            
            component.set("v.reportResponse", reportResponseObj);
			component.set('v.recordCount',reportResponseObj.reportSize);
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if(action.getState() ==='SUCCESS'){
                component.set('v.displayReport','true');
                /*toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your report has been loaded successfully.",
                    "type":"success"
                });*/
            }else{
                component.set('v.displayReport','false');
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong.",
                    "type":"error"
                });
            }
            toastEvent.fire();
        });
         $A.enqueueAction(action);
    },
    getNewReportResponse : function(component) {
        // Load report data
        var reportname = component.get('v.reportName');
        var action = component.get("c.getReportResponseApexWithFilters");
        action.setParams({ 'reportName' : reportname,'filter':JSON.stringify(component.get("v.filters")) });
        var self = this;
        console.log('called getReportResponse');
        action.setCallback(this, function(a){
            component.set("v.IsSpinner",false);
            component.set('v.hasFilters',true);

            
            try{
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            var response = a;
            if(action.getState() ==='SUCCESS'){
                var reportResponseObj = JSON.parse(a.getReturnValue()); 
                try{
                    console.log(reportResponseObj.fieldDataList.length);
                    component.set('v.recordCount',reportResponseObj.reportSize);
                    component.set('v.instanceid',reportResponseObj.instanceId);
                    component.set("v.reportResponse", reportResponseObj);
                }catch(err){
                    console.log(err);
                }
                component.set('v.displayReport','true');
                if(reportResponseObj.fieldDataList.length == 0){
                    toastEvent.setParams({
                    "title": "Error!",
                    "message": "Search could not retrieve any records.",
                    "type":"error"
                	});
                    toastEvent.fire();	
                }else{
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Search has been successful.",
                        "type":"success"
                    });
                    toastEvent.fire();
                }
            }else if (action.getState() === "INCOMPLETE") {
                console.log(response);
            }
            else if (action.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        component.set('v.displayReport','false');
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": " Something has gone wrong.",
                            "type":"error"
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                
            }
                }catch(err){
                    console.log(err);
            toastEvent.setParams({
                            "title": "Error!",
                            "message": "Search Box is Empty.",
                            "type":"error"
                        });
            toastEvent.fire();
        }
            
        });
         $A.enqueueAction(action);
        
    },
    showSpinner: function (component, event, helper) {
            component.set("v.IsSpinner",true);
    },
     
    hideSpinner: function (component, event, helper) {
       		component.set("v.IsSpinner",false);
    },
    searchHelper : function(component,event,getInputkeyWord,sellkptype) {
        debugger;
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
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
    stepOneNext_m : function(component, event, helper) {
        
        //debugger;
        var textMessage = component.get("v.TempText_m");
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
            component.set("v.lstObj_m",objList);
            component.set('v.currentStep_m','1');
        }
        else{
            //Error
            helper.showErrorToast(component, event, helper, "Please fill the text input field.");
        }
    },
    stepSecondNext_m : function(component, event, helper) {
        debugger;
        var isValid = true;
        var lstObj = component.get("v.lstObj_m");
        var allEles = component.find('valField_m');
        
       
        
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
                 component.set('v.currentStep_m','2');
                var textMessage = component.get("v.TempText_m"); 
                component.set("v.textMessage_m",textMessage);
                //var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                var agentname =component.get('v.userInfo');
                
                //textMessage = appendName + textMessage;
                textMessage = textMessage.replace('[[[AgentName]]]',agentname);
                
                component.set("v.textMessage_m",textMessage);
                component.set('v.currentStep_m','2');
            }
            
            else{
                
                var textMessage = component.get("v.TempText_m"); 
                var lstObj = component.get("v.lstObj_m");
                
                for(var i=0;i<lstObj.length;i++){
                    var replaceString = "<<<"+lstObj[i].Label +">>>";
                    textMessage = textMessage.replace(new RegExp(replaceString, 'g'), lstObj[i].Value);
                }
                component.set("v.textMessage_m",textMessage);
                //var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                var agentname =component.get('v.userInfo');
                //textMessage = appendName + textMessage;
                textMessage = textMessage.replace('[[[AgentName]]]',agentname);
                component.set("v.textMessage_m",textMessage);
                component.set('v.currentStep_m','2');
                
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
    stepOneNext_r : function(component, event, helper) {
        //debugger;
        var textMessage = component.get("v.TempText_r");
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
            component.set("v.lstObj_r",objList);
            component.set('v.currentStep_r','1');
        }
        else{
            //Error
            helper.showErrorToast(component, event, helper, "Please fill the text input field.");
        }
    },
    stepSecondNext_r : function(component, event, helper) {
        debugger;
        var isValid = true;
        var lstObj = component.get("v.lstObj_r");
        var allEles = component.find('valField_r');
        
       
        
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
                 component.set('v.currentStep_r','2');
                var textMessage = component.get("v.TempText_r"); 
                component.set("v.textMessage_r",textMessage);
                //var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                var agentname =component.get('v.userInfo');
                //textMessage = appendName + textMessage;
                textMessage = textMessage.replace('[[[AgentName]]]',agentname);
                component.set("v.textMessage_r",textMessage);
                component.set('v.currentStep_r','2');
            }
            
            else{
                var textMessage = component.get("v.TempText_r"); 
                var lstObj = component.get("v.lstObj_r");
                
                for(var i=0;i<lstObj.length;i++){
                    var replaceString = "<<<"+lstObj[i].Label +">>>";
                    textMessage = textMessage.replace(new RegExp(replaceString, 'g'), lstObj[i].Value);
                }
                component.set("v.textMessage_r",textMessage);
                //var appendName = '[[[ Dear CustomerFirstName. This will automatically populate the customer name]]]' + '\n \n';
                var agentname =component.get('v.userInfo');
                
                //textMessage = appendName + textMessage;
                textMessage = textMessage.replace('[[[AgentName]]]',agentname);
                component.set("v.textMessage_r",textMessage);
                component.set('v.currentStep_r','2');
                
            }
        }
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
    
	},
    
    
    uploadHelper: function(component, event) {
        debugger;
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fuploader").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        /*if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }*/
         
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            debugger;
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
             
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
         
        objFileReader.readAsDataURL(file);
    },
    uploadProcess : function(component, file, fileContents) {
        debugger;
        console.log("file ::: "+file);
        console.log("file Name ::: "+component.get("v.fileName"));
        console.log("fileContents ::: "+fileContents);
        if(fileContents != undefined){
            var action = component.get("c.getFileBlob");
        
        action.setParams({
            "FileName": component.get("v.fileName"),
            "Base64String": fileContents
        });
        
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                
            }
            else if (state === "ERROR") {                
                var errors = action.getError();
                // alert(errors)
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error :: '+errors[0].message);
                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
        }
    },
    
    sendFileToController : function(component, event, helper) {
        debugger;
        
        var action = component.get("c.getFileBlob");
        
        action.setParams({
            "FileName": component.get("v.fileName"),
            "FileType": component.get("v.fileType"),
            "blobDataObj": component.get("v.blobData")
        });
        
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                
            }
            else if (state === "ERROR") {                
                var errors = action.getError();
                // alert(errors)
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error :: '+errors[0].message);
                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
    } ,
    
    
    uploadHelper :function(component, event) {
        debugger;
        var action = component.get("c.fetchRecordTypeValues");
          action.setCallback(this, function(response) {
             component.set("v.lstOfRecordType", response.getReturnValue());
              component.set('v.reportSet',true);
          });
          $A.enqueueAction(action);
       
        
       
    },
    
    processHelper : function(component,event,file,fileContents) {
        debugger;
        var action = component.get("c.onProcessBatch");
        action.setParams({
            "fileContents":encodeURIComponent(fileContents)
        });
        action.setCallback(this, function(response) {
            console.log('finished processbatch');
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response =>' + response.getReturnValue());
                component.set('v.parentObject',response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                
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
})