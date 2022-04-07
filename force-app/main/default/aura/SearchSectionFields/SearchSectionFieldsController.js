({
    /** 
     * This Method will be used to save the values enetered to the
     * Object which will be used in searching 
     ***/
    valueChanged : function(component, event, helper) {      
        
        // getting main object in which values will be saved
        var searchValues = component.get("v.searchInput");
        
        // getting field name which will used to set the attribute
        var currentfieldDetails = component.get("v.currentFieldDetails");
        var fieldAPIName = currentfieldDetails.fieldAPIName;
        
        // checking if the object is null or empty
        if($A.util.isEmpty(searchValues))
            searchValues = {};
        
        // assign enetered values
        searchValues[fieldAPIName] = component.get("v.Recordval");  
        
        debugger;
        var newObj = {};
        for(var key in searchValues) {
            var value = searchValues[key];            
            if(!$A.util.isUndefinedOrNull(value)
              	&& !$A.util.isEmpty(value)){
                newObj[key] = value;                
            }
        }        
        
        // Updating Attribute
        component.set("v.searchInput",newObj);
    },    
    
})