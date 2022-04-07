/****
*  This is the Apex class which is used for validating the selected object records
**/
public class GDPRValidationRecords implements Queueable {    
    
    // thsi will save the map of query number and child record details
    public map<string,List<string>> mapPreviousChildQueryResult {get;set;}
    
    // this will save the selected object ids
    public string selectedObjectId {get;set;}
    
    // this will save the selected object ids
    public string selectedTrackerId {get;set;}
    
    // constructor
    public GDPRValidationRecords(string selectedObjectId, string selectedTrackerId, map<string,List<string>> mapPreviousChildQueryResult){
        
        this.selectedObjectId = selectedObjectId;
        this.selectedTrackerId = selectedTrackerId;
        this.mapPreviousChildQueryResult = mapPreviousChildQueryResult;
    }
    
    // this is constructor which will help in hodling data
    @AuraEnabled
    public static void startValidateProcess(string trackerId){        
        system.debug('\n-------------------------------STEP 1-------------------------------\n\n\n RESETTIG THE QUERY STATUS - CALLING GDPRUtility.resetQueryStatus(trackerId); \n\n\n---------------------------------------------------------------------');
        // rest the status of child query
        GDPRUtility.resetQueryStatus(trackerId);
        system.debug('\n-------------------------------STEP 2-------------------------------\n\n\n RESETTIG THE JOB TRACKER - CALLING GDPRUtility.resetTracker(trackerId); \n\n\n---------------------------------------------------------------------');
        // rest the status of child query
        GDPRUtility.resetTracker(trackerId); 
        
        // validate selected object
        validateSelectedObject(trackerId);
    }
    
    // this is the method which will be called for new selected object validation
    public static void validateSelectedObject(string trackerId){
        system.debug('-------------GDPRValidationRecords-------validateSelectedObject--------trackerId' + trackerId);
        // this will save the selected object record to be processed
        List<GDPR_Child_Query__c> lstNonStartedQueryRecords = GDPRUtility.fetchNextSelectedObject(trackerId);
        // checking if we any selected object to be validated
        if(!lstNonStartedQueryRecords.isEmpty()){           
            GDPRValidationRecords validateChild = new GDPRValidationRecords(lstNonStartedQueryRecords[0].GDPR_Selected_Object__c, lstNonStartedQueryRecords[0].GDPR_Selected_Object__r.GDPR_Job_Tracker__c, new map<string,List<string>>());
            System.enqueueJob(validateChild);               
        }
        
        //this means that processing is completedthen update the tracket object with sumamry
        else{
            
            // getting all selected object
            List<GDPR_Selected_Object__c> lstSelectedObject = GDPRUtility.getAllSelectedObjext(trackerId);
            
            // this will save the summary
            string summary = updateSummary(trackerId);            
            
            //update tracker
            GDPR_Job_Tracker__c trackertObj = new GDPR_Job_Tracker__c(id = trackerId, Summary__c = summary);
            trackertObj.Status__c = getTrackerValidateStatus(summary);
            
            update trackertObj;
            
            // start processing
            //calling processing methods
			system.debug('\n-------------------------------CALLING PROCESS RECORDS-------------------------------\n');
            GDPRProcessRecords.startProcessing(trackerId); // need to uncomment if want to perform the validation and processing in 1 go
        }
        
    }
    
