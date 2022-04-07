/**************************************************************************************************
* Name               : AsyncDerwentWebService_SFCustomer_Schdl 
* Description        : This is a schedule class for CustomerDerwentPush_Batch        
* Created Date       : 18-Feb-2020                                                                 
* Created By         : PwC                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS     
***************************************************************************************************/
global class AsyncDerwentWebService_SFCustomer_Schdl implements Schedulable {
    public static final String CRON_EXPR =  System.Label.AsyncDerwentWebService_SFCustomerCronString;
  
  /*
    Call this from Anonymous Apex to schedule at the default regularity
  */
  global static String scheduleIt() 
  {
    AsyncDerwentWebService_SFCustomer_Schdl job = new AsyncDerwentWebService_SFCustomer_Schdl();
    return System.schedule('AsyncDerwentWebService_SFCustomer_Schdl - '+system.now(), CRON_EXPR, job);
  }
  
    global void execute(SchedulableContext ctx) {
        
        AsyncDerwentWebService_SFCustomer_Batch asynccustBatch = new AsyncDerwentWebService_SFCustomer_Batch();
        database.executeBatch(asynccustBatch,1);
        
    }
}