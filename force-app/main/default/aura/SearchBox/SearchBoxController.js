({   
    
    keyPressNameController : function(component, event, helper) {
        component.set('v.resultWrapList',[]);
    },
    
    handleEmailBlur : function(component, event, helper) {
        var emailData = component.get("v.SearchKeyWord_Email");
        component.set("v.emailpop", false);
        if(emailData != undefined
           && emailData != ''){
            component.set("v.emailpop", true);
        }
        //alert(emailData);
    },
    
    handleKeywordBlur : function(component, event, helper) {
        debugger;
        var emailData = component.get("v.SearchKeyWord");
        component.set("v.keywordpop", false);
        if(emailData != undefined
           && emailData != ''){
            component.set("v.keywordpop", true);
        }
        //alert(emailData);
    },
    
    handlePhoneBlur : function(component, event, helper) {
        debugger;
        var phoneData = component.get("v.SearchKeyWord_Mobile");
        
        component.set("v.phonepop", false);
        if(phoneData != undefined
           && phoneData != ''){
            component.set("v.phonepop", true);
        }
        //alert(emailData);
    },
    
    
    keyPhoneCheck : function(component, event, helper) {
        debugger;
        if (event.which == 13){
            debugger;
            component.set("v.phonepop", false);
            // checking if the data is present
            var phoneData = component.get("v.SearchKeyWord_Mobile");
           
            if(phoneData.length < 8){
               // alert('can not greater then 9');
                helper.showToast(component, event, helper,'Please enter at least 9 digits');
            }
            // existing Phone
            var allPhone = component.get("v.lstSelectedRecords_Mobile");
            var pattren = /^[0-9]+$/;
            
            // if data is present then add to list
            if(phoneData.length > 0 && phoneData.match(pattren) && phoneData.length > 8 ){
                var phonecmp = component.find("searchPhone");                
                if(phonecmp.checkValidity()){
                    allPhone.push(phoneData);
                   // component.set("v.lstSelectedRecords_Mobile",allPhone);
                    component.set("v.SearchKeyWord_Mobile",'');
                    if(component.get("v.lstSelectedRecords_Mobile").length <= 5){
                       component.set("v.lstSelectedRecords_Mobile",allPhone); 
                    }else{
                        helper.showToast(component, event, helper,'It is not possible to add more than 5 phone numbers');
                    }
                }
                else{
                    phonecmp.set('v.validity',{valid:false,badInput:true});
                }
            }
            component.set('v.resultWrapList',[]);
       }
        
    },
    
    keyEmailCheck : function(component, event, helper) {
        if (event.which == 13){
            debugger;
            component.set("v.emailpop", false);
            // checking if the data is present
            var emailData = component.get("v.SearchKeyWord_Email");
            
            // existing emails
            var allEmail = component.get("v.lstSelectedRecords_Email");
            
            // if data is present then add to list
            if(emailData.length > 0){
                var emailcmp = component.find("searchEmail");                
                if(emailcmp.checkValidity()){
                    allEmail.push(emailData);
                    if(component.get("v.lstSelectedRecords_Email").length <= 5){
                       	component.set("v.lstSelectedRecords_Email",allEmail); 
                        component.set("v.SearchKeyWord_Email",'');
                    }else{
                        helper.showToast(component, event, helper,'It is not possible to add more than 5 emails');
                    }
                    //component.set("v.lstSelectedRecords_Email",allEmail);
                    //component.set("v.SearchKeyWord_Email",'');
                }
                else{
                    emailcmp.set('v.validity',{valid:false,badInput:true});
                }
            } 
            component.set('v.resultWrapList',[]);            
        }
        
    },

	keywordPressed : function(component, event, helper) {
        if (event.which == 13){
            debugger;
            component.set("v.keywordpop", false);
            // checking if the data is present
            var KeywordData = component.get("v.SearchKeyWord");
            
            // existing emails
            var allKeywords = component.get("v.lstSelectedRecords_Keywords");
            
            // if data is present then add to list
            if(component.get("v.lstSelectedRecords_Keywords").length <= 5){
                
                // adding key word
                allKeywords.push(KeywordData);
                component.set("v.lstSelectedRecords_Keywords",allKeywords);
                component.set("v.SearchKeyWord",'');
                
            }else{
                helper.showToast(component, event, helper,'It is not possible to add more than 5 keywords');
                component.set("v.SearchKeyWord",'');
            }
            component.set('v.resultWrapList',[]);            
        }
        
    },    
    
    clearEmail :function(component,event,helper){        
        var selectedPillId = event.getSource().get("v.name"); 
        
        // existing emails
        var allEmail = component.get("v.lstSelectedRecords_Email");
        
        // new List
        var newList = [];
        
        // for each record
        for(var ele in allEmail){
            if(allEmail[ele] != selectedPillId){
                newList.push(allEmail[ele]);
            }
        }
        component.set("v.lstSelectedRecords_Email",newList);
        component.set('v.resultWrapList',[]); 
    },
    
    clearKeyWord :function(component,event,helper){        
        var selectedPillId = event.getSource().get("v.name"); 
        
        // existing emails
        var allEmail = component.get("v.lstSelectedRecords_Keywords");
        
        // new List
        var newList = [];
        
        // for each record
        for(var ele in allEmail){
            if(allEmail[ele] != selectedPillId){
                newList.push(allEmail[ele]);
            }
        }
        component.set("v.lstSelectedRecords_Keywords",newList);
        component.set('v.resultWrapList',[]); 
    },
    
    clearMobile :function(component,event,helper){        
        var selectedPillId = event.getSource().get("v.name"); 
        
        // existing emails
        var allPhone = component.get("v.lstSelectedRecords_Mobile");
        
        // new List
        var newList = [];
        
        // for each record
        for(var ele in allPhone){
            if(allPhone[ele] != selectedPillId){
                newList.push(allPhone[ele]);
            }
        }
        component.set("v.lstSelectedRecords_Mobile",newList);
        component.set('v.resultWrapList',[]); 
    },
    
    validateField : function(component,event,helper){ 
        debugger;
        var stepNum = component.get("v.stepNumber");
        
        if(stepNum == -1){
            // if step number is true then check if last name is filled and email or phone number have some values
            var lstName = component.get("v.SearchKeyWord_LastName");
            
            // getting the emails
            var emails = component.get("v.lstSelectedRecords_Email");
            
            // var phone numbers
            var mobile = component.get("v.lstSelectedRecords_Mobile");
            
            // var Keyword 
            var Keyword = component.get("v.lstSelectedRecords_Keywords");
            
            // checking if last name is null
            
            /**** KR COMMENTED OUT THIS VALIDATION */
            /*
            if ($A.util.isUndefinedOrNull(lstName)
                || $A.util.isEmpty(lstName)) {
                
                helper.showToast(component,event,helper,'Last Name is Required');
                component.set("v.stepNumber",1);
                return;
            }
            
            else if(emails.length == 0
                    && mobile.length == 0){
                helper.showToast(component,event,helper,'Email or Phone is Required');
                component.set("v.stepNumber",1);
                return;
            }
            */

            /****KR ADDED THIS VALIDATION */
            if(emails.length == 0 && mobile.length == 0 && lstName == undefined && Keyword.length == 0){
                helper.showToast(component,event,helper,'Email or Phone or Name or Keyword is Required');
                component.set("v.stepNumber",1);
                return;
            }
            
          	else{
                component.set("v.stepNumber",2);
           	}  
        }
        
    }
    
    
})