/****
 * Name			:	RecordViewModal
 * Description	:	This Class will be used to get the child record number of records, based upon the
 * 					record id passed in the method
 ***/
public class RecordViewModal {
    public static Map<String, GDPR_Flow_Settings__mdt> mObjectNameGDPRFlowSettings = new Map<String, GDPR_Flow_Settings__mdt>();	
    public static Map<String, Map<Integer, String>> mObjectNameWithChildQueryOrder = new Map<String, Map<Integer, String>>();
    public static Map<Integer, List<sobject>> mQueryOrderWithResults = new Map<Integer, List<sobject>> ();
    public static Map<String, Set<SObject>> mObjectNameListChildren = new Map<String, Set<SObject>>();    
    public static String recordIdPassedIn;
    public static String objectType;
    /****
    * Name			:	fetchChildRecords
    * Description	:	This method will be used to get the child record number of records, based upon the
    * 					record id passed in the method
    ***/
    @AuraEnabled
    public static List<ChildRecordDetails> fetchChildRecords(string objId){
        system.debug('\n--objId--'+objId);
        recordIdPassedIn = objId;
        Id sobjectId = Id.valueOf(objId);

        objectType = sobjectId.getSObjectType().getDescribe().getName();

        // this list we will which we will be returned
        List<ChildRecordDetails> lstReturnChild = new List<ChildRecordDetails>(); 
        
        // checking if we ahve record in parameters
        if(!string.isBlank(objId)){
            createMapGDPRFlowSettings();
            createMapOfObjectWithListChildSOQlQueries();
            //system.debug('jed***££££ mObjectNameWithChildQueryOrder: ' + mObjectNameWithChildQueryOrder);
            queryChildRecords();
            //system.debug('jed***£££ after queryChildRecords mObjectNameListChildren: ' + mObjectNameListChildren);
            // code to add data in wrapper

            for(String sObjName: mObjectNameListChildren.keySet()){
                

                ChildRecordDetails obj = new ChildRecordDetails(sObjName,mObjectNameListChildren.get(sObjName).size());
                system.debug('\n OBJECT:   ' + sObjName + ' --------->  ' + mObjectNameListChildren.get(sObjName).size() + '\n');
                system.debug('\n obj:   ' + obj );
                lstReturnChild.add(obj);
            } 
        }

        if(lstReturnChild.size() == 0 ){
            lstReturnChild.add(new ChildRecordDetails('Related records',0));
            
        }   
        
       
        // return the wrapper
        
        return lstReturnChild;
    }


    public static void createMapGDPRFlowSettings(){
        for(GDPR_Flow_Settings__mdt GDPRFlw:    [SELECT     Object_API_Name__c, 
                                                            Child_Records_SOQL__c,
                                                            Manual_Overwrite_Masking__c
                                                FROM GDPR_Flow_Settings__mdt
                                                WHERE Object_API_Name__c =:objectType]){
            mObjectNameGDPRFlowSettings.put(GDPRFlw.Object_API_Name__c,GDPRFlw);
        }
    }

    public static void createMapOfObjectWithListChildSOQlQueries(){ 
        for(String objName: mObjectNameGDPRFlowSettings.keySet()){   
            system.debug('\n\n\n objName: ' + objName + '\n\n\n');
            if(mObjectNameGDPRFlowSettings.get(objName) == null ) continue; //IF there is no query this will be null
            
            if(mObjectNameGDPRFlowSettings.get(objName).Child_Records_SOQL__c == null){
                continue;
            }
            String sQuery = mObjectNameGDPRFlowSettings.get(objName).Child_Records_SOQL__c;
            //system.debug('££££ 11 sQuery: ' + sQuery);
            
            Integer iQueryLoop = 0; //The queries must be got in order
            Map<Integer, String> mQueryOrderWithQueryString = new Map<Integer, String>();
            
            while(sQuery.contains('Query'+iQueryLoop)){
         
                //system.debug('££££ 11 sQuery in while loop: ' + sQuery);
                String queryToAddToList = '';
                
                //All child queries must have format Query1: SELECT Id FROM Object;
                queryToAddToList = sQuery.substringBetween('Query'+iQueryLoop + ':',';'); 
                //system.debug('££££ 11queryToAddToList: ' + queryToAddToList);
                String sObjectName = queryToAddToList.substringBetween('FROM','WHERE').trim();
                
                mQueryOrderWithQueryString.put(iQueryLoop, queryToAddToList);
                iQueryLoop++;
            }
            mObjectNameWithChildQueryOrder.put(objName, mQueryOrderWithQueryString);
        }
        //system.debug('££££ 11 Exiting with mObjectNameWithChildQueryOrder: ' + mObjectNameWithChildQueryOrder);
    }


