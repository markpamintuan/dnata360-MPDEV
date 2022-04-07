/**************************************************************************************************
* Name               : NewQuoteExtCCTest
* Description        : Test Class
* Created Date       : 01-Oct-2019                                                                
* Created By         : Jed Canlas                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Jed             01-Oct-2019     Initial version                                                                                                                         
**************************************************************************************************/
@isTest
public class NewQuoteExtCCTest {
    @testSetup static void dataSetup() { 
        //CreateAccount
        Account acc= new Account(lastname='eCommerceSampleAccount',
                                 PersonEmail='eCommerce_Test1@gmail.com', 
                                 PersonHomePhone='1111222211121',
                                 recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId(),
                                 Org_Brand__c = 'dnata eCommerce');
        insert acc;
        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(acc.Id, bhs.Id); 
        
        Case cse = new Case();
        cse.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSD B2C - New Enquiry').getRecordTypeId();
        cse.AccountId = acc.Id;
        cse.Org_Brand__c = 'City Sightseeing Dubai';
        insert cse;

        Product2 p =new Product2();
        p.Name='csd prod';
        p.productCode='1234';
        p.isActive = true;
        p.Brand__c = 'City Sightseeing Dubai';
        p.Family = 'dnata eCommerce';
        Insert p;
        Product2 p2 =new Product2();
        p2.Name='marhaba prod';
        p2.productCode='1234';
        p2.isActive = true;
        p2.Brand__c = 'marhaba';
        p2.Family = 'dnata eCommerce';
        Insert p2;
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = p.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        
        
        Lookup__c l = new Lookup__c();
        l.name = 'test';
        l.type__c = 'Airport';
        l.code__c = 'test';
        insert l;
        
        
        
        
        
    }	
    
    @isTest static void testNewBookingCreation() {
        
        Product2 csdProd = [select id from Product2 where Brand__c = 'City Sightseeing Dubai' limit 1];
        Case cse = 	database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet()), ',') + ' FROM Case limit 1');
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewQuoteExtCC newQuoteExtCC = new NewQuoteExtCC(sc);  
        newQuoteExtCC.DoAdd();
        newQuoteExtCC.ObjectList[0].obj.Product__c = csdProd.Id;
        newQuoteExtCC.ObjectList[0].objProduct = csdProd;
        newQuoteExtCC.productId = csdProd.Id;
        newQuoteExtCC.productIdUnique = newQuoteExtCC.ObjectList[0].uniqueId;   
        newQuoteExtCC.checkProductBrand();        
        newQuoteExtCC.ActionRowUniqueId = newQuoteExtCC.ObjectList[0].uniqueId;  
        newQuoteExtCC.saveAll();
        newQuoteExtCC.saveAndPreview();
        newQuoteExtCC.saveAndAttach();
        PageReference pageRef = new pageReference('/apex/NewQuotePDFCC?qId='+[select id from quote_header__c limit 1].Id); 
        Test.setCurrentPage(pageRef);
        NewQuotePDFControllerCC newPDFCC = new NewQuotePDFControllerCC();    
    }
    
    @isTest static void testNewBookingCreationRemoveProduct() {
        
        Product2 csdProd = [select id from Product2 where Brand__c = 'City Sightseeing Dubai' limit 1];
        Case cse = 	database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet()), ',') + ' FROM Case limit 1');
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewQuoteExtCC newQuoteExtCC = new NewQuoteExtCC(sc);  
        newQuoteExtCC.DoAdd();
        newQuoteExtCC.ObjectList[0].obj.Product__c = csdProd.Id;
        newQuoteExtCC.ObjectList[0].objProduct = csdProd;
        newQuoteExtCC.productId = csdProd.Id;
        newQuoteExtCC.productIdUnique = newQuoteExtCC.ObjectList[0].uniqueId; 
        newQuoteExtCC.checkProductBrand();        
        newQuoteExtCC.ActionRowUniqueId = newQuoteExtCC.ObjectList[0].uniqueId;  
        newQuoteExtCC.DoRemove();  
        newQuoteExtCC.saveAll();
        newQuoteExtCC.saveAndPreview();
        newQuoteExtCC.saveAndAttach();       
        
    }
    
   
    
    
}