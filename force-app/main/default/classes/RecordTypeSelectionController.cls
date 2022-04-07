public with sharing class RecordTypeSelectionController {
    @AuraEnabled
    public static string findRecordTypes(string objName){
        string returnString='';
        string queryString='Select id, name from RecordType where sobjectType =: objName and IsActive=true';
        List<sobject> recordList= Database.query(queryString);
        List<RecordTypeWrapper> wrapperList=new List<RecordTypeWrapper>();
        for(sobject sb : recordList)  {
            RecordTypeWrapper rw=new RecordTypeWrapper();
            rw.recordTypeLabel=string.valueof(sb.get('name'));
            rw.recordTypeId=string.valueof(sb.get('id'));
            wrapperList.add(rw);
        } 
        returnString= JSON.serialize(wrapperList);
        system.debug('*****'+returnString);
        return returnString;
    }
    public class RecordTypeWrapper{
        public string recordTypeLabel{get;set;}
        public string recordTypeId{get;set;}
    }
}