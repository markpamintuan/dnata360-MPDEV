@isTest
public class Create_Internal_Req_And_Issues_Test {
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
        
        
        Create_Internal_Req_And_Issues.getAllCase(new List<String>{String.valueOf(cbk.id)}, cs.id);
        Create_Internal_Req_And_Issues.getAllIssues(new List<String>{String.valueOf(cbk.id)});
        Create_Internal_Req_And_Issues.getBookings(new List<String>{String.valueOf(cbk.name)});
        Create_Internal_Req_And_Issues.getRecordTypeId('Travel Republic - Service Request');
        Create_Internal_Req_And_Issues.getAllRelatedBookingHeaders(cs.id);
        Create_Internal_Req_And_Issues.getAllRelatedBookings(cs.id, null, '');
        Create_Internal_Req_And_Issues.getAllRelatedBookings(cs.id, true,bk.name);
        Create_Internal_Req_And_Issues.getSupplierName(cbk.id);
        Create_Internal_Req_And_Issues.saveAll(JSON.serialize(new List<Case>{cs4}), cs.id, cbk.id, null, '');
        Create_Internal_Req_And_Issues.saveAll(JSON.serialize(new List<Case>{cs4}), cs.id, cbk.id, true, bk.name);
        
        }
    
    static testmethod void test2(){
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
        
        Create_Internal_Req_And_Issues.createCase('subject', 'email@test.com', recordtypeid, new List<String>{cbk.name}, cs.id);
        Create_Internal_Req_And_Issues.updateCase(new List<Case>{cs});
        Create_Internal_Req_And_Issues.updateAll(JSON.serialize(new List<Case>{cs4}), cs.id);       
        Create_Internal_Req_And_Issues.saveAllIssues(cs4.id, JSON.serialize(new List<Issues__c>{issue}), cs.id, cbk.id, null, '');
        Create_Internal_Req_And_Issues.saveAllIssues(cs4.id, JSON.serialize(new List<Issues__c>{issue}), cs.id, cbk.id, true, bk.name);
        Create_Internal_Req_And_Issues.deleteAll(new List<String>{cs.id}, new List<String>{issue.id});
        Create_Internal_Req_And_Issues.fetchLookUpValuesForSubject('I', cs.id);
        Create_Internal_Req_And_Issues.fetchLookUpValues2(Userinfo.getFirstName(), cs.id, 'User');
        Create_Internal_Req_And_Issues.fetchLookUpValues2('', cs.id, 'Queue');
        
        }
}