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
 */
@isTest
private class CaseButtonsController_Test {

	@testSetup
    static void setupData(){

        Account acc = new Account(Name = 'Test Ent Account');
        insert acc;

        list<Entitlement> lstEntitlements = new list<Entitlement>();

        Entitlement dnataEntitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = acc.Id, Org_Brand__c = 'dnata');
        lstEntitlements.add(dnataEntitlement);

        Entitlement ekhEntitlement = new Entitlement(Name = 'ekh Entitlement', AccountId = acc.Id, Org_Brand__c = 'ekh');
        lstEntitlements.add(ekhEntitlement);        

        Entitlement trpEntitlement = new Entitlement(Name = 'trp Entitlement', AccountId = acc.Id, Org_Brand__c = 'trp');
        lstEntitlements.add(trpEntitlement);  

        insert lstEntitlements;

    }

    static testMethod void CaseButtonsControllerTest() {
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        TestDataFactory.createBusinessUnitRecordsEKH(bhs.id);
        
        //CreateAccount
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),Org_Business_Unit__c ='EKUK');
        insert acc;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Business_Unit_dropdown__c='dTME',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, AccountId=acc.id);
                                
        insert objCase; 
        
        Profile p = [Select Id,Name from Profile where name='System Administrator' limit 1];
        
        User user = new User(alias = 'test123', email = 'test123123@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing123123', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='dTME',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester123123@noemail.com', Brand__c = 'dnata');
       insert user;
        User user2 = new User(alias = 'test231', email = 'test231231@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing231231', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='TRP',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester231231@noemail.com');
       insert user2;
        test.startTest();
            CaseButtonsController.isTeamLeadRole();
            CaseButtonsController.displayNewBookingButton();
            CaseButtonsController.caseOwnerNotMatching(objCase.id);
            // CaseButtonsController.getselectOptions();
            CaseButtonsController.changeCaseOwner(objCase.id);
            CaseButtonsController.changeOwner_RT(objCase.id,user.id,objCase.recordtypeid);
            CaseButtonsController.reassignOwner(objCase.id,user.id,objCase.recordtypeid,false);
            CaseButtonsController.fetchCaseRTValues();
            CaseButtonsController.fetchLookUpValues('Test',objCase.id,'User');
            CaseButtonsController.fetchLookUpValues('Test',objCase.id,'Queue');
            CaseButtonsController.getDerwentLookupCode('Test');
            CaseButtonsController.getselectOptions('accountid');
            CaseButtonsController.cloneCaseTest(objCase.id);
            CaseButtonsController.isNonAAAgent();
            CaseButtonsController.fetchUserInfo();
            CaseButtonsController.fetchUser();
            CaseButtonsController.fetchLookUpValuesTR('Testing231', objCase.id, 'User');
            CaseButtonsController.fetchLookUpValuesTR('', objCase.id, 'Queue');
            CaseButtonsController.fetchLookUpValues2('Testing231', objCase.id, 'User');
            CaseButtonsController.fetchLookUpValues2('', objCase.id, 'Queue');
            CaseButtonsController.fetchLookUpValuesForSubject('', objCase.id);
            List<Folder> f = CaseButtonsController.getEmailFolder();
                
            CaseButtonsController.createCaseTest(objCase.id);
            CaseButtonsController.updateGroupsEnquiryEmailSent(objCase.id);
        test.stopTest();
        
    }
    
    static testMethod void CaseButtonsControllerTest2() {
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        TestDataFactory.createBusinessUnitRecordsEKH(bhs.id);
        
        //CreateAccount
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),Org_Business_Unit__c ='EKUK');
        insert acc;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Business_Unit_dropdown__c='dTME',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, AccountId=acc.id);
                                
        insert objCase; 
        
        Profile p = [Select Id,Name from Profile where name='System Administrator' limit 1];
        
        User user = new User(alias = 'test123', email = 'test123123@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing123123', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='dTME',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester123123@noemail.com');
       insert user;
        User user2 = new User(alias = 'test231', email = 'test231231@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing231231', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='TRP',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester231231@noemail.com');
       insert user2;
        
        String custComm = CaseButtonsController.createFollowUp(objCase, Datetime.now(), 'description',false);
        test.startTest();
        CaseButtonsController.updateFollowUp(Datetime.now(), 'description', custComm);
        CaseButtonsController.getFollowUpCustomerCommunication(objCase.id);
        CaseButtonsController.deleteFollowUp(custComm);
        CaseButtonsController.updateCaseRecordType(objCase, true, 'TempText', user2.id,false,'test','test');
        CaseButtonsController.updateCaseRecordType(objCase, false, 'TempText', user2.id,false,'test','test');
        test.stopTest();
    }
    
    
    static testMethod void CaseButtonsControllerTest3() {
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        TestDataFactory.createBusinessUnitRecordsEKH(bhs.id);
        
        //CreateAccount
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),Org_Business_Unit__c ='EKUK');
        insert acc;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Business_Unit_dropdown__c='dTME',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, AccountId=acc.id);
                                
        insert objCase; 
        
        Profile p = [Select Id,Name from Profile where name='System Administrator' limit 1];
        
        User user = new User(alias = 'test123', email = 'test123123@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing123132', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='dTME',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester123123@noemail.com');
       insert user;
        User user2 = new User(alias = 'test231', email = 'test231231@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing231231', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = p.id , country = 'United States', IsActive = true, Business_Unit__c='TRP',
                           timezonesidkey = 'America/Los_Angeles', username = 'tester231231@noemail.com');
       insert user2;
        test.startTest();
        CaseButtonsController.createParentCaseNewController('sad','dsa',objcase.id,false,'');
        CaseButtonsController.createParentCaseController('subject', 'New', 'description', user2.id, objCase.id, '');
        test.stopTest();
        
    }
    
    static testmethod void templatestest(){
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        TestDataFactory.createBusinessUnitRecordsEKH(bhs.id);
        
        //CreateAccount
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),Org_Business_Unit__c ='EKUK');
        insert acc;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Business_Unit_dropdown__c='dTME',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, AccountId=acc.id, Send_Messaging_Notification__C = false);
                                
        insert objCase; 
        
        Map<String,String> tempmap = CaseButtonsController.fetchMessagingTemplate(objCase.id);
        CaseButtonsController.getTemplateBody('');
        
    }
}