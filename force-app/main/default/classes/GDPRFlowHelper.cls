public with sharing class GDPRFlowHelper {
    
    public List<Wrapper_Utility.selectedRecordsDetails> selectedRecs = new List<Wrapper_Utility.selectedRecordsDetails> ();
    public set<String> sObjectReferenceTracker = new set<String>();
    public Map<String, Map<String, String>> mObjectNameToAPIFieldsToAnonymise = new Map<String, Map<String, String>>();
    public Map<String, GDPR_Flow_Settings__mdt> mObjectNameGDPRFlowSettings = new Map<String, GDPR_Flow_Settings__mdt>();
    public Map<String, List<FieldDefinition>> mObjectNameListFieldDefinitionFields= new Map<String, List<FieldDefinition>>();
    public Map<String, String> mObjectNameToNestedChildHistoryQuery = new Map<String, String>();
    
    //This is for all objects
    public Map<String, Map<Integer, String>> mObjectNameWithChildQueryOrder = new Map<String, Map<Integer, String>>();
    
    public GDPRFlowHelper(List<Wrapper_Utility.selectedRecordsDetails> selectedRecs) {
        //system.debug('££ entering GDPRFlowHelper with selectedRecs: ' + selectedRecs);
        this.selectedRecs = selectedRecs;
        
        //Keep a running track of all objects mentioned in any of the child queries
        createMapGDPRFlowSettings();
        //Find the query order
        //system.debug('££ After mObjectNameGDPRFlowSettings: '+ mObjectNameGDPRFlowSettings);
        
        createMapOfObjectWithListChildSOQlQueries();
        //system.debug('££ After createMapOfObjectWithListChildSOQlQueries mObjectNameWithChildQueryOrder: ' + mObjectNameWithChildQueryOrder);
        
        createMapOfFieldDefinitionFields();
        //system.debug('££ After createMapOfFieldDefinitionFields with mObjectNameListFieldDefinitionFields: ' + mObjectNameListFieldDefinitionFields);
        
        applyStandardMaskedValuesToFields(); //This is jsut creating a map from the custom definition
        //system.debug('££ After applyStandardMaskedValuesToFields with mObjectNameToAPIFieldsToAnonymise: ' + mObjectNameToAPIFieldsToAnonymise);
        
        applyOverrideFieldValuesFromMetadata(); //THis is the override code that is commented out for the moment
        //	system.debug('££ After applyOverrideFieldValuesFromMetadata mObjectNameToAPIFieldsToAnonymise: ' + mObjectNameToAPIFieldsToAnonymise);
        
        //Loop through the records now
        //1.create new GDPR object

        List<GDPR_Selected_Object__c> lGDPRSelectedObjects = new List<GDPR_Selected_Object__c>();

        GDPR_Job_Tracker__c GDPRjob = new GDPR_Job_Tracker__c();
        insert GDPRjob;
        system.debug('££££ GDPRjob: ' + GDPRjob);
        for(Wrapper_Utility.selectedRecordsDetails sObjFromSelectedFromUI :selectedRecs){
            //Create selected Record
            GDPR_Selected_Object__c GDPRselRecord = new GDPR_Selected_Object__c();
            GDPRselRecord.Object_API_Name__c = sObjFromSelectedFromUI.objectName;
            GDPRselRecord.GDPR_Job_Tracker__c = GDPRjob.Id;

            String sRecordIdsCommaSeperated = '';

            for(String recordId: sObjFromSelectedFromUI.recList){
                sRecordIdsCommaSeperated = recordId + ',';
            }
            GDPRselRecord.RecordIds__c = sRecordIdsCommaSeperated;
            lGDPRSelectedObjects.add(GDPRselRecord);
        }
        insert lGDPRSelectedObjects;
        system.debug('££££ lGDPRSelectedObjects: ' + lGDPRSelectedObjects);

        integer queryOrder = 0;
        List<GDPR_Child_Query__c> lChildQueryToInsert = new List<GDPR_Child_Query__c>();

        for(GDPR_Selected_Object__c GDPRselObject: lGDPRSelectedObjects){
            List<Integer> lIntegersToOrder = new List<Integer>();
            Map<Integer, String> tempQueryOrderWithQuery = new Map<Integer, String> ();
            
            if(mObjectNameWithChildQueryOrder.get(GDPRselObject.Object_API_Name__c)!=null){
                tempQueryOrderWithQuery = mObjectNameWithChildQueryOrder.get(GDPRselObject.Object_API_Name__c);
                lIntegersToOrder.addAll(tempQueryOrderWithQuery.keyset());
                lIntegersToOrder.sort();
            }

            for(Integer childQueryOrderNumber: lIntegersToOrder){
                GDPR_Child_Query__c GDPRChildQuery = new GDPR_Child_Query__c();
                GDPRChildQuery.GDPR_Selected_Object__c = GDPRselObject.Id;


                //These must be in order
                
                GDPRChildQuery.SOQL_Query__c = tempQueryOrderWithQuery.get(childQueryOrderNumber);
                String sObjectName = GDPRChildQuery.SOQL_Query__c.substringBetween('FROM','WHERE').trim();
                GDPRChildQuery.Object_API_Name__c = sObjectName;
				
                String historyQuery = '';

				//Checking to see if the custom object 
                List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{sObjectName}); 
                for(Schema.DescribeSobjectResult objResult:results){
                    
                    //checking to see if hisotry and feed items exist and then will add it to the query
                    if(objResult.isCustom()){
                        try{
                            List<Schema.DescribeSobjectResult> historyResult = Schema.describeSObjects(new List<String>{sObjectName + '__History'});
                            historyQuery = historyQuery + ' (SELECT Id FROM Histories)';
                        }catch(Exception e){
                            system.debug('### GDPRFlowHelper custom ##### History does not exist for : ' + sObjectName);
                        }
                       	try{
                            List<Schema.DescribeSobjectResult> feedResult = Schema.describeSObjects(new List<String>{sObjectName + '__Feed'});
                            if(historyQuery.length()>0) historyQuery = historyQuery + ',';
                            historyQuery = historyQuery + ' (SELECT Id FROM Feeds) ';
                        }catch(Exception e){
                            system.debug('### GDPRFlowHelper custom ##### Feed does not exist for : ' + sObjectName);
                        }
                       	
                    }else{
                         try{
                            List<Schema.DescribeSobjectResult> historyResult = Schema.describeSObjects(new List<String>{sObjectName + 'History'});
                            historyQuery = historyQuery + ' (SELECT Id FROM Histories)';
                        }catch(Exception e){
                            system.debug('### GDPRFlowHelper custom ##### History does not exist for : ' + sObjectName);
                        }
                       	try{
                            List<Schema.DescribeSobjectResult> feedResult = Schema.describeSObjects(new List<String>{sObjectName + 'Feed'});
                            if(historyQuery.length()>0) historyQuery = historyQuery + ',';
                            historyQuery = historyQuery + ' (SELECT Id FROM Feeds) ';
                        }catch(Exception e){
                            system.debug('### GDPRFlowHelper custom ##### Feed does not exist for : ' + sObjectName);
                        }
                    }  
                    system.debug('### GDPRFlowHelper historyQuery #####  : ' + historyQuery);
                }
				

                if(historyQuery.length()>0){
                    GDPRChildQuery.SOQL_Query__c = GDPRChildQuery.SOQL_Query__c.replace('SELECT Id', 'SELECT Id, ' + historyQuery + ' ');
                }
                
                GDPRChildQuery.Query_Order_Number__c = childQueryOrderNumber;
                GDPRChildQuery.Job_Status__c = 'New';
                
                Map<String, String> mFieldNameToFieldValueTemp = new Map<String, String>();
                if(mObjectNameToAPIFieldsToAnonymise.get(sObjectName)!=null){
                    mFieldNameToFieldValueTemp = mObjectNameToAPIFieldsToAnonymise.get(sObjectName);
                }
                
                String commaSeperatedMaskingValues = '';
                for(String fieldApi: mFieldNameToFieldValueTemp.keySet()){
                    
                    system.debug('\n\n\n\n\n' + fieldApi + '\n\n\n\n\n');
                    commaSeperatedMaskingValues =   commaSeperatedMaskingValues + 
                                                    fieldApi + ':' + 
                                                    mFieldNameToFieldValueTemp.get(fieldApi)+
                                                    ',';
                }
                GDPRChildQuery.Masking_Values_For_Fields__c = commaSeperatedMaskingValues;
                
                lChildQueryToInsert.add(GDPRChildQuery);
            }
        }

        if(lChildQueryToInsert.size()> 0 ){
            system.debug('############################################################lChildQueryToInsert    ' + lChildQueryToInsert.size());
            
            insert lChildQueryToInsert;
            
            //for(GDPR_Selected_Object__c selectedRecsInUI: lGDPRSelectedObjects){
                //GDPR_ForgetRecordsProcessBatch myBatchObject = new GDPR_ForgetRecordsProcessBatch(selectedRecsInUI.Id);
                //Id batchId = Database.executeBatch(myBatchObject);
                //system.debug('£££ batch id: ' + batchId);
            //}
        }

        


        system.debug('££££ mObjectNameWithChildQueryOrder: ' + mObjectNameWithChildQueryOrder);
        system.debug('££££ sObjectReferenceTracker: ' + sObjectReferenceTracker);

    }

    public void createMapGDPRFlowSettings(){
        for(GDPR_Flow_Settings__mdt GDPRFlw:    [SELECT     Object_API_Name__c, 
                                                            Child_Records_SOQL__c,
                                                            Manual_Overwrite_Masking__c
                                                FROM GDPR_Flow_Settings__mdt]){
            //system.debug('££££ GDPRFlw.Object_API_Name__c: ' + GDPRFlw.Object_API_Name__c);
            //system.debug('££££ GDPRFlw: ' + GDPRFlw);
            mObjectNameGDPRFlowSettings.put(GDPRFlw.Object_API_Name__c,GDPRFlw);
        }
    }

    public void createMapOfObjectWithListChildSOQlQueries(){ 
        for(String objName: mObjectNameGDPRFlowSettings.keySet()){   
            //system.debug('££££ 11 objName: ' + objName);
            sObjectReferenceTracker.add(objName);
            if(mObjectNameGDPRFlowSettings.get(objName) == null ) continue; //IF there is no query this will be null
            
            if(mObjectNameGDPRFlowSettings.get(objName).Child_Records_SOQL__c == null){
                continue;
            }
            String sQuery = mObjectNameGDPRFlowSettings.get(objName).Child_Records_SOQL__c;
            //system.debug('££££ 11 sQuery: ' + sQuery);
            
            Integer iQueryLoop = 0; //The queries must be got in order
            Map<Integer, String> mQueryOrderWithQueryString = new Map<Integer, String>();
            while(sQuery.contains('Query'+iQueryLoop)){
                String queryToAddToList = '';
                
                //All child queries must have format Query1: SELECT Id FROM Object;
                queryToAddToList = sQuery.substringBetween('Query'+iQueryLoop + ':',';'); 
                String sObjectName = queryToAddToList.substringBetween('FROM','WHERE').trim();
                sObjectReferenceTracker.add(sObjectName);
                mQueryOrderWithQueryString.put(iQueryLoop, queryToAddToList);
                iQueryLoop++;
            }
            mObjectNameWithChildQueryOrder.put(objName, mQueryOrderWithQueryString);
        }
    }

    public void createMapOfFieldDefinitionFields(){ 
        List<FieldDefinition> fldDefLst = new List<FieldDefinition>();
        system.debug('££££ Entering sObjectReferenceTracker: ' + sObjectReferenceTracker);
        fldDefLst = [   SELECT  id,
                                DataType,
                                NamespacePrefix,
                                DeveloperName,
                                SecurityClassification,
                                EntityDefinition.QualifiedApiName, //ObjectName
                                QualifiedApiName
                            FROM FieldDefinition 
                            WHERE EntityDefinition.QualifiedApiName IN:sObjectReferenceTracker 
                            AND SecurityClassification = 'Restricted' 
                            AND DataType != 'Checkbox'
                        ];
        System.debug('#### fldDefLst ' + fldDefLst);

        for(FieldDefinition fieldDef: fldDefLst){
            List<FieldDefinition> lFieldDefTemp = new List<FieldDefinition>();
            
            if(mObjectNameListFieldDefinitionFields.get(fieldDef.EntityDefinition.QualifiedApiName) == null){
                lFieldDefTemp.add(fieldDef);
                mObjectNameListFieldDefinitionFields.put(fieldDef.EntityDefinition.QualifiedApiName,lFieldDefTemp);
            }else{
                lFieldDefTemp = mObjectNameListFieldDefinitionFields.get(fieldDef.EntityDefinition.QualifiedApiName);
                lFieldDefTemp.add(fieldDef);
                mObjectNameListFieldDefinitionFields.put(fieldDef.EntityDefinition.QualifiedApiName,lFieldDefTemp);
            }  
        }
        //ObjectName to list of fields
        system.debug('£££ after mObjectNameListFieldDefinitionFields: ' + mObjectNameListFieldDefinitionFields);
        
    }



    public void applyStandardMaskedValuesToFields(){ 
        
        //mObjectNameListFieldDefinitionFields This one has the map of object, List FieldDef
        List<GDPR_Field_Masking__mdt> maskingValues = new List<GDPR_Field_Masking__mdt>();
        maskingValues = [SELECT FieldDataType__c, Label,Masked_value__c from GDPR_Field_Masking__mdt];
        Map<String, String> mFieldTypeToMaskedValue = new Map<String, String>();
        
        for(GDPR_Field_Masking__mdt mskMeta: maskingValues){
            mFieldTypeToMaskedValue.put(mskMeta.FieldDataType__c.trim(), mskMeta.Masked_value__c);
        }
        system.debug('££££ 1111 mFieldTypeToMaskedValue: ' + mFieldTypeToMaskedValue);




        for(String objName: mObjectNameListFieldDefinitionFields.keyset()){ //Loop through the list of definitionFields
            system.debug('££££ 1111 objName: ' + objName);
            
            Map<String, String> apiFieldToMaskedValueTemp = new Map<String, String>();
            
            SObjectType objTypeDef= ((SObject)(Type.forName('Schema.'+ objName).newInstance())).getSObjectType();
            system.debug('££££ 1111 objTypeDef: ' + objTypeDef);
            DescribeSObjectResult fieldData = objTypeDef.getDescribe();

            //The format in the masked metadata Needs to follow this format DataType=Long Text Area(32000)
            for(FieldDefinition fieldDef: mObjectNameListFieldDefinitionFields.get(objName)){
                 system.debug('££££ 1111 fieldDef: ' + fieldDef);
               
                // USE THIS DATA TYPE : fieldDataType -> This is TEXT STRING ETC
                //KR to mask fields correctly
                string fieldDataType = String.valueof(fieldData.fields.getMap().get(fieldDef.QualifiedApiName).getDescribe().getType());
                system.debug('££££ 1111 fieldDataType: ' + fieldDataType);

                boolean FieldIsEditable = fieldData.fields.getMap().get(fieldDef.QualifiedApiName).getDescribe().isUpdateable();
                system.debug('FieldIsEditable: ' + FieldIsEditable);


                system.debug('££££ xx mFieldTypeToMaskedValue: ' + mFieldTypeToMaskedValue);
                system.debug('££££ xx fieldDataType: ' + fieldDataType);
                system.debug('££££ xx mFieldTypeToMaskedValue.get(fieldDataType): ' + mFieldTypeToMaskedValue.get(fieldDataType));
                //get object and get describe here  
                if(mFieldTypeToMaskedValue.get(fieldDataType)!= null){
                    String valueToAddToField = '';
                    valueToAddToField = mFieldTypeToMaskedValue.get(fieldDataType);
                    system.debug('££££ valueToAddToField: ' + valueToAddToField);
                    apiFieldToMaskedValueTemp.put(fieldDef.QualifiedApiName, valueToAddToField);
                }
            }
            mObjectNameToAPIFieldsToAnonymise.put(objName, apiFieldToMaskedValueTemp);
        }
        system.debug('££££ 1111 exiting with mObjectNameToAPIFieldsToAnonymise: ' + mObjectNameToAPIFieldsToAnonymise);
    }


    
    //This is port
    public void applyOverrideFieldValuesFromMetadata(){ 
    // mObjectNameToAPIFieldsToAnonymise.put(objName, apiFieldToMaskedValueTemp);
    //This is the map we need to override.
        
        
        for(String objName: mObjectNameGDPRFlowSettings.keyset()){
            GDPR_Flow_Settings__mdt metdataFlow = new GDPR_Flow_Settings__mdt();
            
            if(mObjectNameGDPRFlowSettings.get(objName) == null) continue;
            
            
            Map<String, String> tempAPINameToMaskedValue = new Map<String, String>();

            //If this mapping already exists from the field definition then add it here
            if(mObjectNameToAPIFieldsToAnonymise.get(objName)!= null){
                tempAPINameToMaskedValue = mObjectNameToAPIFieldsToAnonymise.get(objName);
            }
            metdataFlow = mObjectNameGDPRFlowSettings.get(objName);

            if(metdataFlow.Manual_Overwrite_Masking__c != null){ //Check override values here
                List<String> lOverrideValues = new List<String>();
                lOverrideValues = metdataFlow.Manual_Overwrite_Masking__c.split(',');
                
                for(String orValue: lOverrideValues){
                    //This will override any existing values if any
                    tempAPINameToMaskedValue.put(orValue.substringBefore(':').trim(), orValue.substringAfter(':').trim()); 
                }
            }
            mObjectNameToAPIFieldsToAnonymise.put(objName,tempAPINameToMaskedValue);
        }
        system.debug('££££ mObjectNameToAPIFieldsToAnonymise: ' + mObjectNameToAPIFieldsToAnonymise);
    }
}