@isTest
public class Booking_Complaints_ControllerTest {
 /*
  
   	static testmethod void test1(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        
        Account acc= new Account();
        acc.name = 'testacc testacc123';
        insert acc;
        
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
        insert cs;
        
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordtypeid;
        cs2.Org_Booking__c = cbk.id;
        cs2.Org_Brand__c = 'trp';
        insert cs2;
        
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.AccountId = acc.id;
        
        
        Case cs4 = new Case();
        cs4.RecordTypeId = recordtypeid;
        cs4.Org_Booking__c = cbk.id;
        cs4.Org_Brand__c = 'trp';
        
        Issues__c issue = new Issues__c();
        issue.Org_Booking__c = cbk.id;
        issue.Org_Case__c = cs.id;
       
        
     
        Booking_Complaint_Controller.getAllCase(new List<String>{bk.id});
        Booking_Complaint_Controller.getAllIssues(new List<String>{bk.id});
       
        Booking_Complaint_Controller.getBookings(new List<String>{bk.Name});
        Booking_Complaint_Controller.getAllBookings(new List<String>{bk.Name});
        Booking_Complaint_Controller.saveAll(JSON.serialize(new List<Case>{cs4}),JSON.serialize(new List<Issues__c>{issue}), cbk.id,true,'');
    }
    
    
    static testmethod void test2(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        insert bk;
        
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        cs.Org_Brand__c = 'trp';
        insert cs;
        
        Booking_Complaint_Controller.getAllCase(new List<String>{bk.id});
        Booking_Complaint_Controller.getAllIssues(new List<String>{bk.id});
        
    }
    
    
     static testmethod void test3(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        String complaintrecordtypeid = [select id from recordtype where developername = 'Travel_Republic_Complaints'].id;
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        
        Account acc= new Account();
        acc.name = 'testacc testacc123';
        insert acc;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        bk.RecordTypeId = bookingHeaderRecordId;
        bk.Booking_Status__c = 'Active';
        bk.Org_Account_Name__c = acc.id;
        insert bk;
        
        
        Booking__c cbk = new Booking__c();
        cbk.Name = 'c9999999';
        cbk.Booking_Header__c = bk.id;
        cbk.RecordTypeId = bookingRecordId;
        insert cbk;
         Booking__c book = [Select Id,Org_Account_Name__c,Booking_Header__c,Org_Account_Name__r.Name from Booking__c where Id =: cbk.id];
		
        Case newcase = new Case();
        newCase.Org_Booking__c = cbk.Booking_Header__c;
        newCase.AccountId = cbk.Org_Account_Name__c;
        newCase.Subject = 'Complaint for ' + book.Org_Account_Name__r.Name;
        newCase.RecordTypeId = complaintRecordTypeId;
        insert newCase;
        
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        //cs.Org_Booking__c = bk.id;
        cs.Org_Brand__c = 'trp';
        cs.AccountId = acc.id;
        insert cs;
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordtypeid;
        cs2.Org_Booking__c = cbk.id;
        cs2.Org_Brand__c = 'trp';
        insert cs2;
        
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.AccountId = acc.id;
        
        
        Case cs4 = new Case();
        cs4.RecordTypeId = recordtypeid;
        cs4.Org_Booking__c = cbk.id;
        cs4.Org_Brand__c = 'trp';
        
        Issues__c issue = new Issues__c();
        issue.Org_Booking__c = cbk.id;
        issue.Org_Case__c = cs.id;
       
        
     
        
        Booking_Complaint_Controller.saveAll(JSON.serialize(new List<Case>{cs4}),JSON.serialize(new List<Issues__c>{issue}), cbk.id,true,'');
    }
*/
    
    static testmethod void test4(){
        GlobalClassOverride.AllowCaseTrigger = false;
        String recordtypeid = [select id from recordtype where developername = 'Travel_Republic_Internal_Request'].id;
        
        String bookingRecordId = [select id from recordtype where developername = 'Booking'].id; 
        String bookingHeaderRecordId = [select id from recordtype where developername = 'Booking_Header'].id; 
        
        
        Account acc= new Account();
        acc.name = 'testacc testacc123';
        insert acc;
        
        Booking__c bk = new Booking__c();
        bk.name = '9999999';
        bk.RecordTypeId = bookingHeaderRecordId;
        bk.Booking_Status__c = 'Active';
        bk.Org_Account_Name__c = acc.id;
        insert bk;
        
        
        Booking__c cbk = new Booking__c();
        cbk.Name = 'c9999999';
        cbk.Booking_Header__c = bk.id;
        cbk.RecordTypeId = bookingRecordId;
        cbk.Booking_Status__c = 'Active';
        insert cbk;
         Booking__c book = [Select Id,Org_Account_Name__c,Booking_Header__c,Org_Account_Name__r.Name from Booking__c where Id =: cbk.id];
		
        Case newcase = new Case();
        newCase.Org_Booking__c = cbk.Booking_Header__c;
        newCase.AccountId = cbk.Org_Account_Name__c;
        newCase.Subject = 'Complaint for ' + book.Org_Account_Name__r.Name;
        
        insert newCase;
        
        Case cs = new Case();
        cs.RecordTypeId = recordtypeid;
        //cs.Org_Booking__c = bk.id;
        cs.Org_Brand__c = 'trp';
        cs.AccountId = acc.id;
        insert cs;
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordtypeid;
        cs2.Org_Booking__c = cbk.id;
        cs2.Org_Brand__c = 'trp';
        insert cs2;
        
        Case cs3 = new Case();
        cs3.RecordTypeId = recordtypeid;
        cs3.Org_Booking__c = bk.id;
        cs3.Org_Brand__c = 'trp';
        cs3.AccountId = acc.id;
        
        
        Case cs4 = new Case();
        cs4.RecordTypeId = recordtypeid;
        cs4.Org_Booking__c = cbk.id;
        cs4.Org_Brand__c = 'trp';
        
        List<Case> ccc = new List<Case>();
        ccc.add(cs4);
        string serializedcase = System.JSON.serialize(ccc);
        
        Booking_Complaint_Controller.fetchLookUpValues2('searchKeyWord', cs.id, 'Queue');
        Booking_Complaint_Controller.fetchLookUpValues2(userinfo.getFirstName(), cs.id, 'User');
        Booking_Complaint_Controller.fetchLookUpValuesForSubject('searchKeyWord', cs.id);
        Booking_Complaint_Controller.getAllCase(new List<String>{cbk.id});
        Booking_Complaint_Controller.getBookings(new List<String>{bk.name});
        Booking_Complaint_Controller.getAllBookings(new List<String>{cbk.id});
        Booking_Complaint_Controller.createInternalRequest(serializedcase,cbk.id, cs2.id);
    }

}