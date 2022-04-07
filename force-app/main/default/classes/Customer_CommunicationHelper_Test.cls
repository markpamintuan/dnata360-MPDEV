@isTest
public class Customer_CommunicationHelper_Test {
    
    @isTest
    public static void SendDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Contact con = new contact();
        con.LastName = 'Test Contact';
        con.Phone = '1234';
        insert con;
        
        
        Booking__c bk = new Booking__c();
        bk.Mobile__c = '1234';
        insert bk;
        
        Case cs = new Case();
        cs.contact = con;
        cs.ContactId  = con.Id;
        cs.Org_Booking__c = bk.id;
        cs.Contact.Phone = '1234' ;
        insert cs;
        
        
        
        Customer_Communication__c Ccommunication = new Customer_Communication__c();
        Ccommunication.Service_Request__c = cs.Id;
        Ccommunication.Send_SMS__c = true;
        Ccommunication.Message__c = 'test message';
        insert Ccommunication;
        
        Ccommunication.Message__c = 'test';
        update Ccommunication;
        
        
        
        //List<Customer_Communication__c> CCommunicationlist = [SELECT id,Send_SMS__c,Message__c,Service_Request__c FROM Customer_Communication__c];
        //Customer_CommunicationHelper.SendDetails(CCommunicationlist);        
        //Customer_CommunicationHelper.markCancelled(CCommunicationlist);
    }

}