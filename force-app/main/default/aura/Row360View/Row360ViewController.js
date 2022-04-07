({
    getRecField : function(component, event, helper) {  
        //debugger;        
        if(!component.get("v.isActionCol")){ 
            
            // getting record data
            var record = component.get("v.record");
            console.log(record);
            
            // getting field name
            var field = component.get("v.field");
            
            var header = component.get("v.header");
            
            // getting field name for reference field
            if(header.fTypes.isReference){
                var index = field.indexOf(".Name");
                if(index >= 0){
                    field = field.replace(".Name","");
                }
            }
            
            // getting value field from record by checking field is reference or not
            if(!$A.util.isUndefined(record)){
                if(header.fTypes.isReference){
                    if(!$A.util.isUndefined(record[field])){
                        component.set("v.cellValue", record[field].Name); 
                    }
                }else{
                    if(!$A.util.isUndefined(record[field])){
                        component.set("v.cellValue", record[field]); 
                    }
                }
            }
        }
    },
    
    handleActionclick : function(component, event, helper) { 
		debugger;
        console.log('### Row360');
        var actionName = component.get("v.actionColText").toLowerCase().replace(/\s/g,'');         
        component.set("v.actionName", actionName); 
        component.set("v.selectedRecord", component.get("v.record"));
		       
    }
})