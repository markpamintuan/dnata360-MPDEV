/**************************************************************************************************
* Name               : GDPR_DataRetentionScheduler
* Description        : This is the scheduler class for GDPR_Data_Retention  batch class     
* Created Date       : 18-Oct-2019                                                                 
* Created By         : PwC                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS    
*****************************************************************************************************/
global class GDPR_DataRetentionScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GDPR_Data_Retention dataRetentionBatch = new GDPR_Data_Retention();
        database.executeBatch(dataRetentionBatch,200);
    }
}