    public static void queryChildRecords(){
        //There should only be one object here anyway.
        for(String objName: mObjectNameWithChildQueryOrder.keySet()){
            Map<Integer, String > mQueryOrderToQueryString = new Map<Integer,String>();
            mQueryOrderToQueryString = mObjectNameWithChildQueryOrder.get(objName);

            //system.debug('£££££ mQueryOrderToQueryString: ' + mQueryOrderToQueryString);

            for (Integer i = 0; i < mQueryOrderToQueryString.size(); i++) { 
                    String sQueryToQuery = mQueryOrderToQueryString.get(i);

                    Integer indexOfPassedInList = sQueryToQuery.indexOf('passedInList');
                    if(indexOfPassedInList != -1){ //This is for the first set of records
                        //system.debug('£££ Entering passedINRecords with sQueryToQuery: ' + sQueryToQuery);
                        List<Id> lRecordIds = new List<Id>();
                        lRecordIds.add(recordIdPassedIn); //This is the ID of the record
                        //system.debug('£££ Entering passedINRecords with lRecordIds: ' + lRecordIds);
                        sQueryToQuery = sQueryToQuery.replace('passedInList','lRecordIds');
						
                        //get the object name
                        String sObjectName = sQueryToQuery.substringBetween('FROM','WHERE').trim();

                        List<SObject> lQuery = new List<SObject>();
                        //system.debug('££££ 444 after sQueryToQuery history relace: ' + sQueryToQuery);
                        lQuery = database.query(sQueryToQuery);  
                        Set<SObject> sObjSet = new Set<SObject>();
                        sObjSet.addAll(lQuery);
                        mObjectNameListChildren.put(sObjectName, sObjSet);
                        mQueryOrderWithResults.put(i, lQuery);
                        
                        system.debug('£££ mObjectNameListChildren: ' + mObjectNameListChildren);
                        system.debug('£££ mQueryOrderWithResultss: ' + mQueryOrderWithResults);
                    }

                    String queryParam = '';
                    queryParam = sQueryToQuery.substringBetween('[',']');
                    if(queryParam !=null){
                        Integer iQueryResult = Integer.valueOf(queryParam.remove('Query')); //Left with query order
                        List<sobject> lRecordsToUseInQuery = new List<sobject>();
                        
                        
                        /** KR UAT TEST Experiemtn
                         * 
                         * 
                         * 
                         */
                        List<String> lRecordIdsToQueryString = new List<String>();
                        lRecordsToUseInQuery = mQueryOrderWithResults.get(iQueryResult); //KR moved this from line 153
                        
                        for(sobject sobj: lRecordsToUseInQuery){
                            lRecordIdsToQueryString.add(String.valueOf(sobj.Id));
                        }

						/******/
                        
                        
                        //lRecordsToUseInQuery = mQueryOrderWithResults.get(iQueryResult); KR experinemtn
                        //system.debug('£££ Opp lRecordIdsToQueryString: ' + lRecordIdsToQueryString);
                        sQueryToQuery = sQueryToQuery.replace('[Query' + iQueryResult + ']', 'lRecordIdsToQueryString');
                        //system.debug('£££ Opp sQueryToQuery: ' + sQueryToQuery);
                        //add History query
                        String sObjectName = sQueryToQuery.substringBetween('FROM','WHERE').trim();

                        List<SObject> lQuery = new List<SObject>();
                        //system.debug('££££888888 after sQueryToQuery history relace: ' + sQueryToQuery);
                        system.debug('###########################mObjectNameListChildren     '+  mObjectNameListChildren );   
                        lQuery = database.query(sQueryToQuery);
                        Set<SObject> sObjSet = new Set<SObject>();
                        sObjSet.addAll(lQuery);
                            if(mObjectNameListChildren.containsKey(sObjectName)){
                                mObjectNameListChildren.get(sObjectName).addAll(sObjSet);
                            }else{
                            	mObjectNameListChildren.put(sObjectName, sObjSet);    
                            }
                        
                        mQueryOrderWithResults.put(i, lQuery);                        
                        system.debug('###########################OBJECT     '+  sObjectName + '    ----->   ' + lQuery.size());  
                    }

            }
        }
    }
    
    /******* Wrapper class ***/
    public class ChildRecordDetails{
        @AuraEnabled public string objectName {get;set;}
        @AuraEnabled public Integer recordCount {get;set;}
        
        // constructor
        public ChildRecordDetails(string objectName, Integer recordCount){
            this.objectName = objectName;
            this.recordCount = recordCount;
        }
    }
}