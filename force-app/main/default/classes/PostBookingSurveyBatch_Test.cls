/**
 * @author: Mark Anthony Pamintuan
 * @date: 7 April 2020
 * @description: Test class for PostBookingSurveyBatch
 * @history:                
 */
@isTest
private class PostBookingSurveyBatch_Test {

    @testSetup
    static void setupData(){
    
    	list<Account> lstAccounts = new list<Account>();
    	
    	for(integer i = 0; i < 10; i++){
    		Account acc = new Account();
    		if(i < 9){
    			acc.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - Detail').getRecordTypeId();
    			acc.Org_Brand__c = 'ekh';
    		} else {
    			acc.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - Detail').getRecordTypeId();
    			acc.Org_Brand__c = 'dnata';    			
    		}    		
    		acc.LastName = 'Emiratesdnata' + i;
    		acc.PersonEmail = 'emirates' + i + '.dnata@test.com';
    		

    		lstAccounts.add(acc);
    	}
    	
    	insert lstAccounts;
    	
    	list<Booking__c> lstBookings = new list<Booking__c>();
    	
    	for(integer j = 0; j < 10; j++){
    		Booking__c bookingHeader = new Booking__c();
    		bookingHeader.RecordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
    		bookingHeader.Name = 'BND/12345' + j;
    		bookingHeader.Org_Account_Name__c = lstAccounts[j].Id;
    		bookingHeader.Org_Brand__c = lstAccounts[j].Org_Brand__c;
            bookingHeader.Org_Travel_Start_Date__c = system.today() + 8;
        	bookingHeader.Org_Travel_End_Date__c = system.today() + 10;
        	bookingHeader.Org_Booked_Date__c = system.today() - 1;
			bookingHeader.Booking_Status__c = 'Receipted';
			bookingHeader.Product_Type__c = 'Flight';
            bookingHeader.Booking_System__c = 'Derwent';   	
        	lstBookings.add(bookingHeader);
    	}
    	
    	insert lstBookings;    	
    }  

    static testMethod void testPostBookingSurveyBatch(){
        
        test.startTest();
        
            PostBookingSurveyBatch batchCls = new PostBookingSurveyBatch();
            Database.executeBatch(batchCls);
                
        test.stopTest();
        
        //verify that Org_Post_Booking_NPS_Survey_Sent_Date__c was updated to date today
        for(Booking__c booking : [SELECT Org_Post_Booking_NPS_Survey_Sent_Date__c FROM Booking__c WHERE Org_Brand__c = 'ekh']){
        	system.assertEquals(system.today(), booking.Org_Post_Booking_NPS_Survey_Sent_Date__c);
        }

    }
    
    static testMethod void testScheduleableMethod(){
        
        String jobId;
        
        test.startTest();
        
            Date dateTomorrow = system.today().addDays(1);
            PostBookingSurveyBatch scheduleBatch = new PostBookingSurveyBatch();      
            String sched = '0 0 0 ' + string.valueOf(dateTomorrow.day()) + ' ' + string.valueOf(dateTomorrow.month()) + ' ? ' + string.valueOf(dateTomorrow.year());
            jobId = system.schedule('Scheduled Batch Job', sched, scheduleBatch);        
                
        test.stopTest();
        
        //verify that class was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        system.assertNotEquals(ct.Id,null);
        system.assertEquals(0, ct.TimesTriggered);
             
    }    

}