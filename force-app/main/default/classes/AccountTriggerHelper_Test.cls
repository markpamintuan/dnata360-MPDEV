/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
* v2.0       Keith        5-Nov-2019    Change Account Record Type Names For EKH
 */
@isTest
private class AccountTriggerHelper_Test {

    static testMethod void AccountTriggerHelperTest1() {
        try{
            Run_Customer_Engine__c obj = new Run_Customer_Engine__c();
            obj.Run__c = true;
            insert obj;
            
            Customer_Matching_Fields__c cmf = new Customer_Matching_Fields__c();
            cmf.Field__c = 'Website';
            cmf.name = 'Name';
            insert cmf;
            
            list<Account> tempList = new list<Account>();
            Account acc= new Account(lastname='test_AccountTriggerHelper',Org_Derwent_Customer_No__c='99988213',Website='www.test.test',PersonEmail='test@test.com',PersonMobilePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
            tempList.add(acc);
            
            Account acc1= new Account(lastname='test_AccountTriggerHelper1',Website='www.test.test',PersonEmail='test@test1.com',PersonMobilePhone='01234567782',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
            tempList.add(acc1);
            
            insert tempList;
            
        }catch (exception ex){
            system.debug('---ex----'+ex);
        }
    }
    
    static testMethod void AccountTriggerHelperTest_method() {
        try{
            Run_Customer_Engine__c obj = new Run_Customer_Engine__c();
            obj.Run__c = true;
            insert obj;
            
            Customer_Matching_Fields__c cmf = new Customer_Matching_Fields__c();
            cmf.Field__c = 'PersonEmail';
            cmf.name = 'Name';
            insert cmf;
            
            list<Account> tempList = new list<Account>();
            Account acc= new Account(lastname='test_AccountTriggerHelper',Org_Derwent_Customer_No__c='99988213',Website='www.test.test',PersonEmail='test@test.com',PersonMobilePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
           insert acc;
            
            Account acc1= new Account(lastname='test_AccountTriggerHelper1',Website='www.test.test',PersonEmail='test@test.com',PersonMobilePhone='01234567782',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId()); //v2.0
      
            insert acc1;
            
        }catch (exception ex){
            system.debug('---ex----'+ex);
        }
    }
    
    static testMethod void AccountTriggerHelperTest_method1() {
        try{
            Run_Customer_Engine__c obj = new Run_Customer_Engine__c();
            obj.Run__c = true;
            insert obj;
            
            Customer_Matching_Fields__c cmf = new Customer_Matching_Fields__c();
            cmf.Field__c = 'PersonEmail';
            cmf.name = 'Name';
            insert cmf;
            
            list<Account> tempList = new list<Account>();
            Account acc= new Account(lastname='test_AccountTriggerHelper',Org_Derwent_Customer_No__c='99988213',Website='www.test.test',PersonEmail='test@test.com',PersonMobilePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
            insert acc;
            
            acc.lastname='test_AccountTriggerHelper1';
            update acc;
         
        }catch (exception ex){
            system.debug('---ex----'+ex);
        }
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 30 April 2019
     * @description: test method for AccountTriggerHelper class
     * @history:                
     */ 
    static testMethod void testAccountTriggerHelper(){

        Run_Customer_Engine__c runCustomerEngine = new Run_Customer_Engine__c();
        runCustomerEngine.Run__c = true;
        insert runCustomerEngine;

        Customer_Matching_Fields__c cMatchingFields = new Customer_Matching_Fields__c();
        cMatchingFields.Field__c = 'PersonEmail';
        cMatchingFields.Name = 'Name';
        insert cMatchingFields;
        
          Account acc= new Account(lastname='test_2AccountTriggerHelper',DFO_ID__C = '123132123',Org_Derwent_Customer_No__c='1299988213',Website='www.test.test',PersonEmail='test34@test23.com',PersonMobilePhone='01234567789234',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;
        
        Account acc1= new Account(lastname='test_1AccountTriggerHelper',DFO_ID__C = '871263238',Org_Derwent_Customer_No__c='9998821453',Website='www.test1.test',PersonEmail='tes1t@tes1t.com',PersonMobilePhone='013234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc1;
        
        Account acc3= new Account(lastname='test_3AccountTriggerHelper',Org_Derwent_Customer_No__c='99938821453',Website='www.test1.test',PersonEmail='tes3t@tes1t.com',PersonMobilePhone='0133234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc3;
        
        List<Account> acclist = [Select Id,DFO_Id__c from Account];
        
        List<DFoAccount__c> dfoacclist= new List<DFoAccount__c>();
        Set<DFoAccount__c> dfoset = new Set<DFoAccount__c>();
        for(Account ac : acclist){
            DFoAccount__c dfo = new DFoAccount__c();
            dfo.Account__c = ac.Id;
            dfo.Child_Id__c = ac.DFO_Id__c;
            dfoset.add(dfo);
            
        }
        
        dfoacclist.addall(dfoset);
        system.debug('dfoacclist'+dfoacclist);
        try{
        	Database.insert(dfoacclist,false);
        }
        catch(Exception e){
            system.debug('Exception '+e+'Line Number:'+e.getLineNumber());
        }
        
        
         Account accNew= new Account(lastname='test1AccountTriggerHelper',DFO_ID__C = '871263238',Org_Derwent_Customer_No__c='999882141253',Website='www.test1.test',PersonEmail='tes1t@t1es1t.com',PersonMobilePhone='0123234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        test.startTest();
        insert accNew;
		
        
         Account accN= new Account(lastname='test1AccountTriggerHelper',DFO_ID__C = '871263238',Org_Derwent_Customer_No__c='99988214123',Website='www.test12.test',PersonEmail='tes1t@t1es1t.com',PersonMobilePhone='012323456779',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        
        insert accN;
		test.stopTest();
       /* list<String> lstAccountRecordtypes = new list<String> {'dTME_B2C Customer - New','EKUK_B2C Customer - New'};
        list<Account> lstExistingAccounts = new list<Account>();

        for(integer i = 0; i < 2; i++){
            Account oldAccount = new Account();
            oldAccount.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(lstAccountRecordtypes[i]).getRecordTypeId();
            oldAccount.LastName = 'TestCustomer' + i;
            oldAccount.PersonEmail = 'test' + i +'@test' + i +'.com';
            oldAccount.Org_Derwent_Customer_No__c = '9998821' + i;
            oldAccount.Website = 'www.test' + i + '.test';
            oldAccount.PersonMobilePhone='0123456778'+ i;
            oldAccount.Org_Is_Master_Account__c = true;
            if(i == 1){
                oldAccount.DFO_Id__c = 'id12345';
            } else {
                oldAccount.DFO_Id__c = null;
            }
            
            oldAccount.Child_IDs__c = null;            
            lstExistingAccounts.add(oldAccount);
        }

        insert lstExistingAccounts;

        DFoAccount__c newDFOAccount = new DFoAccount__c(Account__c = lstExistingAccounts[1].Id, Child_Id__c = 'id12345');
        insert newDFOAccount;

        system.debug('@!@!@!@!!@lstExistingAccounts: ' + lstExistingAccounts);

        list<Account> lstnewAccounts = new list<Account>();

        for(integer j = 0; j < 2; j++){
            Account newAccount = new Account();
            newAccount.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(lstAccountRecordtypes[j]).getRecordTypeId();
            newAccount.LastName = 'TestCustomer' + j;
            newAccount.PersonEmail = 'test' + j +'@test' + j +'.com';
            newAccount.Org_Derwent_Customer_No__c = '9998821' + j;
            newAccount.Website = 'www.test' + j + '.test';
            newAccount.PersonMobilePhone='0123456778'+ j;
            if(j == 1){
                newAccount.DFO_Id__c = 'id12345';
            } else {
                newAccount.DFO_Id__c = null;
            }            
            lstnewAccounts.add(newAccount);
        }
        
        test.startTest();

            try{

                insert lstnewAccounts;

            } catch (Exception e){
                system.debug(e.getMessage());
            }

        test.stopTest();*/

    }  

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 30 April 2019
     * @description: test method for AccountTriggerHelper class preventDeletion method
     * @history:                
     */ 
    static testMethod void testPreventDeletion(){

        Run_Customer_Engine__c runCustomerEngine = new Run_Customer_Engine__c();
        runCustomerEngine.Run__c = true;
        insert runCustomerEngine;

        Customer_Matching_Fields__c cMatchingFields = new Customer_Matching_Fields__c();
        cMatchingFields.Field__c = 'PersonEmail';
        cMatchingFields.Name = 'Name';
        insert cMatchingFields;

        list<String> lstAccountRecordtypes = new list<String> {'dTME_B2C Customer - New','EKH B2C Customer - New'}; //v2.0

        list<Account> lstExistingAccounts = new list<Account>();

        for(integer i = 0; i < 2; i++){
            Account oldAccount = new Account();
            oldAccount.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(lstAccountRecordtypes[i]).getRecordTypeId();
            oldAccount.LastName = 'TestCustomer' + i;
            oldAccount.PersonEmail = 'test' + i +'@test' + i +'.com';
            oldAccount.Org_Derwent_Customer_No__c = '9998821' + i;
            oldAccount.Website = 'www.test' + i + '.test';
            oldAccount.PersonMobilePhone='0123456778'+ i;
            oldAccount.Org_Is_Master_Account__c = true;
            oldAccount.Org_Prevent_Deletion__c = true;           
            lstExistingAccounts.add(oldAccount);
        }

        insert lstExistingAccounts;
        String errorMessage;

        test.startTest();

            try{

                delete lstExistingAccounts;

            } catch (Exception e){

                errorMessage =  e.getMessage();

            }

        test.stopTest();

        //verify that error message was thrown
        system.assertEquals(errorMessage.contains('This account cannot be deleted'),true);

    }  

    /**
     * @author: Keith
     * @date: 1 November 2019
     * @description: test the syncing of picklist mobile country code to mobile field
     * @history:                
     */ 
    static testMethod void testsyncMobilePhoneCountryAndNumber(){
        Account accCreatedByUser = new Account(); 
        accCreatedByUser.Mobile_Country_Code__c = '353';
        accCreatedByUser.Mobile_Phone_Number__c = '872664531';
        accCreatedByUser.LastName = 'test surname';
        accCreatedByUser.PersonEmail = 'test@123432.com';
        insert accCreatedByUser;

        //update the picklist values
        accCreatedByUser.Mobile_Country_Code__c = '44';
        update accCreatedByUser;

        //update the mobilefield directly
        accCreatedByUser.PersonMobilePhone = '39 234234234';
        update accCreatedByUser;

        //update the mobilefield directly and cause an exception (mocking integration)
        Account accByIntegration = new Account(); 
        accByIntegration.LastName = 'test surname';
        accCreatedByUser.PersonMobilePhone = '3934234234';
        accByIntegration.PersonEmail = 'test@12343sdasdad2.com';
        insert accByIntegration;

        accCreatedByUser.PersonMobilePhone = '39234234234';
        update accCreatedByUser;

        Account accCreatedByIntegration = new Account(); 
        accCreatedByIntegration.LastName = 'test surname';
        accCreatedByIntegration.PersonMobilePhone = '39 234234234';
        accCreatedByIntegration.PersonEmail = 'test34242@123432.com';
        insert accCreatedByIntegration;

        Account accCreatedByIntegration2 = new Account(); 
        accCreatedByIntegration2.LastName = 'test surname';
        accCreatedByIntegration2.PersonMobilePhone = '000 234234234';
        accCreatedByIntegration2.PersonEmail = 'test134242@98754test.com';
        insert accCreatedByIntegration2;

        accCreatedByIntegration2.PersonMobilePhone = '000 123456789';
        update accCreatedByIntegration2;
    }  

    /**
     * @author: Keith
     * @date: 1 November 2019
     * @description: test the syncing of picklist phone country code to mobile field
     * @history:                
     */ 
    static testMethod void testsyncPhoneCountryAndNumber(){
        Account accCreatedByUser = new Account(); 
        accCreatedByUser.Phone_Country_Code__c = '353';
        accCreatedByUser.Phone_Number__c = '872664531';
        accCreatedByUser.LastName = 'test surname';
        accCreatedByUser.PersonEmail = 'test@123432.com';
        insert accCreatedByUser;

        //update the picklist values
        accCreatedByUser.Phone_Country_Code__c = '44';
        update accCreatedByUser;

        //update the mobilefield directly
        accCreatedByUser.Phone = '39 234234234';
        update accCreatedByUser;

        //update the mobilefield directly and cause an acception (mocking integration)
        accCreatedByUser.Phone = '39234234234';
        update accCreatedByUser;

        Account accCreatedByIntegration = new Account(); 
        accCreatedByIntegration.LastName = 'test surname';
        accCreatedByIntegration.Phone = '39 234234234';
        accCreatedByIntegration.PersonEmail = 'test34242@123432.com';
        insert accCreatedByIntegration;

    }  
     /**
     * @author: Sri Bala
     * @date: 09-Feb-2020
     * @description: test the marketing optin process
     * @history:                
     */ 

    
    static testMethod void testMarketingOptin2(){
        Account accCreatedByUser1 = new Account(); 
        accCreatedByUser1.Org_Brand__c = 'dnata';
        accCreatedByUser1.LastName = 'test surname';
        accCreatedByUser1.Marketing_Consent__c = true;
        accCreatedByUser1.PersonEmail = 'test@234test.com';
        insert accCreatedByUser1;

        //update the Send Exclusive gifts directly
        accCreatedByUser1.EKUK_Send_exclusive_discounts_offers__c = false;
        update accCreatedByUser1;
        
        accCreatedByUser1.Marketing_Opt_In__pc = true;
        update accCreatedByUser1;

        accCreatedByUser1.PersonHasOptedOutOfEmail = true;
        update accCreatedByUser1;
        
         accCreatedByUser1.Marketing_Consent__c = true;
        update accCreatedByUser1;
        

    }
    static testMethod void testMarketingOptinTrue(){
        Account accCreatedByUser1 = new Account(); 
        accCreatedByUser1.Org_Brand__c = 'dnata';
        accCreatedByUser1.LastName = 'test surname';
        accCreatedByUser1.EKUK_Send_exclusive_discounts_offers__c = true;
        accCreatedByUser1.PersonEmail = 'test@234test.com';
        test.startTest();
        insert accCreatedByUser1;
		
        Account acc = new Account();
        acc = [Select Id,Marketing_Consent__c from Account where Id =: accCreatedByUser1.Id];
        acc.Marketing_Consent__c = false;
        
        update acc;
        test.stopTest();
       
        

    }
    
    static testMethod void testMarketingOptInTrueFalse(){
        Account accCreatedByUser1 = new Account(); 
        accCreatedByUser1.Org_Brand__c = 'dnata';
        accCreatedByUser1.LastName = 'test surname';
        accCreatedByUser1.EKUK_Send_exclusive_discounts_offers__c = true;
        accCreatedByUser1.PersonEmail = 'test@234test.com';
        accCreatedByUser1.CM_Customer_Domain__c = 'Germany';
        accCreatedByUser1.CM_Opt_In_By__c = 'Integration';
        accCreatedByUser1.CM_Opt_In_Date__c = system.today();
        accCreatedByUser1.CM_Opt_In_Reason__c = 'Test';
        accCreatedByUser1.CM_Opt_In_Source__c = 'Test';
        test.startTest();
        insert accCreatedByUser1;
		
        Account acc = new Account();
        acc = [Select Id,Marketing_Opt_In__pc from Account where Id =: accCreatedByUser1.Id];
        acc.Marketing_Opt_In__pc = false;
        
        update acc;
        Account acc1 = new Account();
        acc1 = [Select Id,Marketing_Opt_In__pc from Account where Id =: accCreatedByUser1.Id];
        acc1.Marketing_Opt_In__pc = true;
        
        update acc1;
        test.stopTest();
       
        

    }
    
     static testMethod void testMarketingOptinIntegrationUser(){
        User us = [Select Id,Name from User where Name Like '%Integration%' LIMIT 1];        
        system.runAs(us){
            Account accCreatedByUser1 = new Account(); 
            accCreatedByUser1.Org_Brand__c = 'dnata';
            accCreatedByUser1.LastName = 'test surname';
            accCreatedByUser1.Marketing_Consent__c = true;
            accCreatedByUser1.PersonEmail = 'test@234test.com';
            insert accCreatedByUser1;
        }
    }
    
    static testMethod void testMarketingConsentNonRestrictedMarket(){
        Account accCreatedByUser1 = new Account(); 
        accCreatedByUser1.Org_Brand__c = 'ekh';
        accCreatedByUser1.Customer_Domain__c = 'Germany';
        accCreatedByUser1.LastName = 'test surname';
        accCreatedByUser1.EKUK_Send_exclusive_discounts_offers__c = true;
        accCreatedByUser1.PersonEmail = 'test@234test.com';
       

        test.startTest();
        insert accCreatedByUser1;
		
        Account acc = new Account();
        acc = [Select Id,Marketing_Opt_In__pc from Account where Id =: accCreatedByUser1.Id];
        acc.Marketing_Opt_In__pc = false;
        
        update acc;
        Account acc1 = new Account();
        acc1 = [Select Id,Marketing_Opt_In__pc from Account where Id =: accCreatedByUser1.Id];
        acc1.Marketing_Opt_In__pc = true;
        
        update acc1;
        test.stopTest();
       
        

    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 16 February 2021
     * @description:
     * @history:                
     */
    static testMethod void testMarketingOptInProcessOther(){
        
        list<Account> lstAccounts = new list<Account>();
        Id ekhCustomerRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
        Account customer = new Account();
        customer.RecordtypeId = ekhCustomerRtId;
        customer.Org_Brand__c = 'ekh';
        customer.Customer_Domain__c = 'Germany';
        customer.LastName = 'test surname';
        customer.PersonEmail = 'testmc@234test.com';
        lstAccounts.add(customer);

        Account customer2 = new Account();
        customer2.RecordtypeId = ekhCustomerRtId;
        customer2.Org_Brand__c = 'ekh';
        customer2.Customer_Domain__c = 'Germany';
        customer2.LastName = 'test surname';
        customer2.PersonEmail = 'testmc@432test.com';
        lstAccounts.add(customer2);        

        insert lstAccounts;

        test.startTest();
            lstAccounts[0].Marketing_Opt_In__pc = true;
            lstAccounts[0].EKUK_Send_exclusive_discounts_offers__c = true;
            lstAccounts[0].Opt_In_Status__c = 'Accepted';
            lstAccounts[0].CM_Opt_In_Reason__c = 'Test Class';
            lstAccounts[0].Initial_Opt_In_Reason__c = 'Test Clas';
            lstAccounts[0].CM_Opt_In_Source__c = 'Service Cloud';
            lstAccounts[0].Initial_Opt_In_Source__c = 'Service Cloud';
            
            lstAccounts[1].Marketing_Opt_In__pc = true;
            lstAccounts[1].EKUK_Send_exclusive_discounts_offers__c = true;
            lstAccounts[1].Opt_In_Status__c = 'Accepted';
            lstAccounts[1].Initial_Opt_In_Reason__c = 'Test Clas';
            lstAccounts[1].Initial_Opt_In_Source__c = 'Service Cloud';
            
            update lstAccounts;
        test.stopTest();       

    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 16 February 2021
     * @description:
     * @history:                
     */
    static testMethod void testUpdateLoyaltyId(){
        
        list<Account> lstAccounts = new list<Account>();
        Id ekhCustomerRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
        for(integer i = 0; i < 10; i++){
            Account customer = new Account();
            customer.RecordtypeId = ekhCustomerRtId;
            customer.Org_Brand__c = 'ekh';
            customer.Customer_Domain__c = 'Germany';
            customer.LastName = 'test surname' + i;
            customer.PersonEmail = 'testmc'+i+'@test'+i+'.com';
            lstAccounts.add(customer);
        }     

        insert lstAccounts;

        test.startTest();
            for(Account a : lstAccounts){
                if(a.LastName == 'test surname0'){
                    a.Org_Emirates_Skywards_Number__c = '0019283746';
                } else {
                    a.Org_Emirates_Skywards_Number__c = '0192837465748392019287465738901928374657890938475613';
                }
            }
            update lstAccounts;
        test.stopTest();       

    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 30 April 2019
     * @description: test method for AccountTriggerHelper class DFOAccountCreation method
     * @history:                
     *//* 
    static testMethod void testDFOAccountCreation(){

        Run_Customer_Engine__c runCustomerEngine = new Run_Customer_Engine__c();
        runCustomerEngine.Run__c = true;
        insert runCustomerEngine;

        Customer_Matching_Fields__c cMatchingFields = new Customer_Matching_Fields__c();
        cMatchingFields.Field__c = 'PersonEmail';
        cMatchingFields.Name = 'Name';
        insert cMatchingFields;

        list<String> lstAccountRecordtypes = new list<String> {'dTME_B2C Customer - New','EKH B2C Customer - New'};
        list<Account> lstExistingAccounts = new list<Account>();

        for(integer i = 0; i < 2; i++){
            Account oldAccount = new Account();
            oldAccount.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(lstAccountRecordtypes[i]).getRecordTypeId();
            oldAccount.LastName = 'TestCustomer' + i;
            oldAccount.PersonEmail = 'test' + i +'@test' + i +'.com';
            oldAccount.Org_Derwent_Customer_No__c = '9998821' + i;
            oldAccount.Website = 'www.test' + i + '.test';
            oldAccount.PersonMobilePhone='0123456778'+ i;
            oldAccount.Org_Is_Master_Account__c = true;
            oldAccount.DFO_Id__c = 'id12345' + i;
            oldAccount.Child_IDs__c = null;
            oldAccount.Org_Brand__c = 'dnata';            
            lstExistingAccounts.add(oldAccount);
        }

        insert lstExistingAccounts;
        
        list<DFoAccount__c> lstDFOAccount = new list<DFoAccount__c>();
        for(integer j = 0; j < 2; j++){
            DFoAccount__c newDFOAccount = new DFoAccount__c(Account__c = lstExistingAccounts[j].Id, Child_Id__c = 'id12345'+j);
            lstDFOAccount.add(newDFOAccount);
        }
        
        insert lstDFOAccount;
        
        list<Account> lstnewAccounts = new list<Account>();
        for(integer k = 0; k < 2; k++){
            Account newAccount = new Account();
            newAccount.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(lstAccountRecordtypes[k]).getRecordTypeId();
            newAccount.LastName = 'TestCustomer1' + k;
            //newAccount.PersonEmail = 'test' + k +'@1test' + k +'.com';
            newAccount.Org_Derwent_Customer_No__c = '19998821' + k;
            newAccount.Website = 'www.test' + k + '.1test';
            newAccount.PersonMobilePhone='0123456778'+ k;
            newAccount.Org_Brand__c = 'dnata';
            if(k == 0){
                newAccount.DFO_Id__c = 'id12345'+k;
                newAccount.PersonEmail = 'test' + k +'@1test' + k +'.com';
            } else {
                newAccount.DFO_Id__c = null;
                newAccount.PersonEmail = 'test' + k +'@test' + k +'.com';
            }
                    
            lstnewAccounts.add(newAccount);
        }
        
        test.startTest();

            try{

                insert lstnewAccounts;

            } catch (Exception e){
                system.debug(e.getMessage());
            }

        test.stopTest();

    }  
    */
}