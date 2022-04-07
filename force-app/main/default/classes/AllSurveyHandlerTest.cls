/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   A test class created to validate the CaseTriggerHandler class.
History
<Date>          <Authors Name>     <Brief Description of Change>
2/23/2018        Jed Canlas              Initial Versioin
----------------------------------------------------------------------------*/ 

@IsTest
public class AllSurveyHandlerTest {

    public static testMethod void TestSurveyInsert(){
        
        Id npsRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - NPS').getRecordTypeId();
        
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
        Account customer = new Account(RecordtypeId = customerRecordtypeId,
                    LastName = 'marhaba Customer', 
                    PersonEmail = 'marhabacustomer@test.com',
                    Org_Brand__c = 'marhaba',
                    Survey_Group__pc = 'marhaba',
                    Survey_Date__pc = system.today(),
                    Booking_Reference__pc = '123456765');
        insert customer;
                            
        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = customer.Id);
        insert entitlement;       
        
        Contact con = new Contact(lastname='test',survey_date__c = date.today(),Survey_Group__c = 'marhaba Online');
        insert con;
        
        Case c1 = new Case();
        c1.CX_Survey_Date__c = date.today();
        c1.Survey_Name__c = 'marhaba';
        c1.Survey_Group__c = 'marhaba Online';
        c1.RecordTypeId = npsRT;
        c1.ContactId = con.Id;
        insert c1;
        
        Case c2 = new Case();
        c2.CX_Survey_Date__c = date.today();
        c2.Survey_Name__c = 'marhaba';
        c2.Survey_Group__c = 'marhaba Online';
        c2.RecordTypeId = npsRT;
        c2.ContactId = con.Id;
        insert c2;
        
        Case c3 = new Case();
        c3.CX_Survey_Date__c = date.today();
        c3.Survey_Name__c = 'marhaba';
        c3.Survey_Group__c = 'marhaba Online';
        c3.RecordTypeId = npsRT;
        c3.ContactId = con.Id;
        insert c3;
       
        
        Survey_Sent__c ss = new Survey_Sent__c();
        ss.Survey_Count__c = 100;
        ss.Survey_Date__c = date.today();
        ss.Survey_Name__c = 'marhaba';
        ss.Survey_Group__c = 'marhaba Online';
        
        test.startTest();
            insert ss;
        test.stopTest();
        
        date dateToday = date.today();
        List<Case> srUpdated = [select id,survey_sent__c from Case where CX_Survey_Date__c =: dateToday and Survey_Name__c = 'marhaba' and Survey_Group__c = 'marhaba Online'];
        system.assert(srUpdated.size() == 3);
        
    }
    
    public static testMethod void TestSurveyUpdate(){
        
        Id npsRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - NPS').getRecordTypeId();

        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
        Account customer = new Account(RecordtypeId = customerRecordtypeId,
                    LastName = 'marhaba Customer', 
                    PersonEmail = 'marhabacustomer@test.com',
                    Org_Brand__c = 'marhaba',
                    Survey_Group__pc = 'marhaba',
                    Survey_Date__pc = system.today(),
                    Booking_Reference__pc = '123456765');
        insert customer;
                            
        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = customer.Id);
        insert entitlement;
        
        Contact con = new Contact(lastname='test',survey_date__c = date.today(),Survey_Group__c = 'marhaba Online');
        insert con;
        
        Case c1 = new Case();
        c1.CX_Survey_Date__c = date.today();
        c1.Survey_Name__c = 'marhaba';
        c1.Survey_Group__c = 'marhaba Online';
        c1.RecordTypeId = npsRT;
        c1.ContactId = con.Id;
        insert c1;
        
        Case c2 = new Case();
        c2.CX_Survey_Date__c = date.today();
        c2.Survey_Name__c = 'marhaba';
        c2.Survey_Group__c = 'marhaba Online';
        c2.RecordTypeId = npsRT;
        c2.ContactId = con.Id;
        insert c2;
        
        Case c3 = new Case();
        c3.CX_Survey_Date__c = date.today();
        c3.Survey_Name__c = 'marhaba';
        c3.Survey_Group__c = 'marhaba Sales';
        c3.RecordTypeId = npsRT;
        c3.ContactId = con.Id;
        insert c3;
        
        Survey_Sent__c ss = new Survey_Sent__c();
        ss.Survey_Count__c = 100;
        ss.Survey_Date__c = date.today();
        ss.Survey_Name__c = 'marhaba';
        ss.Survey_Group__c = 'marhaba Online';
        insert ss;
        ss.Survey_Group__c = 'marhaba Online';
        test.startTest();
            update ss;
        test.stopTest();
        
        date dateToday = date.today();
        List<Case> srUpdated = [select id,survey_sent__c from Case where CX_Survey_Date__c =: dateToday and Survey_Name__c = 'marhaba' and Survey_Group__c = 'marhaba Sales'];
        system.assert(srUpdated.size() == 1);
        
    }
    
    public static testMethod void TestSurveyResponseInsert(){
        
        Id npsRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - NPS').getRecordTypeId();
 
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
        Account customer = new Account(RecordtypeId = customerRecordtypeId,
                    LastName = 'marhaba Customer', 
                    PersonEmail = 'marhabacustomer@test.com',
                    Org_Brand__c = 'marhaba',
                    Survey_Group__pc = 'marhaba',
                    Survey_Date__pc = system.today(),
                    Booking_Reference__pc = '123456765');
        insert customer;
                            
        Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = customer.Id);
        insert entitlement;
        
        Contact con = new Contact(lastname='test',survey_date__c = date.today(),Survey_Group__c = 'marhaba Online');
        insert con;
        
        Case c1 = new Case();
        c1.CX_Survey_Date__c = date.today();
        c1.Survey_Name__c = 'marhaba';
        c1.Survey_Group__c = 'marhaba Online';
        c1.RecordTypeId = npsRT;
        c1.ContactId = con.Id;
        //insert c1;
        
        
        Survey_Sent__c ss = new Survey_Sent__c();
        ss.Survey_Count__c = 100;
        ss.Survey_Date__c = date.today();
        ss.Survey_Name__c = 'marhaba';
        ss.Survey_Group__c = 'marhaba Online';
        insert ss;
        
        test.startTest();
            insert c1;
        test.stopTest();
        
        date dateToday = date.today();
        List<Case> srUpdated = [select id,survey_sent__c from Case where CX_Survey_Date__c =: dateToday and Survey_Name__c = 'marhaba' and Survey_Group__c = 'marhaba Online'];
        //system.assert(srUpdated[0].survey_sent__c == ss.Id);
        
        
    }
    
}