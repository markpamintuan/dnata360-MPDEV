@isTest	
public class Create_Booking_Complaints_Test {
    static testmethod void test1(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        String accrecordtype = [select id from recordtype where name ='TRP_B2C Customer- Detail'].id;
        
        Account acc= new Account();
        acc.PersonMobilePhone = '1231231321';
        acc.RecordTypeId = accrecordtype;
        acc.LastName = 'test';
        acc.No_Email_on_Account__c = true;
        insert acc;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        bk.RecordTypeId = bookingHeaderRecordId;
        bk.Booking_Status__c = 'Active';
        bk.Org_Account_Name__c = acc.id;
        insert bk;
         
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = bhs.id;
        ent.AccountId = acc.id;
        insert ent;
        
        
        Booking__c cbk = new Booking__c();
        cbk.Name = 'c9999999';
        cbk.Booking_Header__c = bk.id;
        cbk.Booking_Status__c = 'Active';
        cbk.Org_Booking_Type__c = 'Flight';
        cbk.RecordTypeId = bookingRecordId;
        insert cbk;
        
        Test.startTest();
               
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        cs.Org_Booking__c = bk.id;
        cs.Org_Brand__c = 'trp';
        cs.AccountId = acc.id;
        cs.OwnerId = Userinfo.getUserId();
        insert cs;     
    
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.OwnerId = Userinfo.getUserId();
        cs3.AccountId = acc.id;
        
        
        Case cs4 = new Case();
        cs4.RecordTypeId = recordtypeid;
        cs4.Org_Booking__c = cbk.id;
        cs4.OwnerId = Userinfo.getUserId();
        cs4.Org_Brand__c = 'trp';
        insert cs4; 
        
        Test.stopTest();
        
        Issues__c issue = new Issues__c();
        issue.Org_Booking__c = cbk.id;
        issue.Org_Case__c = cs.id;
        
        Itinerary__c itin = new Itinerary__c();
        itin.Org_Booking__c = cbk.id;
        insert itin;
        
        
        Itinerary_Detail__c itindet = new Itinerary_Detail__c();
        itindet.Org_Marketing_Carrier__c = 'est';
        itindet.Org_Operating_Carrier__c = 'test';
        itindet.Itinerary__c = itin.id;
        insert itindet;
        
        
        Create_Booking_Complaints_Controller.getAllBookings(new List<String>{cbk.id});
        Create_Booking_Complaints_Controller.createComplaint(cbk.id);
        Create_Booking_Complaints_Controller.getBookings(new List<String>{cbk.Name});
        Create_Booking_Complaints_Controller.getAllCase(new List<String>{cbk.id}, cs.id);
        Create_Booking_Complaints_Controller.getAllIssues(new List<String>{cbk.id});
        Create_Booking_Complaints_Controller.getSupplierName(cbk.id);
        Create_Booking_Complaints_Controller.getSupplierNameIssues(cbk.id);
        Create_Booking_Complaints_Controller.fetchLookUpValuesForSubject('searchKeyWord', cs.id);
        Create_Booking_Complaints_Controller.fetchLookUpValues2('', cs.id, 'User');
        Create_Booking_Complaints_Controller.fetchLookUpValues2('', cs.id, 'Queue');
        Create_Booking_Complaints_Controller.createInternalRequest(JSON.serialize(new List<Case>{cs3}), bk.id, cs.id);
        Create_Booking_Complaints_Controller.saveAll(JSON.serialize(new List<Case>{cs3}), bk.id, cs.id);
        
        Create_Booking_Complaints_Controller.saveAllIssues(cs4.id,JSON.serialize(new List<Issues__c>{issue}), cbk.id, cs.id);
        Create_Booking_Complaints_Controller.deleteAll(new List<String>{cs4.id},new List<String>{issue.id}, cs.id);
        
        
    }
    
    
    static testmethod void test2(){
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        String accrecordtype = [select id from recordtype where name ='TRP_B2C Customer- Detail'].id;
        
        Account acc= new Account();
        acc.PersonMobilePhone = '1231231321';
        acc.RecordTypeId = accrecordtype;
        acc.LastName = 'test';
        acc.No_Email_on_Account__c = true;
        insert acc;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        bk.RecordTypeId = bookingHeaderRecordId;
        bk.Booking_Status__c = 'Active';
        bk.Org_Account_Name__c = acc.id;
        insert bk;
        
        
               
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        cs.Org_Booking__c = bk.id;
        cs.Org_Brand__c = 'trp';
        cs.AccountId = acc.id;
        cs.OwnerId = Userinfo.getUserId();
        insert cs;     
    
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.OwnerId = Userinfo.getUserId();
        cs3.AccountId = acc.id;
        
       
        
        Create_Booking_Complaints_Controller.updateAll(JSON.serialize(new List<Case>{cs3}), cs.id);
    }
    
}