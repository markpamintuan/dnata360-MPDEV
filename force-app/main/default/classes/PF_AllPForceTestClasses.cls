/****************************************
* Class Name : PF_AllPForceTestClasses * 
* Description: Test Class used for all of the PForce Application
* Created By : Eric Montelibano
* ****************************************/

@isTest
public class PF_AllPForceTestClasses {
    @isTest
    //create sample test Data
    public static void createTestData(){
        
        List <PF_Project__c> allProject = new List <PF_Project__c>();
        List <PF_Project__c> projInProgress = new List <PF_Project__c>();
        List <PF_Project__c> projOnHold = new List <PF_Project__c>();
        List <PF_Project__c> projCompleted = new List <PF_Project__c>();
        List <PF_Project__c> projPlanning = new List <PF_Project__c>();
        
        // for loop for in progress Project
        for(integer i = 0; i<5; i++){
            PF_Project__c p = new PF_Project__c();
            p.Name = 'Sample Test ' +i;
            p.PF_Project_Status__c = 'In Progress';
            p.PF_Project_Description__c = 'Description Here.... ' +i;
            p.PF_Planned_Start_Date__c = system.today();
            p.PF_Planned_End_Date__c = system.today().addDays(i*5);
            p.PF_Actual_Start_Date__c = system.today();
            p.PF_Actual_End_Date__c = system.today().addDays(i*5);
            allProject.add(p);
        }
        
        //for loop proj on Hold
        for(integer i = 0; i<5; i++){
            PF_Project__c p = new PF_Project__c();
            p.Name = 'Sample Test ' +i;
            p.PF_Project_Status__c = 'On Hold';
            p.PF_Project_Description__c = 'Description Here.... ' +i;
            p.PF_Planned_Start_Date__c = system.today();
            p.PF_Planned_End_Date__c = system.today().addDays(i*5);
            p.PF_Actual_Start_Date__c = system.today();
            p.PF_Actual_End_Date__c = system.today().addDays(i*5);
            allProject.add(p);
        }
        
        
        //for loop proj in Planning
        for(integer i = 0; i<5; i++){
            PF_Project__c p = new PF_Project__c();
            p.Name = 'Sample Test ' +i;
            p.PF_Project_Status__c = 'In Planning';
            p.PF_Project_Description__c = 'Description Here.... ' +i;
            p.PF_Planned_Start_Date__c = system.today();
            p.PF_Planned_End_Date__c = system.today().addDays(i*5);
            p.PF_Actual_Start_Date__c = system.today();
            p.PF_Actual_End_Date__c = system.today().addDays(i*5);
            allProject.add(p);
        }
        
        //for loop proj in Completed
        for(integer i = 0; i<5; i++){
            PF_Project__c p = new PF_Project__c();
            p.Name = 'Sample Test ' +i;
            p.PF_Project_Status__c = 'Completed';
            p.PF_Project_Description__c = 'Description Here.... ' +i;
            p.PF_Planned_Start_Date__c = system.today().addDays(-((i*5)+10));
            p.PF_Planned_End_Date__c = system.today().addDays(-2);
            p.PF_Actual_Start_Date__c = system.today().addDays(-((i*5)+10));
            p.PF_Actual_End_Date__c = system.today().addDays(-2);
            allProject.add(p);
        }
        
        insert allProject;
        
        
        List <PF_Project__c> projid = [select id, name from PF_Project__c where PF_Project_Status__c = 'Completed' limit 1];
        system.assert(projid.size()>0);
        
        //create Release Samples...
        List <PF_Release__c> relList = new List<PF_Release__c>();
        for(Integer i=0; i<5 ; i++){
            PF_Release__c rel = new  PF_Release__c();
            rel.Name = 'Release Sample '+i;
            rel.PF_Release_Status__c = 'In Progress';
            rel.PF_Release_Type__c = 'Major';
            rel.PF_Planned_Start_Date__c = system.today();
            rel.PF_Planned_End_Date__c = system.today().addDays(30);
            rel.PF_Project__c = projid[0].id;
            relList.add(rel);
        }
        system.assert(relList.size()>0);
        insert relList;
        
        List <PF_Release__c> RelId = [select id from PF_Release__c where PF_Project__c =: projId];
        system.assert(RelId.size() >0);
        
        List <PF_Sprints__c> sprintList = new List <PF_Sprints__c>();
        for(Integer i = 0; i<5; i++){
            PF_Sprints__c s = new PF_Sprints__c();
            s.Name = 'Sprint Name' +i;
            s.PF_Sprint_Description__c = 'Sample Description.... ' +i;
            s.PF_Start_Date__c = system.today().addDays(i*5);
            s.PF_End_Date__c = system.today().addDays((i*5)+10);
            s.PF_Release__c = RelId[0].id;
            //s.PF_Sprint_Capacity__c = i*2+5;
            sprintList.add(s);
        }
        system.assert(sprintList.size()>0);
        insert sprintList;
        
        List <PF_Sprints__c> spId= [select id from PF_Sprints__c Limit 1];
        
        //create Epics
        PF_Epic__c epic = new PF_Epic__c();
        epic.Name = 'Sample Epic';
        epic.PF_Assigned_To__c = UserInfo.getUserId();
        epic.PF_Epic_Description__c = 'Sample Description';
        
        insert epic;
        
        //create Stories...
        List <PF_Stories__c> styList = new List <PF_Stories__c>();
        //in progress stories
        for(Integer i =0 ; i<5; i++){
            PF_Stories__c sty = new PF_Stories__c();
            sty.Name = 'Story Sample ' +i;
            sty.PF_Story_Status__c = 'In Progress';
            sty.PF_Story_Owner__c = UserInfo.getUserId();
            sty.PF_Story_Priority__c = 'Medium';
            sty.PF_Story_Description__c = 'Description';
            sty.PF_Acceptance_Criteria__c = 'Acceptance Criteria';
            sty.PF_Implementation_Approach__c = 'Implementation Approach';
            sty.PF_Story_Point__c = '2';
            sty.PF_Sprint__c = spId[0].id;
            sty.PF_Epic__c = epic.id;
            styList.add(sty);
        }
        
        //completed stories
        for(Integer i =0 ; i<5; i++){
            PF_Stories__c sty = new PF_Stories__c();
            sty.Name = 'Story Sample ' +i;
            sty.PF_Story_Status__c = 'Ready for UAT';
            sty.PF_Story_Owner__c = UserInfo.getUserId();
            sty.PF_Story_Priority__c = 'Medium';
            sty.PF_Story_Description__c = 'Description';
            sty.PF_Acceptance_Criteria__c = 'Acceptance Criteria';
            sty.PF_Implementation_Approach__c = 'Implementation Approach';
            sty.PF_Story_Point__c = '5';
            sty.PF_Sprint__c = spId[0].id;
            sty.PF_Epic__c = epic.id;
            sty.PF_Start_Date__c = system.today();
            sty.PF_End_Date__c = system.today();
            styList.add(sty);
        }
        
        insert styList;
        
        //prepare for testcase
         PF_TestCases__c Testcase = new PF_TestCases__c();
         TestCase.PF_Story__c    =    styList[0].Id;
         TestCase.PF_UAT__c      =    True;
         TestCase.PF_Type__c = 'Unit Test';
         insert Testcase;
         
         //prepare for testExecution
         PF_TestCaseExecution__c testExe    =    new PF_TestCaseExecution__c();
         testExe.PF_Test_Case__c    =    Testcase.Id;
         testExe.PF_Status__c       =    'Passed';
         testExe.PF_Test_Execution_Type__c    ='SIT';
         testExe.PF_Date_of_Run__c       = Date.Today();
         testExe.PF_Target_Completion_Date__c = Date.Today() +15;
         insert testExe;
         testExe.PF_Status__c       =    'Failed';
         update testExe;
         delete testExe;
    }
    
