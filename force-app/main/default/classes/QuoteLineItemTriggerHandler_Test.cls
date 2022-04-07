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
private class QuoteLineItemTriggerHandler_Test {

    static testMethod void QuoteLineItemTriggerHandlerTest1() {
    	Quote_Header__c header = new Quote_Header__c();
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Hotel');
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Flight');
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	insert listQLI;
    	
        QuoteLineItemTriggerHandler obj = new QuoteLineItemTriggerHandler();
        QuoteLineItemTriggerHandler.insertQuoteProduct(listQLI);
        
    }
}