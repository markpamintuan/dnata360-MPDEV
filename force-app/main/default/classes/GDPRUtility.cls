/***
 * This class is used to save the common code used in the validation / processing of the GDPR objects
 **/
public class GDPRUtility {
    
    /**
     * This is the method used to pull the selected object to be validated
     **/
    public static List<GDPR_Child_Query__c> fetchNextSelectedObject(string gdprRec_Id){
        return [SELECT Id,
                        GDPR_Selected_Object__c ,
                        GDPR_Selected_Object__r.GDPR_Job_Tracker__c,
                        GDPR_Selected_Object__r.RecordIds__c                    
                    FROM GDPR_Child_Query__c
                    WHERE Job_Status__c =: GDPRConstant.GDPR_SELECTED_STATUS_NOT_STARTED
                    AND GDPR_Selected_Object__r.GDPR_Job_Tracker__c =: gdprRec_Id
                    ORDER BY Query_Order_Number__c asc LIMIT 1];
    }
    
    /**
     * This is the method used to pull the selected object to be processed
     **/
    public static List<GDPR_Child_Query__c> fetchSelectedObjectProcessing(string gdprRec_Id){
        return [SELECT Id,
                        GDPR_Selected_Object__c ,
                        GDPR_Selected_Object__r.GDPR_Job_Tracker__c,                         
                        GDPR_Selected_Object__r.RecordIds__c                    
                    FROM GDPR_Child_Query__c
                    WHERE Job_Status__c =: GDPRConstant.GDPR_SELECTED_STATUS_VALIDATED
                    AND GDPR_Selected_Object__r.GDPR_Job_Tracker__c =: gdprRec_Id
                    ORDER BY Query_Order_Number__c asc LIMIT 1];
        
    }
    
    
    /**
     * This is the method used to pull the child query to be validated
     **/
    public  static List<GDPR_Child_Query__c> fetchNextSelectedObjectQuery(string gdprSelectedRec_Id){
        return [SELECT Id,
                        //Job_End_Time__c,
                        Job_Error__c,
                        //Job_Start_Time__c,
                        Masking_Values_For_Fields__c,
                        Object_API_Name__c,
                        Query_Order_Number__c,                        
                        Record_Count__c,
                        SOQL_Query__c,
                        GDPR_Selected_Object__r.RecordIds__c,
                        Unique_Query_Number__c ,Job_Status__c
                    FROM GDPR_Child_Query__c
                    WHERE GDPR_Selected_Object__c =: gdprSelectedRec_Id AND Job_Status__c =: GDPRConstant.GDPR_SELECTED_STATUS_NOT_STARTED
                    ORDER BY Query_Order_Number__c asc
                    LIMIT 1];
        
    }
    
    /**
     * This is the method used to pull the child query to be processed
     **/
    public  static List<GDPR_Child_Query__c> fetchSelectedObjectQueryProcessing(string gdprSelectedRec_Id){
        return [SELECT Id,
                        //Job_End_Time__c,
                        Job_Error__c,
                        //Job_Start_Time__c,
                        Masking_Values_For_Fields__c,
                        Object_API_Name__c,
                        Query_Order_Number__c,                        
                        Record_Count__c,
                        SOQL_Query__c,
                        GDPR_Selected_Object__r.RecordIds__c,
                        Unique_Query_Number__c ,Job_Status__c
                    FROM GDPR_Child_Query__c
                    WHERE GDPR_Selected_Object__c =: gdprSelectedRec_Id AND Job_Status__c =: GDPRConstant.GDPR_SELECTED_STATUS_VALIDATED 
                    ORDER BY Query_Order_Number__c asc
                    LIMIT 1];
        
    }
    
    /**
     *  Getting all Selected object related to tracker for updation of summary
        of tracker
     **/
    public  static List<GDPR_Selected_Object__c> getAllSelectedObjext(string trackerId){
        return [SELECT Id,
                        Name
                    FROM GDPR_Selected_Object__c
                    WHERE GDPR_Job_Tracker__c =: trackerId];        
    }
    