    public static testMethod void updateTestData(){
        createTestData();
        List <PF_Stories__c> sty = [select id from PF_Stories__c];
        
        for(PF_Stories__c s : sty){
            s.PF_Story_Point__c = '2';
        } 
        
        update sty;
        
    }
    
    public static testMethod void deleteTestData(){
        createTestData();
        List <PF_Stories__c> sty = [select id from PF_Stories__c];
        delete sty;
        
    }
    
    public static testMethod void testProjectSprintClassInitLoad() {
        createTestData();
        //PF_ProjectSprintClass con = new PF_ProjectSprintClass();
        //con.PF_ProjectSprintClass(PF_Homepage);
    }
    
    public static testMethod void testProjectSprintClass() {
        createTestData();
        PageReference pr = Page.PF_Homepage;
       // PF_ProjectSprintClass con = new PF_ProjectSprintClass();
        
        List <PF_Stories__c> p = [select Id, PF_Sprint__c, PF_Sprint__r.PF_Release__c, PF_Sprint__r.PF_Release__r.PF_Project__c 
                                  from PF_Stories__c where PF_Sprint__c != null limit 1];
        
        system.assert(p.size()>0);
        if(p.size() > 0){
        /*   con.projId = p[0].PF_Sprint__r.PF_Release__r.PF_Project__c;
            con.sprintId = p[0].PF_Sprint__c;
            con.retrieveProject();
            con.setOptions();
            con.changeProject();
            con.changeRelease();
            con.retrieveChart();*/
        }
        
        List <PF_Stories__Feed> styfeedList = new List <PF_Stories__Feed>();
        List <FeedItem> feedItemList = new List <FeedItem>();
        
        for (Integer i = 0; i <5; i++){
            FeedItem post = new FeedItem();
            post.ParentId =  p[0].Id;
            post.createdById = UserInfo.getUserId();
            post.Body = 'Sample Feed';
            post.type = 'TextPost ';  // can be other type
            FeedItemList.add(post);
        }
        insert feedItemList;
        PF_Story_Trending trend = new PF_Story_Trending();
        PF_Homepage home = new PF_Homepage();
        
        home.redirectToPreviousPage();
        home.getProject();
        home.getProjectList();
        home.getRisk();
        home.retrieveProjSprint();
    }
    
    
    
}