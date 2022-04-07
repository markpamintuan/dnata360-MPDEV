@isTest
public class SurveyResponseTriggerHandler_TEST {

	static testMethod void testReparentResponses(){
		
		Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('marhaba - Customer').getRecordTypeId();
		list<Account> lstCustomers = new list<Account>();
		
		for(integer i = 0; i < 10; i++){
			Account customer = new Account(RecordtypeId = customerRecordtypeId,
										LastName = 'marhaba Customer' + i, 
										PersonEmail = 'marhaba'+ i +'customer@test.com',
										Org_Brand__c = 'marhaba',
										Survey_Group__pc = 'marhaba',
										Survey_Date__pc = system.today(),
										Booking_Reference__pc = '1234567' + i);
			lstCustomers.add(customer);		
		}

		insert lstCustomers;

		Entitlement entitlement = new Entitlement(Name = 'dnata Entitlement', AccountId = lstCustomers[0].Id);
		insert entitlement;

		list<Survey_Response__c> lstNewSR = new list<Survey_Response__c>();
		for(integer j = 0; j < 10; j++){
			Survey_Response__c sr = new Survey_Response__c();
			sr.Org_Account__c = lstCustomers[j].Id;
			sr.Survey_Name__c = 'marhaba B2C';
			sr.Survey_Group__c = 'marhaba';
			sr.Org_Survey_Model__c = 'CNPS';
			lstNewSR.add(sr);
		}
		
		test.startTest();
		
			insert lstNewSR;
		
		test.stopTest();
		//verify that Survey Sent records were created
		list<Survey_Sent__c> newSurveySent = [SELECT Id FROM Survey_Sent__c];
		system.assertEquals(newSurveySent.size(),1);
		
	}

	static testMethod void testPostChatSurvey(){
		//Insert Account
		String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('EKH B2C Customer - Detail').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='testlivechatcodepost123312@yahoo.com'
        );
        insert acc;

		LiveChatVisitor chatVisitor = new LiveChatVisitor();
		insert chatVisitor;

		//Create chat transcript
		LiveChatTranscript liveChat = new LiveChatTranscript();
		liveChat.LiveChatVisitorId = chatVisitor.Id;
		liveChat.AccountId = acc.Id;
		insert liveChat;
		
		string chatKey = [SELECT Id, ChatKey FROM LiveChatTranscript WHERE ID = :liveChat.Id].ChatKey;
		
		//Create survey response
		Survey_Response__c sr = new Survey_Response__c();
		sr.Chat_Key__c = chatKey;
		sr.Org_Survey_Model__c = 'CSAT';
		sr.Org_Rating__c = 2.0;
		sr.Brand__c = 'dnata';
		insert sr;

	}


}