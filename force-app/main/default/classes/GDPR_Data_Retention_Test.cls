@isTest 
public class GDPR_Data_Retention_Test {
	static testMethod void testMethod1() 
    {
        Case c =  new Case();
        c.Org_Brand__c = 'trp';
        c.Org_Case_Status__c = 'New';
        insert c;
         List<GDPR_Archive_Records__c> recordsToBeDeletedList = 	new List<GDPR_Archive_Records__c>();
        for(Integer i = 0; i< 2;i++){
            GDPR_Archive_Records__c archvRec = new GDPR_Archive_Records__c();
            archVRec.Record_Id__c = c.Id;
            recordsToBeDeletedList.add(archVRec);
        }
       
        test.startTest();
        insert recordsToBeDeletedList;
        GDPR_Data_Retention dtr = new GDPR_Data_Retention();
        database.executeBatch(dtr);
        test.stopTest();
        
    }
}