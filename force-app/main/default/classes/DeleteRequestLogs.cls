global class DeleteRequestLogs implements Database.Batchable<sObject> {
    //date   yester=date.today()-1;
 
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       Date d= date.newinstance(2018,07,10);
    String query = 'SELECT Id FROM Request_Log__c where status__c=\' Completed \' and createddate<TODAY';
        return Database.getQueryLocator('SELECT Id FROM Request_Log__c where status__c=\'Completed\' and createddate<YESTERDAY');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}