/**************************************************************************************************
* Name               : Reconciliation_RequestLog_Batch 
* Description        : This is a batch class for Reconciliation Request Logs     
* Created Date       : 01-Sept-2019                                                                 
* Created By         : Sri Bala                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0		  Sri Bala		01-Sept-2019   Initial Draft
**************************************************************************************************/
global class Reconciliation_RequestLog_Batch implements Database.Batchable<sobject>,Database.AllowsCallouts{
	//static 
	global Datetime finishDate ;
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String entityName = 'BookingReconciliation';
    	return Database.getQueryLocator('SELECT id FROM Request_Log__c WHERE Entity__c =:entityName AND Reconciliation_Update__c ='+true+''+(Test.isRunningTest()?' LIMIT 1':''));
    }
    public void execute(Database.BatchableContext BC,List<Request_Log__c> scope)
    {  
      List<ID> tripList = new List<Id>();
      List<Request_Log__c> reqloglist = new List<Request_Log__c>();
      for(Request_Log__c req : scope){
            tripList.add(req.Id);
           req.Entity__c = 'Booking';
          reqloglist.add(req);
      }
        update reqloglist;
      system.enqueueJob(new AsyncDerwentWebservice (tripList,'Booking_Upsert',null));
      updateReconciliation(tripList);
    }    
   	public void finish(Database.BatchableContext BC)
    {
       
    }
    
    public  void updateReconciliation(List<Id> tripList){
        Integer countofFailedReqLogs = 0;
        List<Request_Log__c> reqLog = new List<Request_Log__c>();
        Set<String> reconIds = new Set<String>();
        List<Request_Log__c> failedReqLog = [Select Id,Status__c,Entity_Id__c,Error_Log__c,Reconciliation_Update__c,Reconciliation_SF_ID__c from Request_Log__c where Id IN : tripList and Status__c = 'Failed'];
        List<Request_Log__c> allReqLog = [Select Id,Status__c,Entity_Id__c,Error_Log__c,Reconciliation_Update__c,Reconciliation_SF_ID__c from Request_Log__c where Id IN : tripList];
        countofFailedReqLogs = failedReqLog.size();
        for(Request_log__c req : allReqLog){
            req.Reconciliation_Update__c = false;
            reqLog.add(req);
            reconIds.add(req.Reconciliation_SF_ID__c);
        }
   		update reqLog;
        if(failedReqLog.size() > 0){
             countofFailedReqLogs = failedReqLog.size();
        }
             List<Reconciliation__c> reconciliationList = [Select Id from Reconciliation__c where Id IN :reconIds LIMIT 1];
            system.debug(reconciliationList);
            if(reconciliationList.size()>0){
                reconciliationList[0].Count_of_failures__c = countofFailedReqLogs;
                reconciliationList[0].Finish_Date__c = System.now();
                update reconciliationList;	
        }
    }
}