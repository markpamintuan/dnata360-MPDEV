({
	myAction : function(component, event, helper) {
        component.set("v.spinner",true);
        console.log(component.get("v.recordId"));
        console.log(component.get('v.SendSMS') + 'here');
        helper.GetMessagesHelper(component, event, helper);
        var secondaction = component.get("c.getEmailFolder");
        secondaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {                   
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.options", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(secondaction);
         
        try{
        setInterval($A.getCallback(function() {helper.GetMessagesHelper(component, event, helper)}),10000);
        }catch(e)
        {}
        
        
        var thirdaction = component.get("c.fetchUser");
        
        thirdaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                console.log('userinfo ' + storeResponse);
            }
             
        });
        $A.enqueueAction(thirdaction);
	},

    SendMessage : function(component, event, helper) {
        var msg = component.get("v.ReplyText");
        if(msg != undefined && msg.trim() != ''){
            helper.SendMessageHelper(component, event, helper);
        }
       
        },
    openModal: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
        
        
   },
  
   closeModal: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      

       component.set("v.isOpen", false);
     
            component.set('v.currentStep','0');
            //component.set('v.textMessage','');
            component.set('v.TempText','');
            component.set('v.lstObj',[]);
            //component.set('v.options','');
            //component.set('v.templateoptions','');
   },
    handlefolderChange : function(component,event,helper) {
        var folderField = component.find('folder');
        var folder = folderField.get('v.value');
      	component.set('v.CSRFolder',folder);
        
        var action = component.get("c.getEmails");
        action.setParams({ 
            "foldername":folder
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var templateField = component.find("template");
                templateField.set('v.disabled',false);
                let resp =response.getReturnValue() ;
                let lables= [] ; 
                resp.forEach(function(key) {
                    console.log('developername ' + key.DeveloperName); 
                    lables.push({"label":key.Name ,"value":key.DeveloperName	});
                });
                component.set("v.templateoptions", lables);
                //   cmp.set("v.contactList", response.getReturnValue());
            }
            
        })
        
        $A.enqueueAction(action);
        
        
    },
    handletemplatechange:function(component,event,helper){
        var templateField = component.find('template');
        var template = templateField.get('v.value');
      	component.set('v.CSRTemplate',template);
        console.log(template);
        
       var action = component.get("c.getEmailContents");
	    action.setParams({ 
            "templatename":template
	    });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
               
                let resp =response.getReturnValue() ;
                component.set('v.TempText',resp);
            }
            
        })
        
        $A.enqueueAction(action);
    },
    
    saveText: function(component,event,helper){
        var conf = true;
        if(component.get('v.ReplyText') != ''){
            conf = confirm('This will overwrite the message previously entered. Do you want to continue ?');
        }
        if(conf == true){
            component.set('v.ReplyText',component.get('v.textMessage'));
            component.set("v.isOpen", false);
            //component.set('v.ReplyText','');
            component.set('v.currentStep','0');
            //component.set('v.textMessage','');
            component.set('v.TempText','');
            component.set('v.lstObj',[]);
            //component.set('v.options','');
            //component.set('v.templateoptions','');
        }
    },
     moveBack : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
        v = v - 1;
        component.set('v.currentStep',v.toString());
    },
    moveNext : function(component,event,helper){
        var v = parseInt(component.get('v.currentStep'),10);
        if(v == 0){
            helper.stepOneNext(component,event,helper);
        }else if(v == 1){
            helper.stepSecondNext(component,event,helper);
        }else{
            v = v + 1;   
            component.set('v.currentStep',v.toString());
        }
    },
    handleCheckTask: function(component,evt,helper){
         var checkbox = evt.getSource();
        console.log(checkbox.get("v.value"));
        component.set('v.SendSMS',checkbox.get('v.value'));
        component.set('v.isChanged',true);
    }
    
   
 
})