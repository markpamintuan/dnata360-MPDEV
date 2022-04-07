public class CRK_UtilityClass {

    public static String constructQueryString(string objName,string whereClause) 
    {
        SObjectType obj = Schema.getGlobalDescribe().get(objName); 
        Map<String,Schema.SObjectField> mfields = obj.getDescribe().fields.getMap(); 
        string queryStr ='Select ';       
        for(String s: mfields.keySet())
        {  
            queryStr += mfields.get(s)+',';     
        }
        queryStr = queryStr.substring(0,queryStr.length()-1);
        queryStr += ' From '+objName;
        if(!string.isEmpty(whereClause) && whereClause != null && whereClause != '')
        { 
            queryStr +=  ' Where '+whereClause;   
        } 
        return queryStr;
    }

    public static map<String,Recordtype_Utility_Mapping__mdt> getRTUtilityMap(String ObjecType){
    	
    	map<String,Recordtype_Utility_Mapping__mdt> rtUtilityMap = new map<String,Recordtype_Utility_Mapping__mdt>();
    	
    	for(Recordtype_Utility_Mapping__mdt rtum : [SELECT Recordtype_Name__c, Recordtype_ID__c, Object_Name__c, Exclude_from_Apex_filter__c FROM Recordtype_Utility_Mapping__mdt WHERE Object_Name__c =: ObjecType]){
    		rtUtilityMap.put(rtum.Recordtype_ID__c,rtum);
    	}
    	
    	return rtUtilityMap;
    	
    }    
    
}