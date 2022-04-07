({
    onload : function(component, event, helper) {
        debugger; 
        // checking do we have any selected records
        var allRecs = component.get("v.resultWrapList");
        
        // thhis will save the object name and list of records
        var selectedRecsData = [];
        
        // for each record
        for(var ele in allRecs){
            
            var selectedRec = {};
            
            if(allRecs[ele].lstRecords != undefined
               && allRecs[ele].lstRecords.length > 0){
                
                // saving the object name
                selectedRec.objectName = allRecs[ele].Object_Name;
                var lstRecs = [];
                
                // for each record check if any of the record is selected
                for(var rec in allRecs[ele].lstRecords){                    
                    
                    // if record is selected then set the step and return
                    if(allRecs[ele].lstRecords[rec].isSelected){
                        lstRecs.push(allRecs[ele].lstRecords[rec].Id);
                    }
                }
                
                // updating object
                selectedRec.recList = lstRecs;
                
                // updating main list
                selectedRecsData.push(selectedRec);
            }            
        }
        
        // calling helper class to pass the records to be processed
        helper.processRecords(component, event, helper, selectedRecsData);
    }
})