global class AsyncDerwentWebService_Csr_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
   List<Derwent_Entity__mdt> entityList = [select label from Derwent_Entity__mdt];
   if(entityList.size() > 0){
   for(Derwent_Entity__mdt ent:entityList){
   entityString.add(ent.label);
   }
   }
   
   if(Test.isRunningTest()){
         return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where Entity__c=\'Csr\' and Unique__c = true  order by createddate ASC');

   }
   else{
      return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where status__c=\'New\' and Entity__c=\'Csr\' and Unique__c = true  order by createddate ASC');
  }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
      List<Request_Log__c> updateRequestLog = new List<Request_Log__c>();
      
      List<id> csrId = new List<id>();

   
     for(sobject reqLogRef : scope){
     Request_Log__c  reqLog = (Request_Log__c)reqLogRef;
   
     // For CSR
     if(reqLog.Entity__c == 'Csr'){
     csrId.add(reqLog.id);
     }
     
     }
     
     
    
     if(csrId.size() > 0){
     AsyncDerwentWebService.getCSR(csrId);
     }
   
     
    
    }

   global void finish(Database.BatchableContext BC){
   
   /* List<Request_Log__c> reqLogList =[select id,Entity__c,Entity_Id__c from Request_Log__c where status__c='New' and Entity__c ='Csr' limit 30];
   if(reqLogList.size() > 0){
    database.executeBatch(new AsyncDerwentWebService_Csr_Batch(),5);
    }*/
   
   }
}