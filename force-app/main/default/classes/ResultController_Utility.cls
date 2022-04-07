public class ResultController_Utility {
    
    /*** 
     * List all the Fields that are added into the FielsSet
     */
    public static List<Wrapper_Utility.FieldSetMemberWrapperClass> getFieldSetMember(GDPR_Flow_Settings__mdt objectMetaData){
        
         
        List<Wrapper_Utility.FieldSetMemberWrapperClass> wrapperList = new List<Wrapper_Utility.FieldSetMemberWrapperClass>();
        if(!string.isBlank(objectMetaData.SOQL_Search_Results__c)){
            String searchSOQL = objectMetaData.SOQL_Search_Results__c;
            String apiFieldsString = searchSOQL.substringBetween('SELECT', 'FROM');
            system.debug('££££ apiFieldsString: ' + apiFieldsString);
            if(apiFieldsString == null){
                throw new AuraHandledException('The query is set up wrong for this object!! ' + objectMetaData.Object_API_Name__c);
            }else{
                set<string> setFieldName = new set<string>();  
                List<string> lstFieldName = apiFieldsString.toLowerCase().split(',');
                setFieldName.addAll(lstFieldName);
                system.debug('££££ lstFieldName: ' + lstFieldName);
                wrapperList = fetchObjectFieldDetails(objectMetaData.Object_API_Name__c,setFieldName);
            }

        }    
        return wrapperList;
    }

    /***
     * Map of Object Name and Metadata Record where object name exist
     */ 
    public static Map<String, GDPR_Flow_Settings__mdt> getReviewMetaDataMAP(List<GDPR_Flow_Settings__mdt> metadataObjList){
        Map<String, GDPR_Flow_Settings__mdt> metaDataMAP = new Map<String, GDPR_Flow_Settings__mdt>();
        if(metadataObjList != null && !metadataObjList.isEmpty()){
            for(GDPR_Flow_Settings__mdt metaObj : metadataObjList){
                if(!String.isBlank(metaObj.Object_API_Name__c)){
                    metaDataMAP.put(metaObj.Object_API_Name__c, metaObj);
                }
            }
        }
        
        return metaDataMAP;
    }
    
    
    /*** 
     * Query to get Metadata Records which can be process for each section in th lightning component
     */ 
    public static List<GDPR_Flow_Settings__mdt> getReviewMetaData(){
        List<GDPR_Flow_Settings__mdt> metadataObjList = [SELECT Id,
                                                                 DeveloperName,
                                                                 MasterLabel,
                                                                 Object_API_Name__c, 
                                                                 Section_Heading__c, 
                                                                 Section_Image__c,
                                                                 Search_Result_Order__c,
                                                                 SOQL_Search_Results__c
                                                             FROM GDPR_Flow_Settings__mdt];
        
        return metadataObjList;
    }

    /****
     * Return set of Account ids where SOSL is performed.
     * 
    **/
    public static set<Id> searchAccountContactsLeadsSOSL(List<Wrapper_Utility.FormFieldResultWrapper> formData){
        //Two sosls are performed because the limit of returned results are 2000
        //By seperatating out it gives a better chance to get more records returned

        String nameSearchText;       
        String otherFieldsSearch;    

        Set<Id> setAccountContactLeadsIds = new Set<Id>();
        if(!formData.isEmpty()){
            for(Wrapper_Utility.FormFieldResultWrapper str : formData){
                system.debug(' £££££ searchAccountsSOSL str: ' + str); 
                //Name is the text value from the form
                if(!String.isBlank(str.Name) && (str.Type=='email' || str.Type=='phone' || str.Type=='Keyword')){
                    if(String.isBlank(otherFieldsSearch)){
                        otherFieldsSearch = str.Name; //Name is the value 
                    }else{
                        otherFieldsSearch += ' or '+str.Name;
                    }
                }     

                //Name is the text value from the form
                if(!String.isBlank(str.Name) && str.Type!='email' && str.Type!='phone' && str.Type!='Keyword'){
                    if(String.isBlank(nameSearchText)){
                        nameSearchText = str.Name;
                    }else{
                        nameSearchText += ' or '+str.Name;
                    }
                }                
            }
            system.debug('£££££ searchAccountsSOSL nameSearchText: ' + nameSearchText);
            system.debug('£££££ searchAccountsSOSL otherFieldsSearch: ' + otherFieldsSearch);
        }  
        //https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_find.htm
        if(nameSearchText !=null && nameSearchText.length()>0){
            String searchquery='FIND ' + '\'' + nameSearchText + '\''  + ' IN NAME FIELDS RETURNING Account(id),Contact(Id),Lead(Id)'; 
            system.debug('££££ searchquery SOSL: ' + searchquery);

            List<List<SObject>> nameSearchResults =search.query(searchquery);
            system.debug('£££ nameSearchResults: ' + nameSearchResults);
            system.debug('£££ nameSearchResults size: ' + nameSearchResults.size());

            List<Sobject> lAccContLeadNameSearchResults = new  List<Sobject>();
            
            for(List<Sobject> soslResults: nameSearchResults){
                for(Sobject accountSObj: soslResults){
                    lAccContLeadNameSearchResults.add(accountSObj);
                }
            }

            system.debug('£££ lAccContLeadNameSearchResults: ' + lAccContLeadNameSearchResults);
            system.debug('£££ lAccContLeadNameSearchResults size: ' + lAccContLeadNameSearchResults.size());
            if(lAccContLeadNameSearchResults.size()>0){
                if(lAccContLeadNameSearchResults.size()> 100){
                    throw new AuraHandledException('Searching by this name returned more than 100 results. Please remove name from search');
                }

                for(SObject searchResult: lAccContLeadNameSearchResults){
                    setAccountContactLeadsIds.add(searchResult.Id);
                }
            }
        }
        
        if(otherFieldsSearch !=null && otherFieldsSearch.length()>0){
            String searchquery='FIND ' + '\'' + otherFieldsSearch + '\'' + ' IN ALL FIELDS RETURNING Account(id),Contact(Id),Lead(Id)'; 
            system.debug('££££ searchquery EMAIL PHONE SOSL: ' + searchquery);
            List<List<SObject>> phoneEmailResults = search.query(searchquery);
            
            if(phoneEmailResults.size()>0){
                for(List<SObject> lstResults: phoneEmailResults){
                    for(SObject accResult: lstResults){
                        if(lstResults.size()>200){
                            throw new AuraHandledException('There are more than 200 records returned. Please try to refine the keywords.');
                        }else{
                            setAccountContactLeadsIds.add(accResult.Id);
                        }
                    }
                }
            }
        }
        return setAccountContactLeadsIds;
    }

    /****
     * This method creates the FIND Clause for SOSL Query
     * 
   **/
    public static String getFindSearchString(List<Wrapper_Utility.FormFieldResultWrapper> formData){
        System.debug('getFindSearchString with formData: ' + formData);

        String searchText;        
        
        if(!formData.isEmpty()){
            for(Wrapper_Utility.FormFieldResultWrapper str : formData){
                system.debug(' £££££ str: ' + str);
                if(!String.isBlank(str.Name) && str.Type=='phone' || str.Type=='email' || str.Type=='Keyword'){
                    if(String.isBlank(searchText)){
                        searchText = str.Name;
                    }else{
                        searchText += ' or '+str.Name;
                    }
                }                
            }
        }        
        return '\'' + searchText + '\'';
    }
    
    /***
     *  This method will be pull the object field details
     **/
    public static List<Wrapper_Utility.FieldSetMemberWrapperClass> fetchObjectFieldDetails(string objectName, set<string> fieldNames){   
        System.debug('££££ entering fetchObjectFieldDetails with objectName: ' + objectName);
        System.debug('££££ entering fetchObjectFieldDetails with fieldNames: ' + fieldNames);
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();       
        List<Wrapper_Utility.FieldSetMemberWrapperClass> wrapperList = new List<Wrapper_Utility.FieldSetMemberWrapperClass>();
        System.debug('££££ Loop fieldMap: ' + fieldMap);

        //casenumber

        // for each fiel which is present in the meta data
        for(string fieldName : fieldNames){
            System.debug('££££ Loop fieldName: ' + fieldName.trim());
            
            // checking if the field is present in the object then add to the wrapper 
            system.debug('£££££ Get the field name fieldName: ' + fieldName);
            system.debug('£££££ Get the field name in map: ' + fieldMap.get(fieldName.trim()));
            String fieldAfterTrim = fieldName.trim().toLowerCase();

            if(fieldMap.containsKey(fieldAfterTrim)){
                System.debug('££££ Entering if statemetn: ' );

                Schema.SObjectField sfield = fieldMap.get(fieldAfterTrim);    
                schema.describefieldresult dfield = sfield.getDescribe();
                Wrapper_Utility.FieldSetMemberWrapperClass wrapper = new Wrapper_Utility.FieldSetMemberWrapperClass();
                wrapper.isDBRequired = false;
                wrapper.isRequired = false;
                wrapper.fieldType = String.valueOf(dfield.getType());
                wrapper.fieldLabel = dfield.getLabel();
                wrapper.fieldAPIName = dfield.getName();
                wrapperList.add(wrapper);
            }else{
                system.debug('££££ this field was not found: ' + fieldName.toLowerCase());
                system.debug('££££ this field length is: ' + fieldName.toLowerCase().length());
                throw new AuraHandledException('The field called ' + fieldName + ' was not found on the object called: ' + objectName + 
                '. Please ask an admin to check the GDPR flow custom metadata');
            }
            
        }
        
        
        system.debug('\n--wrapperList--'+wrapperList+'\n--objectName--'+objectName);
        return wrapperList;
    }
    
    /********
     * Name         :   GetObjectRecordIds
     * Description  :   This is the method which will make a make a map og object name and set of ids of the record
     ****/
    public static set<string> fetchObjectFieldDetails(List<Search.SearchResult> objSearchlist){ 
        system.debug('£££ entering fetchObjectFieldDetails with objSearchlist: ' + objSearchlist);
        // used for saving the ids
        set<string> setRecsIds = new set<string>();
        
        // if we ahve result returned by the query
        if(objSearchlist != null 
                && !objSearchlist.isEmpty()){
            for (Search.SearchResult searchResult : objSearchlist) { 
                
                // getting s object
                sobject obj = searchResult.getSObject();
                
                // saving id of the record
                setRecsIds.add(string.valueOf(obj.get('Id')));
            }
        }
        system.debug('££££ exiting fetchObjectFieldDetails with setRecsIds: ' + setRecsIds);
        return setRecsIds;
    }
}