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
                    message: 'There is no Derwent Id for available',               
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }, 1000);
        }else{
            $A.get("e.force:closeQuickAction").fire();
			var windowURL = $A.get("$Label.c.Derwent_Booking_Page_dTME")+"?BookingID="+component.get('v.bookingRecord.Booking_ID__c');
            console.log(windowURL);
            var popupWindow = window.open(windowURL, "_blank");
        }
            
        }, 1000);
	}
})