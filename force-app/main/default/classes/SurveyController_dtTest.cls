@isTest
public class SurveyController_dtTest {
    @testSetup static void dataSetup() {
		//CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
		
		//Create Cases
		TestDataFactory.createCaseEKH(accountId);

		//Create Booking Header
		Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
		insert bookHeader;

		//Create Active Bookings
		Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
		insert book;

		//Create Historic bookings
		Booking__c historicBookingHeader = TestDataFactory.createHistoricBookingHeader(accountId);
		insert historicBookingHeader;

		Booking__c historicBooking = TestDataFactory.createHistoricBooking(accountId, historicBookingHeader.Id);
		insert historicBooking;
        
        
        Survey__c s = new Survey__c();
        s.Survey_Name__c = 'test survey';
        s.Brand__c = 'dnata';
        s.Customer_Journey__c = 'Post Travel';
        s.Survey_Model__c = 'CNPS';
        insert s;

		
	}

	@isTest static void rate1() {
		Account acc = [SELECT Id FROM Account limit 1];
		Case cse = [SELECT Id FROM Case limit 1];
		Booking__c book = [SELECT Id FROM Booking__c limit 1];
        
		Test.StartTest(); 
			Test.setCurrentPage(Page.Survey_DnataTravel);
			ApexPages.currentPage().getParameters().put('sId', [select id from survey__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('parentId', [select id from booking__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('rate', '1');
			SurveyController_dt  c = new SurveyController_dt();
			c.save();

		Test.StopTest();	
    }
    
    @isTest static void rate7() {
		Account acc = [SELECT Id FROM Account limit 1];
		Case cse = [SELECT Id FROM Case limit 1];
		Booking__c book = [SELECT Id FROM Booking__c limit 1];
        
		Test.StartTest(); 
			Test.setCurrentPage(Page.Survey_DnataTravel);
			ApexPages.currentPage().getParameters().put('sId', [select id from survey__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('parentId', [select id from booking__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('rate', '7');
			SurveyController_dt  c = new SurveyController_dt();
			c.save();

		Test.StopTest();	
    }
    
    @isTest static void rate9() {
		Account acc = [SELECT Id FROM Account limit 1];
		Case cse = [SELECT Id FROM Case limit 1];
		Booking__c book = [SELECT Id FROM Booking__c limit 1];
        
		Test.StartTest(); 
			Test.setCurrentPage(Page.Survey_DnataTravel);
			ApexPages.currentPage().getParameters().put('sId', [select id from survey__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('parentId', [select id from booking__c limit 1].Id);
        	ApexPages.currentPage().getParameters().put('rate', '9');
			SurveyController_dt  c = new SurveyController_dt();
			c.save();

		Test.StopTest();	
    }

}