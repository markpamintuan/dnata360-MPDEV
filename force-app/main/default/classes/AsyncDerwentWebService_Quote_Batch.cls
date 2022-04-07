global class AsyncDerwentWebService_Quote_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
   
    if(Test.isRunningTest()){
          return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where Entity__c=\'Quote\' and Unique__c = true order by createddate ASC');

    }else{
  
      return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where status__c=\'New\' and Entity__c=\'Quote\' and Unique__c = true order by createddate ASC');
  }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
      List<Request_Log__c> updateRequestLog = new List<Request_Log__c>();
      List<id> quoteId = new List<id>();
      

   
     for(sobject reqLogRef : scope){
     Request_Log__c  reqLog = (Request_Log__c)reqLogRef;
     //For Quote
     if(reqLog.Entity__c == 'Quote'){
     quoteId.add(reqLog.id);
     }
    
     
     }
     
     
   
     if(quoteId.size() > 0){
     AsyncDerwentWebService.getQuote(quoteId);
     }
     
    
    }

   global void finish(Database.BatchableContext BC){
   
   /* List<Request_Log__c> reqLogList =[select id,Entity__c,Entity_Id__c from Request_Log__c where status__c='New' and Entity__c ='Quote' limit 30];
    if(reqLogList.size() > 0){
    database.executeBatch(new AsyncDerwentWebService_Quote_Batch(),10);
    }
   */
   }
}