({
	createComplaintCase: function(component, event, helper) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        console.log(today);
        var d1 = new Date(component.get('v.simpleRecord.Org_Travel_Start_Date__c'));
        var d2 = new Date(component.get('v.simpleRecord.Org_Travel_End_Date__c'));
        console.log(d1 + d2);
        var dt  = new Date(today);
        console.log(dt);
        var startdateislessthantoday = d1 < dt;
        var enddateisgreaterthantoday = d2 > dt;
        var two = startdateislessthantoday + enddateisgreaterthantoday; // two will be set to 2 if both are true above.
        var subject = '';
        if(two == 2){
            subject = 'IR Complaint For ' + component.get('v.simpleRecord.Org_Account_Name__r.Name');
        }else{
            subject = 'IR Complaint For ' + component.get('v.simpleRecord.Org_Account_Name__r.Name');
        }
        var recordId = component.get("v.recordId");
        var simpleRecordAccount = component.get("v.simpleRecord.Org_Account_Name__c");
        var simpleRecordBookingheader = component.get("v.simpleRecord.Booking_Header__c");
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId": "0122X000000oqqFQAQ",
            "defaultFieldValues": {
                'AccountId' : simpleRecordAccount,  
                'Subject' : subject,
                'Org_Booking__c' : simpleRecordBookingheader,
                'Org_Customer_Journey_Point__c' : 'In Resort'
                
            }
        });
        createRecordEvent.fire();
    },
})