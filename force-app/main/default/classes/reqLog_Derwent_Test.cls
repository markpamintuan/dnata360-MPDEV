/* v2.0       Keith        5-Nov-2019    Change Account Record Type Names For EKH */

@isTest
public class reqLog_Derwent_Test{
    static testmethod void reqLog_Derwent_Test_method1(){
        Account acc1= new Account(lastname='test_AccountTriggerHelper1',Website='www.test.test',PersonEmail='test34343@test.com',PersonMobilePhone='01234567782',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId()); //v2.0                               
        insert acc1;
        test.starttest();
        database.executebatch(new reqLog_Derwent());
        test.stoptest();
    }
}