    /**
     * this is used to reset the child query status to no start in start of validation
     **/
    public static void resetQueryStatus(string gdprTracker_Id){
        List<GDPR_Child_Query__c> gdprChildList = [SELECT Id,
                                                           //Job_End_Time__c,
                                                           Job_Error__c,
                                                           //Job_Start_Time__c,
                                                           Job_Status__c,
                                                           Masking_Values_For_Fields__c,
                                                           Object_API_Name__c,
                                                           Query_Order_Number__c,
                                                           Record_Count__c,
                                                           SOQL_Query__c,
                                                           Unique_Query_Number__c
                                                       FROM GDPR_Child_Query__c
                                                       WHERE GDPR_Selected_Object__r.GDPR_Job_Tracker__c =: gdprTracker_Id];
        System.debug('gdprChildList :- '+ gdprChildList);
        if(gdprChildList != null && !gdprChildList.isEmpty()){
            for(GDPR_Child_Query__c gcq : gdprChildList){
                gcq.Job_Status__c = GDPRConstant.GDPR_SELECTED_STATUS_NOT_STARTED;
                //gcq.Job_Start_Time__c = null;
                //gcq.Job_End_Time__c = null; 
                gcq.Job_Error__c = null;                
            }
            update gdprChildList;
            
        }
    }
    
    /**
     * this is used to reset the child query status to no start in start of validation
     **/
    public static void resetTracker(string gdprTracker_Id){
        GDPR_Job_Tracker__c tracker = new GDPR_Job_Tracker__c();
        tracker.id = gdprTracker_Id;
        tracker.Status__c = 'Validation in Progress';
        tracker.Summary__c  = '';
        update tracker;     
    }
    
    // update the status of child query to failed and update error // TO DO combine 
    public static void updateQueryStatus(string gdpeChildRec_Id, string statusValue, string joberror){
        GDPR_Child_Query__c gdprChildRec = new GDPR_Child_Query__c(id = gdpeChildRec_Id, Job_Status__c = statusValue); 
        gdprChildRec.Job_Error__c = joberror;
        update gdprChildRec;
    }
    
    // update the status of child query to validated or passed // TO DO combine 
    public static void updateQueryStatus(string gdpeChildRec_Id, string statusValue){
        GDPR_Child_Query__c gdprChildRec = new GDPR_Child_Query__c(id = gdpeChildRec_Id, Job_Status__c = statusValue);         
        update gdprChildRec;
    }
    
    // update the status of child query to validated or passed // TO DO combine 
    public static void updateQueryStatus(string gdpeChildRec_Id, string statusValue, integer recordCount){
        GDPR_Child_Query__c gdprChildRec = new GDPR_Child_Query__c(id = gdpeChildRec_Id, Job_Status__c = statusValue, Record_Count__c = recordCount, Last_run_date__c = system.today());         
        update gdprChildRec;
    }    
   
    
    // used get the selected object and the child query in order to update the summary
    public static List<GDPR_Selected_Object__c> querySelectedObjectRecord(string tracket_Id){
        return [SELECT Id,
                        GDPR_Job_Tracker__c,
                        Object_API_Name__c,
                        RecordIds__c,                        
                        (SELECT ID,
                                name,
                                Job_Status__c,
                                GDPR_Selected_Object__r.Object_API_Name__c,
                                Object_API_Name__c,
                                Job_Error__c,
                                Query_Order_Number__c 
                            FROM GDPR_Child_Queries__r)
                   FROM GDPR_Selected_Object__c
                   WHERE GDPR_Job_Tracker__c =: tracket_Id];
    }
    
    /*** this method creates the feed for Job Tracker object ***/
    public static void CreateSummaryFeed(GDPR_Job_Tracker__c tracker, String summary){
        feeditem fItem = new feeditem();
        fitem.ParentId = tracker.Id;
        fitem.Body = summary;
        
        insert fItem;
    }
    
    
}