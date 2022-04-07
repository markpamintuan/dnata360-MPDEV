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
private class QuotesController_Test {

    static testMethod void QuotesControllerTest1() {
       
       //CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);

		Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
								Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2, AccountId = accountId);
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        options.add(opt1);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
    														 Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Emirates', 
    														From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
    														Arrival_Date_Time__c = system.today().adddays(1));
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
    	listQLI.add(objQLI10);
    	
    	Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
    	listQLI.add(objQLI11);
    	
    	insert listQLI;
    	
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	traveller1.Age_of_child__c = '< 1 year';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	traveller2.Date_of_Birth__c = system.today().adddays(-365);
    	traveller2.Age_of_child__c = '2 years';
    	listQT.add(traveller2);
    	
    	insert listQT;
        
        Apexpages.currentPage().getParameters().put('headerId',header.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(objCase);
        QuotesController obj = new QuotesController(stdCntlr);
        obj.currencyOptions = new List<SelectOption>();
        obj.currentOptionId = string.valueOf(options[0].Option_Number__c); 
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemRecordType = 'Flight';
       	obj.setDisclaimer();
       	obj.editLineItem();
       	obj.returnLineItem();
       	
       	obj.lineItemRecordId = listQLI[0].id;
       	obj.lineItemRecordType = 'Hotel';
       	obj.editLineItem();
       	
       	obj.lineItemRecordId = listQLI[8].id;
       	obj.lineItemRecordType = 'Other';
       	obj.editLineItem();
       	
        obj.cloneQuoteOption();
        obj.finalizeQuoteOption();
        obj.deleteQuoteOption();
        
        obj.setCurrentOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemName = 'Flight';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[0].id;
        obj.lineItemName = 'Hotel';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[8].id;
        obj.lineItemName = 'Other';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[10].id;
        obj.lineItemName = 'Flight';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[9].id;
        obj.lineItemName = 'Hotel';
        //obj.saveQuoteLineItem();
        
        obj.saveQuoteDetails();
        
        obj.addChildAgeRecords();
        
        obj.sendQuote();
        
        obj.updateQuoteDetails();
        
        obj.deleteLineItem();
        
        obj.validateCaseBfrEmail();
        
        obj.closeEmailPopup();
        
    }

    static testMethod void QuotesControllerTest2() {
       
       //CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);

		Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
								Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2, AccountId = accountId);
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        options.add(opt1);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
    														 Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Emirates', 
    														From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
    														Arrival_Date_Time__c = system.today().adddays(1));
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
    	listQLI.add(objQLI10);
    	
    	Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
    	listQLI.add(objQLI11);
    	
    	insert listQLI;
    	
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	traveller2.Date_of_Birth__c = system.today().adddays(-365);
    	listQT.add(traveller2);
    	
    	insert listQT;
    	
    	lookup__c flight = new lookup__c(Name = 'testFlight');
    	insert flight;
    	
    	City__c hotel = new City__c(Name = 'testHotel');
    	insert hotel;
        
        Apexpages.currentPage().getParameters().put('headerId',header.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(objCase);
        QuotesController obj = new QuotesController(stdCntlr);
        //obj.currencyOptions = new List<SelectOption>();
        obj.currentOptionId = '1'; 
        
        //obj.currencyOptions();
        obj.getflightOptions();
        obj.getAge();
        obj.specifyAction();
        obj.getflightpriceOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemRecordType = 'Flight';
       	obj.setDisclaimer();
       	obj.editLineItem();
       	obj.returnLineItem();
       	//obj. getflightpriceOption();
       	
       	obj.lineItemRecordId = listQLI[0].id;
       	obj.lineItemRecordType = 'Hotel';
       	obj.editLineItem();
       	
       	obj.lineItemRecordId = listQLI[8].id;
       	obj.lineItemRecordType = 'Other';
       	obj.editLineItem();
       	
        obj.cloneQuoteOption();
        obj.finalizeQuoteOption();
        obj.deleteQuoteOption();
        
        obj.setCurrentOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemName = 'Flight';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[0].id;
        obj.lineItemName = 'Hotel';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[8].id;
        obj.lineItemName = 'Other';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[10].id;
        obj.lineItemName = 'Flight';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[9].id;
        obj.lineItemName = 'Hotel';
        //obj.saveQuoteLineItem();
        
        obj.isPriceValid();
        obj.toggleContent();
        obj.validateHotelDetails();
        
		QuotesController.getFromFlights('testFlight');
		QuotesController.getToFlights('testFlight');
		QuotesController.getHotelName('testHotel');
        
    }

    static testMethod void QuotesControllerTest3() {
       
       //CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);

		Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Booking Enquiry').getRecordTypeId(),
								Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2, AccountId = accountId, Org_Brand__c = 'trp');
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        options.add(opt1);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
    														 Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Emirates', 
    														From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
    														Arrival_Date_Time__c = system.today().adddays(1));
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
    	listQLI.add(objQLI10);
    	
    	Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
    	listQLI.add(objQLI11);
    	
    	insert listQLI;
    	
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	traveller2.Date_of_Birth__c = system.today().adddays(-365);
    	listQT.add(traveller2);
    	
    	insert listQT;
    	
    	lookup__c flight = new lookup__c(Name = 'testFlight');
    	insert flight;
    	
    	City__c hotel = new City__c(Name = 'testHotel');
    	insert hotel;
        
        Apexpages.currentPage().getParameters().put('headerId',header.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(objCase);
        QuotesController obj = new QuotesController(stdCntlr);
        //obj.currencyOptions = new List<SelectOption>();
        obj.currentOptionId = '1'; 
        
        //obj.currencyOptions();
        obj.getflightOptions();
        obj.getAge();
        obj.specifyAction();
        obj.getflightpriceOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemRecordType = 'Flight';
       	obj.setDisclaimer();
       	obj.editLineItem();
       	obj.returnLineItem();
       	//obj. getflightpriceOption();
       	
       	obj.lineItemRecordId = listQLI[0].id;
       	obj.lineItemRecordType = 'Hotel';
       	obj.editLineItem();
       	
       	obj.lineItemRecordId = listQLI[8].id;
       	obj.lineItemRecordType = 'Other';
       	obj.editLineItem();
       	
        obj.cloneQuoteOption();
        obj.finalizeQuoteOption();
        obj.deleteQuoteOption();
        
        obj.setCurrentOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemName = 'Flight';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[0].id;
        obj.lineItemName = 'Hotel';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[8].id;
        obj.lineItemName = 'Other';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[10].id;
        obj.lineItemName = 'Flight';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[9].id;
        obj.lineItemName = 'Hotel';
        obj.saveQuoteLineItem();
        
        obj.isPriceValid();
        obj.toggleContent();
        obj.validateHotelDetails();
        obj.showEdit();
        
		QuotesController.getFromFlights('testFlight');
		QuotesController.getToFlights('testFlight');
		QuotesController.getHotelName('testHotel');
		
		obj.airline = listQLI[10];
		obj.removePriceforFlightPackageCost();
		obj.updatePriceforFlightPackageCost();
		obj.roundedtotalPriceRollup = 2;
		
        
    }

    static testMethod void QuotesControllerTest4() {
       
       //CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);

		Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId(),
								Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2, AccountId = accountId, Org_Brand__c = 'trp');
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        options.add(opt1);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
    														 Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Emirates', 
    														From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
    														Arrival_Date_Time__c = system.today().adddays(1));
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
    	listQLI.add(objQLI10);
    	
    	Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
    	listQLI.add(objQLI11);
    	
    	insert listQLI;
    	
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	traveller2.Date_of_Birth__c = system.today().adddays(-365);
    	listQT.add(traveller2);
    	
    	insert listQT;
    	
    	lookup__c flight = new lookup__c(Name = 'testFlight');
    	insert flight;
    	
    	City__c hotel = new City__c(Name = 'testHotel');
    	insert hotel;
        
        Apexpages.currentPage().getParameters().put('headerId',header.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(objCase);
        QuotesController obj = new QuotesController(stdCntlr);
        //obj.currencyOptions = new List<SelectOption>();
        obj.currentOptionId = '1'; 
        
        //obj.currencyOptions();
        obj.getflightOptions();
        obj.getAge();
        obj.specifyAction();
        obj.getflightpriceOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemRecordType = 'Flight';
       	obj.setDisclaimer();
       	obj.editLineItem();
       	obj.returnLineItem();
       	//obj. getflightpriceOption();
       	
       	obj.lineItemRecordId = listQLI[0].id;
       	obj.lineItemRecordType = 'Hotel';
       	obj.editLineItem();
       	
       	obj.lineItemRecordId = listQLI[8].id;
       	obj.lineItemRecordType = 'Other';
       	obj.editLineItem();
       	
        obj.cloneQuoteOption();
        obj.finalizeQuoteOption();
        obj.deleteQuoteOption();
        
        obj.setCurrentOption();
        
        obj.lineItemRecordId = listQLI[1].id;
        obj.lineItemName = 'Flight';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[0].id;
        obj.lineItemName = 'Hotel';
        //obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[8].id;
        obj.lineItemName = 'Other';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[10].id;
        obj.lineItemName = 'Flight';
        obj.saveQuoteLineItem();
        
        obj.lineItemRecordId = listQLI[9].id;
        obj.lineItemName = 'Hotel';
        obj.saveQuoteLineItem();
        
        obj.isPriceValid();
        obj.toggleContent();
        obj.validateHotelDetails();
        obj.showEdit();
        
		QuotesController.getFromFlights('testFlight');
		QuotesController.getToFlights('testFlight');
		QuotesController.getHotelName('testHotel');
		
		obj.airline = listQLI[10];
		obj.removePriceforFlightPackageCost();
		obj.updatePriceforFlightPackageCost();
		obj.roundedtotalPriceRollup = 2;
		
        
    }

    static testMethod void QuotesControllerTest5() {
       
       //CreateAccount
		Id accountId = TestDataFactory.createEKUK_AccountId();
		
		//Create Entitlement		
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);

		Case objCase= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
								Org_Number_of_Nights__c = 1,Org_No_of_Children_Travelling__c=2, AccountId = accountId);
        insert objCase;
        
        
        Quote_Header__c header = new Quote_Header__c();
        header.Date_To__c = system.today();
        header.Case__c = objCase.id;
        header.Date_From__c = system.today();
        header.Date_To__c = system.today().addDays(2);
        
    	insert header;
    	
    	list<Quote_Option__c> options = new List<Quote_Option__c>();
        Quote_Option__c opt = new Quote_Option__c();
        opt.Quote_Header__c = header.Id;
        opt.Option_Number__c = 1;
        options.add(opt);
        
        Quote_Option__c opt1 = new Quote_Option__c();
        opt1.Quote_Header__c = header.Id;
        opt1.Option_Number__c = 2;
        options.add(opt1);
        insert options;
    	
    	list<Quote_Line_Item__c> listQLI = new list<Quote_Line_Item__c>();
    	
    	Quote_Line_Item__c objQLI1 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel', Hotel_Name__c = 'Test',
    														 Check_In__c = system.today(), Check_Out__c = system.today().adddays(1));
    	listQLI.add(objQLI1);
    	
    	Quote_Line_Item__c objQLI2 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight', Airline__c = 'Emirates', 
    														From__c = 'Abu Dhabi International Airport', To__c = 'Test', Departure_Date_Time__c = system.today(),
    														Arrival_Date_Time__c = system.today().adddays(1));
    	listQLI.add(objQLI2);
    	
    	Quote_Line_Item__c objQLI3 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Transfer');
    	listQLI.add(objQLI3);
    	
    	Quote_Line_Item__c objQLI4 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Airport Parking');
    	listQLI.add(objQLI4);
    	
    	Quote_Line_Item__c objQLI5 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Car Hire');
    	listQLI.add(objQLI5);
    	
    	Quote_Line_Item__c objQLI6 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Marhaba');
    	listQLI.add(objQLI6);
    	
    	Quote_Line_Item__c objQLI7 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Bundle');
    	listQLI.add(objQLI7);
    	
    	Quote_Line_Item__c objQLI8 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='AdHoc');
    	listQLI.add(objQLI8);
    	
    	Quote_Line_Item__c objQLI9 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Other Services', Other_Service_Type__c='Other');
    	listQLI.add(objQLI9);
    	
    	Quote_Line_Item__c objQLI10 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Hotel');
    	listQLI.add(objQLI10);
    	
    	Quote_Line_Item__c objQLI11 = new Quote_Line_Item__c(Quote_Option__c = options[0].Id,dtme_price__c=100,Type__c='Flight');
    	listQLI.add(objQLI11);
    	
    	insert listQLI;
    	
    	list<Quote_Traveller__c> listQT = new list<Quote_Traveller__c> ();
    	
    	Quote_Traveller__c traveller1 = new Quote_Traveller__c();
    	traveller1.Quote__c = header.id;
    	traveller1.Traveller_Type__c = 'Infant';
    	listQT.add(traveller1);
    	
    	Quote_Traveller__c traveller2 = new Quote_Traveller__c();
    	traveller2.Quote__c = header.id;
    	traveller2.Traveller_Type__c = 'Child';
    	traveller2.Date_of_Birth__c = system.today().adddays(-365);
    	listQT.add(traveller2);
    	
    	insert listQT;
        
        //Apexpages.currentPage().getParameters().put('headerId',header.Id);
        ApexPages.StandardController stdCntlr = new ApexPages.StandardController(objCase);
        QuotesController obj = new QuotesController(stdCntlr);

        
    }
    
}