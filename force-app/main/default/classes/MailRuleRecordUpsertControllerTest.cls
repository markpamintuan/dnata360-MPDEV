@isTest
public class MailRuleRecordUpsertControllerTest {
    
    @isTest
    public static void getMailBox_picklist_ValuesTest(){
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'Test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        MailRuleRecordUpsertController.getMailBox_picklist_Values();
    }
    
    @isTest
    public static void getEmailRuleTest(){
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'Test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        Email_Rule__c EmailRule = new Email_Rule__c();
        EmailRule.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "de"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        EmailRule.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        EmailRule.Object_Name__c = 'EmailMessage';
        EmailRule.Email_MailBox__c = eMailBox.Id;
        EmailRule.Active__c = true;
        EmailRule.Name = 'Test Email Rule 2';
        insert EmailRule;
        
        MailRuleRecordUpsertController.getEmailRule(EmailRule.Id);
    }
    
    @isTest
    public static void upsertEmailRuleTest(){
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'Test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        Email_Rule__c EmailRule = new Email_Rule__c();
        EmailRule.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "de"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        EmailRule.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        EmailRule.Object_Name__c = 'EmailMessage';
        EmailRule.Email_MailBox__c = eMailBox.Id;
        EmailRule.Active__c = true;
        EmailRule.Name = 'Test Email Rule 3';
        insert EmailRule;
        Test.StartTest();
        MailRuleRecordUpsertController.Wrapper wrap = new MailRuleRecordUpsertController.Wrapper();
        wrap.bccAddress =true;
        wrap.ccAddress = true;
        wrap.fromAddress = 'Test@testing.com';
        wrap.mailBox = eMailBox.ID;
        wrap.subject ='No Subject';
        wrap.toAddress = true;
        wrap.Name ='test Rule Name';
        wrap.isActive =true;
        
        MailRuleRecordUpsertController.upsertEmailRule(wrap);
        Test.StopTest();
        
    }
}