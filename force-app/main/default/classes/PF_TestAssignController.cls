public class PF_TestAssignController {
public static List<PF_TestCaseExecution__c> pftest = new List<PF_TestCaseExecution__c>();
public static List<PF_TestCaseExecution__c> testCaseAssList = new List<PF_TestCaseExecution__c>();
public static List<PF_TestCaseExecution__c> testCaseAssDel = new List<PF_TestCaseExecution__c>();        
    @AuraEnabled
    public static string saveRecords (List<PF_TestCaseExecution__c> testCases , list<ID> delAssigne) {
        System.debug('------ Entered saveRecords method');
        System.debug('------ testCases : ' + testCases);
        string msg;
        if(delAssigne.size() > 0){
             testCaseAssDel =  [Select id from PF_TestCaseExecution__c where id IN : delAssigne];
            delete testCaseAssDel;
             msg='SUCCESS';
        }
        if(testCases.size() > 0){            
            try{
                system.debug('pff1'+testCases);
                for (PF_TestCaseExecution__c pf : testCases) {
                    PF_TestCaseExecution__c pf1 = new PF_TestCaseExecution__c(PF_Status__c=pf.PF_Status__c, 
                                                                             PF_Assigned_To__c=pf.PF_Assigned_To__c, 
                                                                             PF_Target_Completion_Date__c= pf.PF_Target_Completion_Date__c, 
                                                                            PF_Test_Case__c=pf.PF_Test_Case__c,Id=pf.id);
                    pfTest.add(pf1);
                }
                system.debug('pff'+pfTest);
                upsert pfTest;
                msg='SUCCESS';
            }catch(Exception ex){
                msg='Error';
                system.debug('Here is Exception ' + ex.getMessage());
            }
        }
        return msg;
    }
    @AuraEnabled
    public static List<PF_TestCaseExecution__c> getRecords (Id testCase) {
        System.debug('----- Entered getRecords method');
        testCaseAssList = [Select id,PF_Assigned_To__c,PF_Assigned_To__r.name,PF_Target_Completion_Date__c,PF_Test_Case__c,PF_Status__c from PF_TestCaseExecution__c where PF_Test_Case__c =: testCase];
        System.debug('----- Entered testCaseAssList : ' + testCaseAssList.size());
        return testCaseAssList;            
    }
    @AuraEnabled
    public static Date getCurrentDate () {
        System.debug('----- Entered getRecords method');
        Date currentDate = system.today()+7;
        
        return currentDate;            
    }
    @AuraEnabled
    public static string massDeleteExecutionRecs(List<string> recsToDelete){
        string msg;
        List<PF_TestCaseExecution__c> delRecs = new List<PF_TestCaseExecution__c>();
        try{
            if(recsToDelete!=null){
                for(string recId : recstoDelete){
                    PF_TestCaseExecution__c exeRec = new PF_TestCaseExecution__c(id=RecId);  
                    delRecs.add(exeRec);    
                }
                delete delRecs;
                msg='SUCCESS';
            }
        }catch(Exception ex){
                msg='Error';
                system.debug('Here is Exception ' + ex.getMessage());
        }
    return msg;     
    }
    
    @AuraEnabled
    public static boolean checkPageAccess(){
        boolean notHavingAccess = false;
        notHavingAccess = PF_Utility.checkPageAccess('PF_ProjectForce_Read_Only');
        return notHavingAccess;    
    }
    
}