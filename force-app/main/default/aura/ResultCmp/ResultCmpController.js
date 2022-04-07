({
    /**
     * This method will be called when component is loaded
     ***/
	doInit : function(component, event, helper) {
        debugger;        
        
        // getting if we have any existing data
        var objResultList = component.get("v.resultWrapList");
       	
        // if existing data is present then do not do any thing
        if(objResultList == undefined){
          helper.getSearchObjectsDataList(component, event, helper); 
       }
       
       // if existing data is not present then call apex class to ger result
       else if(objResultList.length == 0){
           helper.getSearchObjectsDataList(component, event, helper);
       }        
	},
    
    
})