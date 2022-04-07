@isTest
public class IssuePillControllerTest {
    static testmethod void test1(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        String accrecordtype = [select id from recordtype where name ='TRP_B2C Customer- Detail'].id;
        
        Account acc= new Account();
        //acc.name = 'testacc testacc123';
        acc.PersonMobilePhone = '1231231321';
        acc.RecordTypeId = accrecordtype;
        acc.LastName = 'test';
        acc.No_Email_on_Account__c = true;
        insert acc;
        
         BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs.id;
        ent.AccountId = acc.id;
        insert ent;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        bk.RecordTypeId = bookingHeaderRecordId;
        bk.Booking_Status__c = 'Active';
        bk.Org_Account_Name__c = acc.id;
        insert bk;
         
        
        Booking__c cbk = new Booking__c();
        cbk.Name = 'c9999999';
        cbk.Booking_Header__c = bk.id;
        cbk.Booking_Status__c = 'Active';
        cbk.RecordTypeId = bookingRecordId;
        insert cbk;
        
        
               
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        cs.Org_Booking__c = bk.id;
        cs.Org_Brand__c = 'trp';
        cs.AccountId = acc.id;
        cs.OwnerId = Userinfo.getUserId();
        insert cs;
        
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordtypeid;
        cs2.Org_Booking__c = cbk.id;
        cs2.Org_Brand__c = 'trp';
        cs2.ParentId = cs.id;
        insert cs2;
        
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.AccountId = acc.id;
        
        
        Case cs4 = new Case();
        cs4.RecordTypeId = recordtypeid;
        cs4.Org_Booking__c = cbk.id;
        cs4.OwnerId = Userinfo.getUserId();
        cs4.Org_Brand__c = 'trp';
        insert cs4;
        
        Issues__c issue = new Issues__c();
        issue.Org_Booking__c = cbk.id;
        issue.Org_Case__c = cs.id;
        issue.Internal_Request__c = cs4.id;
        issue.End_Provider_Name__c = 'test';
        insert issue;
        
        Issues__c issue2 = new Issues__c();
        issue2.Org_Booking__c = cbk.id;
        issue2.Org_Case__c = cs.id;
        issue2.Internal_Request__c = cs4.id;
        issue2.End_Provider_Name__c = 'test';
        insert issue2;
        
        IssuePillController.findRelatedIssues(cs4.id);
        IssuePillController.findRelatedIssuesWithSupplier(cs4.id);
    }
}