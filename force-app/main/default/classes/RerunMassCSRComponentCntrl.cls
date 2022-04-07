/**************************************************************************************************
* Name               : RerunMassCSRComponentCntrl 
* Description        : This is the class for rerun batch action button  
* Created Date       : 24-Sept-2019                                                              
* Created By         : Evendo D'mello                                                    
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Evendo      24-Sept-2019    Initial Draft
**************************************************************************************************/
public class RerunMassCSRComponentCntrl {

    @AuraEnabled
    public static void runBatch(string recordId){
        Database.executeBatch(new MassCSRFailedBatchRerun(recordId),10);
    }
    
}