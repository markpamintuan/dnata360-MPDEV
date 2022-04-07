public class Wrapper_Utility {
    
    /*** 
     * Form Fields Wrapper Class 
     */ 
    public class FormFieldsWrapper{
        @AuraEnabled public String First_Name {get;set;}
        @AuraEnabled public String Last_Name {get;set;}
        @AuraEnabled public String Email_Address {get;set;}
        @AuraEnabled public String Phone_Number {get;set;}
    }
    
    /***
     * Wrapper class contains the information about all the fields of a FieldSet
     */ 
    public class FieldSetMemberWrapperClass{
        @AuraEnabled
        public Boolean isDBRequired { get; set; }
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String fieldType { get; set; }
        @AuraEnabled
        public String fieldLabel { get; set; }
        @AuraEnabled
        public String fieldAPIName { get; set; }
        
    }
    
    public class ResultWrapper{
        @AuraEnabled public String Object_Name {get;set;}
        @AuraEnabled public String Section_Heading {get;set;}
        @AuraEnabled public String Section_Image {get;set;}
        @AuraEnabled public List<FieldSetMemberWrapperClass> lstFieldSet_Details {get;set;}
        @AuraEnabled public List<sObject> lstRecords {get;set;}
    }
    
    
    public class FormFieldResultWrapper{
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String Id {get;set;}
    }
    
    public class selectedRecordsDetails{
        @AuraEnabled public String objectName {get;set;}
        @AuraEnabled public List<string> recList {get;set;}
    }

}