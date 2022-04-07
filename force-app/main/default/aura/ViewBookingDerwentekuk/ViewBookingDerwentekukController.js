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
            $A.get("e.force:closeQuickAction").fire();
        if(derwentBookingId =='' || derwentBookingId == null){

        
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
            }, 2000);
        }else{
            
            var windowURL = $A.get("$Label.c.Derwent_Booking_Page_ekuk")+"?BookingID="+component.get('v.bookingRecord.Booking_ID__c');
            var popupWindow = window.open(windowURL, "_blank");
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
            
        }, 1000);
        $A.get('e.force:refreshView').fire();
        
	}
})