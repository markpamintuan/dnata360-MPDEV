/****************************************
 * Class Name : PF_TestCaseExecution_TestClass
 * 
 * Description: Test class for PF_TestCaseExecution_TriggerHandler class.
 * 
 * Created By : Prasheela
 * ****************************************/
 @isTest
 private class PF_TestCaseExecution_TestClass{
      static testMethod void myUnitTest() {
          //Prepare project 
        PF_Project__c project = new PF_Project__c();
        project.Name = 'Project Test';       
        project.PF_Project_Status__c = 'In Progress';
        insert project;
        
        //Prepare Release
        PF_Release__c release = new PF_Release__c();
        release .Name = 'Release Test';       
        release.PF_Release_Status__c = 'In Progress';
        release.PF_Project__c = project.id;
        release.PF_Planned_Start_Date__c = Date.Today();
        release.PF_Planned_End_Date__c    = Date.Today().addDays(1);
        insert release;
        
        PF_Sprints__c sprint = new PF_Sprints__c();
        sprint.Name = 'sprint Test';
        sprint.PF_Sprint_Status__c = 'In Progress';
        sprint.PF_Release__c = release.Id;
        //sprint.PF_Priority__c = 'High';
        sprint.PF_Number_Of_Resources__c= 2;
        sprint.PF_Planned_Start_Date__c = Date.Today();
        sprint.PF_Planned_End_Date__c    = Date.Today().addDays(1);
        insert sprint ;
        
        PF_Product__c product = new PF_Product__c(Name = 'Test Case Product');      
        insert product;
        
        PF_Epic__c epic = new PF_Epic__c(Name = 'Test Case Enhancement',
                                         PF_Product__c = product.Id);      
        insert epic;
        
        //Prepare for requirement
        PF_Stories__c story = new PF_Stories__c();
        story.PF_Story_Description__c = 'Requirement Test';
        //story.Source__c = 'Requirement Source';
        story.PF_Story_Status__c = 'New';
        story.PF_Sprint__c= sprint.Id;
        story.PF_Epic__c = epic.id;
        insert story ;
        
        //prepare for testcase
         PF_TestCases__c Testcase = new PF_TestCases__c();
         TestCase.PF_Story__c    =    story.Id;
         TestCase.PF_UAT__c      =    True;
         TestCase.PF_Type__c = 'Unit Test';
         insert Testcase;
         
         //prepare for testExecution
         PF_TestCaseExecution__c testExe    =    new PF_TestCaseExecution__c();
         testExe.PF_Test_Case__c    =    Testcase.Id;
         testExe.PF_Status__c       =    'Passed';
         testExe.PF_Test_Execution_Type__c    ='SIT';
         testExe.PF_Date_of_Run__c       = Date.Today();
         testExe.PF_Target_Completion_Date__c = Date.Today()+15;
         insert testExe;
         testExe.PF_Status__c       =    'Failed';
         update testExe;
         delete testExe;
         
      }
 }