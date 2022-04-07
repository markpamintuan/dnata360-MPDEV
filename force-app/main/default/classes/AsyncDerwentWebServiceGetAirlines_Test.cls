/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   Batch Process Test Class.
History
<Date>          <Authors Name>     <Brief Description of Change>
30/04/2018        Jed Canlas      	      Initial Versioin
----------------------------------------------------------------------------*/
@isTest
public class AsyncDerwentWebServiceGetAirlines_Test {
	
    
    static testMethod void AsyncDerwentWebServiceGetAirlinesTest() { 

    	Test.setMock(HttpCalloutMock.class, new AsyncDerwentWebServiceMockAirline());  
        
        AsynWebService_Airline_Scheduler batchSch = new AsynWebService_Airline_Scheduler();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(3);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Batch Schedule' + sysTime.getTime(),chron_exp,batchSch);
        
    }
    
	static testMethod  void testScheduler () {
        
        Test.startTest();
        AsynWebService_Airline_Scheduler batchSch = new AsynWebService_Airline_Scheduler();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(3);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Batch Schedule' + sysTime.getTime(),chron_exp,batchSch);
        Test.setMock(HttpCalloutMock.class, new AsyncDerwentWebServiceMockAirline()); 
        System.enqueueJob(new AsyncDerwentWebServiceGetAirlines()); 
        Test.stopTest();


    }
}