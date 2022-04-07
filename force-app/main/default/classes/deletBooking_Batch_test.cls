@isTest
public class deletBooking_Batch_test{
 static testmethod void deletBooking_Batch(){
 
         Id accountId = TestDataFactory.createEKUK_AccountId();
    system.debug('#### dataSetup with accountId: ' + accountId);
    
    //Create Entitlement    
    BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
    TestDataFactory.createEntitlement(accountId, bhs.Id);
    
    //Create Cases
    TestDataFactory.createCaseEKH(accountId);

    //Create Booking Header
    Booking__c bookHeader = TestDataFactory.createActiveBookingHeader(accountId);
    insert bookHeader;
        
        test.starttest();
        database.executebatch(new deletBooking());
        test.stoptest();
 }
 }