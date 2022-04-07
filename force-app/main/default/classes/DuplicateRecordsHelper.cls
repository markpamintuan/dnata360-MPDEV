/***********
 * Name         :       DuplicateRecordsHelper
 * Description  :       This Class will have all the Common Method which 
 *                      is related to Any Object in order to re user the Code
 * 
 * Created Date :       27-Sept-2018
 *****/
public class DuplicateRecordsHelper {

    /*******
     * Name         :       findDuplicateAcc
     * Description  :       This Method will be used to find the Duplicate 
     *                      Records based upon the Ids passed
     *                      We can pass 50 Ids as else an error will be thrown
     * 
     * Param        :       @recordId       :   Id of record       
     *              :       @fieldSetName   :   FieldSet Name
     * 
     * Return               Wrapper with Records details and if any error then error Details
     * 
     **********/
    public static ContainerWrapperClass.DuplicateWrapper findDuplicateRecords(String recordId, String fieldSetName, string fieldName,string initalField){
        
        // making list of header , below code will be moved to common utility where the values will be pulled from Field sets
        List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
            
        if(!string.isBlank(recordId)
                && !string.isBlank(fieldSetName)){
            
            // get Object Name from record Id using CommonUtils class method
            String objectName =  CommonUtils.getObjectName(recordId);
            
            // getting header from field set
            lstheaders = CommonUtils.getHeaderList(fieldSetName,objectName);
            
            // making query which will be used to get relevant data to be returned
            List<string> fieldAPINames =  new List<string>();
            
            // pulling API from field set headers as that will be used in making query
            for(ContainerWrapperClass.HeaderWrapper head : lstheaders){
                fieldAPINames.add(head.fieldAPIName);
            }
            
            // code section to get linking field value
            ContainerWrapperClass.LinkingFieldDetails linkFieldDetails = CommonUtils.getLinkingFieldValue(fieldName,RecordId, objectName,null);
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
            
            // this will save the ids which has to be exluded
            set<id> exludedIds = new set<id>();
                
                
            // makking instance of Duplicate Details Wrapper which will have duplcicate Record Details
            List<ContainerWrapperClass.DuplicateDetailWrapper> lstDuplcateRec = new List<ContainerWrapperClass.DuplicateDetailWrapper>();
            
            string query = 'SELECT'
                                +' Id'
                            +' FROM '+ objectName
                            +' WHERE Id = \''+recordId+'\'';
            
            // making instance of Record in order to pass to duplicate Rules
            List<sObject> lstRecords = database.query(query);
             
            // this will store the ids of duplicate Records
            set<id> dulRecIds = new set<id>();
             
            //Identifies duplicates for sObjects provided and returns a list of FindDuplicatesResult objects
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(lstRecords);
            
            //iterate over FindDuplicatesResult objects
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                
                //Returns a list of DuplicateResult objects representing the results of calling FindDuplicates. and iterate over list
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    
                    //Returns the duplicate records and match information.
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        
                        //Returns information about the duplicates for the matching rule
                        for(Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            
                            // adding duplicate records ids
                            dulRecIds.add((string)matchRecord.getRecord().get('Id'));
                        }
                    }
                }
            }
            
            // getting linked record count
            integer countLinked = 0;
                
            // getting required information of duplicate records
            if(!fieldAPINames.isEmpty()){
                system.debug('\n--fieldAPINames--'+fieldAPINames);
                string strQuery = 'SELECT '
                                        + string.join(fieldAPINames,',')
                                    +' FROM '+ objectName
                                    +' WHERE ID IN: dulRecIds';
                
                // cheking if linked has to be removed
                if(linkFieldDetails != null
                && !string.isBlank(linkFieldDetails.fieldValue)){ 
                    
                    string linkWhereClause = '';
                    
                    // getting linked record count                    
                    string linkedRecordCountquery = 'SELECT COUNT () FROM '+objectName
                                            +' WHERE ID != :recordId AND '+fieldName+' != null ';
                    
                    // checking if the field type is date or date time
                    if(linkFieldDetails.fTypes.isDate
                        || linkFieldDetails.fTypes.isDateTime){
                        linkWhereClause += (' AND ' + fieldName + ' !=  '+ linkFieldDetails.fieldValue);  
                        linkedRecordCountquery += (' AND ' + fieldName + ' =  '+ linkFieldDetails.fieldValue);
                    }
                    
                    else if(linkFieldDetails.fTypes.isDate){
                        linkWhereClause += (' AND ' + fieldName + ' != ' + Boolean.valueOf(linkFieldDetails.fieldValue));
                        linkedRecordCountquery += (' AND ' + fieldName + ' = ' + Boolean.valueOf(linkFieldDetails.fieldValue));
                    } 
                    
                    else{
                        linkWhereClause += (' AND ' + fieldName + ' != \'' + linkFieldDetails.fieldValue + '\''); 
                        linkedRecordCountquery += (' AND ' + fieldName + ' = \'' + linkFieldDetails.fieldValue + '\''); 
                    } 
                    strQuery+= linkWhereClause;
                    
                    
                    system.debug('\n--linkedRecordCountquery--'+linkedRecordCountquery); 
                    
                    // getting linked record count
                    countLinked = database.countQuery(linkedRecordCountquery);
                    system.debug('\n--countLinked--'+countLinked);
                    
                }
                system.debug('\n--strQuery--'+strQuery);
                
                // saving set of history records
                set<id> setHistoryRecs = new set<id>();
                
                // getting history record data
                if(linkFieldDetails != null){
                    setHistoryRecs = CommonUtils.getHistoryRecsIds(fieldName,recordId,objectName,linkFieldDetails);
                    system.debug('\n--setHistoryRecs--'+setHistoryRecs);
                }
                
                // getting duplicate records with required fields 
                for(sObject obj : database.query(strQuery)){
                    if(setHistoryRecs.contains(string.valueOf(obj.get('Id'))))
                        lstDuplcateRec.add(new ContainerWrapperClass.DuplicateDetailWrapper(obj,true));
                    
                    else
                        lstDuplcateRec.add(new ContainerWrapperClass.DuplicateDetailWrapper(obj,false));
                }
            }
            
            system.debug('\n--lstDuplcateRec--'+lstDuplcateRec);
            
            // making instance of DuplicateWrapper Wrapper which will be returned
            return new ContainerWrapperClass.DuplicateWrapper(lstDuplcateRec, false, null,lstheaders,linkFieldDetails.fieldValue,countLinked); 
        }
        
        // making return instance
        return new ContainerWrapperClass.DuplicateWrapper(null, true, 'Parameters not Passed',lstheaders,null,0);
    }
    
    
    
    /*******
     * Name         :       findSearchFields
     * Description  :       This method will make instance of wrapper based upon the field set we passed in parameter for search section
     * 
     * Param        :       @recordId               :   Id of record       
     *              :       @searchFieldSetName     :   FieldSet Name
     *                      
     * 
     * Return       :       Wrapper instance which will all the list if fields which has to be displayed on the search component
     * 
     **********/
    public static ContainerWrapperClass.SearchWrapper findSearchFields(String recordId, String searchFieldSetName){
        
        // checking if the parameters are not blank
        if(!string.isBlank(recordId)
            && !string.isBlank(searchFieldSetName)){
        
            // making list of header , below code will be moved to common utility where the values will be pulled from Field sets
            List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
        
            // get Object Name from record Id using CommonUtils class method
            String objectName = CommonUtils.getObjectName(recordId);
            
            // getting header from field set
            lstheaders = CommonUtils.getHeaderList(searchFieldSetName,objectName);
                
            // returning value
            return new ContainerWrapperClass.SearchWrapper(lstheaders);
        }
        
        // need to change to error message
        return null;
    }
    
    /*******
     * Name         :       findSearchFields
     * Description  :       This method will make instance of wrapper based upon the field set we passed in parameter for search section
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done
     *                      @searchFieldSetName     :	 This will have the search field set name and by this parameter we will know that can be the search parameters user has enetered
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @searchValues  	        :	 This will have the actual values os the searched parameter in json format
     *                      @linkedField            :    Linking field which will be used to exclude records to be displayed in search section
     *                      @excludeRecords         :    records which has to be exluded from the search
     * 
     * Return       :       This will retiun the sobject instance and field whichw ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.SearchResultWrapper fetchSearchRecords(String recordId, string searchValues, string displayFieldSetName, 
                                                                                        string searchFieldSetName,string linkedField,
                                                                                        string excludeRecords){
        // this will save the record which hs to be exluded from search result
        List<string> lstRecsExlude = new List<string>();
        
        if(!string.isBlank(recordId)
                && !string.isBlank(displayFieldSetName)
                && !string.isBlank(searchValues)
                && !string.isBlank(searchFieldSetName)
                && !string.isBlank(linkedField)){
        
            
            // get Object Name from record Id using CommonUtils class method
            string objectName = CommonUtils.getObjectName(recordId);
            
            // code section to get linking field value
            ContainerWrapperClass.LinkingFieldDetails linkFieldDetails = CommonUtils.getLinkingFieldValue(linkedField,recordId, objectName,null);
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
        
            // making instance of Duplicate Details Wrapper which will have searched Record Details
            List<ContainerWrapperClass.DuplicateDetailWrapper> lstSearchedRec = new List<ContainerWrapperClass.DuplicateDetailWrapper>();
            
            // making list of header , below code will be moved to common utility where the values will be pulled from Field sets
            List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
            
            // getting header from field set
            lstheaders = CommonUtils.getHeaderList(searchFieldSetName,objectName);
            
            // parse seachValue to object to get Enetered values
            system.debug('\n--searchValues--'+searchValues);
            map<string,string> mapSearchValues = CommonUtils.parseSeachCriteraJson(searchValues);
            
            // building where caluse
            string wherCaluse = 'WHERE ID !=: recordId ';
            for(ContainerWrapperClass.HeaderWrapper head : lstheaders){
                
                //getting field from sobject
                if(mapSearchValues.containsKey(head.fieldAPIName)){
                    
                    if(head.fTypes.isBoolean)
                        wherCaluse += (' AND ' + head.fieldAPIName + ' = ' + Boolean.valueOf(mapSearchValues.get(head.fieldAPIName)));  
                    
                    else if(head.fTypes.isDate)
                        wherCaluse += (' AND ' + head.fieldAPIName + ' =  '+ mapSearchValues.get(head.fieldAPIName));  
                    
                    else
                        wherCaluse += (' AND ' + head.fieldAPIName + ' = \'' + mapSearchValues.get(head.fieldAPIName))+'\'';  
                }
            }
            
            // adding linking field where caluse
            if(linkFieldDetails != null
            && !string.isBlank(linkFieldDetails.fieldValue)){
                
                string linkingCaluse = '';
                
                // checking if the field type is date or date time
                if(linkFieldDetails.fTypes.isDate
                    || linkFieldDetails.fTypes.isDateTime){
                    linkingCaluse += (' AND ' + linkedField + ' !=  '+ linkFieldDetails.fieldValue);  
                }
                
                else if(linkFieldDetails.fTypes.isDate){
                    linkingCaluse += (' AND ' + linkedField + ' != ' + Boolean.valueOf(linkFieldDetails.fieldValue)); 
                }
                
                else{
                    linkingCaluse += (' AND ' + linkedField + ' != \'' + linkFieldDetails.fieldValue + '\'');  
                } 
                wherCaluse += linkingCaluse;
            }
            
            
            // condition for excluded records
            if(!string.isBlank(excludeRecords)){
                lstRecsExlude = (List<string>) JSON.deserialize(excludeRecords, List<string>.class);
                system.debug('\n--lstRecsExlude--'+lstRecsExlude);
                
                wherCaluse += ' AND ID NOT IN :lstRecsExlude';
            }
            system.debug('\n--wherCaluse--'+wherCaluse);
            
            // getting which has to be query
            lstheaders = CommonUtils.getHeaderList(displayFieldSetName,objectName);
            
            // making query which will be used to get relevant data to be returned
            List<string> fieldAPINames =  new List<string>();
            
            // pulling API from field set headers as that will be used in making query
            for(ContainerWrapperClass.HeaderWrapper head : lstheaders){
                fieldAPINames.add(head.fieldAPIName);
            }
            system.debug('\n--displayFieldSetName--'+displayFieldSetName);
            
            // making final query to get data
            string strQuery = 'SELECT '
                                        + string.join(fieldAPINames,',')
                                    +' FROM '+ objectName+' ' 
                                    + wherCaluse;
                                    
            system.debug('\n--strQuery--'+strQuery);
            
            // getting duplicate records with required fields 
            for(sObject obj : database.query(strQuery)){
                lstSearchedRec.add(new ContainerWrapperClass.DuplicateDetailWrapper(obj,false));
            }
            system.debug('\n--lstSearchedRec--'+lstSearchedRec);
            
            // making instance of retun wrapper 
            return new ContainerWrapperClass.SearchResultWrapper(lstheaders,lstSearchedRec);
        }
        
        return null;
    }
    
     
    
    /*******
     * Name         :       findLinkedRecords
     * Description  :       This method is used to search the record where passed field has same value
     * 
     * Param        :       @recordId               :    This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName    :    This will have field set name which will have fields which has to be displayed on cmp
     *                      @fieldName              :    This will have the field name on which search has to be done
     * 
     * Return       :       This will retrun the sobject instance and field whichw ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.SearchResultWrapper findLinkedRecords(String recordId,  string displayFieldSetName, string fieldName){
        
        // making list of header , below code will be moved to common utility where the values will be pulled from Field sets
        List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
        
        // chekcing if non of the value is not present
        if(!String.isBlank(recordId)
            && !String.isBlank(displayFieldSetName)
            && !String.isBlank(fieldName)){
            
            // making instance of Duplicate Details Wrapper which will have searched Record Details
            List<ContainerWrapperClass.DuplicateDetailWrapper> lstSearchedRec = new List<ContainerWrapperClass.DuplicateDetailWrapper>(); 
            
            // getting object Name
            string objectName = CommonUtils.getObjectName(recordId);
            
            // checking if the field has value
            ContainerWrapperClass.LinkingFieldDetails linkFieldDetails = CommonUtils.getLinkingFieldValue(fieldName,recordId, objectName,null);
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
            
            if(linkFieldDetails != null
                && !string.isBlank(linkFieldDetails.fieldValue)){
                
                lstheaders = CommonUtils.getHeaderList(displayFieldSetName,objectName);
                
                // making query which will be used to get relevant data to be returned
                List<string> fieldAPINames =  new List<string>();
                
                // pulling API from field set headers as that will be used in making query
                for(ContainerWrapperClass.HeaderWrapper head : lstheaders){
                    fieldAPINames.add(head.fieldAPIName);
                }
                
                // making where classe for linked query
                string wherCaluse = 'WHERE ID != \''+ recordId + '\'';
                    
                // checking if the field type is date or date time
                if(linkFieldDetails.fTypes.isDate
                    || linkFieldDetails.fTypes.isDateTime){
                    wherCaluse += (' AND ' + fieldName + ' =  '+ linkFieldDetails.fieldValue);  
                }
                
                else if(linkFieldDetails.fTypes.isDate){
                    wherCaluse += (' AND ' + fieldName + ' = ' + Boolean.valueOf(linkFieldDetails.fieldValue)); 
                }
                
                else{
                    wherCaluse += (' AND ' + fieldName + ' = \'' + linkFieldDetails.fieldValue + '\''); 
                }
                
                // getting duplicate records with required fields 
                for(sObject obj : CommonUtils.querySobject(string.join(fieldAPINames,','), wherCaluse,objectName)){
                    lstSearchedRec.add(new ContainerWrapperClass.DuplicateDetailWrapper(obj,false));
                }
                system.debug('\n--lstSearchedRec--'+lstSearchedRec);
                
                // making instance of retun wrapper 
                return new ContainerWrapperClass.SearchResultWrapper(lstheaders,lstSearchedRec);
            }
        }
        return null;
    }
    
    
    
    /*******
     * Name         :       deLinkRecord
     * Description  :       This method will have the code to re link the record and get the latest set of records
     * 
     * Param        :       @recordId               :    This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName    :    This will have the field set name which which will be used to get the field whcih has to be displayed
     *                      @fieldName              :    This will have the field name on which search has to be done
     *                      @deLinkRecId            :    The Id of record which has to be de-link
     *                      @initField  	        :	 Tis will save the fiels value which will help in identifying if the record is master or not 
     * 
     * Return       :       This will retrun the sobject instance and field whichw ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.SearchResultWrapper deLinkRecord(String recordId, string displayFieldSetName, string fieldName, string deLinkRecId,string initField){
     
        if(!string.isBlank(recordId)
            && !string.isBlank(displayFieldSetName)
            && !string.isBlank(fieldName)
            && !string.isBlank(deLinkRecId)){
            
            
            // code to update the record and remove the value from linking field
           CommonUtils.deLinkRecords(new set<id>{deLinkRecId},fieldName,recordId,initField);
           
           // return new set of record
           return findLinkedRecords(recordId,  displayFieldSetName, fieldName);
            
        }
        
        return null;
        
    }
    
    
    /*******
     * Name         :       linkRecord
     * Description  :       This method will have the code to link the record and get the latest set of records
     * 
     * Param        :       @recordId               :    This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName    :    This will have the field set name which which will be used to get the field whcih has to be displayed
     *                      @fieldName              :    This will have the field name on which search has to be done
     *                      @deLinkRecId            :    The Id of record which has to be link
     *                      @searchFieldSet         :    string field for search section (only be required at point of refreshing of the search section)
     * 
     * Return       :       This will retrun the sobject instance and field whichw ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.DuplicateWrapper linkRecord(String recordId, string displayFieldSetName, string fieldName, string deLinkRecId, string initalField){
        
        
        if(!string.isBlank(recordId)
            && !string.isBlank(displayFieldSetName)
            && !string.isBlank(fieldName) 
            && !string.isBlank(deLinkRecId)){
            
            
            // code to update the record and remove the value from linking field
            CommonUtils.linkRecords(new set<id>{deLinkRecId},fieldName,recordId,initalField);
           
            // return new set of record
            return findDuplicateRecords(recordId,  displayFieldSetName, fieldName,initalField);
        }
        
        return null;
        
    }
    
    
    
    /*******
     * Name         :       fetchHistoryLinkedRecords
     * Description  :       This Method will be used to pull the records which were linked to current record in history
     * 
     * Param        :       @recordId  			    :	 This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @displayFieldSetName  	:	 This will have field set name which will have fields which has to be displayed on cmp
     *                      @linkingField  	        :	 This will have the field name on which search has to be done
     *                      @initalField  	        :	 This will save the field value whose values will be copied
     * 
     * Return       :       This will retrun the sobject instance and field which ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.SearchResultWrapper fetchHistoryLinkedRecords(String recordId, string displayFieldSetName, string linkingField, string initalField){
        
        // making instance of Duplicate Details Wrapper which will have searched Record Details
        List<ContainerWrapperClass.DuplicateDetailWrapper> lstSearchedRec = new List<ContainerWrapperClass.DuplicateDetailWrapper>(); 
        
        // making list of header , below code will be moved to common utility where the values will be pulled from Field sets
        List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
        
        if(!string.isBlank(recordId)
            && !string.isBlank(displayFieldSetName)
            && !string.isBlank(linkingField) 
            && !string.isBlank(initalField)){
            
            // getting object name
            String objectName =  CommonUtils.getObjectName(recordId);
            
            // getting required details for linking
            ContainerWrapperClass.LinkingFieldDetails linkFieldDetails =  CommonUtils.getLinkingFieldValue(linkingField,recordId,objectName,initalField);
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
            
            set<id> setHistoryRecords = CommonUtils.getHistoryRecsIds(linkingField,recordId,objectName,linkFieldDetails);
            system.debug('\n--setHistoryRecords--'+setHistoryRecords);
            
            // converting Set to list
            List<id> setRecIds = new List<id>();
            setRecIds.addAll(setHistoryRecords);
            
            // checking if we have the field history
            if(!setHistoryRecords.isEmpty()){
                
                // preparing list of headers
                lstheaders = CommonUtils.getHeaderList(displayFieldSetName,objectName);
                
                // making query which will be used to get relevant data to be returned
                List<string> fieldAPINames =  new List<string>();
                
                // pulling API from field set headers as that will be used in making query
                for(ContainerWrapperClass.HeaderWrapper head : lstheaders){
                    fieldAPINames.add(head.fieldAPIName);
                }
                
                // making where classe for linked query
                string wherCaluse = 'WHERE ID != \''+ recordId + '\' AND ID IN: setRecIds';
                
                string query = 'SELECT ';
        
                // checking if id is present in fields
                if(string.join(fieldAPINames,',').toLowerCase().contains('id')){
                    query += string.join(fieldAPINames,',')
                                +' FROM ' + objectName
                                + ' '+wherCaluse;
                }
                else{
                    query += ' Id, '
                                + string.join(fieldAPINames,',') 
                                +' FROM ' + objectName
                                + ' '+wherCaluse;
                }
                system.debug('\n--query--'+query);
                
                // getting duplicate records with required fields 
                for(sObject obj : database.query(query)){
                    lstSearchedRec.add(new ContainerWrapperClass.DuplicateDetailWrapper(obj,false));
                }
                system.debug('\n--lstSearchedRec--'+lstSearchedRec);
                
                // making instance of retun wrapper 
                return new ContainerWrapperClass.SearchResultWrapper(lstheaders,lstSearchedRec);
            }
        }
        return null;
    }
    
}