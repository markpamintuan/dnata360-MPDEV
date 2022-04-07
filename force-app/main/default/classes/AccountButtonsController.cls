/**************************************************************************************************
* Name               : AccountButtonsController 
* Description        : This is a controller used for lightning button actions on Account
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Keith Rogers                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Keith            08-Aug-2018    Initial version                                                  
* v1.1        Kaavya           01-Nov-2018    Rehlaty - Generic button actions                                                                             
**************************************************************************************************/
public class AccountButtonsController {

    @AuraEnabled
    public static string autoCreateCase(string accid, string rtid, string subject){
        string insertedCaseId = '';
        
        if(accid <> null && accid <> '' && rtid <> null && rtid <> ''){
            case cse = new case();
            cse.AccountId = accid;
            cse.RecordTypeId = rtid;
            cse.Subject = subject;
            cse.Org_Case_Status__c = 'New';            
            insert cse;
            insertedCaseId = cse.Id;
        }
        
        return insertedCaseId;
    }
    
    @AuraEnabled
    public static string getCaseRecordTypeId(string brand, string actiontype){
        RecordType_Mapping__mdt recmap = [select id,DeveloperName,MasterLabel from RecordType_Mapping__mdt where Brand__c=:brand and Type__c =:actiontype limit 1];
        String rectypeid=Schema.SObjectType.Case.getRecordTypeInfosByName().get(recmap.MasterLabel).getRecordTypeId();
        system.debug('Case RTId===='+rectypeid);
        return rectypeid;
    }
}