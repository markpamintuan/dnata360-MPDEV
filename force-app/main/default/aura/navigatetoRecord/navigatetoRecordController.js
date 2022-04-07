({
	invoke : function(component, event, helper) {
		// Get the record ID attribute
        var record = component.get("v.recordId");
        var derwentCustomerId = component.get("v.derwentCustomerId"); 
        var cid = component.get("v.caseId");
        
        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");
        
        // Pass the record ID to the event
        redirect.setParams({
        "recordId": record
        });
        
        // Open the record
        redirect.fire();
        if(derwentCustomerId != null){
        	window.open($A.get("$Label.c.Danube_Booking_Page") + $A.get("$Label.c.ekh_Tenant_Id") + '/' + derwentCustomerId + '?trackingTag=' + cid , "_blank");   
        }
        
        //window.open("http://www.google.com", "_blank");   //KR added this
	}
})