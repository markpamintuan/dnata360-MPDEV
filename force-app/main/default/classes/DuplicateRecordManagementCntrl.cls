/*********
 * Name         :   DuplicateRecordManagementCntrl
 * Description  :   This class will be the server controller for Following Components
 * 
 *                  DuplicateRecordsCmp         Component 
 ****/
public class DuplicateRecordManagementCntrl {
    
    /*********
     * Name         :       findDuplicates
     * Description  :       This method will be used to find the Duplicate Records
     *                      related to the Id passed in Parameters
     * 
     * Param        :       @recId					 :	 Id of the Record for which Duplicates has to be found
     * 						@fieldSetName  			 :	 Field Set Name
     *                      @linkedField             :   Linking field which will be used to exclude records to be displayed in possible section
     *                      @initalField             :   This will save the inital field value
     * 
     * Return       :       ContainerWrapperClass    :   This will have the Duplicate Record Number, If any error comes, then description of Error
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.DuplicateWrapper findDuplicates(String recId, String fieldSetName , string linkedField, string initalField){
        try{
            // checking if we have the Id of Record
            if(!string.isBlank(recId) 
                && !string.isBlank(fieldSetName)){
                return DuplicateRecordsHelper.findDuplicateRecords(recId, fieldSetName,linkedField,initalField);  
            }
            
            // making return instance for error message
            return new ContainerWrapperClass.DuplicateWrapper(null, true, Constants.NO_RECORD_PASSED,null,null,0); 
        }
        catch(Exception Ex){
            System.debug('Error : '+Ex.getMessage());
            String ErrorMsg = 'Error in server side';
            
            // making return instance for error message
            return new ContainerWrapperClass.DuplicateWrapper(null, true, ErrorMsg, null,null,0);
        }
    }
    
    /*********
     * Name         :       getsearchForm
     * Description  :       This method will be used to get the fiels for search forom from field set which
     *                      is passed in parameter
     * 
     * Param        :       @fieldSetName  			 :	 Field Set Name
     * 
     * Return       :       ContainerWrapperClass    :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.SearchWrapper getsearchForm(String recId, String searchFieldSetName){
        return DuplicateRecordsHelper.findSearchFields(recId,searchFieldSetName);
    }
    
    /*********
     * Name         :       fetchSearchRecords
     * Description  :       This method is used to search the record based upon the parameters what we have passed in the parameter
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done
     *                      @searchFieldSetName     :	 This will have the search field set name and by this parameter we will know that can be the search parameters user has enetered
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @searchValues  	        :	 This will have the actual values os the searched parameter in json format
     *                      @linkedField            :    Linking field which will be used to exclude records to be displayed in search section
     *                      @excludeRecords         :    records which has to be exluded from the search
     * 
     * Return       :       ContainerWrapperClass   :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.SearchResultWrapper fetchSearchRecords(String recordId, string searchValues, string displayFieldSetName, string searchFieldSetName, string linkedField, string excludeRecords){
        return DuplicateRecordsHelper.fetchSearchRecords(recordId, searchValues, displayFieldSetName, searchFieldSetName,linkedField,excludeRecords);
    }
    
     /*********
     * Name         :       fetchLinkedRecords
     * Description  :       This method is used to search the record where passed field has same value
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @fieldName  	        :	 This will have the field name on which search has to be done
     * 
     * Return       :       ContainerWrapperClass   :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.SearchResultWrapper fetchLinkedRecords(String recordId, string displayFieldSetName, string fieldName){
        return DuplicateRecordsHelper.findLinkedRecords(recordId, displayFieldSetName, fieldName); 
    }
    
    
    /*********
     * Name         :       deLinkRecord
     * Description  :       This method is used to Link dlink the record which is linked with current record and will return the refresh list for refreshing the table
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp 
     *                      @fieldName  	        :	 This will have the field name on which search has to be done
     *                      @deLinkRecId  	        :	 This will save the record id which has to be de link 
     *                      @initField  	        :	 Tis will save the fiels value which will help in identifying if the record is master or  
     * 
     * Return       :       ContainerWrapperClass   :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.SearchResultWrapper deLinkRecord(String recordId, string displayFieldSetName, string fieldName, string deLinkRecId, string initField){
        return DuplicateRecordsHelper.deLinkRecord(recordId, displayFieldSetName, fieldName, deLinkRecId,initField); 
    }
     
    
    /*********
     * Name         :       linkRecords
     * Description  :       This method is used to Link dlink the record which is linked with current record and will return the refresh list for refreshing the table
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @fieldName  	        :	 This will have the field name on which search has to be done
     *                      @deLinkRecId  	        :	 This will save the record id which has to be de link
     *                      @initalField  	        :	 This will save the field value whose values will be copied
     * 
     * Return       :       ContainerWrapperClass   :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.DuplicateWrapper linkRecords(String recordId, string displayFieldSetName, string fieldName, string deLinkRecId, string initalField){
        return DuplicateRecordsHelper.linkRecord(recordId, displayFieldSetName, fieldName, deLinkRecId,initalField); 
    }
    
    
    /*********
     * Name         :       fetchHistoryLinkedRecords
     * Description  :       This Method will be used to pull the records which were linked to current record in history
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @fieldName  	        :	 This will have the field name on which search has to be done
     *                      @initalField  	        :	 This will save the field value whose values will be copied
     * 
     * Return       :       ContainerWrapperClass   :   This will have the fields which has to be displayed on Seach component unser 360 view
     * 
     ******/
    @AuraEnabled
    public static ContainerWrapperClass.SearchResultWrapper fetchHistoryLinkedRecords(String recordId, string displayFieldSetName, string fieldName, string initalField){
        return DuplicateRecordsHelper.fetchHistoryLinkedRecords(recordId, displayFieldSetName, fieldName, initalField);
    }
}