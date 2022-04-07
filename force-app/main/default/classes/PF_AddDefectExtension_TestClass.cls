/**
 * Test Class for PF_AddDefectExtension
**/
@isTest
private class PF_AddDefectExtension_TestClass {

    static testMethod void testSaveDefect() {
        Test.startTest();
        
        PageReference pgRef = Page.PF_AddDefect;
        
        PF_Product__c product = new PF_Product__c(Name = 'Add Defect Product');      
        insert product;
        
        PF_Epic__c epic = new PF_Epic__c(Name = 'Add Defect Enhancement',
                                         PF_Product__c = product.Id);      
        insert epic;
        
        PF_Stories__c story = new PF_Stories__c(Name = 'Add Defect from Test Case Assignment',
                                                PF_Story_Owner__c = Userinfo.getUserId(),
                                                PF_Epic__c = epic.Id);      
        insert story;
        
        PF_TestCases__c testCase = new PF_TestCases__c(RecordTypeId = Schema.SObjectType.PF_TestCases__c.getRecordTypeInfosByName().get('Unit Test Case').getRecordTypeId(),
                                                       Name = 'Test creation of Defect',
                                                       PF_Type__c = 'Unit Test',
                                                       PF_Description__c = 'Test creation of defect from Test Case Assignment screen', 
                                                       PF_Story__c = story.Id);      
        insert testCase;
        
        PF_TestCaseExecution__c testCaseAssign = new PF_TestCaseExecution__c(PF_Test_Case__c = testCase.Id,
                                                                             PF_Assigned_To__c = Userinfo.getUserId(),    
                                                                             PF_Target_Completion_Date__c = Date.today() + 10);      
        insert testCaseAssign;
        
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('id',testCaseAssign.id);
        
        ApexPages.StandardController stdController = new ApexPages.standardController(testCaseAssign);
        PF_AddDefectExtension controller = new PF_AddDefectExtension(stdController);
        controller.defect.Name = 'Error Message on Test Creation';
        controller.defect.PF_Severity__c = 'Critical';
        controller.defect.PF_Type__c = 'Defect';
        controller.defect.PF_Description__c = 'Error message is displayed when user clicks on Save';
        controller.defect.PF_Steps_to_Reproduce__c = '1) Create a new Test Case. 2) Enter all the required fields and click on Save  ';
        controller.saveDefect();
        System.assertNotEquals(null,controller.defect.Id);
        Test.stopTest();
    }
}