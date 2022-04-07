@isTest
public class BookingButtonsControllerTest {
    static testmethod void test1(){
        Booking__c bk = new Booking__c();
        insert bk;
        
        string accid = [select id from recordtype where developername = 'TRP_B2C_Customer_Detail'].id;
        Account acc = new Account();
        acc.PersonMobilePhone = '1231231231';
        acc.RecordTypeId = accid;
        acc.LastName = 'testlastnametrp';
        acc.No_Email_on_Account__c = true;
        insert acc;
        
        Case c = new Case();
        insert c; 
        
         BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs.id;
        ent.AccountId = acc.id;
        insert ent;
        
        BookingButtonsController.getEmailFolder();
        BookingButtonsController.fetchUser();
        BookingButtonsController.fetchUserInfo();
        BookingButtonsController.fetchLookUpValuesForSubject('searchKeyWord', c.id);
        BookingButtonsController.fetchLookUpValues2('searchKeyWord', c.id, 'User');
        BookingButtonsController.fetchLookUpValues2('searchKeyWord', c.id, 'Queue');
        BookingButtonsController.createServiceRequestController('subject', 'New', 'description', userinfo.getUserId(), bk.id, acc.id, '',true);
    }
}