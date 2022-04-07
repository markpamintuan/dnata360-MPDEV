global class batchExample implements Database.Batchable<sObject> {
    /**
        * Webkul Software.
        *
        * @category  Webkul
        * @author    Webkul
        * @copyright Copyright (c) 2010-2016 Webkul Software Private Limited (https://webkul.com)
        * @license   https://store.webkul.com/license.html
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        //String query = 'SELECT id, Origin, AccountId, ContactId, Org_Case_Status__c, RecordtypeId,marhaba_Customer__c, SuppliedEmail,SuppliedName,SuppliedPhone,Org_Brand__c FROM case WHERE accountId = NULL AND ( SuppliedEmail != NULL OR SuppliedPhone!= NULL ) AND (Org_Brand__c  = \'EKH\' OR Org_Brand__c  = \'dnata\')  AND Origin != \'Social Media\'';
        String query = 'SELECT id,Case__r.id,Case__r.Org_Product_Type__c,Case__r.Status,CategoryId__c,Case__r.Type,Org_Brand__c FROM CSR__c WHERE Case__c != NULL AND Case__r.Record_Type_Name__c = \'dTME - After Sales\' AND Case__r.Status != \'Closed\' AND CategoryId__c != NULL AND case__r.Org_Type__c = NULL'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CSR__c> csrs) 
    {
       
        List<Case> lstCaseToUpdate = new List<Case>();
        //v1.3  Merul: for CSR category.
        Map<String,Lookup__c> lookUpMap = new Map<String,Lookup__c>();
        for(Lookup__c lookUp : [SELECT id,
                                      Name,
                                      Type__c,
                                      CSR_Type__c 
                                 FROM Lookup__c 
                                WHERE Type__c = 'CSR Category'
                                  AND CSR_Type__c != NULL])
        {
            lookUpMap.put(lookUp.Name, lookUp);
        
        }   
        
        for(CSR__c csr : csrs)
        {
        
            if(csr.Case__c  != NULL )
            {
            
                Case cas = new Case(id = csr.Case__c );
                
                //v1.3  Merul: Assigning CSR_Type__c.  
                cas.Org_Type__c = (lookUpMap.containsKey(csr.CategoryId__c) && csr.Org_Brand__c == 'dnata'  ? lookUpMap.get(csr.CategoryId__c).CSR_Type__c  : NULL);
                cas.Type = ( cas.Type == NULL ? csr.CategoryId__c : cas.Type);
                
                lstCaseToUpdate.add(cas); 
            }
                    
        
        }
           
        update lstCaseToUpdate;  
        
    }   
    
    global void finish(Database.BatchableContext BC) 
    {
        // execute any post-processing operations
    }
}