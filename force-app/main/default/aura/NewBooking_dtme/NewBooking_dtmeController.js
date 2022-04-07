({

    doInit: function(component, event, helper) {
        debugger;
        helper.autoCreateCase(component, event, helper);       
    },
    /*
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            var a = component.get('c.newCommendations');
            $A.enqueueAction(a);
            
        } 
    }*/
})