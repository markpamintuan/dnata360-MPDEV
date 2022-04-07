/**
*  This is the apex class which is used for processing the records
**/
public class GDPRProcessChildQueries{ 
    
    public map<string,List<string>> processChildQuery(GDPR_Child_Query__c selectedChildQueries, map<string,List<string>> mapPreviousChildQueryResult){
        
        //system.debug('selectedChildQueries' + selectedChildQueries);
        //system.debug('mapPreviousChildQueryResult' + mapPreviousChildQueryResult);
        
        // this will save the list if ids to be passed in query 
        List<string> lstIds = new List<string>();
        
        // this will save the records to be updated
        List<sobject> lstObjUpdate = new List<sobject>();
        
        // getting the query to be executed
        string tempQuery = selectedChildQueries.SOQL_Query__c;
        //system.debug('\n--tempQuery--'+tempQuery);
        
        // getting the object from query
        string sObjectName= getParentSobjectApiName(tempQuery);
        
        //system.debug('\n--sObjectName--'+sObjectName);    
        
        // big objects
        Boolean isBigObject = false;
        if(sObjectName.containsIgnoreCase('__b')){
            isBigObject = true;
        }
        
        //If parent sObject is Big Object and when child query status is "not started" then return
        if(isBigObject 
           && selectedChildQueries.Job_Status__c == GDPRConstant.GDPR_SELECTED_STATUS_NOT_STARTED){ 
               return mapPreviousChildQueryResult;
           }
        
        
        // adding the query number in the map
        mapPreviousChildQueryResult.put('[Query'+selectedChildQueries.Query_Order_Number__c+']',null);
		system.debug('\n GDPRProcessChildQueries - processChildQuery \n*************************START*************************\n\n tempQuery.indexOf   -----   ' + tempQuery.indexOf('[Query') != -1 + '\n\n*************************END***************************\n');
        // first removing [QUERY] with actual ids
        if(tempQuery.indexOf('[Query') != -1){
            
            do{
                tempQuery = fetchPreviousQueryIds(mapPreviousChildQueryResult, tempQuery);  

            }
            while(tempQuery.indexOf('[Query') != -1);
            
            
        }
        system.debug('\n GDPRProcessChildQueries - processChildQuery \n*************************START*************************\n\n tempQuery   -----   ' + tempQuery + '\n\n*************************END***************************\n');
        // replacing the passedInList
        if(tempQuery.indexOf('passedInList') != -1){
            
            // saving ids
            string queryIds = '';
            
            //for each ids
            if(!Test.isRunningTest()){
                for(string objIds : selectedChildQueries.GDPR_Selected_Object__r.RecordIds__c.split(',')){              
                    queryIds += '\''+objIds+'\',';
                }
            }
            else{
                string q = [select id,RecordIds__c from GDPR_Selected_Object__c limit 1].RecordIds__c; 
                q = q.substring(0,q.length()-1);
                queryIds += '\''+q+'\',';
                //tempQuery = 'SELECT Id,  (SELECT Id FROM Histories), (SELECT Id FROM Feeds)   FROM Account WHERE Id IN :passedInList,'; 
            }

            // removing last comma
            queryIds = queryIds.substring(0,queryIds.length()-1);
            tempQuery = tempQuery.replace('passedInList','( '+queryIds+' )');            
            // replacing colons as well
            tempQuery = tempQuery.replace(':',''); 
        }
        
        
        //system.debug('\n--final--'+tempQuery);
        
        //query the records
        List<sobject> lstRecs = new List<sobject>();
        try{
            lstRecs= Database.query(tempQuery);
        }catch (exception e){
            system.debug('$$$$$$$$$$$$$$$$$$$$$' + e.getMessage());
        }
         
        
        //system.debug('\n--lstRecs--'+lstRecs);
        
        
        // this will save the ids of the records
        List<string> lstRecIds = new List<string>();
        
        // getting ids of record
        for(sobject obj : lstRecs){
            lstRecIds.add((string)obj.get('Id'));
            
            // calling method which will return the sobject which has to be updated (if not a big object)
            if(!isBigObject){
                //system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + selectedChildQueries);
                lstObjUpdate.add(makeInstance(obj, selectedChildQueries, sObjectName));
            }
            
        }
        ////system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + lstObjUpdate);
        //if query result is not of big object then update otherwise delete the big object records
        if(!isBigObject){
            
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            //Account duplicateAccount = new Account(Name='dupe'); 
            List<Database.SaveResult> sr = Database.update(lstObjUpdate, dml); 
            
            //update lstObjUpdate;
        }else if(lstRecs != null && !lstRecs.isEmpty()){
            //delete big object records
            Database.deleteImmediate(lstRecs);
        }
        //system.debug('\n--lstRecIds--'+lstRecIds);
        
        // this will delete the child records if child object is 'Histories' or 'Feeds'
        if(tempQuery.containsIgnoreCase('Histories') || tempQuery.containsIgnoreCase('Feeds')){
            if(lstRecs != null && !lstRecs.isEmpty()){
                deleteChildHistoriesOrFeeds(lstRecs, tempQuery);
            }
        }
        
        // updaing the map getting the map ket where value is null
        for(string key : mapPreviousChildQueryResult.keySet()){
            if(mapPreviousChildQueryResult.get(key) == null){
                mapPreviousChildQueryResult.put(key,lstRecIds);
            }
        }
        
        //system.debug('\n--mapPreviousChildQueryResult--'+mapPreviousChildQueryResult);
        return mapPreviousChildQueryResult;
        
    }
    
