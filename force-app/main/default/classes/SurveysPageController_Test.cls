@isTest
public class SurveysPageController_Test {
    @testSetup static void dataSetup() {
        //CreateAccount
        Id accountId = TestDataFactory.createDTME_AccountId();
        
        //Create Entitlement        
        BusinessHours bhs = [SELECT Id FROM BusinessHours WHERE IsDefault=true LIMIT 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);

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
        
        Survey__c dnataSurvey = new Survey__c();
        dnataSurvey.Survey_Name__c = 'test survey';
        dnataSurvey.Brand__c = 'dnata';
        dnataSurvey.Customer_Journey__c = 'TEST';
        dnataSurvey.Survey_Model__c = 'CNPS';
        insert dnataSurvey;

        Survey__c ekhSurvey = new Survey__c();
        ekhSurvey.Survey_Name__c = 'ekh test survey';
        ekhSurvey.Brand__c = 'ekh';
        ekhSurvey.Customer_Journey__c = 'TEST';
        ekhSurvey.Survey_Model__c = 'CSAT';
        ekhSurvey.Domain_Id__c = 'ekhALL';
        insert ekhSurvey;
        
    }

    static testMethod void testParentBooking() {

        Booking__c booking = [SELECT Id FROM Booking__c WHERE RecordtypeId =: Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId() LIMIT 1];
        Survey__c survey = [SELECT Id FROM Survey__c WHERE Brand__c = 'dnata' LIMIT 1];

        PageReference pageRef = Page.SurveysPage;
        pageRef.getParameters().put('sId', survey.Id);
        pageRef.getParameters().put('parentId', booking.Id);
        pageRef.getParameters().put('rate', '1');  
        Test.setCurrentPage(pageRef);

        Test.StartTest(); 

            SurveysPageController  ctlr = new SurveysPageController();
            ctlr.save();

        Test.StopTest();    
    }
    
    static testMethod void testParentAccount() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Survey_Date__pc = system.today();
        acc.Survey_Count__pc = 1;
        acc.Survey_Group__pc = 'marhaba online';
        update acc;

        Survey__c survey = [SELECT Id FROM Survey__c WHERE Brand__c = 'dnata' LIMIT 1];

        PageReference pageRef = Page.SurveysPage;
        pageRef.getParameters().put('sId', survey.Id);
        pageRef.getParameters().put('parentId', acc.Id);
        pageRef.getParameters().put('rate', '9');  
        Test.setCurrentPage(pageRef);

        Test.StartTest(); 

            SurveysPageController  ctlr = new SurveysPageController();
            ctlr.save();

        Test.StopTest();    
    }    


    static testMethod void testParentAccountWithExistingResponse() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Survey_Date__pc = system.today();
        acc.Survey_Count__pc = 1;
        acc.Survey_Group__pc = 'marhaba online';
        update acc;

        Survey__c survey = [SELECT Id, Survey_Model__c, Brand__c, Customer_Journey__c FROM Survey__c WHERE Brand__c = 'dnata' LIMIT 1];

        Survey_Response__c surveyResponse = new Survey_Response__c();
        surveyResponse.Org_Survey_Model__c = survey.Survey_Model__c;
        surveyResponse.Brand__c = survey.Brand__c;
        surveyResponse.Org_Customer_Journey__c = survey.Customer_Journey__c;
        surveyResponse.Survey_Date__c = acc.Survey_Date__pc;
        surveyResponse.Survey_Count__c = acc.Survey_Count__pc;
        surveyResponse.Survey_Group__c = acc.Survey_Group__pc;
        surveyResponse.Org_Account__c = acc.Id;
        surveyResponse.Survey__c = survey.Id;
        insert surveyResponse;

        PageReference pageRef = Page.SurveysPage;
        pageRef.getParameters().put('sId', survey.Id);
        pageRef.getParameters().put('parentId', acc.Id);
        pageRef.getParameters().put('rate', '9');  
        Test.setCurrentPage(pageRef);

        Test.StartTest(); 

            SurveysPageController  ctlr = new SurveysPageController();
            ctlr.save();

        Test.StopTest();    
    }       

    static testMethod void testParentBookingEKH() {

        Case complaint = new Case();
        complaint.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH - Complaints').getRecordTypeId();
        complaint.Origin = 'Phone';
        complaint.Org_Case_Status__c = 'New';
        complaint.Org_Issue__c = 'Accommodation';
        complaint.Org_Issue_Type__c = 'Duplicate Booking';
        complaint.Org_Customer_Journey_Point__c = 'Pre Travel / Post Booking';
        complaint.Contact_Reason__c = 'Other';
        
        insert complaint;

        Survey__c survey = [SELECT Id FROM Survey__c WHERE Brand__c = 'ekh' LIMIT 1];
        PageReference pageRef = Page.SurveysPage;
        pageRef.getParameters().put('sId', survey.Id);
        pageRef.getParameters().put('parentId', complaint.Id);
        pageRef.getParameters().put('rate', '1');  
        Test.setCurrentPage(pageRef);

        Test.StartTest(); 

            SurveysPageController  ctlr = new SurveysPageController();
            ctlr.save();

        Test.StopTest();    
    }

}