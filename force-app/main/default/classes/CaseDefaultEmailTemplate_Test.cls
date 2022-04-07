@isTest
public class CaseDefaultEmailTemplate_Test{
    static testmethod  void Test()
    {
        //Create test data here
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        Id accountId = TestDataFactory.createDTME_AccountId();
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        Case c = new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId(),
                          Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',
                          Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                          Org_No_of_Children_Travelling__c = 1,SuppliedName='test name',SuppliedPhone='123456789');
        insert c;
        
        Exception failureDuringExecution = null;
        String defaultsAsJSON = '[{"targetSObject":{"attributes":{"type":"EmailMessage"},"TextBody":"",'
            + '"FromName":"Test","FromAddress":"test@example.com","HtmlBody":"<html><body></body></html>","BccAddress":"test@example.com",'
            + '"CcAddress":"","ToAddress":"test@example.com","Subject":"Testing"},"contextId":"'+c.id+'","actionType":"SendEmail",'
            + '"actionName":"Case.SendEmail","fromAddressList":["salesforce@test.com"]}],"TargetSObject:"Case"';
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(defaultsAsJSON, List<QuickAction.SendEmailQuickActionDefaults>.class);
        system.debug('@@'+defaultsSettings);
        Case cs = [SELECT Status, Org_Type__c FROM Case where Id=:c.Id];
        System.debug('Id:'+cs.Id);
        EmailMessage emailMessage = new EmailMessage();    
        //Set email template by default for different Case Types.
        
        Integer emailCount = [SELECT count() FROM EmailMessage];
        Test.startTest();
        try { 
            (new CaseDefaultEmailTemplate()).onInitDefaults(defaultsSettings); 
            
        }
        catch(Exception failure) 
        { 
            failureDuringExecution = failure; 
        }
        
        Test.stopTest();
        //Make other assertions here
    }
    
    
    static testmethod  void Test2()
    {
        //Create test data here
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        Id accountId = TestDataFactory.createDTME_AccountId();
        //Create Entitlement        
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        Case c = new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId(),
                          Subject = 'Test', Org_Destination__c = 'Test',Org_Customer_Journey_Point__c = 'No Booking',Org_Brand__c = 'trp',
                          Org_Traveller__c = 'Couple', Org_No_of_Adults_Travelling__c = 1,
                          Org_No_of_Children_Travelling__c = 1,SuppliedName='test name',SuppliedPhone='123456789');
        insert c;
        
        Exception failureDuringExecution = null;
        String defaultsAsJSON = '[{"targetSObject":{"attributes":{"type":"EmailMessage"},"TextBody":"",'
            + '"FromName":"Test","FromAddress":"test@example.com","HtmlBody":"<html><body></body></html>","BccAddress":"test@example.com",'
            + '"CcAddress":"","ToAddress":"test@example.com","Subject":"Testing"},"contextId":"'+c.id+'","actionType":"SendEmail",'
            + '"actionName":"Case.SendEmail","fromAddressList":["salesforce@test.com"]}],"TargetSObject:"Case"';
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(defaultsAsJSON, List<QuickAction.SendEmailQuickActionDefaults>.class);
        system.debug('@@'+defaultsSettings);
        Case cs = [SELECT Status, Org_Type__c FROM Case where Id=:c.Id];
        System.debug('Id:'+cs.Id);
        EmailMessage emailMessage = new EmailMessage();    
        //Set email template by default for different Case Types.
        
        Integer emailCount = [SELECT count() FROM EmailMessage];
        Test.startTest();
        try { 
            (new CaseDefaultEmailTemplate()).onInitDefaults(defaultsSettings); 
            
        }
        catch(Exception failure) 
        { 
            failureDuringExecution = failure; 
        }
        
        Test.stopTest();
        //Make other assertions here
    }
}