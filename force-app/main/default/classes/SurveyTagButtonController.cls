public class SurveyTagButtonController {
    @AuraEnabled
    public static string getCaseRecordTypeId(string brand, string actiontype,string customerJourney){
        try{
            system.debug('@@'+brand+'@@'+actiontype);
            
            String journeyPoint = '';
            RecordType_Mapping__mdt recmap = new RecordType_Mapping__mdt();
            if(customerJourney == 'Post Travel / Holiday'){
                journeyPoint = '%Post Travel%';
                
            }
            else if(customerJourney == 'Pre Travel / Post Booking'){
                journeyPoint = '%Post Booking%';
            }
            else
                journeyPoint = '%'+customerJourney+'%';
            
            system.debug('Customer Journey &&&'+journeyPoint);
            recmap = [select id,DeveloperName,MasterLabel from RecordType_Mapping__mdt where Brand__c=:brand and Type__c =:actiontype and MasterLabel LIKE : journeyPoint limit 1];
            system.debug('@@'+recmap);
            String rectypeid=Schema.SObjectType.Tag__c.getRecordTypeInfosByName().get(recmap.MasterLabel).getRecordTypeId();
            system.debug('Case RTId===='+rectypeid);
            return rectypeid;
             
        }
        catch(Exception e){
            System.debug('Exception'+e);
            return null;
        }
    }
}