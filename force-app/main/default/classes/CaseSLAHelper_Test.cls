@isTest
private class CaseSLAHelper_Test {

    static testMethod void CaseSLAHelper_Test_Method() {
        try{
             //CreateAccount
            Id accountId = TestDataFactory.createEKUK_AccountId();
            
            //Create Entitlement    
            BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
            TestDataFactory.createEntitlement(accountId, bhs.Id);
            
            Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                        Subject = 'Test', Org_Destination__c = 'Test',
                        Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                        Org_No_of_Children_Travelling__c = 1);
                        
            insert objCase;    
            
            List<group> gr=[select id,name from group where type='queue' limit 1];
            if(gr.size() > 0)
            objCase.ownerId = gr[0].id;            
            objCase.Org_Case_Status__c= 'In Progress';    
            update objCase;
            
            objCase.Org_Case_Status__c= 'Closed'; 
            objCase.Closing_Comments__c = 'CSR Closed';
            objCase.Reason = 'Resolved';
            objCase.Org_Case_Close_Reason__c = 'Resolved';   
            update objCase;
        }catch (exception ex){
            system.debug('---ex----'+ex);
        }
    }
}