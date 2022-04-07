/***
 * This class is used by the Step4POC component
 **/
public class ProcessResult {

    /****
    * Called from Step4POC.cmp
    * It will pass the data which is obtained while sosl and soql, in order to fetch the records which is selected we have 
    * pick the record where isSelected attribute is true.
    * 
    */ 
    @AuraEnabled
    public static boolean processRecords(string selectedRecords){
        system.debug('\n--selectedRecords--'+selectedRecords);
        List<Wrapper_Utility.selectedRecordsDetails> recsToProcess = new List<Wrapper_Utility.selectedRecordsDetails>();
        // converting json to List
        List<Wrapper_Utility.selectedRecordsDetails> selectedRecs = (List<Wrapper_Utility.selectedRecordsDetails>) 
            															JSON.deserialize(selectedRecords, 
                                                                                         List<Wrapper_Utility.selectedRecordsDetails>.class);
        
        
        for(Wrapper_Utility.selectedRecordsDetails sele: selectedRecs){
            if(sele.recList != null && sele.recList.size()>0){
                recsToProcess.add(sele);
            }
        }        
        GDPRFlowHelper flowHelper = new GDPRFlowHelper(recsToProcess);

        
        system.debug('\n--selectedRecs--'+selectedRecs);
        return true;
    }
}