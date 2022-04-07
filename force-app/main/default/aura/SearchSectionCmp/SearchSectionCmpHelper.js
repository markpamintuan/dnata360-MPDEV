({
    getSearchRecord : function(component) {        
        var recId = component.get("v.recordId");        
        var searchFieldSetName = component.get("v.searchFieldSetName");
        
        //get instance of server side method
        var action = component.get('c.getsearchForm');
        
        //show spinner
        component.set("v.Spinner",true);
        
        //pass account Id to controller method
        action.setParams({
            recId : recId,
            searchFieldSetName : searchFieldSetName
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {                
                var result = response.getReturnValue();
                component.set("v.searchSectionFields",result);
                component.set("v.Spinner",false);
            }else{
                /*
                var showToast = $A.get("e.force:showToast"); 
                showToast.setParams({ 
                    title : 'Error!', 
                    message : 'Error in calling Server Method',
                    type: 'error',
                }); 
                showToast.fire();
                */
            }
        });
        
        //adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    getSearchedRecords : function(component) {
        //show spinner
        component.set("v.Spinner",true);
        
        var searchFieldSetName = component.get("v.searchFieldSetName");
        var displayFieldsSetName = component.get("v.displayFieldSet");
        var recId = component.get("v.recordId");
        var searchCriteria = component.get("v.searchedValues");
        var linkingField = component.get("v.linkingfield");
        var possibleRecs = component.get("v.possibleRecs");
        
        //get instance of server side method
        var action = component.get('c.fetchSearchRecords');
        var searchParam = JSON.stringify(searchCriteria);        
        
        if($A.util.isUndefinedOrNull(searchCriteria)
           || searchParam == '{}'){
            
            // setting message                    
            component.set("v.Message",'Please Enter Value for searching');
            
            // display Tost
            component.set("v.displayTostMsg",true);
            
            //hide spinner
            component.set("v.Spinner",false);
            
            // hide search action    		
            component.set("v.displaySearchTable",false);  
            
            return;
        }
        
        //pass account Id to controller method
        action.setParams({
            recordId : recId,
            searchValues : searchParam,
            displayFieldSetName : displayFieldsSetName,
            searchFieldSetName : searchFieldSetName,
            linkedField : linkingField,
            excludeRecords : JSON.stringify(possibleRecs)
        });
        
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {                
                debugger;                                
                // checking if the length of the search result is not null
                if(!response.getReturnValue().hasRecords){
                    // setting message                    
                    component.set("v.Message",'No record Found');
                    
                    // hide search action    		
                    component.set("v.displaySearchTable",false);  
                    
                    // display Tost
            		component.set("v.displayTostMsg",true);
                }
                else{
                    
                    // display Tost            		
                    component.set("v.displaySearchTable",true);                    
                    component.set("v.SearchedRecords",response.getReturnValue());
                }
            }else{
                /*
                var showToast = $A.get("e.force:showToast"); 
                showToast.setParams({ 
                    title : 'Error!', 
                    message : 'Error in calling Server Method',
                    type: 'error',
                }); 
                showToast.fire();
                */
            }
            
            //hide spinner
            component.set("v.Spinner",false);
        });
        
        //adds the server-side action to the queue.
        $A.enqueueAction(action);
    }
})