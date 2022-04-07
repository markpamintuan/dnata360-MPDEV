/****
* Name          :   ResultController
* Description   :   This class is mainly used to seach the data based upon the data
*                   enetered by the user in search form
***/
public class ResultController {
    /***
    * Creating the SOSL Query 
    */ 
    public static String createSOSLQuery(Map<String,List<Wrapper_Utility.FieldSetMemberWrapperClass>> objNameWithFieldSetWrapperMAP, Map<String, GDPR_Flow_Settings__mdt> metaDataMAP, String findTextString){
        System.debug('££££ entering createSOSLQuery with findTextString: ' + findTextString);
        System.debug('££££ entering createSOSLQuery with metaDataMAP: ' + metaDataMAP);
        System.debug('££££ entering createSOSLQuery with objNameWithFieldSetWrapperMAP: ' + objNameWithFieldSetWrapperMAP);
        
        //KR this search
        // this will save the query
        String query;        
        System.debug('Entering createSOSLQuery with objNameWithFieldSetWrapperMAP :: '+objNameWithFieldSetWrapperMAP);
        
        // if field details are not blank
        if(!objNameWithFieldSetWrapperMAP.isEmpty()){

            query = 'FIND ';
            query += findTextString + ' IN ALL FIELDS RETURNING';
     
            // for each object make the field which has to be returned
            for(String objName : objNameWithFieldSetWrapperMAP.keySet()){
                
                if(objName.toLowerCase() =='account' && objNameWithFieldSetWrapperMAP.size()==1){
                    return null;
                }

                if(findTextString.contains('null')){
                    system.debug('£££ findTextString: ' + findTextString);
                    return null;
                }
                
                if(objName.toLowerCase() =='account' || objName.toLowerCase() =='lead' || objName.toLowerCase() =='contact') continue; //put this after count
                List<Wrapper_Utility.FieldSetMemberWrapperClass> FieldSetWrapperList = objNameWithFieldSetWrapperMAP.get(objName);
                query += ' '+objName + '(Id),';          
            }            
        }        
        query = query.removeEnd(',');
        System.debug('query line 65 ==>> '+query);
        return query;
        
    }
    