    /***
*  This method will run and enqueue job is enqueued for validation if child objects
**/
    public void execute(QueueableContext context) {
        
        // creating save point
        Savepoint sp = Database.setSavepoint();
        // getting the next record of child object to be processed
        List<GDPR_Child_Query__c> lstValidateChildRecs = GDPRUtility.fetchNextSelectedObjectQuery(selectedObjectId);
        try{            
            
            // if we have any object to be validated  
            if(!lstValidateChildRecs.isEmpty()){
                
                // code for process the record (need to discuss)
                GDPRProcessChildqueries processQuery = new GDPRProcessChildQueries();                
                map<string,List<string>> mapChildQueryResult = processQuery.processChildQuery(lstValidateChildRecs[0], mapPreviousChildQueryResult); 
                
                system.debug('--------------------------CALLING ROLLBACK AFTER PROCESSING CHILD QUERIES-------------------------');
                
                // rolling back the process records
                Database.rollback( sp );
                
                // code for update the status of child object
                GDPRUtility.updateQueryStatus(lstValidateChildRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_Validated);
                
                // calling enqueue job again
                //if(!Test.isRunningTest()){
                    system.debug('--------------------------CALLING GDPRValidationRecords-------------------------');
                    GDPRValidationRecords validateChild = new GDPRValidationRecords(selectedObjectId, selectedTrackerId, mapPreviousChildQueryResult);
                    System.enqueueJob(validateChild);
                //}
            }
            
            // if we do not have any child object to be processed
            else{
                GDPRValidationRecords.validateSelectedObject(selectedTrackerId);
            }
        }
        catch(Exception ex){
            
            // logging error 
            Database.rollback( sp );
            
            // update the child query to error
            if(!lstValidateChildRecs.isEmpty()){
                GDPRUtility.updateQueryStatus(lstValidateChildRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED, ex.getMessage() + '\n StackTrace# '+ex.getStackTraceString());//+ '\n Line# '+ex.getLineNumber()
            }
            
            string summary = updateSummary(selectedTrackerId);
            
            //update tracker
            GDPR_Job_Tracker__c trackertObj = new GDPR_Job_Tracker__c(id = selectedTrackerId, Summary__c = summary);
            trackertObj.Status__c = getTrackerValidateStatus(summary);
            update trackertObj;
            
            
            
        }
    }
    
    // it will return the status of tracker ( after validation )
    private static String getTrackerValidateStatus(String summary){
        if(String.isNotBlank(summary) && summary.contains('Error')){
            return 'Validation Fail';
        }
        //default status
        return 'Validation Success';        
    }
    
    private static string updateSummary(string trackerId){
        
        // this will save teh summary
        string summary = 'Validate Status';
        
        // this will save all the child records
        List<GDPR_Child_Query__c> lstProcessedChild = new List<GDPR_Child_Query__c>();
        
        // getting all child records
        for(GDPR_Selected_Object__c selectedObj : GDPRUtility.querySelectedObjectRecord(trackerId)){            
            
            // for child
            for(GDPR_Child_Query__c childQuery : selectedObj.GDPR_Child_Queries__r){
                lstProcessedChild.add(childQuery);
            }
        }
        
        // gtting quick summary 
        string errorSummary = fetchFailedObject(lstProcessedChild);
        system.debug('\n--errorSummary--'+errorSummary);
        
        
        // checking if the summary is empty which means that no error
        if(!string.isBlank(errorSummary)){
            summary += '\n'+errorSummary;
        }
        
        // getting the success sumamry
        else{           
            
            // savign summary for success
            summary += '\nAll items are Validated Successfully \n Total number child queries: '+lstProcessedChild.size();           
        }
        
        
        system.debug('\n--final--'+summary);
        return summary;
    }
    
    
    private static string fetchFailedObject(List<GDPR_Child_Query__c> lstChildQuery){
        
        // this will save the text for the summary (error part)
        string summary = '';
        
        // checking if the status is failed then return the select object name
        for(GDPR_Child_Query__c childQuery : lstChildQuery){            
            if(childQuery.Job_Status__c == GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED){
                summary += 'Error While Validation - Selected Object Name '+childQuery.GDPR_Selected_Object__r.Object_API_Name__c+'\nChild Query Number :'+childQuery.Query_Order_Number__c+'\nChild Object Name : '+childQuery.Object_API_Name__c;
                summary += '\n Error message: '+childQuery.Job_Error__c;
                summary += '\n Record Id: '+childQuery.Id;                
                return summary;
            }
        }
        return summary;
    }
    
    
}