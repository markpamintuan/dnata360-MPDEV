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
private class PF_AddEditTCSteps_Test {

    static testMethod void myUnitTest() {
        Test.startTest();
        
        PF_Product__c product = new PF_Product__c(Name = 'Test Case Product');      
        insert product;
        
        PF_Epic__c epic = new PF_Epic__c(Name = 'Test Case Enhancement',
                                         PF_Product__c = product.Id);      
        insert epic;
        
        PF_Stories__c story = new PF_Stories__c(Name = 'Clone Test Case',
                                                PF_Story_Owner__c = Userinfo.getUserId(),
                                                PF_Epic__c = epic.Id);      
        insert story;
        
        PF_TestCases__c testCase = new PF_TestCases__c(RecordTypeId = Schema.SObjectType.PF_TestCases__c.getRecordTypeInfosByName().get('Unit Test Case').getRecordTypeId(),
                                                       Name = 'Test Case Cloning',
                                                       PF_Type__c = 'Unit Test',
                                                       PF_Description__c = 'Test successful cloning of test case with its child objects', 
                                                       PF_Story__c = story.Id);      
        insert testCase;
        
        PF_TestCaseExecution__c testCaseAssign = new PF_TestCaseExecution__c(PF_Test_Case__c = testCase.Id,
                                                                             PF_Assigned_To__c = Userinfo.getUserId(),    
                                                                             PF_Target_Completion_Date__c = Date.today() + 10);      
        insert testCaseAssign;
        
        PF_Test_Case_Step__c testCaseStep = new PF_Test_Case_Step__c(Name = 'Test Case Step',
                                                                       PF_Test_Case__c = testCase.Id,
                                                                       PF_Step_Number__c = 1,
                                                                       PF_Step_Description__c = 'Click on Clone',
                                                                       PF_Expected_Result__c = 'User should be navigated to the clone screen');      
        insert testCaseStep;
        
		List<PF_Test_Case_Step__c> listTestCaseStep = new List<PF_Test_Case_Step__c>();
         for(integer i=0;i<5;i++){
			PF_Test_Case_Step__c testStep = new PF_Test_Case_Step__c();
			testStep.PF_Test_Case__c = testCase.Id;
			testStep.PF_Expected_Result__c = 'Sample Expected Result Test';
			testStep.PF_Step_Description__c = 'Step Description Test'; 
			testStep.PF_Step_Number__c = i; 
			listTestCaseStep.add(testStep);
		 }
        insert listTestCaseStep;
        
        List<Id> testCaseId = new List<id>();
        PF_Test_Case_Step__c testCaseStepId = [Select id from PF_Test_Case_Step__c limit 1];
        testCaseId.add(testCaseStepId.Id);
          
        PF_AddEditTCSteps.upsertTestCaseSteps(listTestCaseStep, testCaseId);
        PF_AddEditTCSteps.getRecords(testCase.Id); 
        PF_AddEditTCSteps.deleteSeleted(testCaseId);  
        System.assertEquals(false, PF_AddEditTCSteps.checkPageAccess());
        
        Test.stopTest();
        
    }
}