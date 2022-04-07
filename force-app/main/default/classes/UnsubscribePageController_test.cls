@isTest
public class UnsubscribePageController_test{

	@testSetup static void dataSetup() {
    	//CreateAccount
    	Id accountId = TestDataFactory.createEKUK_AccountId();
		
        //Create Booking Header
		Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
		insert bookHeader;

		//Create Active Bookings
		Booking__c booking = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
		insert booking;    

        Order ord = new Order();
        ord.AccountId = accountId;
        ord.EffectiveDate = date.today();
        ord.Status = 'Draft';
        ord.SFCC_Brand__c = 'marhaba';
        ord.Order_SCCSync_Status__c = 'Created';
        insert ord;

        list<Account> lstAccountsForBrands = new list<Account>();
        Account dnataCustomer = new Account();
        dnataCustomer.RecordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId();
        dnataCustomer.LastName='dTME_Test1';
        dnataCustomer.PersonEmail='dTME_Test1@gmail.com';
        dnataCustomer.PersonHomePhone='01234567789';
        dnataCustomer.Org_Brand__c = 'dnata';
        lstAccountsForBrands.add(dnataCustomer);       

        Account ekhCustomer = new Account();
        ekhCustomer.RecordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
        ekhCustomer.LastName='ekh_Test1';
        ekhCustomer.PersonEmail='ekh_Test1@gmail.com';
        ekhCustomer.PersonHomePhone='9876543210';
        ekhCustomer.Org_Brand__c = 'ekh';
        lstAccountsForBrands.add(ekhCustomer);

        Account trCustomer = new Account();
        trCustomer.recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId();
        trCustomer.lastname='TRP_Test1';
        trCustomer.PersonEmail='TRP_Test1@gmail.com';
        trCustomer.PersonHomePhone='01234567789';
        trCustomer.Org_Brand__c = 'trp';
        lstAccountsForBrands.add(trCustomer);

        insert lstAccountsForBrands;
    
	}
	
    /*
	@isTest static void testCreateCase() {
    	Account acc = [SELECT Id FROM Account limit 1];
      
    	String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId();
    	UnsubscribePageController test = new UnsubscribePageController();
    	ApexPages.currentPage().getParameters().put('cid',acc.Id);
    	test.unsubscribeCustomer();
  	}
	*/

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 12 May 2019
     * @description: test method for UnsubscribePageController
     * @history:                
     */ 
    static testMethod void testWithBookingDnata(){
        
        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'dnata' LIMIT 1];

        Booking__c booking = new Booking__c();
        booking.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        booking.Name = '12345678';
        booking.Org_Account_Name__c = acc.Id;
        booking.Org_Brand__c = acc.Org_Brand__c;
        booking.Org_Travel_Start_Date__c = System.today() + 8;
        booking.Org_Travel_End_Date__c = System.today() + 10;
        booking.Org_Booked_Date__c = System.today() - 1;
        booking.Booking_Status__c = 'Receipted';		
        booking.Org_Email__c = acc.PersonEmail;
        insert booking;

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);
        pageRef.getParameters().put('bkid',booking.Id);
		Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE ID =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: test method for UnsubscribePageController
     * @history:                
     */ 
    static testMethod void testWithBookingEKH(){

        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'ekh' LIMIT 1];

        Booking__c booking = new Booking__c();
        booking.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        booking.Name = '12345678';
        booking.Org_Account_Name__c = acc.Id;
        booking.Org_Brand__c = acc.Org_Brand__c;
        booking.Org_Travel_Start_Date__c = System.today() + 8;
        booking.Org_Travel_End_Date__c = System.today() + 10;
        booking.Org_Booked_Date__c = System.today() - 1;
        booking.Booking_Status__c = 'Receipted';		
        booking.Org_Email__c = acc.PersonEmail;
        booking.Org_Domain_Name__c = 'UAE';
        insert booking;        

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);
        pageRef.getParameters().put('bkid',booking.Id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

    static testMethod void testWithOrderEKH(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];


        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('Ordid',ord.Id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account LIMIT 1];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,false);
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: test method for UnsubscribePageController
     * @history:                
     */ 
    static testMethod void testWithBookingNoMatch(){
        
        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'ekh' LIMIT 1];

        Booking__c booking = new Booking__c();
        booking.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        booking.Name = '12345678';
        booking.Org_Account_Name__c = acc.Id;
        booking.Org_Brand__c = acc.Org_Brand__c;
        booking.Org_Travel_Start_Date__c = System.today() + 8;
        booking.Org_Travel_End_Date__c = System.today() + 10;
        booking.Org_Booked_Date__c = System.today() - 1;
        booking.Booking_Status__c = 'Receipted';		
        booking.Org_Email__c = acc.PersonEmail;
        booking.Org_Domain_Name__c = 'test';
        insert booking;  

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);
        pageRef.getParameters().put('bkid',booking.Id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: test method for UnsubscribePageController
     * @history:                
     */ 
    static testMethod void testWithoutBookingDnata(){
        
        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'dnata' LIMIT 1];

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);

        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: test method for UnsubscribePageController
     * @history:                
     */ 
    static testMethod void testWithoutBookingNoMatch(){
        
        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'ekh' LIMIT 1];

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);

        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

    static testMethod void testWithBookingEKHArabic(){

        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'ekh' LIMIT 1];

        Booking__c booking = new Booking__c();
        booking.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        booking.Name = '12345678';
        booking.Org_Account_Name__c = acc.Id;
        booking.Org_Brand__c = acc.Org_Brand__c;
        booking.Org_Travel_Start_Date__c = System.today() + 8;
        booking.Org_Travel_End_Date__c = System.today() + 10;
        booking.Org_Booked_Date__c = System.today() - 1;
        booking.Booking_Status__c = 'Receipted';		
        booking.Org_Email__c = acc.PersonEmail;
        booking.Org_Domain_Name__c = 'UAE';
        insert booking;        

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);
        pageRef.getParameters().put('bkid',booking.Id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
            ctlr.isShowArabic = true;
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }    

    static testMethod void testWithBookingTRP(){

        Account acc = [SELECT Id, PersonEmail, Org_Brand__c FROM Account WHERE Org_Brand__c = 'trp' LIMIT 1];

        Booking__c booking = new Booking__c();
        booking.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        booking.Name = '12345678';
        booking.Org_Account_Name__c = acc.Id;
        booking.Org_Brand__c = acc.Org_Brand__c;
        booking.Org_Travel_Start_Date__c = System.today() + 8;
        booking.Org_Travel_End_Date__c = System.today() + 10;
        booking.Org_Booked_Date__c = System.today() - 1;
        booking.Booking_Status__c = 'Receipted';		
        booking.Org_Email__c = acc.PersonEmail;
        booking.Org_Domain_Name__c = 'UAE';
        insert booking;        

        PageReference pageRef = Page.UnsubscribePage;
        pageRef.getParameters().put('cid',acc.Id);
        pageRef.getParameters().put('bkid',booking.Id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
            UnsubscribePageController ctlr = new UnsubscribePageController();
            ctlr.unsubscribeCustomer();
        test.stopTest();
        
        //verify that account Survey_Opt_Out__pc was updated to true
        Account updatedAccount = [SELECT Survey_Opt_Out__pc FROM Account WHERE Id =: acc.Id];
        system.assertEquals(updatedAccount.Survey_Opt_Out__pc,true);
        
    }

}