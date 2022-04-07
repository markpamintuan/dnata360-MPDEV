/**
 * @author: Mark Anthony Pamintuan
 * @date: 1 March 2021
 * @description: Test class for GroupsEnquiryFormTriggerHandler class
 * @history:                
 */
@isTest
public class GroupsEnquiryFormTriggerHandler_Test {

    static testMethod void testpopulateCaseAccountIDs(){
    
        Person_Account_Record_Types__c accountRecordtypeSetting = new Person_Account_Record_Types__c(Name = 'ekh',Record_Type_Name__c = 'EKH B2C Customer - New');
        insert accountRecordtypeSetting;

		list<Account> lstNewAccounts = new list<Account>();
		
        Account existingCustomer = new Account();
        existingCustomer.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
        existingCustomer.FirstName = 'Testfirstname0';
        existingCustomer.LastName = 'Testlastname0';
        existingCustomer.PersonEmail = 'testfirst.testlast0@test.com';
        existingCustomer.PersonMobilePhone = '193847560900';
        existingCustomer.Org_Brand__c = 'ekh';
        lstNewAccounts.add(existingCustomer);
 
        Account existingCustomer2 = new Account();
        existingCustomer2.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId();
        existingCustomer2.FirstName = 'Testfirstname1';
        existingCustomer2.LastName = 'Testlastname1';
        existingCustomer2.PersonEmail = 'testfirst.testlast1@test.com';
        existingCustomer2.PersonMobilePhone = '193847560901';
        existingCustomer2.Org_Brand__c = 'ekh';
        lstNewAccounts.add(existingCustomer2);
        
        insert lstNewAccounts;
        system.debug('!!!!!!!existingCustomer2.Id: ' + existingCustomer2.Id);
        Case cse = new Case();
        cse.RecordtypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH Groups Enquiry').getRecordTypeId();
        cse.AccountId = existingCustomer2.Id;
		cse.Org_Departure_Date__c = system.today().addDays(10);
		cse.Org_No_of_Adults_Travelling__c = 5;
		cse.Org_No_of_Children_Travelling__c = 5;
		cse.Org_Number_of_Nights__c = 5;
		
		insert cse;        
        
        list<Groups_Enquiry_Form__c> lstNewGroupEnquiries = new list<Groups_Enquiry_Form__c>();
        
        for(integer i = 0; i < 10; i++){
            Groups_Enquiry_Form__c groupsEnquiry = new Groups_Enquiry_Form__c();
            groupsEnquiry.RecordtypeId = Schema.SObjectType.Groups_Enquiry_Form__c.getRecordTypeInfosByName().get('EKH Groups Enquiry').getRecordTypeId();
            groupsEnquiry.First_Name__c = 'Testfirstname' + i;
            groupsEnquiry.Last_Name__c = 'Testlastname' + i;
            groupsEnquiry.Email__c = 'testfirst.testlast' +i+'@test.com';
            groupsEnquiry.Brand__c = 'ekh';
            groupsEnquiry.Domain_Name__c = 'UAE';
            groupsEnquiry.Mobile__c = '19384756090' + i;
            groupsEnquiry.Preferred_Destination__c = 'Germany';
            groupsEnquiry.Preferred_Start_Date__c = system.today().addDays(10);
            groupsEnquiry.Preferred_End_Date__c = system.today().addDays(15);
            groupsEnquiry.Number_of_Adults__c = 5;
            groupsEnquiry.Number_of_Children__c = 5;
            groupsEnquiry.Number_of_Nights__c = 5;
            groupsEnquiry.Preferred_Cabin_Class__c = 'Business';
            if(i == 1){
            	groupsEnquiry.Case__c = cse.Id;
            	groupsEnquiry.Customer__c = existingCustomer2.Id;
            }
            lstNewGroupEnquiries.add(groupsEnquiry);        
        }

        test.startTest();
            insert lstNewGroupEnquiries;
        test.stopTest();
        //verify that Case and Account was created and linked to Groups Enquiry
        for(Groups_Enquiry_Form__c gef : [SELECT Case__c, Customer__c FROM Groups_Enquiry_Form__c]){
        	system.assertNotEquals(null,gef.Case__c);
        	system.assertNotEquals(null,gef.Customer__c);
        }


    }

}