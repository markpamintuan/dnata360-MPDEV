Public with sharing class PF_AddEditTCSteps {  
    public static List<PF_Test_Case_Step__c> testCaseStpList = new List<PF_Test_Case_Step__c>();
    public static List<PF_Test_Case_Step__c> existingTestCaseStps = new List<PF_Test_Case_Step__c>();
    public static List<PF_Test_Case_Step__c> testCaseAssStpDel = new List<PF_Test_Case_Step__c>();
    
    @AuraEnabled
    public static String upsertTestCaseSteps(List<PF_Test_Case_Step__c> testCaseStps, List<Id> delAssigne){  
         System.debug('------ Entered saveRecords method');
        string msg;
       if(delAssigne.size() > 0){
             testCaseAssStpDel =  [Select id from PF_Test_Case_Step__c where id IN : delAssigne];
            delete testCaseAssStpDel;
             msg='SUCCESS';
        }
        if(testCaseStps.size() > 0){            
            try{
                system.debug('pff1'+testCaseStps);
                for (PF_Test_Case_Step__c pf : testCaseStps) {
                    
                    PF_Test_Case_Step__c pf1 = new PF_Test_Case_Step__c(PF_Step_Description__c=pf.PF_Step_Description__c, 
                                                                             PF_Expected_Result__c=pf.PF_Expected_Result__c, 
                                                                             PF_Actual_Result__c= pf.PF_Actual_Result__c, 
                                                                             PF_Test_Case__c=pf.PF_Test_Case__c,Id=pf.id,
                                                                             PF_Step_Number__c =pf.PF_Step_Number__c);
                    testCaseStpList.add(pf1);
                }
                system.debug('pff'+testCaseStpList);
                upsert testCaseStpList;
                msg='SUCCESS';
            }catch(Exception ex){
                msg='Error';
                system.debug('Here is Exception ' + ex.getMessage());
            }
        }
        return msg;
    }
    @AuraEnabled
    public static List<PF_Test_Case_Step__c> getRecords (Id testCase) {
        System.debug('----- Entered getRecords method');
        existingTestCaseStps = [Select id,PF_Step_Description__c,PF_Expected_Result__c,PF_Actual_Result__c, PF_Test_Case__c,PF_Step_Number__c from PF_Test_Case_Step__c where PF_Test_Case__c =: testCase order By PF_Step_Number__c];
        System.debug('----- Entered testCaseAssList : ' + existingTestCaseStps.size());
        return existingTestCaseStps;            
    }
    @AuraEnabled
    public static string deleteSeleted (List<Id> testStpsDel) {
            string msg;
       if(testStpsDel.size() > 0){
            testCaseAssStpDel =  [Select id from PF_Test_Case_Step__c where id IN : testStpsDel];
            delete testCaseAssStpDel;
             msg='SUCCESS';
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