({
	 isFormValid: function (component) {
         return (component.find('{!field.ApiName}') || [])
        .filter(function (i) {
            var value = i.get('v.value');
            var val = i.get('v.fieldName');
            console.log(value);
            if(val == 'Org_Departure_Date__c' || val == 'Org_Product_Type__c' ||val == 'Number_of_children_below_12__c'||val == 'Org_Traveller__c'||val == 'Org_Destinations__c'||val == 'Org_Preferred_Cabin__c'||val == 'Org_No_of_Adults_Travelling__c'||val == 'EKUK_TM_Marketing_Source__c'){
            	return !value || value == '' || value.trim().length === 0;
            }
        })
        .map(function (i) {
            console.log(i.get('v.fieldName'));
           var val = i.get('v.fieldName');
            
            console.log('val'+val);
            if(val == 'Org_Departure_Date__c' || val == 'Org_Product_Type__c' ||val == 'Number_of_children_below_12__c'||val == 'Org_Traveller__c'||val == 'Org_Destinations__c'||val == 'Org_Preferred_Cabin__c'||val == 'Org_No_of_Adults_Travelling__c'||val == 'EKUK_TM_Marketing_Source__c'){
                 return i.get('v.fieldName');
            }
           
        });
	}
})