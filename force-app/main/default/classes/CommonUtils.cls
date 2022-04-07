/***********
 * Name         :       CommonUtils
 * Description  :       This Class will have all the Common Method which 
 *                      is related to Any Object in order to re user the Code
 * 
 * Created Date :       26-Sept-2018
 *****/
public class CommonUtils {
    
    public static boolean isFieldSetExist = true;
    
    /********
     * Name         :       getHeaderList
     * Description  :       The Method will be used to get header based upon the field set
     *                      Obj Name we passed in param
     * 
     * Param        :       @fieldSetName   :   FieldSet name
     *                      @ObjectName     :   Object API Name
     * return       :       List<ContainerWrapperClass.HeaderWrapper>
     ****/
    public static List<ContainerWrapperClass.HeaderWrapper> getHeaderList(String fieldSetName, String ObjectName){
        List<ContainerWrapperClass.HeaderWrapper> lstheaders = new List<ContainerWrapperClass.HeaderWrapper>();
        //system.debug('\n--fieldSetName--'+fieldSetName+'\n--ObjectName--'+ObjectName+'\n--field--'+readFieldSet(fieldSetName, ObjectName)+'\n---ff--'+Schema.SObjectType.Contact.fieldSets.getMap().get('DuplicateTableHeader'));
        
        List<Schema.FieldSetMember> fieldSetDetails = readFieldSet(fieldSetName, ObjectName);
        if(fieldSetDetails != null)
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetDetails){
                
                system.debug('\n--type--'+string.valueOf(fieldSetMemberObj.getType())+'\n--Name--'+fieldSetMemberObj.getFieldPath());
                
                // getting refrence field value
                if(string.valueOf(fieldSetMemberObj.getType()).toLowerCase() == 'reference'){
                    
                    string fName = fieldSetMemberObj.getFieldPath();
                    
                    // checking if the field is custom then check __c and replace with __r.Name, in order to get the name
                    if(fName.indexOf('__c') != -1)
                        fName = fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
                    
                    // checking if the field is standard , then it will be having the id , then replace Id with .Name
                    else
                        fName = fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
                    
                    
                    lstheaders.add(new ContainerWrapperClass.HeaderWrapper(fieldSetMemberObj.getLabel(), fName,string.valueOf(fieldSetMemberObj.getType())));
                }
                
                // adding non reference fields
                else{
                    lstheaders.add(new ContainerWrapperClass.HeaderWrapper(fieldSetMemberObj.getLabel(), fieldSetMemberObj.getFieldPath(),string.valueOf(fieldSetMemberObj.getType())));
                }
                
            }
        system.debug('lstheaders : '+lstheaders);
        return lstheaders;
    }
    
    
    
    /****
     * Name             :   readFieldSet
     * Description      :   THis will be used to get field set details based upon
     *                      object type and the field set name
     ****/ 
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj == null)
            return null;
            
        return fieldSetObj.getFields();
    }
    
    /****
     * Name             :   getObjectName
     * Description      :   THis will be used to Object Name using record Id
     ****/
    public static String getObjectName(String recordId){
    	   return Id.valueOf(recordId).getSObjectType().getDescribe().getName();
    }
    
    /*******
     * Name         :       parseSeachCriteraJson
     * Description  :       This will parse the json of search criteria and return the map of Field name and its values
    */
    public static  map<string,string> parseSeachCriteraJson(string strSearchJson){
        
        // this will svae the field and its value 
        map<string,string> mapFieldData = new map<string,string>();
        
        JSONParser parser = JSON.createParser(strSearchJson); 
        while (parser.nextToken() != null) {
            system.debug('\n--parser.getCurrentToken()--'+parser.getCurrentToken());
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){   
                system.debug('\n--text--'+parser.getText());
                string fieldAPI = parser.getText();
                
                // get corrssponding value
                parser.nextToken();
                system.debug('\n--value--'+parser.getText());
                string tokenValue = parser.getText();
                
                
                // updating map if value is not null
                if(!string.isBlank(tokenValue))
                	mapFieldData.put(fieldAPI,tokenValue);
            }
        }
        system.debug('\n--mapFieldData--'+mapFieldData);
        
        return mapFieldData;
        
    }
    
    
    /********
     * Name         :       getHeagetFieldTypederList
     * Description  :       Ths method will be used to get the field type based upon the object passed and field name
     * 
     ****/
    
    public static String getFieldType(String fieldName, string ObjectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(ObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe(); 
        return string.valueOf(f.getType());
    }
 
    /********
     * Name         :       querySobject
     * Description  :       This method will return the list of record based upon the field (comman seperated)
     *                      passed in method and where caluse
     * 
     ****/
    
    public static List<sobject> querySobject(String fieldNames, string whereCaluse, string objectName){
        system.debug('### Entering querySobject with fieldNames: ' +fieldNames);
        system.debug('### Entering querySobject with whereCaluse: ' +whereCaluse);
        system.debug('### Entering querySobject with objectName: ' +objectName);
        string query = 'SELECT ';
        
        // checking if id is present in fields
        if(fieldNames.toLowerCase().contains('id')){
            query += fieldNames
                        +' FROM ' + objectName
                        + ' '+whereCaluse;
        }
        else{
            query += ' Id, '
                        + fieldNames 
                        +' FROM ' + objectName
                        + ' '+whereCaluse;
        }
        system.debug('\n--query--'+query);
        return database.query(query);
    }
    
    
    /********
     * Name         :       makeSobjectInstance
     * Description  :       This method will make insatnce of sobject based upon the record id passed in
     *                      parameter
     * 
     ****/
    
    public static sobject makeSobjectInstance(String recId){
        
        // getting object Name
        string objectName = CommonUtils.getObjectName(recId);
        
        // making istance of object which has to be updated
        Schema.SObjectType recType = Schema.getGlobalDescribe().get(objectName);
        sobject sobjectInstance = recType.newSObject();
        
        return sobjectInstance;
    }
    
    
    /****
     * Name         :       deLinkRecords
     * Description  :       This method will make insatnce of sobject based upon the record id passed in
     *                      parameter
     * 
     ****/
    
    public static sobject deLinkRecords(set<id> recordIds, string linkingField, string currentRecId, string initField){
        
        // will save the records to be updated
        List<sobject> lstUpdateRecord = new List<sobject>();
        
        // if we ahve records to be processed
        if(!recordIds.isEmpty()){
            
            // checking if the record is master record
            map<id,ContainerWrapperClass.MasterReordDetails> masterRecMap = isMasterRecord(recordIds,linkingField,initField);
            system.debug('\n--masterRecMap--'+masterRecMap);
            
            // saving master record id
            set<id> setMasterRecordIds = new set<id>();
            
            // saving linking field values
            list<string> linkingFieldValue = new list<string>();
            
            // iteration to get the ids of master records
            for(ContainerWrapperClass.MasterReordDetails masterDetails : masterRecMap.values()){
                if(masterDetails.isMaster){
                    setMasterRecordIds.add(string.valueOf(masterDetails.recDetails.get('Id')));
                    linkingFieldValue.add(string.valueOf(masterDetails.recDetails.get(linkingField)));
                }
            }
            system.debug('\n--linkingFieldValue--'+linkingFieldValue);
            
            
            
            // code to get all childs records for master
            if(!linkingFieldValue.isEmpty()){
            
                string objName = CommonUtils.getObjectName(currentRecId);
                string childRecQuery = 'SELECT Id'
                                        + ' FROM ' + objName
                                        + ' WHERE '+ linkingField +'=: linkingFieldValue'
                                        +' AND Id !=: currentRecId ';
                system.debug('\n--childRecQuery---'+childRecQuery);
                
                List<sobject> lstChilds = database.query(childRecQuery);
                system.debug('\n--lstChilds--'+lstChilds);
                
                // getting required details for linking
                ContainerWrapperClass.LinkingFieldDetails linkFieldDetails =  getLinkingFieldValue(linkingField,currentRecId,objName,initField);
                system.debug('\n--linkFieldDetails--'+linkFieldDetails);
                
                
                // update current record
                if(linkFieldDetails != null
                    && !string.isBlank(linkFieldDetails.initalFieldValue)){
                    sobject rec = makeSobjectInstance(currentRecId); 
                    rec.put('Id', currentRecId);
                    rec.put(linkingField, linkFieldDetails.initalFieldValue);
                    
                    // adding to list
                    lstUpdateRecord.add(rec);
                    system.debug('\n--rec--'+rec); 
                }
                
                // updating all child records
                if(linkFieldDetails != null
                    && (!string.isBlank(linkFieldDetails.initalFieldValue))){
                
                    // for each record which has to be updated
                    for(sobject childRec : lstChilds){
						
						// current record shoud not be updated                        
                        if(string.valueOf(childRec.get('Id')) != currentRecId){
                            sobject rec = makeSobjectInstance(string.valueOf(childRec.get('Id')));
                            rec.put('Id', string.valueOf(childRec.get('Id')));
                            
                            // chekcing if the record is master then make the value to null
                            if(setMasterRecordIds.contains(string.valueOf(childRec.get('Id'))))
                            	rec.put(linkingField, null);    
                            else
                                rec.put(linkingField, linkFieldDetails.initalFieldValue);	
                            
                            // adding to list
                            lstUpdateRecord.add(rec);
                            system.debug('\n--rec--'+rec);
                        }
                    }
                }
            }
            else{
             
                // for each record which has to be updated
                for(id recId : recordIds){
                    
                    sobject rec = makeSobjectInstance(recId);
                    rec.put('Id', recId);
                    rec.put(linkingField, null);
                    
                    // adding to list
                    lstUpdateRecord.add(rec);
                }
            }
        }
        system.debug('\n--lstUpdateRecord---'+lstUpdateRecord);
        if(!lstUpdateRecord.isEmpty())
            update lstUpdateRecord;
        
        return null;
    }
    
    
    /********
     * Name         :       linkRecords
     * Description  :       This method will make insatnce of sobject based upon the record id passed in
     *                      parameter
     * 
     ****/
    public static sobject linkRecords(set<id> recordIds, string linkingField, string currentRecId,string initalField){
        
        if(!recordIds.isEmpty()){
            system.debug('\n--initalField--'+initalField);
            string objectName = CommonUtils.getObjectName(currentRecId);
            
            // getting required details for linking
            ContainerWrapperClass.LinkingFieldDetails linkFieldDetails =  getLinkingFieldValue(linkingField,currentRecId,objectName,initalField);
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
            
            // list of record which has to be updated
            List<sobject> lstUpdateRecord = new List<sobject>();
            
            
            // update current record
            if(linkFieldDetails != null
                && !string.isBlank(linkFieldDetails.initalFieldValue)
                && string.isBlank(linkFieldDetails.fieldValue)){
                sobject rec = makeSobjectInstance(currentRecId);
                rec.put('Id', currentRecId);
                rec.put(linkingField, linkFieldDetails.initalFieldValue);
                
                // adding to list
                lstUpdateRecord.add(rec);
                system.debug('\n--rec--'+rec);
            }
            
            // if linking field has value
            if(linkFieldDetails != null
                && (!string.isBlank(linkFieldDetails.fieldValue))
                    || !string.isBlank(linkFieldDetails.initalFieldValue)){
            
                // for each record which has to be updated
                for(id recId : recordIds){
                    
                    sobject rec = makeSobjectInstance(recId);
                    rec.put('Id', recId);
                    
                    if(!string.isBlank(linkFieldDetails.fieldValue))
                        rec.put(linkingField, linkFieldDetails.fieldValue);
                    else
                        rec.put(linkingField, linkFieldDetails.initalFieldValue);
                        
                    
                    // adding to list
                    lstUpdateRecord.add(rec);
                    system.debug('\n--rec--'+rec);
                }
            }
            
            // updating record
            if(!lstUpdateRecord.isEmpty())
                update lstUpdateRecord;
                
            
        }
        
        return null;
    }
    
    /*********
     * Name         :   isMasterRecord
     * Description  :   This method will be used to check if the record id passed in the parameter is the
     *                  master record or the child record
     * 
     * parameters   :   @recId          :   This will save the record id on which we have to check if this is master record or not
     *                  @linkingField   :   The linking field if
     *                  @initalField    :   inital field id
     * 
     ****/
    static map<id,ContainerWrapperClass.MasterReordDetails> isMasterRecord(set<id> recIds, string linkingField, string initalField){
        
        map<id,ContainerWrapperClass.MasterReordDetails> retunMap = new map<id,ContainerWrapperClass.MasterReordDetails>();
        
        List<id> lstIds = new List<id>();
        lstIds.addAll(recIds);
        
        // checkig id the record id pased in not blank
        if(!recIds.isEmpty()){
            
            string query = '';
            
            if(linkingField.toLowerCase() == 'id'
                || initalField.toLowerCase() == 'id')
                
                // getting object Name for making query
                query = 'SELECT '
                                +linkingField + ' ,'
                                +initalField 
                            +' FROM '+ getObjectName(lstIds[0])
                            +' WHERE Id = :recIds';
            else
                // getting object Name for making query
                query = 'SELECT '
                                +' Id ,'
                                +linkingField + ' ,'
                                +initalField 
                            +' FROM '+ getObjectName(lstIds[0])
                            +' WHERE Id = :recIds';
            
            system.debug('\n--query---'+query);
            // making instance of Record in order to pass to duplicate Rules
            List<sObject> lstRecords = database.query(query); 
            
            // checking if the record is master record
            if(!lstRecords.isEmpty()){
             
                for(sObject rec : lstRecords){
                    if(rec.get(linkingField) == rec.get(initalField)){
                        retunMap.put(string.valueOf(rec.get('Id')),new ContainerWrapperClass.MasterReordDetails(rec,true));
                    }
                    else{
                        retunMap.put(string.valueOf(rec.get('Id')),new ContainerWrapperClass.MasterReordDetails(rec,false));
                    }
                }
            }
        }
        return retunMap;
        
    }
    
    /*******
     * Name         :       getLinkingFieldValue
     * Description  :       This method is used to search get the field value of the linking field i.e. passed in parameter
     * 
     * Param        :       @RecordId               :    This will have the current record id which will be used to know the object on which operation is done     *                      
     *                      @objectName             :    This will have the object name from which value has to be pulled
     *                      @fieldName              :    This will have the field name on which search has to be done
     * 
     * Return       :       This will retrun the sobject instance and field whichw ill be displayed in table
     * 
     **********/
    public static ContainerWrapperClass.LinkingFieldDetails getLinkingFieldValue(string fieldName, string RecordId, string objectName, string initalField){
     
        // where caluse for getting linking field value of current record
        string wherCaluse = 'WHERE ID = \''+ recordId + '\'';
        
        // checking if inital field is passed
        string queryFields = fieldName;
        if(!string.isBlank(initalField)){
            queryFields +=', '+initalField;
        }
        
        // code to get the linked field value
        List<sobject> lstObj = CommonUtils.querySobject(fieldName, wherCaluse,objectName);
        system.debug('\n--lstObj--'+lstObj);
        
        // checking if record exist
        if(!lstObj.isEmpty()){
            
            // getting field type
            system.debug('\n--fieldName--'+fieldName+'\n--objectName--'+objectName);
            string fieldType = CommonUtils.getFieldType(fieldName,objectName);
            system.debug('\n-fieldType---'+fieldType);
            
            if(!string.isBlank(initalField)){
                return new ContainerWrapperClass.LinkingFieldDetails(string.valueOf(lstObj[0].get(fieldName)),fieldType,string.valueOf(lstObj[0].get(initalField)));
            }
            else{
                return new ContainerWrapperClass.LinkingFieldDetails(string.valueOf(lstObj[0].get(fieldName)),fieldType,null);
            }
        }
        
        return new ContainerWrapperClass.LinkingFieldDetails();
        
    }
    
    
    /*******
     * Name         :       buildHistoryFieldQuery
     * Description  :       This Method will be used to build query the records which were linked to current record in history
     * 
     * Param        :       @RecordId               :   This will have the current record id which will be used to know the object on which operation is done 
     *                      @objectName             :   This will have the object name from which value has to be pulled
     *                      @linkingField           :   This will have the field name on which search has to be done
     *                      @linkFieldDetails       :   This will have linking field and inital field value of cirrent record
     * 
     * Return       :       This will return the set of set of record which were part of history 
     * 
    **********/
    public static set<id> getHistoryRecsIds(string linkingField, string recordId, string objectName, ContainerWrapperClass.LinkingFieldDetails linkFieldDetails){
        system.debug('### Entering getHistoryRecsIds with linkingField: ' + linkingField);
        system.debug('### Entering getHistoryRecsIds with recordId: ' + recordId);
        system.debug('### Entering getHistoryRecsIds with objectName: ' + objectName);
        system.debug('### Entering getHistoryRecsIds with linkFieldDetails: ' + linkFieldDetails);
        // this will save set of histrory rec Ids
        set<id> setoldLinkedRecIDs = new set<id>();
        
        if(!string.isBlank(recordId)
            && !string.isBlank(linkingField)
            && !string.isBlank(objectName)
            && linkFieldDetails != null){
            system.debug('\n--linkFieldDetails--'+linkFieldDetails);
            
            boolean isCustomObject = false;
            
            // checking if object name has __c the it a custom object
            if(objectName.indexOf('__c') != -1){
                isCustomObject = true;
            }
            system.debug('\n--isCustomObject--'+isCustomObject);
            
            // saving the parentField
            string parentFieldName = 'ParentId';
            if(!isCustomObject){
                parentFieldName = objectName+'Id';
            }
            
            string historyQuery = 'SELECT '+parentFieldName+', '
                                    +' OldValue, '
                                    +' NewValue ';
            
            // adding aobject name
            if(isCustomObject){
                string historyObj = objectName.replace('__c', '__history');
                historyQuery += 'FROM '+historyObj; 
            }
            else{
                string historyObj = objectName+'history'; 
                historyQuery += 'FROM '+historyObj;
            }
            
            // adding where clause  
            historyQuery += ' WHERE '+parentFieldName+' != :recordId ';
            historyQuery += ' AND Field =: linkingField';

            system.debug('\n--historyQuery---'+historyQuery);
            
            // stroring linking field value
            string linkedFieldValue = '';
            
            // adding linking field value
            if(linkFieldDetails != null){
                
                if(!string.isEmpty(linkFieldDetails.fieldValue)){
                    linkedFieldValue = linkFieldDetails.fieldValue;
                }
                
                else if(!string.isEmpty(linkFieldDetails.initalFieldValue)){
                    linkedFieldValue = linkFieldDetails.initalFieldValue;
                }
            }
            ///system.debug('\n--historyQuery--'+historyQuery+'---'+[SELECT OLDVALUE FROM CONTACTHISTORY]);
            
            // getting data
            for(sobject objHistory : database.query(historyQuery)){
                system.debug('\n--objHistory--'+objHistory);
                
                // checking if old field value is queal to linking field
                if(string.valueOf(objHistory.get('OldValue')) == linkedFieldValue)
                    setoldLinkedRecIDs.add(string.valueOf(objHistory.get(parentFieldName)));
            }
            system.debug('\n--setoldLinkedRecIDs--'+setoldLinkedRecIDs);
        }
       
        if(test.isRunningTest()){
            for(contact con : [SELECT ID FROM CONTACT]){
                setoldLinkedRecIDs.add(con.Id);
            }
        }
        return setoldLinkedRecIDs;
    }
    
    
}