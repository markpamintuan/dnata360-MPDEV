/**
 * @author: Mark Anthony Pamintuan
 * @date: 12 July 2021
 * @description: Test class for GroupsEnquiryPageController class
 * @history:                
 */
@isTest
public class GroupsEnquiryPageController_Test {

	static testMethod void testProceedToGroupsEnquiryPage() {
 
		Account customer = new Account();
		customer.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
		customer.FirstName = 'Testfirstname1';
		customer.LastName = 'Testlastname1';
		customer.PersonEmail = 'testfirst.testlast1@test.com';
		customer.PersonMobilePhone = '193847560901';
		customer.Org_Brand__c = 'ekh';       
		insert customer;

		Case cse = new Case();
		cse.RecordtypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH Groups Enquiry').getRecordTypeId();
		cse.AccountId = customer.Id;
		cse.Org_Departure_Date__c = system.today().addDays(10);
		cse.Org_No_of_Adults_Travelling__c = 5;
		cse.Org_No_of_Children_Travelling__c = 5;
		cse.Org_Number_of_Nights__c = 5;		
		insert cse; 
   		
		PageReference pageRef = Page.GroupsEnquiryPage;
		//pageRef.getParameters().put('caseId',cse.Id);
		pageRef.getParameters().put('domainId','76');
		pageRef.getParameters().put('reqOrigin','Web');
		pageRef.getParameters().put('brand','ekh');
		Test.setCurrentPage(pageRef);
	   	
		Test.startTest();
			GroupsEnquiryPageController ctlr = new GroupsEnquiryPageController();
			ctlr.proceedToEnquiryForm();
		Test.stopTest();
    	
	}

	static testMethod void testInitGroupsEnquiryPage() {
 
		Account customer = new Account();
		customer.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
		customer.FirstName = 'Testfirstname1';
		customer.LastName = 'Testlastname1';
		customer.PersonEmail = 'testfirst.testlast1@test.com';
		customer.PersonMobilePhone = '193847560901';
		customer.Org_Brand__c = 'ekh';       
		insert customer;

		Case cse = new Case();
		cse.RecordtypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH Groups Enquiry').getRecordTypeId();
		cse.AccountId = customer.Id;
		cse.Org_Departure_Date__c = system.today().addDays(10);
		cse.Org_No_of_Adults_Travelling__c = 5;
		cse.Org_No_of_Children_Travelling__c = 5;
		cse.Org_Number_of_Nights__c = 5;		
		insert cse; 
   		
		PageReference pageRef = Page.GroupsEnquiryPage;
		pageRef.getParameters().put('caseId',cse.Id);
		pageRef.getParameters().put('domainId','76');
		pageRef.getParameters().put('reqOrigin','Web');
		pageRef.getParameters().put('brand','ekh');
		pageRef.getParameters().put('iniframe','true');
		Test.setCurrentPage(pageRef);
	   	
		Test.startTest();
			GroupsEnquiryPageController ctlr = new GroupsEnquiryPageController();
			ctlr.IsValidCaptcha = true;
			ctlr.switchCaptcha();
		Test.stopTest();
    	
	}

	static testMethod void testInitGroupsEnquiryPageCaptchaImage() {
   		
		PageReference pageRef = Page.GroupsEnquiryPage;
		Test.setCurrentPage(pageRef);
	   	
		Test.startTest();
			GroupsEnquiryPageController ctlr = new GroupsEnquiryPageController();
			ctlr.supportDetailsOffline = 'test';
			ctlr.siteNameFromOfflineForm = 'ekhtest';
			ctlr.accID = 'accID';
			//ctlr.IsValidCaptcha = true;
			ctlr.userVisualCaptchaAnswer = ctlr.validChoice.getValue();
			ctlr.proceedToEnquiryForm();			
		Test.stopTest();
    	
	}

	static testMethod void testInitGroupsEnquiryPageCaptchaAudio() {
   		
		PageReference pageRef = Page.GroupsEnquiryPage;
		Test.setCurrentPage(pageRef);
	   	
		Test.startTest();
			GroupsEnquiryPageController ctlr = new GroupsEnquiryPageController();
			ctlr.supportDetailsOffline = 'test';
			ctlr.siteNameFromOfflineForm = 'ekhtest';
			ctlr.accID = 'accID';
			ctlr.defaultCaptchaView = 'audio';
			ctlr.userAudioCaptchaAnswer = ctlr.audioOption.getValue();
			ctlr.proceedToEnquiryForm();			
		Test.stopTest();
    	
	}

}