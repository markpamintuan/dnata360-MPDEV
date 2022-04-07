/**************************************************************************************************
* Name               : CustomerDerwentPush_Schedule 
* Description        : This is a schedule class for CustomerDerwentPush_Batch        
* Created Date       : 08-Aug-2018                                                                 
* Created By         : PwC                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS     
***************************************************************************************************/
global class CustomerDerwentPush_Schedule implements Schedulable {
    public static final String CRON_EXPR =  System.Label.CustomerDerwentPush_ScheduleCron;
       /*
        Call this from Anonymous Apex to schedule at the default regularity
        */
        global static String scheduleIt() 
        {
            CustomerDerwentPush_Schedule job = new CustomerDerwentPush_Schedule();
            return System.schedule('CustomerDerwentPush_Schedule - '+system.now(), CRON_EXPR, job);
        }
        global void execute(SchedulableContext ctx) {
            
            CustomerDerwentPush_Batch custBatch = new CustomerDerwentPush_Batch();
            database.executeBatch(custBatch,1);
            
        }
        
        
    
}