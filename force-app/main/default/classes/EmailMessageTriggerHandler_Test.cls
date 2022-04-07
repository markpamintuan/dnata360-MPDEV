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
private class EmailMessageTriggerHandler_Test {

    static testMethod void EmailMessageTriggerHandlerTest() {
        Account acc= new Account(lastname='test_AccountTriggerHelper',Website='www.test.test',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),
                                    personemail='test@test.test');
        insert acc;     
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(acc.id, bhs.Id);
        
        String recTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        String recTeamTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Team').getRecordTypeId();
        Business_Unit__c busUnitParent = new Business_Unit__c();
        busUnitParent.Name = 'EKUK';
        busUnitParent.RecordTypeId = recTypeId;
        busUnitParent.Org_Brand__c = 'EKH';
        busUnitParent.Org_Region__c = 'UK';
        busUnitParent.Org_Queue_Name__c = 'Duty Travel All';
        busUnitParent.Org_Email__c = 'dutytravel.uat@gmail.com';
        busUnitParent.Email_Routing_Address__c = 'testing@testing.testing12i21938732187.com';
        insert busUnitParent;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false,
                                accountID = acc.id, Org_Brand__c = 'EKH');
                                
        insert objCase; 
        
        EmailMessage obj = new EmailMessage();
        obj.FromAddress = 'test@test.test';
        obj.ToAddress = 'testing@testing.testing';
        obj.parentID = objCase.id;
        obj.Incoming = true;
        obj.Headers = '<928374298347testing@testing.testing12i21938732187.com>1927319823712938';
        insert obj;
        
        obj.FromAddress = 'testq@test.test';
        update obj;
        
        
        
        EmailMessage obj1 = new EmailMessage();
        obj1.FromAddress = 'test@test.test';
        obj1.incoming = true;
        obj1.ToAddress = 'testing@testing.testing';
        obj1.parentID = objCase.id;
        obj1.Incoming = true;
        obj.Headers = '<928374298347testing@testing.testing12i21938732187.com>1927319823712938';
        
        insert obj1;
        
        delete obj;
        
    }
    
    static testMethod void EmailMessageTriggerHandlerTest1() {
        Account acc= new Account(lastname='test_AccountTriggerHelper',Website='www.test.test',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),
                                    personemail='testing@testing.testing');
        insert acc;     
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(acc.id, bhs.Id);
        
        String recTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Business_Unit__c busUnitParent = new Business_Unit__c();
        busUnitParent.Name = 'EKUK';
        busUnitParent.RecordTypeId = recTypeId;
        busUnitParent.Org_Brand__c = 'EKH';
        busUnitParent.Org_Region__c = 'UK';
        busUnitParent.Org_Email__c = 'testing@testing.testing';
        busUnitParent.Org_Queue_Name__c = 'Test';
        insert busUnitParent;
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false,
                                accountID = acc.id, Org_Brand__c = 'EKH', Org_Current_Team_Name__c = 'Test');
                                
        insert objCase; 
        
        EmailMessage obj = new EmailMessage();
        obj.FromAddress = 'test@test.test';
        obj.ToAddress = 'testing@testing.testing';
        obj.parentID = objCase.id;
        obj.Incoming = false;
        obj.SLA_Completion_Date__c = system.today().addDays(1);
        obj.Email_SLA_Status__c = 'SLA Invalid';
        insert obj;
    }

    static testMethod void EmailMessageTriggerHandlerTest2() {
        Account acc= new Account(lastname='test_AccountTriggerHelper',Website='www.test.test',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),
                                    personemail='testing@testing.testing');
        insert acc;     
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(acc.id, bhs.Id);

		Group grp = new Group(Name='Test', Type='Queue');
        insert grp;
        
        QueueSObject qso = new QueueSObject(QueueId = grp.Id, SobjectType = 'Case');
        //insert qso;
        
        String recTypeIdEmail = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Business_Unit__c busUnitEmail = new Business_Unit__c();
        busUnitEmail.Name = 'dTME';
        busUnitEmail.RecordTypeId = recTypeIdEmail;
        busUnitEmail.Org_Brand__c = 'dnata';
        busUnitEmail.Org_Region__c = 'UAE';
        busUnitEmail.Org_Email__c = 'testing@testing.testing';
        busUnitEmail.Org_Queue_Name__c = 'Central';
        insert busUnitEmail;

        String recTypeIdTeam = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Team').getRecordTypeId();
        Business_Unit__c busUnitTeam = new Business_Unit__c();
        busUnitTeam.Name = 'dTME';
        busUnitTeam.RecordTypeId = recTypeIdTeam;
        busUnitTeam.Org_Brand__c = 'dnata';
        busUnitTeam.Org_Region__c = 'UAE';
        busUnitTeam.Org_Email__c = 'testing@testing.testing';
        busUnitTeam.Org_Queue_Name__c = 'Central';
        busUnitTeam.Org_Team_Name__c = 'Central';
        busUnitTeam.Queue_ID__c = grp.Id;
        insert busUnitTeam;
        
        list<Case> lstNewCases = new list<Case>();
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false,
                                accountID = acc.id, Org_Brand__c = 'dnata', Org_Current_Team_Name__c = 'Central', Reopened__c = true);
                                
        lstNewCases.add(objCase); 

        Case objCase2 = new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false,
                                accountID = acc.id, Org_Brand__c = 'dnata', Org_Current_Team_Name__c = 'Central', Reopened__c = true);
                                
        lstNewCases.add(objCase2);

        Case objCase3 = new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false,
                                accountID = acc.id, Org_Brand__c = 'dnata', Org_Current_Team_Name__c = 'Central', Reopened__c = true);
                                
        lstNewCases.add(objCase3);
        
        insert lstNewCases;        
        
        list<EmailMessage> lstNewEmailMessage = new list<EmailMessage>();
        EmailMessage obj = new EmailMessage();
        obj.FromAddress = 'test@test.test';
        obj.ToAddress = 'testing@testing.testing';
        obj.parentID = lstNewCases[0].Id;
        obj.Incoming = true;
        obj.SLA_Completion_Date__c = system.today().addDays(1);
        obj.Email_SLA_Status__c = 'SLA Invalid';
        lstNewEmailMessage.add(obj);

        EmailMessage email2 = new EmailMessage();
        email2.FromAddress = 'test@test.test';
        email2.CcAddress = 'testing@testing.testing';
        email2.ToAddress = 'testingto@testing.testing';
        email2.parentID = lstNewCases[1].Id;
        email2.Incoming = true;
        email2.SLA_Completion_Date__c = system.today().addDays(1);
        email2.Email_SLA_Status__c = 'SLA Invalid';
        lstNewEmailMessage.add(email2);
        
        EmailMessage email3 = new EmailMessage();
        email3.FromAddress = 'test@test.test';
        email3.CcAddress = 'testingcc@testing.testing';
        email3.ToAddress = 'testingto@testing.testing';
        email3.BccAddress = 'testing@testing.testing';
        email3.parentID = lstNewCases[2].Id;
        email3.Incoming = true;
        email3.SLA_Completion_Date__c = system.today().addDays(1);
        email3.Email_SLA_Status__c = 'SLA Invalid';
        lstNewEmailMessage.add(email3);
        
        insert lstNewEmailMessage;
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 22 February 2019
     * @description: test method for setReopenedLastEmailReplied method on EmailMessageTriggerHandler
     * @history:                
     */ 
    static testMethod void testReopenedLastEmailReplied(){
        
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId();
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/Abus',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;

        Account marhabaSpamAccount = new Account(RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId(),
                                                Name = 'marhaba SPAM EMAILS Account',
                                                Account_Number__c = 'N/A',
                                                marhaba_Account_Rating__c = 'marhaba Ops',
                                                Org_Brand__c = 'marhaba B2C');
        insert marhabaSpamAccount;        
        
        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = businessAccount.Id);
        insert entitlement;

        String busUnitEmailId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Business_Unit__c busUnitEmail = new Business_Unit__c();
        busUnitEmail.Name = 'marhaba';
        busUnitEmail.RecordTypeId = busUnitEmailId;
        busUnitEmail.Org_Email__c = 'marhaba@marhabaservices.com';
        busUnitEmail.Org_Queue_Name__c = 'marhaba';
        busUnitEmail.Org_Brand__c = 'marhaba';
        insert busUnitEmail;

        list<Case> lstParentCases = new list<Case>();       
        Case parentCaseIncoming = new Case(//RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Closed',
                                    Reason = 'Replied',
                                    Org_Type__c = 'Amendment',
                                    AccountId = businessAccount.Id,
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C');
        lstParentCases.add(parentCaseIncoming);                         

        Case parentCaseOutGoing = new Case(//RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Closed',
                                    Reason = 'Replied',
                                    Org_Type__c = 'Amendment',
                                    AccountId = businessAccount.Id,
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C');
        lstParentCases.add(parentCaseOutGoing);
        
        insert lstParentCases;
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        EmailMessage incomingEmail = new EmailMessage(ValidatedFromAddress = 'iomrequest@marhabaservices.com',
                                                ToAddress = 'marhaba@marhabaservices.com',
                                                ParentId = lstParentCases[0].Id,
                                                Incoming = true,
                                                Status = '1');
        lstEmailMessages.add(incomingEmail);
                                                
        EmailMessage outGoingEmail = new EmailMessage(ValidatedFromAddress = 'marhaba@marhabaservices.com',
                                                ToAddress = 'marhabatest@marhabaservices.com',
                                                ParentId = lstParentCases[1].Id,
                                                Incoming = false,
                                                Status = '2');       
        lstEmailMessages.add(outGoingEmail);
        
        test.startTest();
            insert lstEmailMessages;
        test.stopTest();
        
        //verify that Parent Case's status was updated to Reopened
        Case updatedParentCaseIncoming = [SELECT Org_Case_Status__c, Reopened__c FROM Case WHERE Id =: lstEmailMessages[0].ParentId];
        //system.assertEquals(updatedParentCaseIncoming.Org_Case_Status__c,'Reopened');
        //verify that Last Email Replied was set to true
        Case updatedParentCaseOutGoing = [SELECT Last_Email_Replied__c FROM Case WHERE Id =: lstEmailMessages[1].ParentId];
        //system.assertEquals(updatedParentCaseOutGoing.Last_Email_Replied__c,true);
        
    }
    
  static testmethod void CustomerSupplierResponsePendingTest(){
       /*        Group g1 = new Group(Name='dTME - Product Support Queue', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
       
            Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0); 
            User u = new User(firstname= 'Test',
                      lastname='User',
                      Alias='tuser',
                      email = 'test.user@dnata.com',
                      username= 'test.user@dnata.com',
                      profileId= p.id,
                      emailencodingkey='UTF-8',
                      languagelocalekey='en_US',
                      localesidkey='en_US',
                      timezonesidkey='America/Los_Angeles');
            insert u; */ 
            Account acc= new Account(lastname='test_AccountTriggerHelper',Website='www.test.test',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId(),
                                        personemail='testing@testing.testing');
            insert acc;     
      
            contact con = new contact(LastName='TestContact',Email='test@test.test');
            insert con;
      
            Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = acc.Id);
            insert entitlement;
      
           
            
            //Create Entitlement        
            BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
            TestDataFactory.createEntitlement(acc.id, bhs.Id);
            
            String recTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            Business_Unit__c busUnitParent = new Business_Unit__c();
            busUnitParent.Name = 'EKUK';
            busUnitParent.RecordTypeId = recTypeId;
            busUnitParent.Org_Brand__c = 'EKH';
            busUnitParent.Org_Region__c = 'UK';
            busUnitParent.Org_Email__c = 'testing@testing.testing';
            busUnitParent.Org_Queue_Name__c = 'Test';
            insert busUnitParent;
        
            Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - After Sales').getRecordTypeId(),
                                    Subject = 'Test', Org_Destination__c = 'Test', Org_Case_Status__c = 'Pending - Customer',
                                    Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                    Org_No_of_Children_Travelling__c = 1, Org_Email_From_Customer__c = false, contactId=con.Id,
                                    accountID = acc.id, Org_Brand__c = 'EKH', Org_Current_Team_Name__c = 'Test',EntitlementId = entitlement.Id);
                                    
            insert objCase; 
            
            EmailMessage obj = new EmailMessage();
            obj.FromAddress = 'test@test.test';
            obj.ToAddress = 'testing@testing.testing';
            obj.CcAddress = 'testingCC@testing.testing';
            obj.BccAddress = 'testingBcc@testing.testing';
            obj.parentID = objCase.id;
            obj.Incoming = true;
            obj.SLA_Completion_Date__c = system.today().addDays(1);
            obj.Email_SLA_Status__c = 'SLA Invalid';
            insert obj;
      
            //EmailMessageTriggerHandler.mapEmailtoQueue('test.test@test.com',obj);
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 14 April 2019
     * @description: test method for setStatusReopenedOrInProgress method on EmailMessageTriggerHandler
     * @history:                
     */ 
    static testMethod void testSetReopenedInProgressCase(){
        
        Id aaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AA - Business').getRecordTypeId();
        Id b2cEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - B2C').getRecordTypeId();
        Account businessAccount = new Account(RecordtypeId = aaBusinessRecTypeID,
                                                Name = 'Test AA Business',
                                                Account_Number__c = 'N/A',
                                                Org_Brand__c = 'Arabian Adventures B2C');
        insert businessAccount;

        Account marhabaSpamAccount = new Account(RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId(),
                                                Name = 'marhaba SPAM EMAILS Account',
                                                Account_Number__c = 'N/A',
                                                marhaba_Account_Rating__c = 'marhaba Ops',
                                                Org_Brand__c = 'marhaba B2C');
        insert marhabaSpamAccount;         
        
        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = businessAccount.Id);
        insert entitlement;

        String busUnitEmailId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Business_Unit__c busUnitEmail = new Business_Unit__c();
        busUnitEmail.Name = 'Arabian Adventures';
        busUnitEmail.RecordTypeId = busUnitEmailId;
        busUnitEmail.Org_Email__c = 'tours@arabian-adventures.com';
        busUnitEmail.Org_Queue_Name__c = 'AA - B2C';
        busUnitEmail.Org_Brand__c = 'Arabian Adventures';
        insert busUnitEmail;

        list<Case> lstParentCases = new list<Case>();       
        Case parentCaseClosed = new Case(RecordtypeId = b2cEmailRecTypeID,
                                    Org_Case_Status__c = 'Closed',
                                    Reason = 'Replied',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C');
        lstParentCases.add(parentCaseClosed);                         

        Case parentCasePending = new Case(RecordtypeId = b2cEmailRecTypeID,
                                    Org_Case_Status__c = 'Pending - Customer',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C');
        lstParentCases.add(parentCasePending); 
        
        insert lstParentCases;
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        EmailMessage incomingClosedEmail = new EmailMessage(FromAddress = 'customer@test.com',
                                                ToAddress = 'tours@arabian-adventures.com',
                                                ParentId = lstParentCases[0].Id,
                                                Incoming = true,
                                                Status = '1');
        lstEmailMessages.add(incomingClosedEmail);
                                                
        EmailMessage incomingPendingEmail = new EmailMessage(FromAddress = 'customer2@test.com',
                                                ToAddress = 'tours@arabian-adventures.com',
                                                ParentId = lstParentCases[1].Id,
                                                Incoming = true,
                                                Status = '1');       
        lstEmailMessages.add(incomingPendingEmail);
        
        test.startTest();
            insert lstEmailMessages;
        test.stopTest();
        
        //verify that Parent Case's status was updated to Reopened
        Case updatedParentCaseClosed = [SELECT Org_Case_Status__c, Reopened__c FROM Case WHERE Id =: lstEmailMessages[0].ParentId];
        system.assertEquals(updatedParentCaseClosed.Org_Case_Status__c,'Reopened');
        //verify that Last Email Replied was set to true
        Case updatedParentCasePending = [SELECT Org_Case_Status__c FROM Case WHERE Id =: lstEmailMessages[1].ParentId];
        system.assertEquals(updatedParentCasePending.Org_Case_Status__c,'In Progress');
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 14 April 2019
     * @description: test method for getBusinessAccount method on EmailMessageTriggerHandler
     * @history:                
     */ 
    static testMethod void testGetBusinessAccount(){
        
        Id aaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AA - Business').getRecordTypeId();
        Id aaContactRecTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('AA - Stella').getRecordTypeId();
        Id stellaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - Stella').getRecordTypeId();
        Id ekhukEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - EKHUK').getRecordTypeId();

        Account businessAccount = new Account(RecordtypeId = aaBusinessRecTypeID,
                                                Name = 'Test AA Business',
                                                Account_Number__c = 'N/A',
                                                Org_Brand__c = 'Arabian Adventures B2C');
        insert businessAccount;

        Contact aaContact = new Contact(RecordtypeId = aaContactRecTypeID,LastName = 'Aacontactlastname', Email = 'aa.contact@aatest.com', AccountId = businessAccount.Id);
        insert aaContact;

        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = businessAccount.Id);
        insert entitlement;

        String busUnitEmailId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Business_Unit__c busUnitEmailAAStella = new Business_Unit__c();
        busUnitEmailAAStella.Name = 'AA - Stella';
        busUnitEmailAAStella.RecordTypeId = busUnitEmailId;
        busUnitEmailAAStella.Org_Email__c = 'aa-resvnsupport@emirates.com';
        busUnitEmailAAStella.Org_Queue_Name__c = 'AA - Stella';
        busUnitEmailAAStella.Org_Brand__c = 'Arabian Adventures';
        insert busUnitEmailAAStella;

        Business_Unit__c busUnitEmailAAekhUK = new Business_Unit__c();
        busUnitEmailAAekhUK.Name = 'AA - EKHUK';
        busUnitEmailAAekhUK.RecordTypeId = busUnitEmailId;
        busUnitEmailAAekhUK.Org_Email__c = 'aaekhuk@emirates.com';
        busUnitEmailAAekhUK.Org_Queue_Name__c = 'AA - EKHUK';
        busUnitEmailAAekhUK.Org_Brand__c = 'Arabian Adventures';
        insert busUnitEmailAAekhUK;

        list<Case> lstParentCases = new list<Case>();       
        Case parentCaseExistingContact = new Case(RecordtypeId = stellaEmailRecTypeID,
                                    Org_Case_Status__c = 'New',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C');
        lstParentCases.add(parentCaseExistingContact);                         
        
        Case parentStellaCase = new Case(RecordtypeId = stellaEmailRecTypeID,
                                    Org_Case_Status__c = 'New',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C');
        lstParentCases.add(parentStellaCase); 

        Case parentEKHUKCase = new Case(RecordtypeId = ekhukEmailRecTypeID,
                                    Org_Case_Status__c = 'New',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C');
        lstParentCases.add(parentEKHUKCase); 
        
        insert lstParentCases;
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        EmailMessage incomingExistingContactEmail = new EmailMessage(FromAddress = 'aa.contact@aatest.com',
                                                ToAddress = 'aa-resvnsupport@emirates.com',
                                                ParentId = lstParentCases[0].Id,
                                                Incoming = true,
                                                Status = '1',
                                                FromName = 'aaFirst Aacontactlastname');
        lstEmailMessages.add(incomingExistingContactEmail);
                                             
        EmailMessage incomingStellaEmail = new EmailMessage(FromAddress = 'customer2@test.com',
                                                ToAddress = 'aa-resvnsupport@emirates.com',
                                                ParentId = lstParentCases[1].Id,
                                                Incoming = true,
                                                Status = '1',
                                                FromName = 'aaCustomer2 Aaccustomer2lastname');       
        lstEmailMessages.add(incomingStellaEmail);

        EmailMessage incomingEKHUKEmail = new EmailMessage(FromAddress = 'customer3@test.com',
                                                ToAddress = 'aaekhuk@emirates.com',
                                                ParentId = lstParentCases[2].Id,
                                                Incoming = true,
                                                Status = '1',
                                                FromName = 'aaCustomer3 Aaccustomer3lastname');       
        lstEmailMessages.add(incomingEKHUKEmail);
        
        test.startTest();
            insert lstEmailMessages;
        test.stopTest();
        
        //verify that Parent Case's contact was the existing contact
        Case updatedParentCaseExistingContact = [SELECT ContactId FROM Case WHERE Id =: lstEmailMessages[0].ParentId];
        //system.assertEquals(updatedParentCaseExistingContact.ContactId,aaContact.Id);
        //verify that Parent Case's Account is Stella
        Case updatedParentStella = [SELECT AccountId FROM Case WHERE Id =: lstEmailMessages[1].ParentId];
        //system.assertEquals(updatedParentStella.AccountId,Label.AA_Stella_Account_ID);
        //verify that Parent Case's Account is Stella
        Case updatedParentEKHUK = [SELECT AccountId FROM Case WHERE Id =: lstEmailMessages[2].ParentId];
        //system.assertEquals(updatedParentEKHUK.AccountId,Label.AA_EKHUK_Account_ID);

    }

}