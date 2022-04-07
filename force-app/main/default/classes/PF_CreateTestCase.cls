public class PF_CreateTestCase{

    @AuraEnabled
    public static Id createNewTestCase(string thetestCaseRec,string recordId){
    PF_TestCases__c TestCaseRecord = (PF_TestCases__c)JSON.deserialize(thetestCaseRec,PF_TestCases__c.class);

        PF_TestCases__c testCaseRec = new PF_TestCases__c();  
        testCaseRec.Name = TestCaseRecord.Name;
        testCaseRec.PF_Predecessor_Test_Case__c= TestCaseRecord.PF_Predecessor_Test_Case__c;
        testCaseRec.PF_Story__c = TestCaseRecord.PF_Story__c==null?recordId:TestCaseRecord.PF_Story__c;
        testCaseRec.PF_Task__c = TestCaseRecord.PF_Task__c;
        testCaseRec.PF_Type__c = TestCaseRecord.PF_Type__c;
        testCaseRec.PF_Description__c= TestCaseRecord.PF_Description__c;
        testCaseRec.PF_Execution_initiated__c = TestCaseRecord.PF_Execution_initiated__c;
        testCaseRec.PF_TC_Creation_Effort__c= TestCaseRecord.PF_TC_Creation_Effort__c;
        testCaseRec.PF_TC_Execution_Effort__c= TestCaseRecord.PF_TC_Execution_Effort__c;
        testCaseRec.recordTypeId= TestCaseRecord.recordTypeId;

        try{
            insert testCaseRec;
        }catch (Exception e){
        }
        return testCaseRec.Id;
    }
    
     @AuraEnabled
    public static testCaseWrapperClass getPicklist () {
        testCaseWrapperClass getPicklistWrap = new testCaseWrapperClass();
        getPicklistWrap.optionsMap = getFieldsMapPicklists();
        system.debug('FieldsOption -->' + getPicklistWrap);
        return getPicklistWrap;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getFieldsMapPicklists(){
        Map<String,List<String>> options = new Map<String,List<String>>();
        List<String> fieldNamesList = new List<String>{'PF_Status__c','PF_Type__c'};
                    
        Schema.sObjectType sobject_type = PF_TestCases__c.getSObjectType();
        //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            
            for(String field_name : fieldNamesList){
                List<Schema.PicklistEntry> pick_list_values = new List<Schema.PicklistEntry>();
                List<String> fieldOptions = new List<String>();
                pick_list_values.addAll(field_map.get(field_name).getDescribe().getPickListValues());
                for (Schema.PicklistEntry f: pick_list_values) {
                    fieldOptions.add(f.getLabel());                    
                }
                options.put(field_name,fieldOptions);
            }
        return options;
        
    }
    public class testCaseWrapperClass {
         @AuraEnabled
         public Map<String,List<String>> optionsMap;
    }
    
    @AuraEnabled
    public static RecordType getRecordType(String RECTYPE){
        if (RECTYPE == 'worktask'){
            return [SELECT Id,Name FROM RecordType WHERE Name=:'Unit Test Case' LIMIT 1];
        }else {
            return [SELECT Id,Name FROM RecordType WHERE Name=:'End to End Test Case' LIMIT 1];
        }
        	
    }
    
    @AuraEnabled
    public static PF_Tasks__c getStoryData(Id TaskId){
        return [SELECT Id,PF_Story__c,PF_Story__r.Name FROM PF_Tasks__c WHERE Id=:TaskId LIMIT 1];
    }
    
    @AuraEnabled
    public static boolean checkPageAccess(){
        boolean notHavingAccess = false;
        notHavingAccess = PF_Utility.checkPageAccess('PF_ProjectForce_Read_Only');
        system.debug('Does it have access - '+notHavingAccess);
        return notHavingAccess;    
    }
    
}