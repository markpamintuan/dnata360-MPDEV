({
    createMapOfBookingType: function(bookedItems) {
        debugger;
         var masterListBookingHeader = [];

            var mainMap = {}; //This will keep the overall track of the new object
        for (var bookingHeader in bookedItems) {
                   var newBookingsValuesArray = []; //This intialises the value as a list
				
                if (!mainMap[bookedItems[bookingHeader].Org_Booking_Type__c]) {
                    newBookingsValuesArray.push(bookedItems[bookingHeader]);
                   
                    mainMap[bookedItems[bookingHeader].Org_Booking_Type__c] = newBookingsValuesArray;
                } else {
                   
                    mainMap[bookedItems[bookingHeader].Org_Booking_Type__c].push(bookedItems[bookingHeader]);
                }
          
        } 
            
            //BReak out into another method
            for (var valueInTempMap in mainMap) {
                var objDef = { bookingtype: '', records: [] };
                var valuesList = mainMap[valueInTempMap];               
                objDef.bookingtype = valueInTempMap;
                objDef.records = valuesList;
                masterListBookingHeader.push(objDef);
            }          
        	console.log(masterListBookingHeader);
            bookedItems = masterListBookingHeader;
        
        console.log(bookedItems);
        return bookedItems;
    }
})