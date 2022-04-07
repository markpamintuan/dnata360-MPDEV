@isTest(seeAllData='true')
public class MassEmailSenderControllerTest {
    static testmethod void test1(){
        MassEmailSenderController msc1 = new MassEmailSenderController();     
        String csvContent = 'Field 1, Field 2, Field 3 \n  99999999, Value 2, Value 3 \n';
        List<Report> reports = MassEmailSenderController.fetchReports();        
        MassEmailSenderController.fetchRecordTypeValues();       
        MassEmailSenderController.saveCase('description', '', UserInfo.getUserId(), 'Travel Republic - Service Request', 'New', '', false,EncodingUtil.urlEncode(csvContent,'UTF-8'));        
        Booking__c book = new Booking__c();
        book.Booking_ID__c = '99999999';
        insert book;
        MassEmailSenderController.checkBookingIdList(book.Booking_ID__c);
        MassEmailSenderController.saveCaseManual('description', '', book.Booking_ID__c, '','Travel Republic - Service Request','New','',false);     
        String lookups = String.valueOf(MassEmailSenderController.fetchLookUpValues('TR','','Queue'));
        String lookups2 = String.valueOf(MassEmailSenderController.fetchLookUpValues('Ken','','User'));        
    	MassEmailSenderController.getRecTypeId('Travel Republic - Service Request');
    }
    
    
    static testmethod void test2(){
        MassEmailSenderController msc1 = new MassEmailSenderController();
        Booking__c book = new Booking__c();
        book.Booking_ID__c = '99999999';
        insert book;   
        String csvContent = 'Field 1, Field 2, Field 3 \n  99999999, Value 2, Value 3 \n';
        MassEmailSenderController.saveCase('description', '', userInfo.getUserId(),'Travel Republic - Service Request','New','',false,EncodingUtil.urlEncode(csvContent,'UTF-8'));    
        MassEmailSenderController.checkBookingIdList(book.Booking_ID__c);
        MassEmailSenderController.saveCaseManual('description', '', book.Booking_ID__c, '','Travel Republic - Service Request','New','',false);
        String lookups = String.valueOf(MassEmailSenderController.fetchLookUpValues('TR','','Queue'));
        String lookups2 = String.valueOf(MassEmailSenderController.fetchLookUpValues('Ken','','User'));
        MassEmailSenderController.fetchLookUpValuesForSubject('', null);       
    }
   
}