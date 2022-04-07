@isTest 
public class batchExampleTest 
{
    
    
    
    
    static testMethod void testMethod4() 
    {
           
            Account acc = new Account();
            acc.FirstName ='test';
            acc.LastName ='test';
            acc.PersonMobilePhone = '589736044';
            acc.MobileBrand__c = '589736044';
            acc.Org_Brand__c = 'dnata';
            acc.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(); 
            acc.No_Email_on_Account__c = true;
            insert acc;
            
            Case cas = new Case();
            cas.Org_Brand__c = 'dnata';
           // cas.SuppliedEmail = 'merulshah0@gmail.com';
            cas.SuppliedPhone = '589736044';
            cas.Origin = 'Email'; 
            cas.SuppliedName = 'Merul Shah';
            cas.recordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('dTME - After Sales').getRecordTypeId(); 
            cas.Status = 'New';
            insert cas; 
            
             CSR__c csr = new CSR__c();
             csr.Case__c = cas.Id;
             csr.CategoryId__c = 'My name is spelt incorrectly';
             
             insert csr;
             
           
             
        Test.startTest();

            batchExample obj = new batchExample();
            DataBase.executeBatch(obj,1); 
            
        Test.stopTest();
    }
    
}