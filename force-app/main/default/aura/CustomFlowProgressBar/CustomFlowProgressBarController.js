({
   init : function(component, event, helper) {
       
      var device = $A.get("$Browser.formFactor");
      var progressIndicator = component.find('progressIndicator');
      console.log(device);
      for (let step of component.get('v.stages')) {
          
          if(device == 'DESKTOP'){
              setTimeout(function(){ document.getElementById("pBarId").style.width = "65%";  }, 1);
          }
          
          
         $A.createComponent(
            "lightning:progressStep",
            {
               "aura:id": "step_" + step,
               "label": step,
               "value": step
             },
             function(newProgressStep, status, errorMessage){
                // Add the new step to the progress array
                if (status === "SUCCESS") {
                    
                    
                    
                    
                   var body = progressIndicator.get("v.body");
                   body.push(newProgressStep);
                   progressIndicator.set("v.body", body);
                 }
                 else if (status === "INCOMPLETE") {
                    // Show offline error
                    console.log("No response from server, or client is offline.")
                  }
                  else if (status === "ERROR") {
                     // Show error message
                     console.log("Error: " + errorMessage);
                  }
              }
           );
       }
       
      
   }
    
})