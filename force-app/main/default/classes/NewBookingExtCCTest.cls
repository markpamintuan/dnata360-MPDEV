/**************************************************************************************************
* Name               : NewBookingExtCCTest
* Description        : Test Class
* Created Date       : 01-Oct-2019                                                                
* Created By         : Jed Canlas                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Jed             01-Oct-2019     Initial version                                                                                                                         
**************************************************************************************************/
@isTest
public class NewBookingExtCCTest {
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
        NewBookingExtCC newBookExtCC = new NewBookingExtCC(sc);  
        newBookExtCC.DoAdd();
        newBookExtCC.ObjectList[0].obj.Product__c = csdProd.Id;
        newBookExtCC.ObjectList[0].obj.Unit_Price__c = 10;
        newBookExtCC.ObjectList[0].obj.Quantity__c = 10;
        newBookExtCC.ObjectList[0].obj.Service_Start_Date__c = system.now();
        newBookExtCC.ObjectList[0].objProduct = csdProd;
        newBookExtCC.productId = csdProd.Id;
        newBookExtCC.productIdUnique = newBookExtCC.ObjectList[0].uniqueId;  
        newBookExtCC.checkProductBrand();        
        newBookExtCC.ActionRowUniqueId = newBookExtCC.ObjectList[0].uniqueId;  
        newBookExtCC.DoAddTr();   
        newBookExtCC.oliRecId = newBookExtCC.ObjectList[0].uniqueId;
        newBookExtCC.fileName='Unit Test Attachment';
        newBookExtCC.fileBody=Blob.valueOf('Unit Test Attachment Body');
        newBookExtCC.UploadFile();
        NewBookingExtCC.getFromFlights('test');
        newBookExtCC.saveAll();
        newBookExtCC.saveAndPreview();
        newBookExtCC.saveAndAttach();
    }
    
    @isTest static void testNewBookingCreationMarhaba() {
        
        Product2 csdProd = [select id from Product2 where Brand__c = 'marhaba' limit 1];
        Case cse = 	database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet()), ',') + ' FROM Case limit 1');
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExtCC newBookExtCC = new NewBookingExtCC(sc);  
        newBookExtCC.DoAdd();
        newBookExtCC.ObjectList[0].obj.Product__c = csdProd.Id;
        newBookExtCC.ObjectList[0].objProduct = csdProd;
                newBookExtCC.ObjectList[0].obj.Unit_Price__c = 10;
        newBookExtCC.ObjectList[0].obj.Quantity__c = 10;
        newBookExtCC.ObjectList[0].obj.Service_Start_Date__c = system.now();
        //newBookExtCC.ObjectList[0].obj.service_start_date__c = system.today();
        //newBookExtCC.ObjectList[0].obj.service_end_date__c = system.today();
        //newBookExtCC.ObjectList[0].obj.service_start_time__c = '10:00';
        //newBookExtCC.ObjectList[0].obj.service_end_time__c = '12:00';
        newBookExtCC.productId = csdProd.Id;
        newBookExtCC.productIdUnique = newBookExtCC.ObjectList[0].uniqueId;  
        newBookExtCC.checkProductBrand();        
        newBookExtCC.ActionRowUniqueId = newBookExtCC.ObjectList[0].uniqueId;  
        newBookExtCC.DoAddTr();   
        NewBookingExtCC.getFromFlights('test');
        newBookExtCC.saveAll();
        newBookExtCC.saveAndPreview();
        newBookExtCC.saveAndAttach();
    }
    
    @isTest static void testNewBookingCreationRemoveProduct() {
        
        Product2 csdProd = [select id from Product2 where Brand__c = 'City Sightseeing Dubai' limit 1];
        Case cse = 	database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet()), ',') + ' FROM Case limit 1');
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExtCC newBookExtCC = new NewBookingExtCC(sc);  
        newBookExtCC.DoAdd();
        newBookExtCC.ObjectList[0].obj.Product__c = csdProd.Id;
        newBookExtCC.ObjectList[0].objProduct = csdProd;
        newBookExtCC.ObjectList[0].obj.Quantity__c = 10;
        newBookExtCC.ObjectList[0].obj.Service_Start_Date__c = system.now();
        newBookExtCC.productId = csdProd.Id;
        newBookExtCC.productIdUnique = newBookExtCC.ObjectList[0].uniqueId; 
        newBookExtCC.checkProductBrand();        
        newBookExtCC.ActionRowUniqueId = newBookExtCC.ObjectList[0].uniqueId;  
        newBookExtCC.DoAddTr(); 
        newBookExtCC.DoRemoveTr();  
        newBookExtCC.DoRemove();  
        newBookExtCC.saveAll();
        newBookExtCC.saveAndPreview();
        newBookExtCC.saveAndAttach();
    }
    
    @isTest static void testNewBookingUpdateandDelete() {
        
        Product2 csdProd = [select id from Product2 where Brand__c = 'City Sightseeing Dubai' limit 1];
        Case cse = 	database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet()), ',') + ' FROM Case limit 1');        
        
        Order o = new Order();
        o.SFCC_Created_By__c = 'Salesforce';
        o.Status__c = 'Confirmed';
        o.Status = 'Draft';
        o.Shipment_Status__c = 'NOT_SHIPPED';
        o.Name =  'Booking for Case - ';
        o.Case__c = cse.Id;
        o.AccountId = cse.AccountId;
        o.SFCC_Customer_Name__c = 'test acc';
        o.SFCC_Customer_Email__c = 'email@email123.com';
        o.Order_SCCSync_Status__c = 'Created';
        o.SFCC_Order_Total__c = 0;
        o.SFCC_Brand__c = cse.Org_Brand__c;
        o.EffectiveDate = date.today();
        o.SFCC_Order_Number__c = '1';
        insert o;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Quantity__c = 10;
        oli.Unit_Price__c = 10;
        oli.Order__c = o.Id;
        oli.Product__c = csdProd.Id;
        oli.Service_Start_Date__c = system.now();
        insert oli;
        
        
        Order_Traveller__c ot = new Order_Traveller__c();
        ot.Order_Line_Item__c = oli.Id;
        ot.Org_Date_of_Birth__c = date.today() - 1000;
        ot.Org_First_Name__c = 'first';
        ot.Org_Last_Name__c = 'last';
        insert ot;
        
        
        Test.startTest();
        PageReference pageRef = new pageReference('/apex/NewBookingCC?id='+cse.Id+'&oId='+o.Id); 
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        NewBookingExtCC newBookExtCC = new NewBookingExtCC(sc);     
        newBookExtCC.DoRemove();  
        newBookExtCC.saveAll();
        
        PageReference pageRef2 = new pageReference('/apex/NewBookingPDFCC?oId='+o.Id); 
        Test.setCurrentPage(pageRef2);
        NewBookingPDFControllerCC newPDFCCCC = new NewBookingPDFControllerCC();     


        test.stopTest();
        
    }
    
    
}