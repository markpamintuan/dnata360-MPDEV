Public with sharing class PF_CreateDefect {  
    
    
    public class defectWrapperClass {
         @AuraEnabled
         public Map<String,List<String>> optionsMap;
    }
   
    
    @AuraEnabled
    public static String createDefect(String theDefect,Id recordId){  
        system.debug('######### - '+theDefect);
        system.debug('######### - '+recordId);
        PF_Defects__c inputDefect = (PF_Defects__c)JSON.deserialize(theDefect,PF_Defects__c.class);
        String msg;
        PF_Defects__c defect = new PF_Defects__c();
        
        defect.PF_Type__c =  !String.isBlank(inputDefect.PF_Type__c) ? inputDefect.PF_Type__c : 'Defect';
        defect.PF_Status__c = inputDefect.PF_Status__c;
        defect.Name = inputDefect.Name;
        defect.PF_Severity__c = inputDefect.PF_Severity__c;
        defect.PF_Description__c = inputDefect.PF_Description__c ;
        defect.PF_Steps_to_Reproduce__c = inputDefect.PF_Steps_to_Reproduce__c;
        defect.PF_Record_Link__c = inputDefect.PF_Record_Link__c;
        defect.PF_Resolution_Type__c= inputDefect.PF_Resolution_Type__c;
        defect.PF_Priority__c= inputDefect.PF_Priority__c;
        
        
        try{
            
            PF_TestCaseExecution__c TCE = [Select id,PF_Test_Case__c from PF_TestCaseExecution__c where id =: recordId][0];        
            defect.PF_Test_Case__c = TCE.PF_Test_Case__c;
            insert defect;
            msg = 'SUCCESS';
        }
        catch(exception e){
            system.debug('Here is the exception -->' +  e.getMessage());
            msg= 'ERROR';
        }
        return msg;        
    }    
    
    @AuraEnabled
    public static defectWrapperClass getPicklist () {
        defectWrapperClass getPicklistWrap = new defectWrapperClass();
        getPicklistWrap.optionsMap = getFieldsMapPicklists();
        system.debug('FieldsOption -->' + getPicklistWrap);
        return getPicklistWrap;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getFieldsMapPicklists(){
        Map<String,List<String>> options = new Map<String,List<String>>();
        List<String> fieldNamesList = new List<String>{'PF_Severity__c','PF_Status__c','PF_Type__c','PF_Priority__c','PF_Resolution_Type__c'};
                    
        Schema.sObjectType sobject_type = PF_Defects__c.getSObjectType();
        //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            system.debug('field_map -'+field_map);
            for(String field_name : fieldNamesList){
                List<Schema.PicklistEntry> pick_list_values = new List<Schema.PicklistEntry>();
                List<String> fieldOptions = new List<String>();
                pick_list_values.addAll(field_map.get(field_name).getDescribe().getPickListValues());
                for (Schema.PicklistEntry f: pick_list_values) {
                    fieldOptions.add(f.getLabel());                    
                }
                options.put(field_name,fieldOptions);
            }
            system.debug('field_map Options-'+options);
        return options;
        
    }
    
    @AuraEnabled
    public static boolean checkPageAccess(){
        boolean notHavingAccess = false;
        notHavingAccess = PF_Utility.checkPageAccess('PF_ProjectForce_Read_Only');
        return notHavingAccess;    
    }
}