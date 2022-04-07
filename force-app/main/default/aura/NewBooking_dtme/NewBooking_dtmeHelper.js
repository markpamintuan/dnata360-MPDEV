({
	autoCreateCase : function(component, event, helper){
        var action = component.get("c.autoCreateCase");
        var accid = component.get("v.recordId");
        var rtid = $A.get("$Label.c.dTME_Enquiry_Case_Record_Type_ID");
        var parentRecordDetails = component.get("v.recordInfo");
        action.setParams({
            "accid": accid,
            "rtid": rtid,
            "subject": "New Booking for " + parentRecordDetails.Name 
        });
        action.setCallback(this, function(response) {
            debugger;
            if (response.getState() == "SUCCESS") {
                var cid = response.getReturnValue();
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                     "recordId": cid
               	});
                editRecordEvent.fire();
                //var popupWindow = window.open($A.get("$Label.c.ADT_Customer_Page"), "_blank");
            }
        });
        $A.enqueueAction(action);
        //var a = component.get('c.defaultCloseAction');
        //$A.enqueueAction(a);
    },
    /*
    defaultCloseAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, */
    
})