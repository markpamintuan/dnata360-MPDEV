/************
 * Name         :   ContainerWrapperClass
 * Description  :   This Class can be used by any other class
 *                  as it will contain th genric Wrappers
 * 
 * Created Date :   26-Sept-2018
 *****/
public class ContainerWrapperClass {
    
    
    // This class will save the duplicate High Level details i.e number of record and if any error then wat is the error
    public class DuplicateWrapper{
        
        @AuraEnabled
        public Integer duplicaRecordCount{get;set;}
        
        @AuraEnabled
        public List<DuplicateDetailWrapper> lstDuplicateRecs {get;set;}
        
        @AuraEnabled
        public List<id> lstRecIds {get;set;}
        
        @AuraEnabled
        Public boolean isError{get;set;}
        
        @AuraEnabled
        Public string errorDetails{get;set;}
        
        @AuraEnabled
        Public boolean hasRecords{get;set;}
        
        @AuraEnabled
        public List<HeaderWrapper> lstHeaders {get;set;}
        
        @AuraEnabled
        Public string linkedFieldValue{get;set;} 
        
        @AuraEnabled
        public Integer linkedRecCount{get;set;}
        
        // Constructor
        public DuplicateWrapper(List<DuplicateDetailWrapper> lstDuplicateRecs, boolean isError, string errorDetails, 
                                List<HeaderWrapper> lstHeaders, string linkedFieldValue, integer linkedRecCount){
            
            this.lstDuplicateRecs = lstDuplicateRecs;
            this.isError = isError;
            this.errorDetails = errorDetails;
            
            // harcoding headers ir will be pulled from Field Sets
            this.lstHeaders = lstHeaders;
            
            // if size of list is not blank
            if(lstDuplicateRecs != null
                && !lstDuplicateRecs.isEmpty()){
                duplicaRecordCount = lstDuplicateRecs.Size();
                hasRecords = true;
            }
            else{
                duplicaRecordCount = 0;
                hasRecords = false;
            }
             
            this.linkedFieldValue = linkedFieldValue;
            
            // setting recods ids
            this.lstRecIds = new List<id>();
            if(lstDuplicateRecs != null)
                for(DuplicateDetailWrapper recDetails : lstDuplicateRecs){
                    lstRecIds.add(string.valueOf(recDetails.sObj.get('Id')));
                }
            this.linkedRecCount = linkedRecCount;
        }
    }
    
    
    // this will svae the details of each duplicate Account Record
    public class DuplicateDetailWrapper{
        
        @AuraEnabled
        public sObject sObj {get;set;}
        
        @AuraEnabled
        public boolean isHistoryRec {get;set;}
        
        // constructor
        public DuplicateDetailWrapper(sObject sObj, boolean isHistoryRec){
            this.sObj = sObj;
            this.isHistoryRec = isHistoryRec;
        }
    }
    
    public class HeaderWrapper{
        
        @AuraEnabled
        Public string displayValue{get;set;}
        
        @AuraEnabled
        Public string fieldAPIName{get;set;}
        
        @AuraEnabled
        Public FieldTypes fTypes {get;set;}
        
        
        public HeaderWrapper(string displayValue, string fieldAPIName, string fieldType){
            
            // setting default values for flags
            setAllFieldFlags();
            
            this.fieldAPIName = fieldAPIName;
            this.displayValue = displayValue;
            this.fTypes = new FieldTypes(fieldType);
            
        }
        
        public void setAllFieldFlags(){
            this.fTypes = new FieldTypes();
        }
    }
    
    // This class will be used to show data on search section of duplicate records component popup screen 
    public class SearchWrapper{
        
        @AuraEnabled
        public List<HeaderWrapper> lstHeaders {get;set;}
        
        // constructor
        public SearchWrapper(List<HeaderWrapper> lstHeaders){
            this.lstHeaders = lstHeaders;
        }
    }
    
    
    // this will help in storing the types of field
    public class FieldTypes{
        
        @AuraEnabled
        Public boolean isBoolean{get;set;}
        
        @AuraEnabled
        Public boolean isReference{get;set;}
        
        @AuraEnabled
        Public boolean isDate{get;set;}
        
        @AuraEnabled
        Public boolean isDateTime{get;set;}
        
        @AuraEnabled
        Public boolean isNumber{get;set;}
        
        public FieldTypes(){
            setDefaultValues();
        }
        
        public FieldTypes(string fieldType){
            
            setDefaultValues();
            
            // setting field type flags
            if(fieldType.toLowerCase() == 'boolean'){
                isBoolean = true;
            }
            
            if(fieldType.toLowerCase() == 'reference'){
                isReference = true;
            }
            
            if(fieldType.toLowerCase() == 'date'){
                isDate = true;
            }
            
            if(fieldType.toLowerCase() == 'datetime'){
                isDateTime = true;
            }
        }
        
        // will be called bu cinstructor to set all flags to false
        void setDefaultValues(){
            isBoolean = false;
            isReference = false;
            isDate = false;
            isDateTime = false;
            isNumber = false;
        }
        
    }
    
    
    // This class will be used to show data when user hit search values
    public class SearchResultWrapper{
        
        @AuraEnabled
        public List<DuplicateDetailWrapper> lstRecs {get;set;}
        
        @AuraEnabled
        public List<HeaderWrapper> lstHeaders {get;set;}
        
        @AuraEnabled
        public boolean hasRecords {get;set;}
        
        // constructor
        public SearchResultWrapper(List<HeaderWrapper> lstHeaders, List<DuplicateDetailWrapper> lstRecs){
            this.lstHeaders = lstHeaders;
            this.lstRecs = lstRecs;
            
            if(lstRecs.size() > 0)
                this.hasRecords = true;
                
            else
                this.hasRecords = false;
        }
        
        // constructor
        public SearchResultWrapper(){
            this.lstHeaders = new List<HeaderWrapper>();
            this.lstRecs = new List<DuplicateDetailWrapper>();
            this.hasRecords = false;
        }
    }
    
    // this class will be used to store the information for linking fields
    public class LinkingFieldDetails{
        public string fieldValue {get;set;}
        public string initalFieldValue {get;set;}
        Public FieldTypes fTypes {get;set;}
        
        public LinkingFieldDetails(string fieldValue, string fTypes, string initalFieldValue){
            this.fTypes = new FieldTypes(fTypes);
            this.fieldValue = fieldValue;
            this.initalFieldValue = initalFieldValue;
        }
        
        public LinkingFieldDetails(){
            this.fTypes = new FieldTypes();
        }
    }
    
    
    // this will save the maseter record details
    public class MasterReordDetails{
        public sobject recDetails {get;set;}
        public boolean isMaster {get;set;}
        
        public MasterReordDetails(sobject recDetails, boolean isMaster){
            this.recDetails = recDetails;
            this.isMaster = isMaster;
        }
    }
    
    
    
}