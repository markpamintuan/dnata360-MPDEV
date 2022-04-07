Public class PF_NewTestCaseAssignmentExtension{
 public List<TestCaseAssWrapper> testCaseAssWrapList{get;set;}
 public TestCaseAssWrapper testCaseAssWrap{get;set;}
 public Id testCaseId{get;set;}
 public Date completionDate{get;set;}
 Public PF_TestCaseExecution__c testCaseAss{get;set;}


public PF_NewTestCaseAssignmentExtension() {
    testCaseId= apexPages.currentPage().getParameters().get('id');
    testCaseAssWrapList= new List<TestCaseAssWrapper>();
    testCaseAss = new PF_TestCaseExecution__c ();
   // testCaseAssWrap= new TestCaseAssWrapper(1);
  //  testCaseAssWrapList.add(testCaseAssWrap);
    
    }

 public void addNewAssigne() {
        // testCaseAss = new PF_TestCaseExecution__c ();
        testCaseAssWrap= new TestCaseAssWrapper(testCaseAssWrapList.size()+1,testCaseAss.PF_Target_Completion_Date__c);
        testCaseAssWrapList.add(testCaseAssWrap);
        
    }
 
 public class TestCaseAssWrapper{
        public Integer SerialNo {get;set;}
        public PF_TestCaseExecution__c testCaseAssgn{get;set;}
          
        
        public TestCaseAssWrapper(Integer sno,Date testCas) {
            testCaseAssgn= new PF_TestCaseExecution__c(PF_Target_Completion_Date__c=testCas);
            SerialNo = sno;
           
        }
    }
    
    
    public PageReference onSave() {
       //  PageReference pgref= ApexPages.currentPage();
        try{
                      
                List<PF_TestCaseExecution__c > testCaseAss= new List<PF_TestCaseExecution__c >();
                system.debug('testCaseAssWrapList'+testCaseAssWrapList);
                for(TestCaseAssWrapper tcw: testCaseAssWrapList){
                    tcw.testCaseAssgn.PF_Test_Case__c = testCaseId;
                    tcw.testCaseAssgn.PF_Status__c= 'Not Started';
                   // tcw.testCaseAssgn.Assigned_To__c= 'Not Started';
                    testCaseAss.add(tcw.testCaseAssgn);
                }
                system.debug('wwwwww'+testCaseAss);   
                if(testCaseAss!= null && testCaseAss.size() > 0) {  
                    insert testCaseAss; 
                }
                 //urlLink = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ParticipantRegisterPage?id=' + trainingSched.id;
                PageReference pgref= new PageReference('/'+testCaseId);
                pgref.setredirect(true);
                return pgref ;
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,e.getmessage()));
        }
        return null;
    }

}