@isTest
public class RecordViewModal_Test {
    @testSetup static void createData() {
        Account acc = new Account();
        acc.Name = 'testSF';
        acc.Phone = '123456789';
        insert acc;
    }
    
    @isTest 
    static void fetchChildRecordsTest() { 
        // getting the account
        Account acc = [SELECT Id FROM Account WHERE Name = 'testSF'];
        RecordViewModal.fetchChildRecords(acc.id);
    }
}