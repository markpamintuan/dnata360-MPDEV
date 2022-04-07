@isTest(SeeAllData=true)
public with sharing class MessagingEndUserTriggerHelper_Test {

    static testMethod void simulateAccountLinked() {
        MessagingChannel msChannel = new MessagingChannel(); //See all data = true for this
        msChannel = [SELECT Id FROM MessagingChannel limit 1];
        
        Account acc= new Account(lastname='test_AccountTriggerHelper',Org_Derwent_Customer_No__c='99988213',Website='www.test.test',PersonEmail='tesdummmydmmyydmyyydmmyyt@test.com',PersonMobilePhone='0123543554354567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;

        MessagingEndUser enduser = new MessagingEndUser();
        endUser.MessageType = 'Facebook';
        endUser.Name = 'Dsbt Sundari';
        endUser.MessagingChannelId = msChannel.Id; //This may need to be a real channel Id custom label
        endUser.MessagingPlatformKey = '2762939957167472';
        insert enduser;

        MessagingSession msgSession = new MessagingSession();
        msgSession.MessagingEndUserId = enduser.Id;
        msgSession.Origin = 'InboundInitiated';
        msgSession.status= 'Active';
        msgSession.MessagingChannelId =msChannel.Id;
        insert msgSession;

        msgSession.ChannelLocale = 'dummy update';
        update msgSession; 

    /* Old code
        Contact con = new Contact();
        con = [SELECT Id FROM Contact WHERE AccountID = :acc.Id limit 1];
        endUser.ContactId = con.Id;
        update endUser; 
   */
   
   
        endUser.AccountId = acc.Id;
        update endUser; 

        

    }
}