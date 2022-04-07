({
	doInit : function(component, event, helper) {
		debugger;
        var bookingSFId = component.get("v.recordId"); 
        var derwentBookingId = '';
        var bookingRec ='';
        
                //Need to delay until modal opens
        setTimeout(function(){
            bookingRec = component.get("v.bookingRecord");
            derwentBookingId = bookingRec.Booking_ID__c;
        if(derwentBookingId =='' || derwentBookingId == null){
        $A.get("e.force:closeQuickAction").fire();
            setTimeout(function(){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'There is no Derwent Id for this',               
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }, 1000);
        }else{
            $A.get("e.force:closeQuickAction").fire();
            //Enter label here: Danube_Booking_Page
            //$A.get("$Label.c.EKUK_Enquiry_Case_Record_Type_ID");
			window.open($A.get("$Label.c.View_Danube_Booking") + $A.get("$Label.c.ekh_Tenant_Id") + '/'+ derwentBookingId, "_blank");
            //window.open('https://www2.dnataagentdesktop.com/update_booking/' + $A.get("$Label.c.ekh_Tenant_Id") + '/'+ derwentBookingId, "_blank");
        }
            
        }, 1000);
	}
})