@isTest
public class CustomerDerwentPush_Batch_Test {
	static testmethod void CustomerDerwentPush_Batch_TestMethod(){
        
        Person_Account_Record_Types__c PART = new Person_Account_Record_Types__c();
        PART.Name = 'Test';
        PART.Push_to_Derwent__c = True;
        PART.Record_Type_Name__c = 'Test';
        insert PART;
        
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',Org_Brand__c='Test');
        insert acc;
       
        
        test.starttest();
        	database.executebatch(new CustomerDerwentPush_Batch());
        test.stoptest();
 }
}