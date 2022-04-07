({
	doInit : function(component, event, helper) {       
		var record = component.get("v.record");
        var field = component.get("v.field");
        
        /*console.log('record ==>> '+JSON.stringify(record));
        console.log('field ==>> '+JSON.stringify(field));
        console.log("record Field Data ::: "+record[field.fieldLabel]);
        console.log('');*/
        //component.set("v.cellValue", record[field.fieldAPIName]);
        if(field.fieldAPIName == 'Parent.CaseNumber'){
            if(record.Parent != undefined){
                component.set("v.cellValue", record.Parent.CaseNumber);
            }
            //component.set("v.cellValue", record[field.fieldAPIName]);
        }
        else{
            component.set("v.cellValue", record[field.fieldAPIName]);
        }
        if(field.fieldType == 'STRING' || field.fieldType == 'PICKLIST')
            component.set("v.isTextField", true);
        else if(field.fieldType == 'DATE'){
        	component.set("v.isDateField", true);
        }
        else if(field.fieldType == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }
        else if(field.fieldType == 'DOUBLE' || field.fieldType == 'INTEGER'){
        	component.set("v.isNumberField", true);
        }
        else if(field.fieldType == 'PERCENT'){
        	component.set("v.isPercentField", true);
        }
        else if(field.fieldType == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }
        else if(field.fieldType == 'EMAIL'){
        	component.set("v.isEmailField", true);
        }
        else if(field.fieldType == 'PHONE'){
        	component.set("v.isPhoneField", true);
        }
        else if(field.fieldType == 'BOOLEAN'){
        	component.set("v.isBooleanField", true);
        }
        else if(field.fieldType == 'REFERENCE'){
            
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.fieldAPIName.indexOf('__c') == -1) {
                relationShipName = field.fieldAPIName.substring(0, field.fieldAPIName.indexOf('Id'));
            }
            else {
                relationShipName = field.fieldAPIName.substring(0, field.fieldAPIName.indexOf('__c')) + '__r';
            }
            
            if(record[relationShipName] != undefined){
                console.log('record[relationShipName].Name :: '+record[relationShipName].Name);
                component.set("v.cellLabel", record[relationShipName].Name);
            }
        }
	}
})