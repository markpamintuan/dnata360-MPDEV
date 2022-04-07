/**************************************************************************************************
* Name               : CustomerDerwentPush_Batch 
* Description        : This is the batch class for pushing customers to Derwent for new Account        
* Created Date       : 26-March-2019                                                                 
* Created By         : Maruf Bagwan                                                   
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Maruf        26-March-2019     Initial version

**************************************************************************************************/
global class CustomerDerwentPush_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    List<Account> accountsToBeUpdated = new List<Account>();
   
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> brandList = new Set<String>();
        for(Person_Account_Record_Types__c PA: Person_Account_Record_Types__c.getall().values()){
            if(PA.Push_to_Derwent__c){
                brandList.add(PA.Name);
            }
        }
        Integer numOfRecs = (Label.CustomerDerwentPushRecordLimit != null && Label.CustomerDerwentPushRecordLimit != '') ? Integer.valueOf(Label.CustomerDerwentPushRecordLimit) : 1000;
        return Database.getQueryLocator('select id,Org_Derwent_Customer_No__c,Org_Brand__c,Org_Derwent_Status__c from Account where Org_Derwent_Customer_No__c = \'\' AND Org_Derwent_Status__c = \'\' AND Org_Brand__c IN :brandList order by createddate ASC LIMIT :numOfRecs');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){   
        
        List<id> newcustomerIds = new List<id>(); 
        for(sobject CustRef : scope){
            Account cust= (Account)CustRef;
            if(cust.Org_Derwent_Customer_No__c == null){
                newcustomerIds.add(cust.id);
            } 
        }
        
        if(newcustomerIds.size() > 0){
            AsyncDerwentWebservice.sendCustCreate(newcustomerIds,'New');
        }
    }
    
    global void finish(Database.BatchableContext BC){    
        
    }
}