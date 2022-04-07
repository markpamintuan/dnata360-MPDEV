({
    /***
	keyPressControllerHelper : function(component, event, helper, getInputkeyWord,wordvalue) {
        
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
       // var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.  
        
        
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
           
            if(event.getParams().keyCode == 13 ){
             	var word;
                if(wordvalue == 'FirstName'){
                    word = component.get('v.lstSelectedRecords_FirstName');
                }else if(wordvalue == 'LastName'){
                    word = component.get('v.lstSelectedRecords_LastName');
                }else if(wordvalue == 'Email'){
                    word = component.get('v.lstSelectedRecords_Email');
                }else if(wordvalue == 'Mobile'){
                    word = component.get('v.lstSelectedRecords_Mobile');
                }
                word.push({
                    Name : getInputkeyWord,
                    Id: getInputkeyWord
                          });
                if(wordvalue == 'FirstName'){
                    component.set('v.lstSelectedRecords_FirstName',word);
                    component.set("v.SearchKeyWord_FirstName",'');
                }else if(wordvalue == 'LastName'){
                    component.set('v.lstSelectedRecords_LastName',word);
                    component.set("v.SearchKeyWord_LastName",'');
                }else if(wordvalue == 'Email'){
                    component.set('v.lstSelectedRecords_Email',word);
                    component.set("v.SearchKeyWord_Email",'');
                }else if(wordvalue == 'Mobile'){
                    component.set('v.lstSelectedRecords_Mobile',word);
                    component.set("v.SearchKeyWord_Mobile",'');
                }
             }
        }
        console.log('First Name :- '+JSON.stringify(component.get("v.lstSelectedRecords_FirstName")));
    },
    
    // function for clear the Record Selaction 
    clearHelper :function(component,event,helper,wordvalue){
        debugger;
        console.log('wordvalue:- '+wordvalue);
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList;
        if(wordvalue == 'FirstName'){
            AllPillsList = component.get("v.lstSelectedRecords_FirstName"); 
            console.log(selectedPillId);
        }else if(wordvalue == 'LastName'){
            AllPillsList = component.get("v.lstSelectedRecords_LastName"); 
            console.log(selectedPillId);
        }else if(wordvalue == 'Email'){
            AllPillsList = component.get("v.lstSelectedRecords_Email"); 
            console.log(selectedPillId);
        }else if(wordvalue == 'Mobile'){
            AllPillsList = component.get("v.lstSelectedRecords_Mobile"); 
            console.log(selectedPillId);
        }
        
        
        for(var i = 0; i < AllPillsList.length; i++){
            console.log(AllPillsList[i].Id);
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                if(wordvalue == 'FirstName'){
                    component.set("v.lstSelectedRecords_FirstName", AllPillsList);
                }else if(wordvalue == 'LastName'){
                    component.set("v.lstSelectedRecords_LastName", AllPillsList);
                }else if(wordvalue == 'Email'){
                    component.set("v.lstSelectedRecords_Email", AllPillsList);
                }else if(wordvalue == 'Mobile'){
                    component.set("v.lstSelectedRecords_Mobile", AllPillsList);
                }
            }  
        }
        if(wordvalue == 'FirstName'){
            component.set("v.SearchKeyWord_FirstName",null);
        }else if(wordvalue == 'LastName'){
            component.set("v.SearchKeyWord_LastName",null);
        }else if(wordvalue == 'Email'){
            component.set("v.SearchKeyWord_Email",null);
        }else if(wordvalue == 'Mobile'){
            component.set("v.SearchKeyWord_Mobile",null);
        }     
    },
    ***/
    
    showToast : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type" : "error"
        });
        toastEvent.fire();
    }

    
})