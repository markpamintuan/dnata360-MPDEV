({
	doInit : function(component, event) { 
        var action = component.get("c.searchResult");
        action.setParams({
            srchstr : component.get("v.searchstr"),
            sobjname   : component.get("v.objName")
        });
        action.setCallback(this, function(response){
            var searchreturn = response.getReturnValue();
            var state = response.getState();
            if(state === "SUCCESS" && searchreturn!=null){
                component.set("v.showresults",true);
                component.set("v.searchresults",searchreturn);
                
            }   
        });
        $A.enqueueAction(action); 
        
    }
})