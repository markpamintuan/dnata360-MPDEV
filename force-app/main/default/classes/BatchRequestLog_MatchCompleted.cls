/**************************************************************************************************
* Name               : BatchRequestLog_MatchCompleted 
* Description        : This batch class will check for completed request logs and update the matching pending logs          
* Created Date       : 25-Dec-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Kaavya        25-Dec-2018    Initial version                                            
**************************************************************************************************/
global class BatchRequestLog_MatchCompleted implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
    global List<Request_Log__c> CompletedRlist= new List<Request_Log__c> ();
    global List<Request_Log__c> UpdCompletedRlist= new List<Request_Log__c> ();
    global List<Request_Log__c> NonCompleteRlist= new List<Request_Log__c> ();
    global Map<String,Request_Log__c> CompletedMap = new Map<String,Request_Log__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
         Date TDate = Date.Today(); 
         Date StartDate=Parameters__c.getInstance().Start_Date__c;//Date.newinstance(2019,01,01);
         Date EndDate=Parameters__c.getInstance().End_Date__c;//Date.newinstance(2018,11,01);
         String entity=Parameters__c.getInstance().Entity__c;
         return Database.getQueryLocator('select id,Entity__c,Entity_Id__c,Status__c,CreatedDate from Request_Log__c where Entity__c = :entity AND CreatedDate >= :StartDate AND CreatedDate <= :EndDate ORDER BY CreatedDate DESC'); 
        //return Database.getQueryLocator('select id,Entity__c,Entity_Id__c,Status__c,CreatedDate from Request_Log__c where CreatedDate <= :TDate ORDER BY CreatedDate DESC'); 
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    
        
        
        for(sobject reqLogRef : scope){
            Request_Log__c  reqLog = (Request_Log__c)reqLogRef;  
            if(reqLog.Status__c=='Completed'){
                CompletedRlist.add(reqLog );
                if(!CompletedMap.containsKey(reqLog.Entity_Id__c))
                CompletedMap.put(reqLog.Entity_Id__c,reqLog );
            }
            else{
                NonCompleteRlist.add(reqLog );
            }             
        } 
        
    }
   
    global void finish(Database.BatchableContext BC){
        system.debug('CompletedLogs==='+CompletedMap);
        system.debug('PendingLogs==='+NonCompleteRlist);
        for(Request_Log__c Req:NonCompleteRlist){
            if(CompletedMap.containsKey(Req.Entity_Id__c)){
                if(Req.Entity__c==CompletedMap.get(Req.Entity_Id__c).Entity__c ){
                     
                    Datetime CompDate=CompletedMap.get(Req.Entity_Id__c).CreatedDate.addMinutes(1);
                    if(Req.CreatedDate<=CompDate){
                        Req.Status__c='Completed';
                        system.debug('Updating to completed');
                        UpdCompletedRlist.add(Req);
                    }
                }
            }
            
        }
        if(UpdCompletedRlist.size()>0)
            update UpdCompletedRlist;
    }
    
    //Scheduleable
    global void execute(SchedulableContext sc){

        BatchRequestLog_MatchCompleted  b = new BatchRequestLog_MatchCompleted ();        

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b);

    }
    

}