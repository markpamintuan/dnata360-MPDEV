global class AsyncDerwentWebService_Booking_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
    if(Test.isRunningTest()){
         return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where Entity__c=\'Booking\' and Unique__c = true order by createddate ASC LIMIT ' + Label.DerwentWebService_Booking_Batch_LIMIT);
    }
    else{
  
      return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where status__c=\'New\' and Entity__c =\'Booking\' and Unique__c = true order by createddate ASC LIMIT ' + Label.DerwentWebService_Booking_Batch_LIMIT);
  }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   
      List<Request_Log__c> updateRequestLog = new List<Request_Log__c>();
      List<id> bookingId = new List<id>();
      
   
     for(sobject reqLogRef : scope){
     Request_Log__c  reqLog = (Request_Log__c)reqLogRef;
   
     
     //For Booking
     if(reqLog.Entity__c == 'Booking'){
     bookingId.add(reqLog.id);
     }
     
     
 
     }
     
    
     
     if(bookingId.size() > 0){
     AsyncDerwentWebService.getBooking(bookingId);
     }
     
    
    
    }

   global void finish(Database.BatchableContext BC){
   
   /* List<Request_Log__c> reqLogList =[select id,Entity__c,Entity_Id__c from Request_Log__c where status__c='New' and Entity__c ='Booking' limit 30];
    if(reqLogList.size() > 0){
  database.executebatch(new AsyncDerwentWebService_Booking_Batch(),1);
    }*/
   
   }
}