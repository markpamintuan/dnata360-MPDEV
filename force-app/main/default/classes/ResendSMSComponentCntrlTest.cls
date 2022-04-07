@isTest
public class ResendSMSComponentCntrlTest {
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
        
       Case c = new Case();
        c.Org_Booking__c = bk.id;
        c.Subject = 'test';
        insert c;
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Message__c = 'test';
        cc.Send_SMS__c = true;
        cc.Service_Request__c = c.id;
        insert cc;
        
        ResendSMSComponentCntrl.resendSMS(cc.id);
        
    }
}