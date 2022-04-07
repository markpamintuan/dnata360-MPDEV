/****
 *  This is the Apex class which is used for processing the selected object records
 **/
public class GDPRProcessRecords implements Queueable {     
    
    // thsi will save the map of query number and child record details
    public map<string,List<string>> mapPreviousChildQueryResult {get;set;}
    
    // this will save the selected object ids
    public string selectedObjectId {get;set;}
    
    // this will save the selected object ids
    public string selectedTrackerId {get;set;}
    
    // constructor
    public GDPRProcessRecords(string selectedObjectId, string selectedTrackerId, map<string,List<string>> mapPreviousChildQueryResult){
        this.selectedObjectId = selectedObjectId;
        this.selectedTrackerId = selectedTrackerId;
        this.mapPreviousChildQueryResult = mapPreviousChildQueryResult;
    }
     
    // this is constructor which will help in hodling data
    public static void startProcessing(string trackerId){        
        
        // rest the status of child query
        //GDPRUtility.resetQueryStatus(trackerId);
        
        // validate selected object
        processSelectedObject(trackerId);
    }
    
    // processing the selected object
    public static void processSelectedObject(string trackerId){
        
        // this will save the selected object record to be processed
        List<GDPR_Child_Query__c> lstNonStartedQueryRecords = GDPRUtility.fetchSelectedObjectProcessing(trackerId);
        
        // checking if we any selected object to be validated
        if(!lstNonStartedQueryRecords.isEmpty()){           
            GDPRProcessRecords processChild = new GDPRProcessRecords(lstNonStartedQueryRecords[0].GDPR_Selected_Object__c, lstNonStartedQueryRecords[0].GDPR_Selected_Object__r.GDPR_Job_Tracker__c, new map<string,List<string>>());
            System.enqueueJob(processChild);               
        }
        
        //this means that processing is completedthen update the tracket object with sumamry
        else{
            
            // getting all selected object
            List<GDPR_Selected_Object__c> lstSelectedObject = GDPRUtility.getAllSelectedObjext(trackerId);
            
            // this will save the summary
            string summary = updateSummary(trackerId);            
            
            //update tracker
            GDPR_Job_Tracker__c trackertObj = new GDPR_Job_Tracker__c(id = trackerId, Summary__c = summary);
            trackertObj.Status__c = getTrackerProcessStatus(summary);
            update trackertObj;
        }        
    }
    
    /***
     *  This method will run and enqueue job is enqueued for validation if child objects
     **/
    public void execute(QueueableContext context) {        
        
        // getting the next record of child object to be processed
        List<GDPR_Child_Query__c> lstProcessRecs = GDPRUtility.fetchSelectedObjectQueryProcessing(selectedObjectId);
        try{            
            
            // if we have any object to be validated
            if(!lstProcessRecs.isEmpty()){
                
                //sObject Name 
                String sObjectName='';
                if(String.isNotBlank(lstProcessRecs[0].SOQL_Query__c)){
                    sObjectName= GDPRProcessChildQueries.getParentSobjectApiName(lstProcessRecs[0].SOQL_Query__c);
                }
                
                // code for process the record (need to discuss)
                GDPRProcessChildqueries processQuery = new GDPRProcessChildQueries();
                 map<string,List<string>> mapChildQueryResult;
                
                
                //getting the object name from query
                string objectName = GDPRProcessChildQueries.getParentSobjectApiName(lstProcessRecs[0].SOQL_Query__c);
                
                //Check big object process is fail or not
                Boolean isBigObjectProcessFailed = false;
                
                //if the query is on big object and there is some error then proceed with process
                if(objectName.containsIgnoreCase('__b')){
                    try{
                        // processing the big objects
                        mapChildQueryResult = processQuery.processChildQuery(lstProcessRecs[0], mapPreviousChildQueryResult); 
                    }
                    catch(Exception ex){
                    	GDPRUtility.updateQueryStatus(lstProcessRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED, ex.getMessage());
                        isBigObjectProcessFailed = true;
                    }// TO DO 27-Jun code to update the big object record with error new method in the utility class 
                }
                
                // if object is not a big object
                else{
                    
                    //if not a big object
                    mapChildQueryResult = processQuery.processChildQuery(lstProcessRecs[0], mapPreviousChildQueryResult);
                }
                
                //count the number of records which was processed
                Integer recordCount = 0;
                List<string> tempList = new List<String>();
                if(mapChildQueryResult != null){
                    tempList = mapChildQueryResult.get('[Query'+Integer.valueOf(lstProcessRecs[0].Query_Order_Number__c)+']');
                }
                if(tempList != null && !tempList.isEmpty()){
                    recordCount = tempList.size();
                }
                
                // code for update the status of child object
                //GDPRUtility.updateQueryStatus(lstProcessRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_PASSED, mapChildQueryResult.get('[Query'+Integer.valueOf(lstProcessRecs[0].Query_Order_Number__c)+']').size());
                if(!isBigObjectProcessFailed){
                    GDPRUtility.updateQueryStatus(lstProcessRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_PASSED, recordCount);
                }
                
                system.debug('\n--lstProcessRecs--'+lstProcessRecs);
                
                // calling enqueue job again
                GDPRProcessRecords processChild = new GDPRProcessRecords(selectedObjectId, selectedTrackerId, mapPreviousChildQueryResult);
                System.enqueueJob(processChild); 
            }
            
            // if we do not have any child object to be processed
            else{
                GDPRProcessRecords.processSelectedObject(selectedTrackerId);
            }
        }
        catch(Exception ex){
            
            System.debug('error message ::: '+ex.getMessage());
            System.debug('error line ::: '+ex.getLineNumber());
            
            // update the child query to error
            if(!lstProcessRecs.isEmpty()){
                GDPRUtility.updateQueryStatus(lstProcessRecs[0].Id, GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED, ex.getMessage());
            }
            
            // getting summary to be updated
            string summary = updateSummary(selectedTrackerId);
            
            //update tracker
            GDPR_Job_Tracker__c trackertObj = new GDPR_Job_Tracker__c(id = selectedTrackerId, Summary__c = summary);
            trackertObj.Status__c = getTrackerProcessStatus(summary);
            update trackertObj;            
            
        }
    }
    
    // it will return the status of tracker ( after processing )
    private static String getTrackerProcessStatus(String summary){
        if(String.isNotBlank(summary) && summary.contains('Error')){
            return 'Process Fail';
        }
        //default status
        return 'Process success';        
    }
    
    private static string updateSummary(string trackerId){
        
        // this will save teh summary
        string summary = 'Processing Status: \n';
        
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
            summary += '\nAll items are Processed Successfully \n Total number child queries: '+lstProcessedChild.size();            
        }
        return summary;
    }    
    
    private static string fetchFailedObject(List<GDPR_Child_Query__c> lstChildQuery){ 
        
        // this will save the text for the summary (error part)
        string summary = '';
        
        // checking if the status is failed then return the select object name
        for(GDPR_Child_Query__c childQuery : lstChildQuery){            
            if(childQuery.Job_Status__c == GDPRConstant.GDPR_CHILD_QUERY_STATUS_FAILED){
                summary += 'Error While Processing - Selected Object Name '+childQuery.GDPR_Selected_Object__r.Object_API_Name__c+'\nChild Query Number :'+childQuery.Query_Order_Number__c+'\nChild Object Name : '+childQuery.Object_API_Name__c;
                summary += '\n Error message: '+childQuery.Job_Error__c;
                summary += '\n Record Id: '+childQuery.Id;                
                return summary;
            }
        }
        return summary;
    }
}