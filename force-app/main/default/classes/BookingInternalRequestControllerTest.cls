@isTest
public class BookingInternalRequestControllerTest {
    static testmethod void test1(){
    	Booking__c bk = new Booking__c();
        insert bk;
        
        string accid = [select id from recordtype where developername = 'TRP_B2C_Customer_Detail'].id;
        Account acc = new Account();
        acc.PersonMobilePhone = '1231231231';
        acc.RecordTypeId = accid;
        acc.LastName = 'testlastnametrp';
        acc.No_Email_on_Account__c  = true;
        insert acc;
        
        Case c = new Case();
    	c.Org_Booking__c = bk.id;
        insert c;
        
        Case ccc = new Case();
        ccc.Org_Booking__c = bk.id;
        
         BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs.id;
        ent.AccountId = acc.id;
        insert ent;

        List<Case> cc = new List<Case>();
        cc.add(c);
        cc.add(ccc);
        
        string casejson = System.JSON.serialize(cc);
	BookingInternalRequestController.fetchLookUpValues2(userinfo.getFirstName(), c.id, 'User');
    BookingInternalRequestController.fetchLookUpValues2('searchKeyWord', c.id, 'Queue');
    BookingInternalRequestController.getAllCase(bk.id);
        BookingInternalRequestController.saveAll(casejson, bk.id);
    }
}