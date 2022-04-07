({
	doInit : function(component, event, helper) {
		/*debugger;
        console.log('Result table Component');*/  
        var displaytable = false;
        
        // for view all modal changed component.get("v.tableRecords") to component.get("v.tableRecordsAll")
        // getting all records
        var tableRecords = component.get("v.tableRecordsAll");
        
        // start - for view all modal
        console.log('tableRecords');
        console.log(tableRecords);
        var recordlimit = parseInt($A.get('$Label.c.GDPR_Record_Page_Limit'));
        if(tableRecords.length > recordlimit){
            component.set("v.viewAll",true);
            component.set("v.tableRecords", tableRecords.slice(0, recordlimit));
        }
        else{
            component.set("v.tableRecords", tableRecords);
        }
        
        // display selected from modal as well on step 3
        /*if(component.get("v.stepNumber") == 3){
            var tableRecordsAll = component.get("v.tableRecordsAll");
            component.set("v.tableRecords", tableRecordsAll);
        }*/
        // end - for view all modal
        
        // check if the step is 2 or 3
        var isNonSelectable = component.get("v.isNonSelectable");
        
        // if step 3
        if(isNonSelectable){
        	
            // for each record
            for(var ele in tableRecords){
                if(tableRecords[ele].isSelected){
                    displaytable = true;
                }
            }           
        }
        
        // if step 2
        else{
            // for each record
            for(var ele in tableRecords){
                displaytable = true;
            } 
        }
        component.set("v.displaytable",displaytable);
	},
    
    updateSelectionTrue : function(component, event, helper) {		
        
        //Show Spinner
        component.set("v.showSpinner",true);
        window.setTimeout(
            $A.getCallback(function() {
               component.set("v.showSpinner",false);
            }), 300
        );
        
        var indexNumber = event.currentTarget.name;
        console.log("index number :: "+indexNumber);
        
        if(!$A.util.isUndefinedOrNull(indexNumber)){
            var lstRecords = component.get("v.tableRecords");
            // added if condition for view all modal
            if(indexNumber < lstRecords.length){
                lstRecords[indexNumber].isSelected = true;
                component.set("v.tableRecords",lstRecords);
            }
            
            // start - for view all modal
            var tableRecordsAll = component.get("v.tableRecordsAll");
            tableRecordsAll[indexNumber].isSelected = true;
            component.set("v.tableRecordsAll",tableRecordsAll);
            // end - for view all modal
            
            //Call Toast Method
            helper.showSuccessToast(component, event, helper, 'Record is added for review');
        }
        
        //Show Spinner
       // component.set("v.showSpinner", false);
	},
    
    updateSelectionFalse : function(component, event, helper) {
		debugger;

        var indexNumber = event.currentTarget.name;
        console.log("index number :: "+indexNumber);
        /*if(!$A.util.isUndefinedOrNull(indexNumber)){
            var lstRecords = component.get("v.tableRecords");
            lstRecords[indexNumber].isSelected = false;
            component.set("v.tableRecords",lstRecords);
        }*/
        
        component.set("v.SelectedRecIndexNumber", indexNumber);
        component.set("v.showRemoveModal", true);
        
        // for view all modal
        helper.addOpacityViewAll(component, event, helper);
	},
    
    buttonActionChange : function(component, event, helper){
        debugger;
        var bAction = component.get("v.buttonAction");
        if(bAction != undefined){
            var indexNumber = component.get("v.SelectedRecIndexNumber");
            var lstRecords = component.get("v.tableRecords");
            // for view all modal
            var tableRecordsAll = component.get("v.tableRecordsAll");
            
            if(bAction == 'closeAction'){
                component.set("v.showRemoveModal",false);
                component.set("v.SelectedRecIndexNumber",undefined);
            }
            if(bAction == 'likeAndCloseAction' && !$A.util.isUndefinedOrNull(indexNumber)){
                // added if condition for view all modal
                if(lstRecords.length > indexNumber){
                    lstRecords[indexNumber].isSelected = false;
                    component.set("v.tableRecords",lstRecords);
                }
                
                // start - for view all modal
                tableRecordsAll[indexNumber].isSelected = false;
                component.set("v.tableRecordsAll",tableRecordsAll);
                // end - for view all modal
                
                component.set("v.showRemoveModal",false);
                component.set("v.SelectedRecIndexNumber",undefined);
            }
            //Set button action 
            component.set("v.buttonAction", undefined);
            
            // for view all modal
            helper.removeOpacityViewAll(component, event, helper);
        }
    },
    
    openView : function(component, event, helper){        
        var indexNumber = event.currentTarget.name;
        console.log("index number :: "+indexNumber);
        debugger;
        if(!$A.util.isUndefinedOrNull(indexNumber)){
            // for view all modal changed component.get("v.tableRecords") to component.get("v.tableRecordsAll")
            var lstRecords = component.get("v.tableRecordsAll");
            var recId = lstRecords[indexNumber].Id;
            component.set("v.recId",recId);
            component.set("v.displayChildRecordsModal",true);
            
        }
        
        // for view all modal
        helper.addOpacityViewAll(component, event, helper);
    },
    
    // for view all modal
    showAll : function(component, event, helper){
        //component.set("v.tableRecords", component.get("v.tableRecordsAll"));
        component.set("v.viewAllModal", true);
    },
    
    // for view all modal
    closeModal : function(component, event, helper){
        //component.set("v.tableRecords", component.get("v.tableRecordsAll"));
        component.set("v.viewAllModal", false);
    },
    
    // for view all modal
    changeOpacity : function(component, event, helper){
        helper.removeOpacityViewAll(component, event, helper);
    },
    
})