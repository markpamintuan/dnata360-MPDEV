/* v2.0        Keith       11-Nov-2019    Updaterecord type EKH /EKUK  */                                                   

@isTest 
private class CaseTriggerHandler_TEST {
    
    static list<Customer_Communication__c> CConServiceRequest = new List<Customer_Communication__c>();
    
	@testSetup
    static void setupData(){
        Account marhabaBusinessAccount = new Account(RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId(),
                                                Name = 'marhaba SPAM EMAILS Account',
                                                Account_Number__c = 'N/A',
                                                marhaba_Account_Rating__c = 'marhaba Ops',
                                                Org_Brand__c = 'marhaba B2C');
        insert marhabaBusinessAccount;

        Case_Email_Configuration__c caseEmailConfig = new Case_Email_Configuration__c();
        caseEmailConfig.Name = 'marhaba Email';
        caseEmailConfig.Email_to_Case_Address__c = 'marhaba@marhabaservices.com';
        caseEmailConfig.Business_Unit__c = 'marhaba';
        caseEmailConfig.Brand__c = 'marhaba B2C';
        caseEmailConfig.Is_Active__c = true;
        caseEmailConfig.B2B_Contact_Recordtype_ID__c = '0121n000000Rd1lAAC';
        caseEmailConfig.Account_Type__c = 'B2B';

        insert caseEmailConfig;

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
    
    static testMethod void CaseTriggerHandlerTest1() {
        //CreateAccount
        Id accountId = TestDataFactory.createDTME_AccountId();       
        
        //Create Entitlement        
        //BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId, bhs.Id);
        
        Person_Account_Record_Types__c par = new Person_Account_Record_Types__c(name='dnata',Record_Type_Name__c='dTME_B2C Customer - New');
        insert par;
        Case objCase0= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - Complaints').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='Supplied Name should not be greater than forty characters',SuppliedPhone='123456789');
                                
        insert objCase0;   
        objCase0.Org_Case_Status__c= 'Closed'; 
        objCase0.Closing_Comments__c = 'CSR Closed';
        objCase0.Reason = 'Resolved';
        objCase0.Org_Case_Close_Reason__c = 'Resolved';
        
        objCase0.Org_Interaction_Type__c='Service';
        objCase0.Org_Issue__c='Flight';
        objCase0.Org_Issue_Type__c='Baggage Allowance';
        objCase0.Org_Responsible_Department__c='Airline';  
        objCase0.Org_Outcome_Findings__c = 'Test';
        objCase0.Org_Interaction_Type__c = 'Sales';
        objCase0.Org_Issue__c = 'Flight';
        objCase0.Org_Responsible_Department__c = 'Test';
        objCase0.Org_Controllable__c = 'Test';
        objCase0.Org_Corrective_Action__c  = 'tets';
        objCase0.Org_Preventive_Action__c = 'Taken';
        update objCase0;  
        
        Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='test name',SuppliedEmail='DTME_Test1@gmail.com',SuppliedPhone='123456789');
                                
        insert objCase;     
        
        Booking__c objBooking = new Booking__c();
        objBooking.Org_Account_Name__c = accountId;
        objBooking.Org_Date_From__c = system.today().adddays(11);
        objBooking.Org_Date_To__c = system.today().adddays(1);
        insert objBooking;
        
        Booking__c objBooking1 = new Booking__c();
        objBooking1.Org_Account_Name__c =accountId;
        objBooking1.name='test';
        objBooking1.Org_Domain_Name__c='UAE';
        insert objBooking1;

        Itinerary__c itin = TestDataFactory.createItinerary(objBooking1.Id);
        itin.Type__c = 'Accommodation';
        itin.Org_Hotel_Name__c = 'Test Hotel Name';
        insert itin;
        
        objCase.Org_Booking__c = objBooking1.id;
        objCase.AccountId =  accountId;
        //update objCase;
        
        
        CaseTriggerHandler.getEmailBusinessUnit();
        
        delete objCase;
    }
    
    static testMethod void testCloseMarhabaEmail() {
        
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId();
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Id aaB2CRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - B2C').getRecordTypeId();

        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/Aemail',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;

        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = businessAccount.Id);
        insert entitlement;

