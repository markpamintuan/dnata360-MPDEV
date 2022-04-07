({
    initializeMethod : function(component,event,helper) {
        helper.getSearchRecord(component);
    },
    
    search : function(component,event,helper) { 
        helper.getSearchedRecords(component);
    },
    
    callSearchmethod : function(component,event,helper) {    
        debugger;
        if(component.get("v.searchRecords")){
            helper.getSearchedRecords(component);
            component.set("v.searchRecords",false);
        }        
    }, 
})