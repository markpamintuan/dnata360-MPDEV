({
    createMapOfBookingType: function(bookedItems) {
        debugger;
        for (var bookingHeader in bookedItems) {
            var masterListBookingHeader = [];
            var mainMap = {}; //This will keep the overall track of the new object

            for (var val in bookedItems[bookingHeader].Bookings__r) {
                var newBookingsValuesArray = []; //This intialises the value as a list

                if (!mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c]) {
                    newBookingsValuesArray.push(bookedItems[bookingHeader].Bookings__r[val]);
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c] = newBookingsValuesArray;
                } else {
                    mainMap[bookedItems[bookingHeader].Bookings__r[val].Org_Booking_Type__c].push(bookedItems[bookingHeader].Bookings__r[val]);
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
            bookedItems[bookingHeader].Bookings__r = masterListBookingHeader;
        }
        return bookedItems;
    },
    getAllTabInfo : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log(response);
       })
        .catch(function(error) {
            console.log(error);
        });
    }
})