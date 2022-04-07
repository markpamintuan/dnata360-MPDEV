@isTest
public class SurveyTagButtonController_TEST {
     @isTest static void testSurveyTag(){
        test.startTest();
        Survey_Response__c survey = new Survey_Response__c();
        survey.Brand__c = 'ekh';
        survey.Org_Survey_Model__c = 'CSAT';
        insert survey;
        String journeyPoint = '';
        journeyPoint = 'Post Travel';
        SurveyTagButtonController stb = new SurveyTagButtonController();
        SurveyTagButtonController.getCaseRecordTypeId('ekh','Tag',journeyPoint);
        SurveyTagButtonController.getCaseRecordTypeId('ekh','Tag','Post Travel / Holiday');
        SurveyTagButtonController.getCaseRecordTypeId('ekh','Tag','Pre Travel / Post Booking');
        test.stopTest();
        
    }
}