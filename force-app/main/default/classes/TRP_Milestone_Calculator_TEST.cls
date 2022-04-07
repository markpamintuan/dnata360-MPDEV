@isTest
public class TRP_Milestone_Calculator_TEST {
    /*
	@testSetup static void dataSetup(){
		Id accountId = TestDataFactory.createTRP_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id,Name from BusinessHours where Name = 'Travel Republic Standard' limit 1];
		TestDataFactory.createTRPEntitlement(accountId, bhs.Id);
		
		//Create Cases
		//Create Booking Header
        Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert bookHeader;

        //Create Active Bookings
        Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
        insert book;
        
		Case cs = new Case(
        			Subject = 'test1',
                	Org_Customer_Journey_Point__c = 'In Resort',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs;
        Case cs1 = new Case(
        			Subject = 'test2',
                	Org_Customer_Journey_Point__c = 'Post Travel / Holiday',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Reopened__c = true,
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs1;
        Case cs3 = new Case(
        			Subject = 'test3',
                	Org_Customer_Journey_Point__c = 'Pre Travel / Post Booking',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs3;
        Case cs4 = new Case(
        			Subject = 'test4',
                	Org_Customer_Journey_Point__c = 'Post Travel / Holiday',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Reopened__c = true,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs4;
        
        
        List<Issues__c> issuesList = new List<Issues__c>();
        Issues__c issues = new Issues__c(Issue__c = 'Health and Safety',Status__c = 'In Progress',Org_Case__c = cs.Id,Org_booking__c =book.Id,Internal_Request__c = cs.id);
        issuesList.add(issues);
        Issues__c issues1 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs1.Id,Org_booking__c =book.Id,Internal_Request__c = cs1.id);
        issuesList.add(issues1);
        Issues__c issues2 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs3.Id,Org_booking__c =book.Id,Internal_Request__c = cs3.id);
        issuesList.add(issues2);
        Issues__c issues3 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs4.Id,Org_booking__c =book.Id,Internal_Request__c = cs4.id);
        issuesList.add(issues3);
        if(issuesList.size() > 0)
            insert issuesList;
//
	}
    */
    
    @isTest static void testMilestoneCalculator() {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
        	Alias = 'standt', 
        	Email='standarduser@testorg.com',
       		EmailEncodingKey='UTF-8', 
       		LastName='Testing', 
       		LanguageLocaleKey='en_US',
        	LocaleSidKey='en_US', 
        	ProfileId = p.Id, 
        	Team_Name__c = 'EKUK Queue',
        	TimeZoneSidKey='Europe/London',
        	UserName=uniqueUserName);
        insert u;

        System.runAs(u) {
            
            Id accountId = TestDataFactory.createTRP_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id,Name from BusinessHours where Name = 'Travel Republic Standard' limit 1];
		TestDataFactory.createTRPEntitlement(accountId, bhs.Id);
		
		//Create Cases
		//Create Booking Header
        Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert bookHeader;

        //Create Active Bookings
        Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
        insert book;
        
		Case cs = new Case(
        			Subject = 'test1',
                	Org_Customer_Journey_Point__c = 'In Resort',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Org_Case_Status__c = 'In Progress',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs;
        Case cs1 = new Case(
        			Subject = 'test2',
                	Org_Customer_Journey_Point__c = 'Post Travel / Holiday',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Reopened__c = true,
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs1;
        
        List<Issues__c> issuesList = new List<Issues__c>();
        Issues__c issues = new Issues__c(Issue__c = 'Health and Safety',Status__c = 'In Progress',Org_Case__c = cs.Id,Org_booking__c =book.Id,Internal_Request__c = cs.id);
        issuesList.add(issues);
        Issues__c issues1 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs1.Id,Org_booking__c =book.Id,Internal_Request__c = cs1.id);
        issuesList.add(issues1);
        
        if(issuesList.size() > 0)
            insert issuesList;
//
            
			//Case cse = [SELECT Id FROM Case where Subject = 'test2' limit 1];
            //Booking__c book = [Select Id from Booking__c WHERE RecordType.Name = 'Booking' limit 1];
          
			MilestoneType milestoneTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Email Response'];
            MilestoneType milestoneCaseTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Resolution'];
			TRP_Milestone_Calculator ms = new TRP_Milestone_Calculator();
			Integer timeReturned = ms.calculateMilestoneTriggerTime(cs1.Id, milestoneTypeId.Id);
            Integer timeTRReturned = ms.calculateMilestoneTriggerTime(cs1.Id, milestoneCaseTypeId.Id);
			system.debug('### testMilestoneCalculator timeReturned: ' + timeReturned);
            
            //Case cse2 = [Select id from Case where Subject = 'test1' limit 1];
            timeReturned = ms.calculateMilestoneTriggerTime(cs.id, milestoneTypeId.Id);
            timeTRReturned = ms.calculateMilestoneTriggerTime(cs.id, milestoneCaseTypeId.Id);
            
        }
	}
    
    
    @isTest static void testMilestoneCalculator2() {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
        	Alias = 'standt', 
        	Email='standarduser@testorg.com',
       		EmailEncodingKey='UTF-8', 
       		LastName='Testing', 
       		LanguageLocaleKey='en_US',
        	LocaleSidKey='en_US', 
        	ProfileId = p.Id, 
        	Team_Name__c = 'EKUK Queue',
        	TimeZoneSidKey='Europe/London',
        	UserName=uniqueUserName);
        insert u;

        System.runAs(u) {
            
            Id accountId = TestDataFactory.createTRP_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id,Name from BusinessHours where Name = 'Travel Republic Standard' limit 1];
		TestDataFactory.createTRPEntitlement(accountId, bhs.Id);
		
		//Create Cases
		//Create Booking Header
        Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert bookHeader;

        //Create Active Bookings
        Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
        insert book;
        
		
        Case cs3 = new Case(
        			Subject = 'test3',
                	Org_Customer_Journey_Point__c = 'Pre Travel / Post Booking',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs3;
        Case cs4 = new Case(
        			Subject = 'test4',
                	Org_Customer_Journey_Point__c = 'Post Travel / Holiday',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Reopened__c = true,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs4;
        
        
        List<Issues__c> issuesList = new List<Issues__c>();
                Issues__c issues2 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs3.Id,Org_booking__c =book.Id,Internal_Request__c = cs3.id);
        issuesList.add(issues2);
        Issues__c issues3 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs4.Id,Org_booking__c =book.Id,Internal_Request__c = cs4.id);
        issuesList.add(issues3);
        if(issuesList.size() > 0)
            insert issuesList;
