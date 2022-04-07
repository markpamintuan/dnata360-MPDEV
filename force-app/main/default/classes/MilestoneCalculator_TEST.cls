@isTest
public class MilestoneCalculator_TEST {
	@testSetup static void dataSetup(){
		Id accountId = TestDataFactory.createEKUK_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
		TestDataFactory.createBusinessUnitRecordsEKH(bhs.Id);
		//Create Cases
		
//
	}

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
			Account acc = [SELECT Id FROM Account limit 1];
			TestDataFactory.createCaseEKHWithEmail(acc.Id);
			Case cse = [SELECT Id FROM Case limit 1];
			MilestoneType milestoneTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Email Response'];
			MilestoneCalculator ms = new MilestoneCalculator();
			Integer timeReturned = ms.calculateMilestoneTriggerTime(cse.Id, milestoneTypeId.Id);
			system.debug('### testMilestoneCalculator timeReturned: ' + timeReturned);
        }
	}

	@isTest static void testMilestoneDefaultCalculator() {
		Account acc = [SELECT Id FROM Account limit 1];
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        TestDataFactory.createCaseEKHWithEmail(acc.Id);
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
			Case cse = [SELECT Id FROM Case limit 1];
			MilestoneType milestoneTypeId = [SELECT Id, Name FROM MilestoneType WHERE Name = 'Email Response'];
			MilestoneCalculator ms = new MilestoneCalculator();
			Integer timeReturned = ms.calculateMilestoneTriggerTime(cse.Id, milestoneTypeId.Id);
			system.debug('### testMilestoneCalculator timeReturned: ' + timeReturned);
        }
	}
}