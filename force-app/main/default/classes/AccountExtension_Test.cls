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
private class AccountExtension_Test {

    static testMethod void AccountExtensionTest1() {
    	
    	Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
		insert acc;
		
		Booking__c objBooking = new Booking__c();
		objBooking.Org_Account_Name__c = acc.id;
		objBooking.Org_Date_From__c = system.today().adddays(11);
		objBooking.Org_Date_To__c = system.today().adddays(1);
		insert objBooking;
		
		Booking__c objBooking1 = new Booking__c();
		objBooking1.Org_Account_Name__c = acc.id;
		insert objBooking1;
		
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(acc);
        AccountExtension obj = new AccountExtension(stdCntlr);
        
    }
}