({
	fetchEmailHelper : function(component, event, helper) {
        var action = component.get("c.fetchEmailResultArchive");
        var requestWrap =
            {
                MergeID : component.get("v.MergeID"),
                RelObjID : component.get("v.RelObjID"),
                RelSendID : component.get("v.RelSendID")
            }
         action.setParams(
                              {
                                 "requestWrapParam": JSON.stringify(requestWrap)
                              }
          				  );
     
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
            	var emailResultObj = response.getReturnValue().emailResultObj;
                component.set("v.emailResultObj", emailResultObj);
               // component.set("v.mergeId", emailResultObj.MergeId__c);
                component.set("v.emailResWrapLst", response.getReturnValue().emailResWrapLst);
                
            }
        });
        $A.enqueueAction(action);
    },

	
})