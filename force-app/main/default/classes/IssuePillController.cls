public class IssuePillController {
		
    @AuraEnabled
    public static List<Issues__c> findRelatedIssues(String caseId){
        List<Issues__c> issueList = new List<Issues__c>();
        try{
        	issueList = [Select Issue__c,Issue_Type__c,End_Provider_Name__c from Issues__c where Internal_Request__c =: caseId];
        } catch (Exception e){
            System.debug('Error in getAllRelatedIssues : ' + e.getMessage());
        }
        if(issueList.size() > 0){
        	return issueList;
        } else {
            return null;
        }
    }
    
    
    
    @AuraEnabled
    public static void deleteIssue(String idToDelete){
        Issues__c issue = [Select id from issues__c where id =: idToDelete];
        delete issue;
    }
    
    
    @AuraEnabled
    public static Map<String,List<PillMap>> findRelatedIssuesWithSupplier(String caseId){
        Map<String,List<PillMap>> supplierValueMap = new Map<String,List<PillMap>>();
        
         List<Issues__c> issueList = new List<Issues__c>();
        try{
        	issueList = [Select Issue__c,Issue_Type__c,End_Provider_Name__c from Issues__c where Internal_Request__c =: caseId];
        } catch (Exception e){
            System.debug('Error in getAllRelatedIssues : ' + e.getMessage());
        }
        
        if(issueList.size() > 0){
            for(Issues__c iss: issueList){
                if(supplierValueMap.containsKey(iss.End_Provider_Name__c)){
                    List<PillMap> valueMap = supplierValueMap.get(iss.End_Provider_Name__c);
                    PillMap pillLabel = new PillMap();
                    pillLabel.label =  iss.Issue__c + ' ► ' + iss.Issue_Type__c;
                    pillLabel.id = iss.id;
                    valueMap.add(pillLabel);
                    supplierValueMap.put(iss.End_Provider_Name__c,valueMap);
                }else{
                    PillMap pillLabel = new PillMap();
                    pillLabel.label = iss.Issue__c + ' ► ' + iss.Issue_Type__c;
                    pillLabel.id = iss.id;
                    List<PillMap> valueMap = new List<PillMap>();
                    valueMap.add(pillLabel);
                    supplierValueMap.put(iss.End_Provider_Name__c,valueMap);
                }
            }
            system.debug(supplierValueMap);
            return supplierValueMap;
        }else{
            return null;
        }
    }
    
    
    public class PillMap{        
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string id;
    }
}