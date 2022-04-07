@isTest
public class RulesUtilityTest {
    
    @isTest
    public static void updateSoqlDetailsTest(){
        
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        Email_Rule__c delRecord = new Email_Rule__c();
        delRecord.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "KR"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        delRecord.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        delRecord.Object_Name__c = 'EmailMessage';
        delRecord.Email_MailBox__c = eMailBox.Id;
        delRecord.Active__c = true;
        delRecord.Name = 'First Test Email';
        insert delRecord;
        
        //create case
        Case c = new Case();
        //enter details
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'My Status';
        insert c;
        set<Id> csId = new set<id>();
        csId.add(c.id);
        
        List<Email_Rule__c> DelRecordList = [SELECT Id,Filters_Json__c,Hard_Coded_Rules__c,
                                             Object_Name__c,Rule_Logic__c,SOQL__c,Email_MailBox__c 
                                             FROM Email_Rule__c];
        RulesUtility.updateSoqlDetails(DelRecordList);
        RulesUtility.deleteCases(csId);
    }
    
    @isTest
    public static void deleteFiltersQueryTest(){
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'Test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        Email_Rule__c delRecord = new Email_Rule__c();
        delRecord.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "KR"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        delRecord.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        delRecord.Object_Name__c = 'EmailMessage';
        delRecord.Email_MailBox__c = eMailBox.Id;
        delRecord.Active__c = true;
        delRecord.Name = 'First Test Email 1';
        insert delRecord;
        
        Email_Rule__c delRecord2 = new Email_Rule__c();
        delRecord2.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "KR"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        delRecord2.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        delRecord2.Object_Name__c = 'EmailMessage';
        delRecord2.Email_MailBox__c = eMailBox.Id;
        delRecord.Active__c = true;
        delRecord.Name = 'First Test Email 2';
        insert delRecord2;
        
        Case c = new Case();
        //enter details
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'My Status';
        insert c;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.ParentId = c.Id;
        incomingMail .fromaddress= 'test@email.com';
        incomingMail .toAddress = 'test@testing.com';
        incomingMail .ccAddress = 'test2@testing.com';
        incomingMail .bccAddress = 'Test4@testing.com';
        incomingMail .subject = ' Test Message';
        incomingMail .TextBody= 'This is the message body ';
        incomingMail .incoming=true;
        insert incomingMail ;
        Set<Id> IdsSet = new  Set<Id>();
        List<EmailMessage> lEmails = new List<EmailMessage>();
        IdsSet.add(incomingMail.Id);
        RulesUtility.deleteFiltersQuery('EmailMessage',IdsSet,lEmails);
    }
    

    @isTest
    public static void validateBracketsInLogicTest(){
        Email_Mailbox__c eMailBox = new Email_Mailbox__c();
        eMailBox.Email__c = 'test@testing.com';
        eMailBox.Brand__c = 'ekh';
        insert eMailBox;
        
        Email_Rule__c rdr = new Email_Rule__c();
        rdr.Filters_Json__c = '[{"Column" : "FromAddress","Operator" : "equals","value" : "KRD@gmail.com"},{"Column" : "FromAddress","Operator" : "notEqual","value" : "abc@gmail.com"},{"Column" : "FromAddress","Operator" : "startsWith","value" : "KR"},{"Column" : "FromAddress","Operator" : "contains","value" : "bhar"}]';
        rdr.Rule_Logic__c = '(1 OR 2) AND (3 OR 4)'; 
        rdr.Object_Name__c = 'EmailMessage';
        rdr.Hard_Coded_Rules__c = 'FromAddress = \'KRD@gmail.com\'';
        rdr.Email_MailBox__c = eMailBox.Id;
        rdr.Active__c = true;
        rdr.Name = 'First Test Email 3';
        insert rdr;
        
        List<String> lstChars = rdr.Rule_Logic__c.split('');
        RulesUtility.validateBracketsInLogic(lstChars);
        
        List<RulesUtility.ReportFilterWrap> rfWrapList = RulesUtility.parse(rdr.Filters_Json__c);
        RulesUtility.validateNumbersInLogic(rdr.Rule_Logic__c, rfWrapList);
    }

    
}