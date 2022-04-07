global class EvaluateRecordsBatch implements Database.Batchable<sObject> {
    
    private String strParameter;
    public EvaluateRecordsBatch(String strParam) {
        strParameter = strParam;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute         
        //String query = 'SELECT Id, Account__c FROM CSR__c where Account__c = null limit 1';
        return Database.getQueryLocator(strParameter);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        
        // process each batch of records default size is 200
        List<CSR__c> csrList = new List<CSR__c>();
        List<Margin_Movement__c> mmList = new List<Margin_Movement__c>();
        for(sObject obj : objList) {        
            if(String.ValueOf(obj.getSObjectType()) == 'CSR__c'){
                CSR__c csr = (CSR__c)obj;
                csr.Account__c = csr.Booking_ID__r.Org_Account_Name__r.Id;
                if(csr.Account__c != null){
                    csrList.add(csr);  
                }
                
            }
            if(String.ValueOf(obj.getSObjectType()) == 'Margin_Movement__c'){
                Margin_Movement__c mm = (Margin_Movement__c)obj;
                mm.Account__c = mm.Booking__r.Org_Account_Name__r.Id;
                if(mm.Account__c == null){
                    mm.Account__c =  mm.Case__r.Account.Id;
                }
                mmList.add(mm);
            }
        }
        try {
            if(csrList.size() > 0){
                //system.debug(csrList.size());
                //system.debug(csrList);
                update csrList;
            }
            if(mmList.size() > 0){
                //system.debug(mmList.size());
                //system.debug(mmList);
                update mmList;
            }
            
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}