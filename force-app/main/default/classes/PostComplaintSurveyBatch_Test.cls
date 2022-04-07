/**
 * @author: Mark Anthony Pamintuan
 * @date: 7 April 2020
 * @description: Test class for PostComplaintSurveyBatch
 * @history:                
 */
@isTest
private class PostComplaintSurveyBatch_Test {

    @testSetup
    static void setupData(){
    
        list<Account> lstAccounts = new list<Account>();
        
        for(integer i = 0; i < 10; i++){
            Account acc = new Account();
            acc.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - Detail').getRecordTypeId();
            acc.Org_Brand__c = 'ekh';          
            acc.LastName = 'Emiratesdnata' + i;
            acc.PersonEmail = 'emirates' + i + '.dnata@test.com';
            acc.Org_Last_Date_Survey_Completed__c = system.today() - 9;
            lstAccounts.add(acc);
        }
        
        insert lstAccounts;
        
        list<Case> lstComplaints = new list<Case>();
        
        for(integer j = 0; j < 10; j++){
            Case complaintCase = new Case();
            complaintCase.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKH - Complaints').getRecordTypeId();
            complaintCase.AccountId = lstAccounts[j].Id;
            complaintCase.ContactId = lstAccounts[j].PersonContactId;
            complaintCase.Subject = 'Test' + j;
            complaintCase.Org_Brand__c = lstAccounts[j].Org_Brand__c;
            complaintCase.Org_Case_Status__c = 'Closed';
            complaintCase.Reason = 'Resolved';
            complaintCase.Booking_Ref__c = '12345' + j;
            lstComplaints.add(complaintCase);
        }
        
        insert lstComplaints;     
    }  

    static testMethod void testPostComplaintSurveyBatch(){
        
        test.startTest();
        
            PostComplaintSurveyBatch batchCls = new PostComplaintSurveyBatch();
            Database.executeBatch(batchCls);
                
        test.stopTest();
        
        //verify that Post_Complaint_Survey_Sent_Date__c was updated to date today
        for(Case complaint : [SELECT Org_Case_Complaint_Survey_Sent_Date__c FROM Case]){
            system.assertEquals(system.today(), complaint.Org_Case_Complaint_Survey_Sent_Date__c);
        }

    }
    
    static testMethod void testScheduleableMethod(){
        
        String jobId;
        
        test.startTest();
        
            Date dateTomorrow = system.today().addDays(1);
            PostComplaintSurveyBatch scheduleBatch = new PostComplaintSurveyBatch();      
            String sched = '0 0 0 ' + string.valueOf(dateTomorrow.day()) + ' ' + string.valueOf(dateTomorrow.month()) + ' ? ' + string.valueOf(dateTomorrow.year());
            jobId = system.schedule('Scheduled Batch Job', sched, scheduleBatch);        
                
        test.stopTest();
        
        //verify that class was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        system.assertNotEquals(ct.Id,null);
        system.assertEquals(0, ct.TimesTriggered);
             
    }    

}