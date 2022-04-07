/**************************************************************************************************
 * Name               : DeleteCompletedRequestLogsBatchTest
 * Description        : This is test class for DeleteCompletedRequestLogsBatch
 * Created Date       : 03-Mar-2020
 * Created By         : PwC
 * -----------------------------------------------------------------------------------------------
 ******************************************************************************************************/
@isTest
 public with sharing class DeleteCompletedRequestLogsBatchTest {
    @isTest
    public static void DeleteCompletedRequestLogsBatchTest() {
        Request_Log__c objLog = new Request_Log__c();
        objLog.Entity__c = 'Customer';
        objLog.Entity_Id__c = '12345';
        objLog.Status__c = 'Completed';
        objLog.Is_Synchronous__c = true;
        insert objLog;

        test.startTest();
            DeleteCompletedRequestLogsBatch objBatch = new DeleteCompletedRequestLogsBatch();
            objBatch.sQuery = 'select Id,Name,Entity__c,Entity_Id__c,Error_Log__c,Type__c,Status__c,CreatedDate from Request_Log__c';
        	database.executeBatch( objBatch, 1);
			objBatch.execute(null);
        	objBatch.getContentWorkspaceId('getContentWorkspaceId');
        test.stopTest();
    }
}