/**
 * Test Class for PF_CloneTestCasewithChildController
**/
@isTest
private class PF_CloneTestCasewithChildController_Test {
    
    static testMethod void executeTestClone() {
        Test.startTest();
        
        PageReference pgRef = Page.PF_CloneTestCasewithChild;
        
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
        
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('id',testCase.id);
        
        ApexPages.StandardController stdController = new ApexPages.standardController(testCase);
        PF_CloneTestCasewithChildController controller = new PF_CloneTestCasewithChildController(stdController);
        
        controller.cancel();
        
        controller.isSelected = true;
        controller.checkSelectAll();
        controller.cloneParentwithSelectedChild();
        System.assertNotEquals(null,controller.cloneParentwithSelectedChild());
        
        controller.isSelected = false;
        controller.checkSelectAll();
        controller.cloneParentwithSelectedChild();
        System.assertNotEquals(null,controller.cloneParentwithSelectedChild());
        
        Test.stopTest();
    }
    
}