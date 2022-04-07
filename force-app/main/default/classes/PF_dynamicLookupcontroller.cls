public without sharing class PF_dynamicLookupcontroller 
{
    //Method to search 
    @AuraEnabled
    public static list<sObject> searchResult(String srchstr,String sobjname)
    {
        system.debug('srchstr'+srchstr);
        system.debug('sobjname'+sobjname);
        List<sObject> sobjList;
        	string tempInput = srchstr+'%';	
            sobjList = Database.query('SELECT Id,Name FROM ' +sobjname+' WHERE Name like :tempInput  LIMIT 5'); 
        return sobjList;
    }
}