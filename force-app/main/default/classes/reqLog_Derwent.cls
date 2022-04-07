global class reqLog_Derwent implements Database.Batchable<sObject>,Database.AllowsCallouts{

   
  

   global Database.QueryLocator start(Database.BatchableContext BC){
  
      return Database.getQueryLocator('select id from account where org_brand__c !=null and Org_Derwent_Customer_No__c=null');
  
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<id> recordids = new List<id>();

     for(sobject reqLogRef : scope){
     Account  acc = (Account)reqLogRef;
     
     recordids.add(acc.id);
     }
     
     AsyncDerwentWebService.sendCustCreate(recordids,'New');
     
     
    }

   global void finish(Database.BatchableContext BC){
   
   }
}