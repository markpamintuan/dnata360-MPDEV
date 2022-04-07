@isTest
public class LiveChatTranscriptTriggerHandler_TEST {

	@isTest static void testcreateLiveChatMissed() {
		LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;
		LiveChatTranscript lct = new LiveChatTranscript();
        lct.Contact_First_Name__c = 'Contact FirsName';
        lct.Status = 'Missed';
        lct.LiveChatVisitorId = lcv.Id;
        lct.Contact_Last_Name__c = 'Contact LastName';
        lct.Contact_Email__c = 'testemail345454343@gmail.com';
        lct.Contact_Phone_Number__c = '9876456789';
        lct.Contact_Brand__c = 'dnata';
        insert lct;
	}
    
    @isTest static void testcreateCasednata() {
		LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;
		LiveChatTranscript lct1 = new LiveChatTranscript();
        lct1.Contact_First_Name__c = 'Contact FirsName';
        lct1.LiveChatVisitorId = lcv.Id;
        lct1.Contact_Last_Name__c = 'Contact LastName';
        lct1.Contact_Email__c = 'testemail345454343@gmail.com';
        lct1.Contact_Phone_Number__c = '9876456789';
        lct1.Contact_Brand__c = 'dnata';
        lct1.Live_Chat_Type__c = 'Existing Booking';
        insert lct1;
        LiveChatTranscript lct2 = new LiveChatTranscript();
        lct2.Contact_First_Name__c = 'Contact FirsName';
        lct2.LiveChatVisitorId = lcv.Id;
        lct2.Contact_Last_Name__c = 'Contact LastName';
        lct2.Contact_Email__c = 'testemail345454343@gmail.com';
        lct2.Contact_Phone_Number__c = '9876456789';
        lct2.Contact_Brand__c = 'dnata';
        lct2.Live_Chat_Type__c = 'General Enquiry';
        insert lct2;
        LiveChatTranscript lct3 = new LiveChatTranscript();
        lct3.Contact_First_Name__c = 'Contact FirsName';
        lct3.LiveChatVisitorId = lcv.Id;
        lct3.Contact_Last_Name__c = 'Contact LastName';
        lct3.Contact_Email__c = 'testemail345454343@gmail.com';
        lct3.Contact_Phone_Number__c = '9876456789';
        lct3.Contact_Brand__c = 'dnata';
        lct3.Live_Chat_Type__c = 'New Booking';
        insert lct3; 
        
	}
    
    @isTest static void testcreateCasetrp() {
        LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;
       
       	LiveChatTranscript lct2 = new LiveChatTranscript();
        lct2.Contact_First_Name__c = 'Contact FirsName';
        lct2.LiveChatVisitorId = lcv.Id;
        lct2.Contact_Last_Name__c = 'Contact LastName';
        lct2.Contact_Phone_Number__c = '9876456789';
        lct2.Contact_Email__c = 'testemail345454343@gmail.com';
        lct2.Contact_Brand__c = 'trp';
        insert lct2;
    }
	
      @isTest static void testupdateCasetrp() {
        LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;
       
       	LiveChatTranscript lct2 = new LiveChatTranscript();
        lct2.Contact_First_Name__c = 'Contact FirsName';
        lct2.LiveChatVisitorId = lcv.Id;
        lct2.Contact_Last_Name__c = 'Contact LastName';
        lct2.Contact_Phone_Number__c = '9876456789';
        lct2.Contact_Brand__c = 'trp';
        insert lct2;
          
        LiveChatTranscript lct3 = new LiveChatTranscript(Id =lct2.id);
        lct3.Contact_Email__c = 'test@trp2.com';
        update lct3;
    }

}