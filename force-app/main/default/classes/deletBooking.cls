global class deletBooking implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
   
      return Database.getQueryLocator('select id from booking__c');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
     delete scope;
     
    
    }

   global void finish(Database.BatchableContext BC){
   
   
   }
}