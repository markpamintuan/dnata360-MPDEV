/**************************************************************************************************
* Name               : eCommerceComponentsControllerTest
* Description        : Test Class
* Created Date       : 01-Oct-2019
* Created By         : Jed Canlas
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR           DATE           COMMENTS
* v1.0        Jed             01-Oct-2019     Initial version
**************************************************************************************************/
@isTest
public class eCommerceComponentsControllerTest {

@testSetup static void dataSetup() {
	//CreateAccount



	Account acc= new Account(lastname='eCommerceSampleAccount',
	                         PersonEmail='eCommerce_Test1@gmail.com',
	                         PersonHomePhone='1111222211121',
	                         recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dnata eCommerce').getRecordTypeId(),
	                         Org_Brand__c = 'dnata eCommerce');
	insert acc;

	BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
	TestDataFactory.createEntitlement(acc.Id, bhs.Id);

	Case cse = new Case();
	cse.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSD B2C - New Enquiry').getRecordTypeId();
	cse.AccountId = acc.Id;
	cse.Org_Brand__c = 'City Sightseeing Dubai';
	insert cse;

	Product2 p =new Product2();
	p.Name='csd prod';
	p.productCode='1234';
	p.isActive = true;
	p.Brand__c = 'City Sightseeing Dubai';
	p.Family = 'dnata eCommerce';
	Insert p;
	Product2 p2 =new Product2();
	p2.Name='marhaba prod';
	p2.productCode='1234';
	p2.isActive = true;
	p2.Brand__c = 'marhaba';
	p2.Family = 'dnata eCommerce';
	Insert p2;

	//Instantiate the Pricebook2 record with StandardPricebookId
	Pricebook2 standardPricebook = new Pricebook2(
		Id = Test.getStandardPricebookId(),
		IsActive = true
		);

	//Execute an update DML on the Pricebook2 record, to make IsStandard to true
	Update standardPricebook;

	//Query for the Pricebook2 record, to check IsStandard field
	standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
	//It should return true
	System.assertEquals(true, standardPricebook.IsStandard);


	//Create the PricebookEntry
	PricebookEntry pbe = new PricebookEntry(
		Pricebook2Id = standardPricebook.Id,
		Product2Id = p.Id,
		UnitPrice = 1020,
		IsActive = true
		);
	Insert pbe;


	Lookup__c l = new Lookup__c();
	l.name = 'test';
	l.type__c = 'Airport';
	l.code__c = 'test';
	insert l;





}

@isTest static void testComponent() {

	Order o = new Order();
	o.SFCC_Created_By__c = 'Salesforce';
	o.Status__c = 'Confirmed';
	o.Status = 'Draft';
	o.Shipment_Status__c = 'NOT_SHIPPED';
	o.Name =  'Booking for Case - ';
	o.Case__c = [select id from case limit 1].Id;
	o.AccountId = [select id,AccountId from case limit 1].AccountId;
	o.SFCC_Customer_Name__c = 'test acc';
	o.SFCC_Customer_Email__c = 'email@email123.com';
	o.Order_SCCSync_Status__c = 'Created';
	o.SFCC_Order_Total__c = 0;
	o.SFCC_Brand__c = [select id,Org_Brand__c from case limit 1].Org_Brand__c;
	o.EffectiveDate = date.today();
	o.SFCC_Order_Number__c = '1';
	insert o;

	Order_Line_Item__c oli = new Order_Line_Item__c();
	oli.Quantity__c = 10;
	oli.Unit_Price__c = 10;
	oli.Order__c = o.Id;
	oli.Product__c = [select id from product2 limit 1].Id;
	insert oli;


	Order_Traveller__c ot = new Order_Traveller__c();
	ot.Order_Line_Item__c = oli.Id;
	ot.Org_Date_of_Birth__c = date.today() - 1000;
	ot.Org_First_Name__c = 'first';
	ot.Org_Last_Name__c = 'last';
	insert ot;


	eCommerceComponentsController.displayNewBookingButton();
	eCommerceComponentsController.fetchUser();
	eCommerceComponentsController.getSobjectType(o.Id);
	eCommerceComponentsController.getObjectRecord(o.Id);
	eCommerceComponentsController.getParentId(o.Id);
    eCommerceComponentsController.getRecTypeId('marhaba B2C - Generic');
    eCommerceComponentsController.caseOwnerNotMatching(o.Case__c);
    eCommerceComponentsController.changeCaseOwner(o.Case__c);
    eCommerceComponentsController.cloneCaseTest(o.Case__c);
    eCommerceComponentsController.fetchLookUpValues(string.valueOf(userinfo.getFirstName()),o.Case__c,'User');

	eCommerceComponentsController.getAfterSalesRT(o.Id);
	eCommerceComponentsController.getComplaintsRT(o.Id);
	eCommerceComponentsController.getCreatableFieldsSOQL('Order');
	eCommerceComponentsController.getselectOptions('Status');
	eCommerceComponentsController.fetchCaseComplaintRecordTypeValues();
	eCommerceComponentsController.fetchCaseCommendationRecordTypeValues();
	eCommerceComponentsController.fetchCaseGeneralEnquirytRecordTypeValues();

}

















}