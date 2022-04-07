public class QuoteLightningController {
    
    @AuraEnabled
    public static List<QuoteWrapper> getConfiguration(String parentRecordId){
        
        List<QuoteWrapper> lstWrapper = new List<QuoteWrapper>();
        QuoteWrapper qw = new QuoteWrapper();
        qw.Key = 'Quote Information';
        lstWrapper.add(qw);
        
        QuoteWrapper qw1 = new QuoteWrapper();
        qw1.Key = 'Preview';
        lstWrapper.add(qw1);
        
        QuoteWrapper qw2 = new QuoteWrapper();
        qw2.Key = 'Send';
        lstWrapper.add(qw2);
        
        return lstWrapper;
    }
    
    public static CaseQuoteInfo getCaseDetails(String recId){
        CaseQuoteInfo c = new CaseQuoteInfo();
        List<Case> lstResult = new List<Case>([Select Id,Org_Traveller__c,Org_No_of_Adults_Travelling__c,Org_No_of_Children_Travelling__c From Case Where Id = :recId LIMIT 1]);
        if(!lstResult.isEmpty()){
            Case cs = lstResult[0];
            c.RecordId = cs.Id;
            //c.
        }
        return c;
    }
    
    public class QuoteWrapper {
        @AuraEnabled
        public String Key {get;set;}
        
        @AuraEnabled
        public String CSS {get;set;}
    }
    
    public class CustomerInfo {
        @AuraEnabled
        public String RecordId {get;set;}
        
        @AuraEnabled
        public String CustomerName {get;set;}
        
    }
    
    public class CaseQuoteInfo {
        @AuraEnabled
        public String RecordId {get;set;}
        
        @AuraEnabled
        public String CaseNumber {get;set;}
        
        @AuraEnabled
        public String Subject {get;set;}
        
        @AuraEnabled
        public Date DateFrom {get;set;}
        
        @AuraEnabled
        public Date DateTo {get;set;}
        
        @AuraEnabled
        public String Destination {get;set;}
        
        @AuraEnabled
        public String TravellerType {get;set;}
        
        @AuraEnabled
        public String NoOfAdults {get;set;}
        
        @AuraEnabled
        public String NoOfChildren {get;set;}
        
    }
    
}