//
            
			//Case cse = [SELECT Id FROM Case where Subject = 'test3' limit 1];
            //Booking__c book = [Select Id from Booking__c WHERE RecordType.Name = 'Booking' limit 1];
          
			MilestoneType milestoneTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Email Response'];
            MilestoneType milestoneCaseTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Resolution'];
			TRP_Milestone_Calculator ms = new TRP_Milestone_Calculator();
			Integer timeReturned = ms.calculateMilestoneTriggerTime(cs3.Id, milestoneTypeId.Id);
            Integer timeTRReturned = ms.calculateMilestoneTriggerTime(cs3.Id, milestoneCaseTypeId.Id);
			system.debug('### testMilestoneCalculator timeReturned: ' + timeReturned);
          
            //Case cse4 = [Select id from Case where Subject = 'test4' limit 1];
            timeReturned = ms.calculateMilestoneTriggerTime(cs4.id, milestoneTypeId.Id);
            timeTRReturned = ms.calculateMilestoneTriggerTime(cs4.id, milestoneCaseTypeId.Id);
           
        }
	}
    
    
    
    @isTest static void testMilestoneCalculator3() {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
        	Alias = 'standt', 
        	Email='standarduser@testorg.com',
       		EmailEncodingKey='UTF-8', 
       		LastName='Testing', 
       		LanguageLocaleKey='en_US',
        	LocaleSidKey='en_US', 
        	ProfileId = p.Id, 
        	Team_Name__c = 'EKUK Queue',
        	TimeZoneSidKey='Europe/London',
        	UserName=uniqueUserName);
        insert u;

        System.runAs(u) {
            
            Id accountId = TestDataFactory.createTRP_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id,Name from BusinessHours where Name = 'Travel Republic Standard' limit 1];
		TestDataFactory.createTRPEntitlement(accountId, bhs.Id);
		
		//Create Cases
		//Create Booking Header
        Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
        insert bookHeader;

        //Create Active Bookings
        Booking__c book = TestDataFactory.createActiveBooking(accountId, bookHeader.Id);
        insert book;
        
		
        Case cs3 = new Case(
        			Subject = 'test3',
                	Org_Customer_Journey_Point__c = 'Pre Travel / Post Booking',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId());
        insert cs3;
        Case cs4 = new Case(
        			Subject = 'test4',
                	Org_Customer_Journey_Point__c = 'Post Travel / Holiday',
        			Org_Brand__C = 'trp',
            		Org_Booking__c = bookHeader.Id,Reopened__c = true,Origin='Email',
        			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId());
        insert cs4;
        
        
        List<Issues__c> issuesList = new List<Issues__c>();
                Issues__c issues2 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs3.Id,Org_booking__c =book.Id,Internal_Request__c = cs3.id);
        issuesList.add(issues2);
        Issues__c issues3 = new Issues__c(Issue__c = 'Flight',Status__c = 'In Progress',Org_Case__c = cs4.Id,Org_booking__c =book.Id,Internal_Request__c = cs4.id);
        issuesList.add(issues3);
        if(issuesList.size() > 0)
            insert issuesList;
//
            
			//Case cse = [SELECT Id FROM Case where Subject = 'test3' limit 1];
            //Booking__c book = [Select Id from Booking__c WHERE RecordType.Name = 'Booking' limit 1];
          
			MilestoneType milestoneTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Email Response'];
            MilestoneType milestoneCaseTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Resolution'];
			TRP_Milestone_Calculator ms = new TRP_Milestone_Calculator();
			Integer timeReturned = ms.calculateMilestoneTriggerTime(cs3.Id, milestoneTypeId.Id);
            Integer timeTRReturned = ms.calculateMilestoneTriggerTime(cs3.Id, milestoneCaseTypeId.Id);
			system.debug('### testMilestoneCalculator timeReturned: ' + timeReturned);
          
            //Case cse4 = [Select id from Case where Subject = 'test4' limit 1];
            timeReturned = ms.calculateMilestoneTriggerTime(cs4.id, milestoneTypeId.Id);
            timeTRReturned = ms.calculateMilestoneTriggerTime(cs4.id, milestoneCaseTypeId.Id);
           
        }
	}
}