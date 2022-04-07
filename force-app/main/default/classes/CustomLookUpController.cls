public class CustomLookUpController {

    @AuraEnabled
    public static List <Hotel__c> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('searchKeyWord-->' + searchKeyWord);
        String searchKey = searchKeyWord + '%';
        
        list<Hotel__c> returnList = new list<Hotel__c>();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name LIKE: searchKey ORDER BY CreatedDate DESC LIMIT 5';
        
        for (Hotel__c hotel : Database.query(sQuery)) {
            returnList.add(hotel);
        }
        
        return returnList;
    }

    @AuraEnabled
    public static Hotel__c fetchDefaultLookupValue(String hotelId, String ObjectName) {
      
        String sQuery =  'SELECT Id, Name FROM ' + ObjectName + ' WHERE Id = \'' + hotelId + '\'';
        system.debug(sQuery);
        system.debug(Database.query(sQuery));
        return Database.query(sQuery);
        
    }    

}