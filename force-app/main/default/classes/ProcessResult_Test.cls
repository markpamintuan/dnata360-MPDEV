@isTest
public class ProcessResult_Test {
    @isTest 
    static void Validate_processResult() { 
        Wrapper_Utility.selectedRecordsDetails srdWrap = new Wrapper_Utility.selectedRecordsDetails();
        srdWrap.objectName = 'Contact';
        srdWrap.recList = new List<string>();
        
        List<Wrapper_Utility.selectedRecordsDetails> recsToProcess = new List<Wrapper_Utility.selectedRecordsDetails>();
        recsToProcess.add(srdWrap);
        
        ProcessResult.processRecords(JSON.serialize(recsToProcess));
    }
}