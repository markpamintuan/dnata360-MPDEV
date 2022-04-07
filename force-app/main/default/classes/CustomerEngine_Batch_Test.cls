/* v2.0       Keith        5-Nov-2019    Change Account Record Type Names For EKH */

@isTest
public class CustomerEngine_Batch_Test{

    static testmethod void CustomerEngine_Batch_Test1(){

        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;
        test.starttest();
        database.executebatch(new CustomerEngine_Batch(new List<id>{acc.id}));
        test.stoptest();

    }

    static testmethod void CustomerEngine_Batch_Test2(){

        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',Org_Brand__c='dnata',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;
        
        Account acc1= new Account(lastname='ekuk_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',Org_Brand__c='EKH',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId()); //v2.0

        insert acc1;
        
        test.starttest();
        database.executebatch(new CustomerEngine_Batch(new List<id>{acc.id}));
        test.stoptest();

    }
}