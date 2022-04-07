/**************************************************************************************************
* Name               : AsyncDerwentWebService_SFCustomer_Batch 
* Description        : This is the batch class for re-pushing customers to Derwent if failed           
* Created Date       : 20-Nov-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Kaavya        20-Nov-2018    Initial version
                                                         
**************************************************************************************************/
global class AsyncDerwentWebService_SFCustomer_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();

  

   global Database.QueryLocator start(Database.BatchableContext BC){
  if(Test.isRunningTest()){
      return Database.getQueryLocator('select id,Org_Derwent_Customer_No__c from Account where Re_Push__c = true  order by createddate ASC LIMIT '+ Label.CustomerDerwentPushRecordLimit);
   }
   else{
         return Database.getQueryLocator('select id,Org_Derwent_Customer_No__c from Account where Re_Push__c = true  order by createddate ASC LIMIT '+Label.CustomerDerwentPushRecordLimit);

   }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){   
      
        List<id> newcustomerIds = new List<id>(); 
        List<id> extcustomerIds = new List<id>();   
        String ExtDerwentId='';
        for(sobject CustRef : scope){
         Account cust= (Account)CustRef;
        
         //For Customer where Derwent Id is null
         if(cust.Org_Derwent_Customer_No__c == null){
             newcustomerIds.add(cust.id);
         } 
         else {
             extcustomerIds.add(cust.id);
             ExtDerwentId=cust.Org_Derwent_Customer_No__c;
         }  
        }
          
        if(newcustomerIds.size() > 0){
         AsyncDerwentWebservice.sendCustCreate(newcustomerIds,'New');
        }
        if(extcustomerIds.size() > 0){
         AsyncDerwentWebservice.sendCustCreate(extcustomerIds,ExtDerwentId);
        }
         
    }

   global void finish(Database.BatchableContext BC){    
   
   }
}