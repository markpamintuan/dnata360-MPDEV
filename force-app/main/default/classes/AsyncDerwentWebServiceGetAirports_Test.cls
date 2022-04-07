/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   Batch Process Test Class.
History
<Date>          <Authors Name>     <Brief Description of Change>
30/04/2018        Jed Canlas      	      Initial Versioin
----------------------------------------------------------------------------*/
@isTest
public class AsyncDerwentWebServiceGetAirports_Test {
    
    
    static testMethod void AsyncDerwentWebServiceGetAirportsTest() { 
        
        Test.setMock(HttpCalloutMock.class, new AsyncDerwentWebServiceMockAirport()); 
        
        AsynWebService_Airport_Scheduler batchSch = new AsynWebService_Airport_Scheduler();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(3);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Batch Schedule' + sysTime.getTime(),chron_exp,batchSch);
        
    }
    
    static testMethod  void testScheduler () {
        Lookup__c l = new Lookup__c();
        l.Name = '108 Mile Ranch';
        l.Code__c = 'ZMH';
        l.Type__c = 'Airport';
        
        Test.startTest();
        insert l;
        AsynWebService_Airport_Scheduler batchSch = new AsynWebService_Airport_Scheduler();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(3);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Batch Schedule' + sysTime.getTime(),chron_exp,batchSch);
        Test.setMock(HttpCalloutMock.class, new AsyncDerwentWebServiceMockAirport()); 
        System.enqueueJob(new AsyncDerwentWebServiceGetAirports()); 
        Test.stopTest();
        
        
    }
}