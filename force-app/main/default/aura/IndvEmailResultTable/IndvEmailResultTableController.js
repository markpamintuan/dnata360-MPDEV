({
      doInit: function(component, event, helper) {
        // Fetch the cbigObject list from the Apex controller
        helper.getBig(component, event, helper);
        
      },
    
      handleClick: function(cmp, event, helper) 
      {
        var MergeID = event.currentTarget.dataset.mergeid;
        var RelObjID = event.currentTarget.dataset.relobjid;
        var RelSendID = event.currentTarget.dataset.relsendid;
          
        var navService = cmp.find("navService");
        var pageReference = {
								"type": "standard__component",
                                "attributes": {
                                    "componentName": "c__IndvEmailResultDetail"    
                                },    
                                "state": {
                                    "c__MergeID":MergeID,
                                    "c__RelObjID":RelObjID,
                                    "c__RelSendID":RelSendID
                                }
                            };
        cmp.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        
         navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) 
        {
             cmp.set("v.url", url ? url : defaultUrl);
             var pageReference = cmp.get("v.pageReference");
             event.preventDefault();
             navService.navigate(pageReference);
        }), $A.getCallback(function(error) {
            cmp.set("v.url", defaultUrl);
        }));  
        
          
       
      }
   
     
    })