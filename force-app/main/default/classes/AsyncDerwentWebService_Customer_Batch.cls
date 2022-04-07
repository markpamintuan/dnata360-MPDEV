global class AsyncDerwentWebService_Customer_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
  if(Test.isRunningTest()){
      return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where Entity__c =\'Customer\' and Unique__c = true  order by createddate ASC');
   }
   else{
         return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where status__c=\'New\' and Entity__c =\'Customer\' and Unique__c = true  order by createddate ASC');

   }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
      List<Request_Log__c> updateRequestLog = new List<Request_Log__c>();
      List<id> quoteId = new List<id>();
      List<id> bookingId = new List<id>();
      List<id> customerId = new List<id>();
      List<id> csrId = new List<id>();

   
     for(sobject reqLogRef : scope){
     Request_Log__c  reqLog = (Request_Log__c)reqLogRef;
    
     //For Customer
     if(reqLog.Entity__c == 'Customer'){
     customerId.add(reqLog.id);
     }
     
  
     }
     
     
     if(customerId.size() > 0){
     AsyncDerwentWebService.getCustomer(customerId);
     }
     
    
    
    }

   global void finish(Database.BatchableContext BC){
   
  /*  List<Request_Log__c> reqLogList =[select id,Entity__c,Entity_Id__c from Request_Log__c where status__c='New' and Entity__c ='Customer' limit 30];
   if(reqLogList.size() > 0){
    database.executeBatch(new AsyncDerwentWebService_Customer_Batch(),10);
    }*/
   
   }
}