        list<Case> lstNewCases  =new list<Case>();
        Case marhabaCase = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Closed',
                                    Reason = 'Replied',
                                    Org_Type__c = 'Amendment',
                                    //AccountId = businessAccount.Id,
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C',
                                    Subject = '[Postmaster] Email Delivery Warning');
        lstNewCases.add(marhabaCase);

        Case aaCase = new Case(RecordtypeId = aaB2CRecTypeID,
                                    Org_Case_Status__c = 'Closed',
                                    Reason = 'Replied',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Direct email',
                                    Org_Brand__c = 'Arabian Adventures B2C',
                                    Subject = 'Your Arabian Adventures Booking',
                                    SuppliedEmail = 'no-reply@arabian-adventures.com');
        lstNewCases.add(aaCase);
        try{
        insert lstNewCases;
        }
        catch(Exception e){
            system.debug('Exception '+e+'Line Number '+e.getLineNumber());
        }
    }

    static testMethod void testmarhabaCustomer() {
        
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Id aaB2CRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - B2C').getRecordTypeId();
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId();
        Id marhabaCustomerRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
        
        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/Acust',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;

        Account marhabaCustomer = new Account(RecordtypeId = marhabaCustomerRecTypeID,
                                                LastName = 'Test3Test',
                                                PersonEmail = 'marhaba3test.customer@test3.com',
                                                Org_Brand__c = 'marhaba B2C',
                                                Emailbrand__c = 'marhaba3test.customer@test3.commarhaba');
        insert marhabaCustomer;

        list<Case> lstNewCases  =new list<Case>();
        Case marhabaCase = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'marhaba@marhabaservices.com',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhabatest.customer@test.com',
                                    SuppliedName = 'Marhaba Customer TestCUstomer TestCustomer TestCustomer Test Customer');
        lstNewCases.add(marhabaCase);

        Case marhabaCase2 = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhaba2test.customer@test2.com',
                                    SuppliedName = 'Marhaba Customer2 Marhaba Customer2 Marhaba Customer2 Marhaba Customer2');
        lstNewCases.add(marhabaCase2);

        Case marhabaCase3 = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhaba3test.customer@test3.com',
                                    SuppliedName = 'Marhaba Customer Test3Test');
        lstNewCases.add(marhabaCase3);
               
        insert lstNewCases;

    }

    static testMethod void testmarhabaCustomer2() {
        
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Id aaB2CRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - B2C').getRecordTypeId();
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId(); 
        Id marhabaCustomerRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
        
        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/A2',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;

        list<Case> lstNewCases  =new list<Case>();
        Case marhabaCase = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'Email',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhabatest.customer@test.com',
                                    SuppliedName = 'Marhaba Customer Test');

               
        insert marhabaCase;

    }
    
   static testMethod void CaseTriggerHandlerTest2() {
       //CreateAccount
        Id accountId = TestDataFactory.createDTME_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId, bhs.Id);
        
        Person_Account_Record_Types__c par = new Person_Account_Record_Types__c(name='dnata',Record_Type_Name__c='dTME_B2C Customer - New');
        insert par;
        Case objCase0= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - Complaints').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='Test Name',SuppliedPhone='123456789');
                                
        insert objCase0;  
    }
    
    static testMethod void CaseTriggerHandlerTest3() {
        //CreateAccount
        Id accountId1 = TestDataFactory.createDTME_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs1 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId1, bhs1.Id);
        
        Person_Account_Record_Types__c par1 = new Person_Account_Record_Types__c(name='dnata',Record_Type_Name__c='dTME_B2C Customer - New');
        insert par1;
        Case objCase1= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - Complaints').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='SuppliedNameShouldNotbegreaterthanfortycharacters',SuppliedPhone='123456789');
                                
        insert objCase1; 
    }
    
    static testMethod void CaseTriggerHandlerTest4() {
           //CreateAccount
        Id accountId2 = TestDataFactory.createDTME_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId2, bhs2.Id);
        
        Person_Account_Record_Types__c par2 = new Person_Account_Record_Types__c(name='dnata',Record_Type_Name__c='dTME_B2C Customer - New');
        insert par2;
        Case objCase2= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - Complaints').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='Test',SuppliedPhone='123456789');
                                
        insert objCase2; 
        
    }
    
    static testMethod void CaseTriggerHandlerTest5() {
        //CreateAccount
        Id accountId2 = TestDataFactory.createDTME_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId2, bhs2.Id);
        
        Person_Account_Record_Types__c par2 = new Person_Account_Record_Types__c(name='dnata',Record_Type_Name__c='dTME_B2C Customer - New');
        insert par2;
        Case objCase2= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - Complaints').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='SuppliedNameShould Notbegreaterthanforty',SuppliedPhone='123456789');
                                
        insert objCase2; 
    }
    
    
    static testMethod void CaseTriggerHandlerTest6() {
           //CreateAccount
        Id accountId2 = TestDataFactory.createTRP_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId2, bhs2.Id);
        
        Person_Account_Record_Types__c par2 = new Person_Account_Record_Types__c(name='trp',Record_Type_Name__c='TRP_B2C Customer - New');
        insert par2;
        Case objCase2= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',Org_Brand__c = 'trp',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,Origin='Web',Description='test',
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='Test',SuppliedPhone='123456789');
                                
        insert objCase2; 
        
    }
    
    
    static testMethod void CaseTriggerHandlerTest7() {
           //CreateAccount
        Id accountId2 = TestDataFactory.createTRP_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId2, bhs2.Id);
        
        Person_Account_Record_Types__c par2 = new Person_Account_Record_Types__c(name='trp',Record_Type_Name__c='TRP_B2C Customer - New');
        insert par2;
        Case objCase2= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId(),
                                Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',Org_Brand__c = 'trp',
                                Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,Origin='Web',Description='test',Status='Closed',
                                Org_No_of_Children_Travelling__c = 1,SuppliedName='Test',SuppliedPhone='123456789');
                                
        insert objCase2; 
        
    }
    
    
    static testMethod void CaseTriggerHandlerTest8() {
        //CreateAccount
        Id accountId2 = TestDataFactory.createEKUK_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createEntitlement(accountId2, bhs2.Id);
         Booking__c bk = new Booking__c();
        bk.Org_Domain_Name__c = 'Ireland';
        bk.Org_Account_Name__c = accountId2;
        insert bk;
        bk.Org_Domain_Id__c = '37';
        update bk;
        
        Person_Account_Record_Types__c par2 = new Person_Account_Record_Types__c(name='ekh',Record_Type_Name__c='EKH B2C Customer - New');
        insert par2;
        Case objCase2= new Case(Subject = 'Test',org_business_unit_dropdown__c = 'ekh',
                                SuppliedName='SuppliedNameShould Notbegreaterthanforty',SuppliedPhone='123456789',AccountId = accountId2,Org_Booking__c=bk.id);
                                
        insert objCase2; 
        objCase2.Subject = 'test2';
        
        update objCase2;
    }
    
    @IsTest
    static void doTest() {
        //CreateAccount
        Id accountId2 = TestDataFactory.createTRP_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs2 = [select id from BusinessHours where IsDefault=true limit 1];
        //TestDataFactory.createTRPEntitlement(accountId2, bhs2.Id);
        
        // Build a simple feed item
       /* ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;
        
        // Set the test data
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,
            ConnectApi.FeedType.News, 'me', testPage);*/
        List<Case> newCase = new List<Case>();
        Case cs1 = new Case(subject='test',
        					Org_Case_Status__c = 'New',
        					AccountId = accountId2,
        					recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId() );
        insert cs1;
        
        Case cs = new Case();
        cs.Subject = 'test';
        cs.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
        //cs.ParentId = cs1.Id;
        cs.Org_Case_Status__c = 'Closed';
        cs.Closing_Comments__c = 'Test';
        cs.Reason = 'No Action Required';
        cs.Invoke_Assignment_Rules__c = true;
        insert cs;
        cs.ParentId = cs1.Id;
        update cs;
        
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + cs);
        
        newCase.add(cs);
        // The method returns the test page, which we know has two items in it.
        Test.startTest();
        CaseTriggerHandler.createChatterPostOnParentCaseTR(newCase,null);
        Test.stopTest();
    }

    static testMethod void testSetRegionName() {
        
        Id ekukNewEnquiryRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH - New Enquiry').getRecordTypeId(); //V2.0
        Id ekukB2CRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - Detail').getRecordTypeId(); //v2.0


        Account ekukAccount = new Account(RecordtypeId = ekukB2CRecTypeID,
                                                LastName = 'Test EKUK',
                                                PersonMobilePhone = '123456796',
                                                PersonEmail='EKUK_Test1@gmail.com',
                                                PersonHomePhone='01234567789',
                                                Org_Brand__c = 'ekh');
        insert ekukAccount;

        list<Case> lstNewCases  =new list<Case>();
		
		for(integer i = 0; i < 5; i++){	
			Case cse = new Case();
        	cse.RecordtypeId = ekukNewEnquiryRecTypeID;
        	cse.AccountId = ekukAccount.Id;
        	cse.Org_Case_Status__c = 'New';
        	cse.Org_Brand__c = 'ekh';
        	lstNewCases.add(cse);
		}
		
		insert lstNewCases;

    }

    static testMethod void testCreateChatterPost() {
        
        Id trRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
        Id trpB2CRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId();

        Account trAccount = new Account(RecordtypeId = trpB2CRecTypeID,
                                                LastName = 'Test TRP',
                                                PersonMobilePhone = '123456796',
                                                PersonEmail='TRP_Test1@gmail.com',
                                                PersonHomePhone='01234567789',
                                                Org_Brand__c = 'trp');
        insert trAccount;
        
        User newCaseOwner = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        list<Case> lstNewCases  =new list<Case>();
		
		for(integer i = 0; i < 5; i++){	
			Case cse = new Case();
        	cse.RecordtypeId = trRecTypeID;
        	cse.AccountId = trAccount.Id;
        	cse.Org_Case_Status__c = 'New';
        	cse.Org_Brand__c = 'trp';
        	cse.Invoke_Assignment_Rules__c = true;
        	lstNewCases.add(cse);
		}
		
		insert lstNewCases;
		
		for(Case c : lstNewCases){
			c.Org_Case_Status__c = 'Closed';
            c.Closing_Comments__c = 'test';
		}
		
		lstNewCases[1].Org_Case_Status__c = 'Closed';
		lstNewCases[1].ParentId = lstNewCases[0].Id;
		
		update lstNewCases[1];

    }

    @isTest
    static void myUnitTest(){

        Case cs1 = new Case(subject='test',Org_Case_Status__c = 'New');
        insert cs1;

        Case cs = new Case();
        cs.Subject = 'test';
        cs.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
        cs.ParentId = cs1.Id;
        cs.Org_Case_Status__c = 'Closed';
        cs.Closing_Comments__c = 'Test';
        cs.Reason = 'No Action Required';
        cs.Invoke_Assignment_Rules__c = true;
        insert Cs;
        
        list<Task> lstTasks = new list<Task>();
        Task objTask = new Task();
        objTask.WhatId = cs.Id;
        objTask.Org_Due_Date_Time__c = system.now().addHours(3);
        objTask.Status = 'Open';
        //objTask.WhoId = UserInfo.getUserId();
        lstTasks.add(objTask);

        objTask = new Task();
        objTask.WhatId = cs.Id;
        objTask.Org_Due_Date_Time__c = system.now().addHours(3);
        objTask.Status = 'Open';
        //objTask.WhoId = UserInfo.getUserId();
        lstTasks.add(objTask);

        insert lstTasks;

        map<Id, Case> mapCases = new map<Id, Case>();
        mapCases.put(cs.Id, cs);
        try{
            CaseTriggerHandler.addErrorOnCase( new list<Case>{cs}, mapCases);
        }catch(Exception ex){}
    }

    static testMethod void testLinkContactToAccount() {
        
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId();
		Id marhabaContactRecTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('marhaba Contact').getRecordTypeId();
        
        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/Acust',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;
        
        Contact marhabaContact = new Contact(RecordtypeId = marhabaContactRecTypeID,
                                             LastName = 'Testlastname', 
                                             FirstName = 'Testfirstname', 
                                             Email = 'testemail@test.com');
        insert marhabaContact;

        list<Case> lstNewCases  = new list<Case>();
        Case marhabaCase = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'marhaba@marhabaservices.com',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhabatest.customer@test.com',
                                    SuppliedName = 'Marhaba Customer TestCUstomer TestCustomer TestCustomer Test Customer',
                                    ContactId = marhabaContact.Id);
        lstNewCases.add(marhabaCase);
               
        insert lstNewCases;
        
        test.startTest();
        	lstNewCases[0].Org_Case_Status__c = 'In Progress';
        	lstNewCases[0].AccountId = businessAccount.Id;
        	lstNewCases[0].ContactId = marhabaContact.Id;
        	update lstNewCases;
        test.stopTest();
        
        //verify that contact was linked to Account
        //Contact con = [SELECT AccountId FROM Contact WHERE Id =: marhabaContact.Id];
		//system.assertEquals(con.AccountId, businessAccount.Id);
    }

    static testMethod void testPopulateMilestoneTargetDateInsert() {
    	
        Id sfChangeRequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Change Request').getRecordTypeId();
	    Id sfIncidentsRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Incidents').getRecordTypeId();
		Id sfGenericRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Generic').getRecordTypeId();

        list<Case> lstNewCases  = new list<Case>();
        for(integer i = 0; i < 10; i++){
        	Case sfIncident = new Case(RecordtypeId = sfIncidentsRTId,
                                    Status = 'New',
                                    ss_Salesforce_Org__c = 'dnata 360',
                                    Priority = 'Low',
                                    Origin = 'Low',
                                    Subject = 'test',
                                    ss_Business_Unit__c = 'Emirates Holidays',
                                    ss_Request_Type__c = 'Error/Defect',
                                    ss_Business_Requirements__c = 'Test');
        	lstNewCases.add(sfIncident);
        }
        insert lstNewCases;
        
        Map<ID, Case> m = new Map<ID, Case>([SELECT Id from Case]);
        
        test.startTest();              
			CaseTriggerHandler.populateMilestoneTargetDate(m.keyset());     	        
        test.stopTest();

    }

    static testMethod void testPopulateMilestoneTargetDateUpdate() {
    	
        Id sfChangeRequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Change Request').getRecordTypeId();
	    Id sfIncidentsRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Incidents').getRecordTypeId();
		Id sfGenericRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Generic').getRecordTypeId();
		list<case> dummyCase = database.query(CRK_UtilityClass.constructQueryString('Case', ' Id != null limit 1'));
        list<Case> lstNewCases  = new list<Case>();
        for(integer i = 0; i < 10; i++){
        	Case sfChangeRequest = new Case(RecordtypeId = sfChangeRequestRTId,
                                    Status = 'New',
                                    Sub_Status__c = 'New',
                                    ss_Salesforce_Org__c = 'dnata 360',
                                    Priority = 'Low',
                                    Origin = 'Low',
                                    Subject = 'test',
                                    ss_Business_Unit__c = 'Emirates Holidays',
                                    ss_Request_Type__c = 'Enhancement',
                                    ss_Business_Requirements__c = 'Test');
        	lstNewCases.add(sfChangeRequest);
        }
        
        insert lstNewCases;
        
        test.startTest();
        
        	for(Case c : lstNewCases){
        		c.Status = 'In Progress';
        		c.Sub_Status__c = 'R&D';
        	}
        	
        	update lstNewCases;
        
        test.stopTest();

    }
    
    static testMethod void CreateCustomerCommunicationForServiceRequest() {
        
        
        Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId();
        Id marhabaBusinessRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Business').getRecordTypeId();
		Id marhabaContactRecTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('marhaba Contact').getRecordTypeId();
        
        Account businessAccount = new Account(RecordtypeId = marhabaBusinessRecTypeID,
                                                Name = 'Test marhaba Business',
                                                Account_Number__c = 'N/Acust',
                                                marhaba_Account_Rating__c = 'Corporate',
                                                Org_Brand__c = 'marhaba B2C');
        insert businessAccount;
        
        Contact marhabaContact = new Contact(RecordtypeId = marhabaContactRecTypeID,
                                             LastName = 'Testlastname', 
                                             FirstName = 'Testfirstname', 
                                             Email = 'testemail@test.com');
        insert marhabaContact;
        Case marhabaCase = new Case(RecordtypeId = marhabaEmailRecTypeID,
                                    Org_Case_Status__c = 'Open',
                                    Org_Type__c = 'Amendment',
                                    Priority = 'Low',
                                    Origin = 'marhaba@marhabaservices.com',
                                    Org_Brand__c = 'marhaba B2C',
                                    marhaba_Customer__c = true,
                                    Subject = 'test',
                                    SuppliedEmail = 'marhabatest.customer@test.com',
                                    SuppliedName = 'Marhaba Customer TestCUstomer TestCustomer TestCustomer Test Customer',
                                    ContactId = marhabaContact.Id);
        insert marhabaCase;
        
        Test.startTest();
            CaseTriggerHandler.CreateCustomerCommunicationForServiceRequest(marhabaCase); 
        	insert CConServiceRequest;
        	CaseTriggerHandler.cancelScheduledCCs(marhabaCase,CConServiceRequest); 
        Test.stopTest();
        
    }
        
}