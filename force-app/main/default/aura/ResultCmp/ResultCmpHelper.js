({
    /***
     * calling the apex class when user has entered the data to be searched
     ***/
    getSearchObjectsDataList : function(component, event, helper) {
        debugger;
        
        //Show Spinner
        component.set("v.showSpinner", true);
        
        // making instance
        var action = component.get("c.getObjectsData");
        
        // making object for search form
        var formObj = [];
        
        // adding first Name
        var firstName = {};
        firstName.Name = component.get("v.FirstName");
        firstName.type = 'firstname';
        formObj.push(firstName);
        
        // adding Last Name
        var lastName = {};
        lastName.Name = component.get("v.LastName");
        lastName.type = 'lastname';
        formObj.push(lastName);
        
        // adding Email
        var allEmail = component.get("v.Email")
        for(var ele in allEmail){
            var emailobj = {};
            emailobj.Name = allEmail[ele];
            emailobj.type = 'email';
            formObj.push(emailobj);
        }
        //alert('Email :- '+JSON.stringify(formObj));
        
        // adding phone
        var allPhone = component.get("v.Mobile")
        for(var ele in allPhone){
            var phoneobj = {};
            phoneobj.Name = allPhone[ele];
            phoneobj.type = 'phone';
            formObj.push(phoneobj);
        }
        //alert('Phone :- '+JSON.stringify(formObj));
        
        // adding Keyword
        var allKeyword = component.get("v.Keyword")
        for(var ele in allKeyword){
            var Keyobj = {};
            Keyobj.Name = allKeyword[ele];
            Keyobj.type = 'Keyword';
            formObj.push(Keyobj);
        }
        //alert('allKeyword :- '+JSON.stringify(formObj));
        
        // setting parameters
        action.setParams({
            "formFieldsObj" : formObj,
            "metaDataNames" : component.get("v.metadata_Name"),
            /**            
            "fnameList" : component.get("v.FirstName"),
            "LnameList" : component.get("v.LastName"),
            "EmailList" : component.get("v.Email"),
            "MobileList" : component.get("v.Mobile"),
            **/
        });
        
        // method when apex method is called
        action.setCallback(this, function(response) {
            debugger;
            //hide Spinner
            component.set("v.showSpinner", false);
            
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") { 
                console.log("--->>> "+JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                var isresultPresent = false;
                debugger;
                for(var ele in res){                    
                    if(res[ele].lstRecords.length > 0){
                        isresultPresent = true;
                    }
                }
                //alert(isresultPresent);
                if(isresultPresent)
                    component.set("v.resultWrapList", response.getReturnValue());
                else{
                    component.set("v.stepNumber", 1);
                    this.showToast(component, event, helper, 'No Result Found', 'error')
                }
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.stepNumber", 1);
                        this.showToast(component, event, helper, errors[0].message, 'error');
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    component.set("v.stepNumber", 1);
                    this.showToast(component, event, helper, 'Unknown Error', 'error');
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, Message, type) {        
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "",
                "type": type,
                "message": Message              
                
                
            });
            toastEvent.fire();
        }
        catch(e){
            alert(e.message);
        }
        
    },
    
})