    private static sobject makeInstance(sobject obj, GDPR_Child_Query__c childQuery, string objectName){
        
        
        system.debug('\n\n\n-------------------------------METHOD(makeInstance)' + obj);
        system.debug('\n\n\n-------------------------------METHOD(makeInstance)' + childQuery);
        system.debug('\n\n\n-------------------------------METHOD(makeInstance)' + objectName);
        
        
        sobject objectInstance = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        
        // add ids
        objectInstance.put('Id', (string)obj.get('Id'));
        system.debug('\n\n\n-------------------------------objectInstance     ' + objectInstance);
        system.debug('\n\n\n-------------------------------childQuery.Masking_Values_For_Fields__c     ' + childQuery.Masking_Values_For_Fields__c);
        // iteration over field
        if(childQuery.Masking_Values_For_Fields__c != null){
            
            
            for(string field_Val: childQuery.Masking_Values_For_Fields__c.split(',')){
                // splitting to get field name and the value
                List<string> lstField_Val = field_Val.split(':');           
                
                // replace record id
                if(lstField_Val[1].containsIgnoreCase('[recordid]')){
                    lstField_Val[1] = lstField_Val[1].replace('[recordid]',(string)obj.get('Id'));
                }
                
                // getting field Type
                string fType = getFieldType(objectName,lstField_Val[0]);
                
                if(fType.toLowerCase() == 'boolean'){
                    objectInstance.put(lstField_Val[0], boolean.valueOf(lstField_Val[1]));
                    
                }else{
                    objectInstance.put(lstField_Val[0], lstField_Val[1]);
                }
                
                
            }
            
        }
        return objectInstance;
        
    }
    
    public static void deleteChildHistoriesOrFeeds(List<sObject> lstRecs, String finalQuery){
        if(lstRecs != null && !lstRecs.isEmpty()){
            List<sobject> lHistoryToDelete = new List<sobject>();
            List<sobject> lChatterFeedHistory = new List<sobject>();
            
            for(Sobject recsAnon: lstRecs){
                List<sobject> ltempHistory;
                List<sobject> ltempChatterFeed;
                
                if(finalQuery.containsIgnoreCase('Histories')){
                    ltempHistory = recsAnon.getSObjects('Histories');
                }
                if(finalQuery.containsIgnoreCase('Feeds')){
                    ltempChatterFeed = recsAnon.getSObjects('Feeds');
                }
                
                if(ltempHistory != null) lHistoryToDelete.addAll(ltempHistory);
                if(ltempChatterFeed != null) lChatterFeedHistory.addAll(ltempChatterFeed);
            }
            
            if(!lHistoryToDelete.isEmpty()){
                delete lHistoryToDelete;
            }
            
            if(!lChatterFeedHistory.isEmpty()){
                delete lChatterFeedHistory;
            }
            
        }
        
    }
    
    public string fetchPreviousQueryIds(map<string,List<string>> mapPreviousChildQueryResult, string query){
        integer startIndex = query.indexOf('[Query');
        integer endIndex = query.indexOf(']');
        // getting the child number of which result has to be put in
        string childqueryNumber = query.substring(startIndex,endIndex)+']';
        //system.debug('\n--childqueryNumber--'+childqueryNumber+'\n--query--'+query);
        
        // checking if we have the list in map
        if(mapPreviousChildQueryResult.containsKey(childqueryNumber) && mapPreviousChildQueryResult.get(childqueryNumber) != null){
            string queryIds = '';
            for(string ids : mapPreviousChildQueryResult.get(childqueryNumber)){
                queryIds += '\''+ids+'\',';                
            }

            // removing last comma
            string tempQuery = '';
            if(queryIds != ''){
                queryIds = queryIds.substring(0,queryIds.length()-1);
                        	
            }else{
                queryIds = '000000000000';
            }
            // replace with actual ids
                tempQuery = query.replace(childqueryNumber,'( '+queryIds+' )'); 
                tempQuery = tempQuery.replace(':','');
                query = tempQuery;    
           //system.debug('\n GDPRProcessChildQueries - fetchPreviousQueryIds \n*************************START*************************\n\n query   -----   ' + query + '\n\n*************************END***************************\n'); 
        }
        return query;
    }
    
    // return the Parent object api name from query string
    public static String getParentSobjectApiName(String query){
        // getting the object from query
        string sObjectName='';
        if(String.isNotBlank(query)){
            //convert query into lower case
            String lowerCaseString = query.toLowerCase();
            //get Index number of last "from" in string
            Integer lastFromIndex = lowerCaseString.lastIndexOf('from');
            //get the sub string
            String lastFromString = lowerCaseString.substring(lastFromIndex);
            //check "where" clause
            if(lastFromString.contains('where')){
                sObjectName = lastFromString.substringBetween('from','where').trim();
            }else{
                sObjectName = lastFromString.removeStart('from').trim();
            }
        }
        
        return sObjectName;
    }
    
    private static string getFieldType(string objectName, string FName){        
        
        // this will save the type of the field
        string type = '';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        
        
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();        
        for (String fieldName: fieldMap.keySet()) {
            //It provides to get the object fields label.
            string fieldAPIName = fieldMap.get(FieldName).getDescribe().getName();
            if(fieldAPIName.toLowerCase() == FName){
                return string.valueOf(fieldMap.get(FieldName).getDescribe().getType());
            }           
        }
        return 'string';
    }
}