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
private class QuotePDFGenerationController_Test {

    static testMethod void QuotePDFGenerationControllerTest1() {
    	
    	
    	Quote_Header__c header = new Quote_Header__c();
        header.RecordTypeId = '0120Y000000yty0QAA';//SF Quote Prod Id
    	insert header;
    	
        Quote_Header__c header1 = new Quote_Header__c();
        header1.RecordTypeId = '0120Y000000ytxzQAA';//Derwent Quote Prod Id
    	insert header1;
        
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	listQT.add(traveller2);
    	
        Quote_Traveller__c traveller3 = new Quote_Traveller__c();
    	traveller3.Quote__c = header1.id;
    	traveller3.Traveller_Type__c = 'Child';
    	listQT.add(traveller3);
    	insert listQT;
    	
    	Quote_Option__c objQO = new Quote_Option__c();
    	objQO.Quote_Header__c = header.id;
    	insert objQO;
    	
        Quote_Option__c objQO1 = new Quote_Option__c();
    	objQO1.Quote_Header__c = header1.id;
    	insert objQO1;
        
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c> ();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c();
    	objQLI1.Quote_Option__c = objQO.id;
    	objQLI1.Type__c = 'Package';
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c();
    	objQLI2.Quote_Option__c = objQO.id;
    	objQLI2.Type__c = 'Flight';
    	objQLI2.Departure_Date_Time__c = system.today();
    	objQLI2.Arrival_Date_Time__c = system.today();
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c();
    	objQLI3.Quote_Option__c = objQO.id;
    	objQLI3.Type__c = 'Hotel';
    	objQLI3.Check_In__c = system.today();
    	objQLI3.Check_Out__c = system.today();
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c();
    	objQLI4.Quote_Option__c = objQO.id;
    	objQLI4.Type__c = 'Other Services';
    	listQLI.add(objQLI4);
        insert listQLI;
        
    	list<Quote_Line_Item__c> listQLI1 = new list<Quote_Line_Item__c> ();
        
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c();
    	objQLI6.Quote_Option__c = objQO1.id;
    	objQLI6.Type__c = 'Flight';
    	objQLI6.Departure_Date_Time__c = system.today();
    	objQLI6.Arrival_Date_Time__c = system.today();
    	listQLI1.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c();
    	objQLI7.Quote_Option__c = objQO1.id;
    	objQLI7.Type__c = 'Accommodation';
    	objQLI7.CheckInDate__c = system.today();
    	objQLI7.CheckOutDate__c = system.today();
    	listQLI1.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c();
    	objQLI8.Quote_Option__c = objQO1.id;
    	objQLI8.Type__c = 'Marhaba';
    	listQLI1.add(objQLI8);
        
        Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c();
    	objQLI9.Quote_Option__c = objQO1.id;
    	objQLI9.Type__c = 'Insurance';
    	listQLI1.add(objQLI9);
    	
        Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c();
    	objQLI10.Quote_Option__c = objQO1.id;
    	objQLI10.Type__c = 'Transfer';
    	listQLI1.add(objQLI10);
    	 
        insert listQLI1;
    	
    	
    	ApexPages.StandardController stdCntlr = new ApexPages.StandardController(header);
        ApexPages.StandardController stdCntlr1 = new ApexPages.StandardController(header1);
        QuotePDFGenerationController obj = new QuotePDFGenerationController(stdCntlr);
        QuotePDFGenerationController obj1 = new QuotePDFGenerationController(stdCntlr1);
        obj.lineItems  = new List<Quote_Line_Item__c>();
        obj1.lineItems  = new List<Quote_Line_Item__c>();
    }
}