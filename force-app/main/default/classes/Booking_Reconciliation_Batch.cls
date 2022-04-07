/**************************************************************************************************
* Name               : Booking_Reconciliation_Batch 
* Description        : This is the schedule batch class for Reconciliation       
* Created Date       : 26-Aug-2019                                                                 
* Created By         : Sri Bala                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Sri Bala      26-Aug-2019    Initial Draft
**************************************************************************************************/
global class Booking_Reconciliation_Batch implements Database.Batchable<sobject>,Database.AllowsCallouts,schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Abort any existing jobs so they dont get called again
        List<CronTrigger> jobsToAbort = [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name like '%Reconciliation%'];
		for (CronTrigger job : jobsToAbort) { 
            System.abortJob(job.Id); 
        }
		System.debug([SELECT id,Page_Number__c,Next_Page_Id__c FROM Reconciliation__c ORDER BY CreatedDate DESC limit 1]);        
        return Database.getQueryLocator('SELECT id,Page_Number__c,Next_Page_Id__c FROM Reconciliation__c ORDER BY CreatedDate DESC limit 1');
    }
    public void execute(Database.BatchableContext BC,List<Reconciliation__c> scope)
    {  
       
       system.debug('<<<<Next Page>>>>'+scope[0].Next_Page_Id__c);
       Reconciliation_BatchUtilClass.webServiceCallout(scope[0].Next_Page_Id__c);//
        
    }    
     global void execute(SchedulableContext SC) {
        /*String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 10); 
        String ss = String.valueOf(Datetime.now().second());
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';*/
        database.executebatch(new Booking_Reconciliation_Batch());
        //String jobID = system.schedule('Reconciliation Callout',nextFireTime,new Booking_Reconciliation_Batch());
        
    }
    /*global void start(integer hour){
         string jobName = 'Reconciliation Callout';
         if (hour == 0) 
             database.executebatch(new Booking_Reconciliation_Batch());
        else {
            database.executebatch(new Booking_Reconciliation_Batch());
         //jobName = jobName += ' - ' + datetime.now().format();
         //string cron = '0 0 * * * ?';
         //system.schedule(jobName, cron, new Booking_Reconciliation_Batch());
        }
     }*/
    
     public void finish(Database.BatchableContext BC)
    {
        

        Reconciliation_RequestLog_Batch RequestLog = new Reconciliation_RequestLog_Batch();
        Database.executeBatch(RequestLog,1);
       
        
    }
   
}