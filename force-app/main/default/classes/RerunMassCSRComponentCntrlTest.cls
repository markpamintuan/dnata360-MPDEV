@isTest
public class RerunMassCSRComponentCntrlTest {
    static testmethod void test1(){
        Account acc= new Account();
        acc.LastName = 'test';
        acc.PersonMobilePhone = '213123123';
        acc.No_Email_on_Account__c = true;
        insert acc;
        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs.id;
        ent.AccountId = acc.id;
        insert ent;
        
        Booking__c bk = new Booking__c();
        bk.name = '123123123';
        bk.Booking_ID__c = '123123123';
        bk.Org_Account_Name__c = acc.id;
        
        insert bk;
        
        Bulk_Case_Job__c bcp = new Bulk_Case_Job__c();
        bcp.Description__c ='test';
        bcp.Request_Type__c = 'Travel Republic - Service Request';
        bcp.Subject__c = 'test';
        bcp.Category__c = 'Accommodation provider query about booking';
        bcp.Send_SMS__c = false;
        bcp.Case_Owner_Id__c = UserInfo.getUserId();
        insert bcp;
        
        Bulk_Case_Job_Item__c bcc = new Bulk_Case_Job_Item__c();
        bcc.Bulk_Case_Job__c = bcp.id;
        bcc.BookingId__c = bk.Booking_ID__c;
        bcc.Status__c = 'New';
        insert bcc;
        
        RerunMassCSRComponentCntrl.runBatch(bcp.id);
        
    }
}