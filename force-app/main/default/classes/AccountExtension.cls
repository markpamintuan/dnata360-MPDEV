public  without sharing class AccountExtension {
    
    //public CustomerBookingsExtension(ApexPages.StandardController stdController) {}
    public Account record {get;set;}
    
   
    
    private List<Booking__c> accBookings {get;set;}
    
    public List<Booking__c> lstActiveBookings {get;set;}
    public List<Booking__c> lstHistoricBookings {get;set;}
    
    public List<Relation__c> lstRelations {get;set;}
    
    public List<Case> openCases {get;set;}
    
    public AccountExtension(ApexPages.StandardController stdController) {
        
        lstActiveBookings = new List<Booking__c>();
        lstHistoricBookings = new List<Booking__c>();
        
        openCases = new List<Case>();
        
        lstRelations = new List<Relation__c>();
        
        this.record = (Account)stdController.getRecord();
        if(this.record != null && this.record.Id != null){
            
            this.record = [Select Id, Name From Account Where Id =:this.record.Id LIMIT 1];
            
            lstRelations = [SELECT Org_Name__r.Name,Id,Name,Org_AccountName__c,Org_Age__c,Org_Birth_Date__c,Org_Date_of_Birth__c,Org_Email__c,Org_First_Name__c,Org_Gender__c,Org_Last_Name__c,Org_Mobile__c,Org_Name__c,Org_Passport_Number__c,Org_Relationship__c FROM Relation__c Where Org_AccountName__c = :this.record.Id];
            //accOpps = [SELECT Id,CreatedDate, Name, OwnerId, Product_Type__c, StageName, Owner.Name FROM Opportunity Where AccountId =: this.record.Id Order by LastModifiedDate];
            accBookings = [SELECT Product_Type__c,Org_Date_To__c,Org_Date_From__c,Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c,Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,CreatedDate,Name,Opportunity__c,Owner.Name FROM Booking__c Where Org_Account_Name__c =: this.record.Id Order by Org_Date_From__c DESC LIMIT 50000];
            
            openCases = [Select Id, Subject, Org_Case_Status__c, Status,Org_Type__c, CaseNumber, OwnerId, Owner.Name, CreatedDate, Createdby.Name, Priority From Case Where AccountId = :this.record.Id AND Org_Case_Status__c != 'Closed' ORDER By CreatedDate DESC];
            
            /*if(accOpps != null && accOpps.size() > 0){
                for(Opportunity rec : accOpps){
                    if(rec.StageName == 'New Request'){
                        lstActiveOpps.add(rec);
                    }else {
                        lstHistoricOpps.add(rec);
                    }
                }
            }*/
            
            if(accBookings != null && accBookings.size() > 0){
                for(Booking__c rec : accBookings){
                    if(( rec.Org_Date_From__c> DateTime.now() ) && (DateTime.now() < rec.Org_Date_To__c)){
                        /*if(rec.Booking_Status__c == 'New Request'){*/
                        lstActiveBookings.add(rec);
                    }else {
                        lstHistoricBookings.add(rec);
                    }
                }
            }
        }
    }
}