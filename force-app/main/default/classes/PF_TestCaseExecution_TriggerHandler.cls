/****************************************
 * Class Name : PF_TestCaseExecution_TriggerHandler
 * 
 * Description: Helper class for PF_TestCaseExecution__c object.
 * 
 * Created By : Prasheela
 * ****************************************/

public class PF_TestCaseExecution_TriggerHandler {

    private boolean m_isExecuting = false;

    public PF_TestCaseExecution_TriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    /*================================================================
     * Method Name : onAfterInsert
     * 
     * Return Type : void
     * 
     * Parameters  : TPF_TestCaseExecution__c List
     * 
     * Description : updating 'First Pass Rate' and Status fields on TestCase records based on TestCase Executions Result.
     * 
     * Created  By : Prasheela 
     * 
     * Modified By :
     =====================================================================*/
    public static void onAfterInsert(List<PF_TestCaseExecution__c> newObjectList) {
        
        update_FPR_Status(newObjectList);
    
    }
    /*================================================================
     * Method Name : onAfterInsert
     * 
     * Return Type : void
     * 
     * Parameters  : TPF_TestCaseExecution__c List
     * 
     * Description : updating 'First Pass Rate' and Status fields on TestCase records based on TestCase Executions Result.
     * 
     * Created  By : Prasheela 
     * 
     * Modified By :
     =====================================================================*/
    public static void onAfterUpdate(List<PF_TestCaseExecution__c> newObjectList, Map<Id, PF_TestCaseExecution__c> oldMap) {
        
        update_FPR_Status(newObjectList);
        
    }

    public static void onAfterDelete(List<PF_TestCaseExecution__c> newObjectList, Map<Id, PF_TestCaseExecution__c> oldMap) {
        
        update_FPR_Status(newObjectList);
        
    }
                   
    
   
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    
    /*================================================================
     * Method Name : update_FPR_Status
     * 
     * Return Type : List<PF_TestCases__c>
     * 
     * Parameters  : TestCase Record Ids
     * 
     * Description : Querying record and mapping the 'First Pass Rate' and Status field values.
     * 
     * Created  By : Prasheela 
     * 
     * Modified By :
     =====================================================================*/
    public  static  void update_FPR_Status(List<PF_TestCaseExecution__c> newObjectList){
        set<Id> testCaseIds    = new set<Id>();
        Map<Id , PF_TestCases__c> testCase_Map  = new Map<Id , PF_TestCases__c>();
        
        //adding corresponding testCase Id to set.
        for(PF_TestCaseExecution__c  testExe: newObjectList){
            testCaseIds.add(testExe.PF_Test_Case__c);
        }
        
        if(testCaseIds.size()>0){
            
            for(PF_TestCases__c tc: [select Id,PF_First_Pass_Rate__c,PF_Status__c,(select Id,PF_Status__c,PF_Test_Execution_Type__c from Test_Case_Executions__r where PF_Test_Execution_Type__c  = 'SIT' ORder BY PF_Date_of_Run__c ASC Limit 1) from PF_TestCases__c where Id IN: testCaseIds]){  
               
                 if(tc.Test_Case_Executions__r.size()>0){
                 
                    if(tc.Test_Case_Executions__r[0].PF_Status__c    == 'Passed'){
                         
                        tc.PF_First_Pass_Rate__c    =    true;
                         
                    }else{
                         
                        tc.PF_First_Pass_Rate__c    =    false;
                   
                    }
                   testCase_Map.put(tc.Id, tc);
                }
                 
             }//end for
             
             for(PF_TestCases__c tc: [select Id,PF_First_Pass_Rate__c,PF_Status__c,(select Id,PF_Status__c,PF_Test_Execution_Type__c from Test_Case_Executions__r ORder BY PF_Date_of_Run__c DESC Limit 1) from PF_TestCases__c where Id IN: testCaseIds]){  
               
                 if(tc.Test_Case_Executions__r.size()>0){
                 
                     // assign last record status and type of test.
                      tc.PF_Status__c =   tc.Test_Case_Executions__r[0].PF_Status__c;
                      
                      
                      if(testCase_Map.containsKey(tc.Id)){
                            tc.PF_First_Pass_Rate__c    = testCase_Map.get(tc.Id).PF_First_Pass_Rate__c    ;
                      }
                        
                 }
                 else{
                       tc.PF_Status__c    =    null;
                       tc.PF_First_Pass_Rate__c  = false;
                }
                        
                testCase_Map.put(tc.Id, tc);
                 
                 
             }//end for
                
            
            if(testCase_Map.size() >0){
                try{
                
                    update testCase_Map.Values();// update tese case records
                    
                }catch(Exception ex){
                    System.debug('******exception********'+ex);
                }
            }
            
        }//end if
    }//end method.
    
}