    /****
    * Called from ResultCmp.cmp
    * this method retun the list of records for searchable objects
    * formFieldsObj : is the search form parameters
    * metaDataNames  : meta data names which will have the config settings
    */ 
    @AuraEnabled
    public static List<Wrapper_Utility.ResultWrapper> getObjectsData(List<Wrapper_Utility.FormFieldResultWrapper> formFieldsObj, 
                                                                        String metaDataNames){
        // this is used for saving if account is present in the meta data
        string isAccountPresent = '';
        
        // this will save the SOQL for the sOQL object
        string soql = '';
        GDPR_Flow_Settings__mdt soqlMetaData = null;
        
        // this wil svae the data for soql
        List<sobject> lstObj = new List<sobject>();
        
        // this will save the result which will be returned by the user
        List<Wrapper_Utility.ResultWrapper> lstResultWrapper = new List<Wrapper_Utility.ResultWrapper>();
        
        //Searched Result 
        Search.SearchResults searchResults;
        
        //Get map of Objects with list of fields name (using Fieldset)
        Map<String,Set<String>> objWithFieldsNamesMAP = new Map<String,Set<String>>();
        
        //Get Metadata Records (object name GDPR_Flow_Settings__mdt)
        List<GDPR_Flow_Settings__mdt> metadataObjList = ResultController_Utility.getReviewMetaData();      
        System.debug('metadataObjList ==>> '+metadataObjList);
        

        //Object name to metadata
        Map<String, GDPR_Flow_Settings__mdt> metaDataMAP = ResultController_Utility.getReviewMetaDataMAP(metadataObjList);        
        System.debug('metaDataMAP ==>> '+metaDataMAP);
        

        // if we do not found any setting i.e. field set etc throw error
        if(metaDataMAP.isEmpty()){
            throw new AuraHandledException('Please contact an administrator to set up the metadata correctly');
        }
        
        //Create a FIND clause for SOSL Query       
        //Text St    
        system.debug('££££ before getting findTextString with formFieldsObj: ' + formFieldsObj);
        string findTextString = ResultController_Utility.getFindSearchString(formFieldsObj);
        system.debug('\n--findTextString--'+findTextString); //These keywords are ONLY for email, phone and keywords
        
        
        if(string.isBlank(findTextString)){
            throw new AuraHandledException('Nothing to Search !!');
        }                                                                            
                                                                            
                                                                            
        //Map of Object Name and FieldSet Data
        Map<String,List<Wrapper_Utility.FieldSetMemberWrapperClass>> objNameWithFieldSetWrapperMAP = new Map<String,List<Wrapper_Utility.FieldSetMemberWrapperClass>>();
        List<Integer> orderNumber = new List<Integer>();
        Map<Integer, String> mResultsOrderToObjectName = new Map<Integer, String>();

        for(GDPR_Flow_Settings__mdt meta : metaDataMAP.values()){
            objNameWithFieldSetWrapperMAP.put(meta.Object_API_Name__c, ResultController_Utility.getFieldSetMember(meta));
            orderNumber.add(Integer.valueOf(meta.Search_Result_Order__c));
            mResultsOrderToObjectName.put(Integer.valueOf(meta.Search_Result_Order__c), meta.Object_API_Name__c);
           
        }
        
        system.debug('\n--objNameWithFieldSetWrapperMAP--'+objNameWithFieldSetWrapperMAP+'\n--soql--'+soql);
        
        //Create a Query for SOSL
        String query = '';
        
        //This is the query for accounts, contacts and leads
        Set<id> accountContactLeadIds = new Set<Id>();
        accountContactLeadIds = ResultController_Utility.searchAccountContactsLeadsSOSL(formFieldsObj);
        System.debug('accountContactLeadIds ==>> '+accountContactLeadIds);


        query = ResultController.createSOSLQuery(objNameWithFieldSetWrapperMAP, metaDataMAP, findTextString);  
        System.debug('query line SOSL 254 ==>> '+query);
        List<List<SObject>> SOSLResultsOtherObjects = new List<List<SObject>>();

        if(!String.isBlank(query) && query!=null){
            SOSLResultsOtherObjects = search.query(query);
            System.debug('$$$$ SOSLResultsOtherObjects==>> '+SOSLResultsOtherObjects);
        }

        if(!metaDataMAP.isEmpty()){
                    
            List<ID> sResultsAllIds = new List<Id>();
            sResultsAllIds.addAll(accountContactLeadIds);
            system.debug('£££ sResultsAllIds after adding accs contacts leads: ' + sResultsAllIds);
            //Map<String, List<Id>> mObjectNameListIDs =  new Map<String, List<Id>>();
            for(List<SObject> lSobjects: SOSLResultsOtherObjects){
                
                if(lSobjects.size()> 200){
                    throw new AuraHandledException('There are more returned results returned. Please refine the keywords of your search.');
                }
                List<Id> lSobjectIds = new List<id>();

                for(SObject sobj: lSobjects){
                    lSobjectIds.add(sobj.Id);
                    sResultsAllIds.add(sobj.Id);
                }
            }
            system.debug('£££ sResultsAllIds after getting accounts: ' + sResultsAllIds);
            orderNumber.sort(); //Sort the order number on page

            for(Integer dispOrder : orderNumber){
                String Obj_Name = mResultsOrderToObjectName.get(dispOrder);
                
                Wrapper_Utility.ResultWrapper rw = new Wrapper_Utility.ResultWrapper();
                rw.Object_Name = Obj_Name;
                rw.Section_Heading = metaDataMAP.get(Obj_Name).Section_Heading__c;
                rw.Section_Image = metaDataMAP.get(Obj_Name).Section_Image__c;
                rw.lstFieldSet_Details = objNameWithFieldSetWrapperMAP.get(Obj_Name);
                rw.lstRecords = new List<sObject>();
                String SOQLQueryToPerform = '';
                SOQLQueryToPerform = metaDataMAP.get(Obj_Name).SOQL_Search_Results__c;
                
                if(!SOQLQueryToPerform.toLowerCase().contains('where')){
                    SOQLQueryToPerform = SOQLQueryToPerform + ' WHERE Id IN: sResultsAllIds';
                    system.debug('££££ SOQLQueryToPerform: ' + SOQLQueryToPerform);
                }else{
                    SOQLQueryToPerform = SOQLQueryToPerform + ' AND Id IN: sResultsAllIds';
                }
                SOQLQueryToPerform = SOQLQueryToPerform + ' LIMIT 20000';

                
                //replace results tag
                SOQLQueryToPerform = SOQLQueryToPerform.replace('[Results]', 'sResultsAllIds');
                system.debug('££££ SOQLQueryToPerform: ' + SOQLQueryToPerform);

                rw.lstRecords = new List<sObject>();
                rw.lstRecords = Database.query(SOQLQueryToPerform);
                lstResultWrapper.add(rw);    
            }
        }        
                
        return lstResultWrapper;
    }
}