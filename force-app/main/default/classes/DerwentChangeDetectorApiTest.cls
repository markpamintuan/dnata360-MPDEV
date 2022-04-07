@isTest
public class DerwentChangeDetectorApiTest {

    @isTest
    static void CustomerTest(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());

        String CustomerRequest = '{\r\n\"Entity\":\"Customer\",\r\n\"EntityId\":\"2131313131\"\r\n}';
        RestRequest restreq = new RestRequest();
        restreq.requestURI = '/services/apexrest/derwent-change-detector';
        restreq.httpmethod = 'POST';
        restreq.requestBody = Blob.valueOf(CustomerRequest);        
        Test.startTest();
        Restcontext.request = restreq;
        derwentchangedetectorapi.doCallout();
		derwentchangedetectorapi.getCreatableFieldsSOQL('Account');        
        Test.stopTest();
    }
    
    @isTest
    static void BookingTest(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        
        String BookingRequest = '{\r\n\"Entity\":\"Booking\",\r\n\"EntityId\":\"1138764\"\r\n}';
        RestRequest restreq = new RestRequest();
        restreq.requestURI = '/services/apexrest/derwent-change-detector';
        restreq.httpmethod = 'POST';
        restreq.requestBody = Blob.valueOf(BookingRequest);       
        Test.startTest();
        Restcontext.request = restreq;
        derwentchangedetectorapi.doCallout();
        derwentchangedetectorapi.getCreatableFieldsSOQL('Account');
        Test.stopTest();
    }
    
    @isTest
    static void QuoteTest(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        
        String QuoteRequest = '{\r\n\"Entity\":\"Quote\",\r\n\"EntityId\":\"213131313123\"\r\n}';
        RestRequest restreq = new RestRequest();
        restreq.requestURI = '/services/apexrest/derwent-change-detector';
        restreq.httpmethod = 'POST';
        restreq.requestBody = Blob.valueOf(QuoteRequest);
        
        Test.startTest();
        Restcontext.request = restreq;
        derwentchangedetectorapi.doCallout();
        derwentchangedetectorapi.getCreatableFieldsSOQL('Account');
        Test.stopTest();
    }
    
    @isTest
    static void CSRTest(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());        
        String QuoteRequest = '{\r\n\"Entity\":\"Csr\",\r\n\"EntityId\":\"1113333\"\r\n}';
        RestRequest restreq = new RestRequest();
        restreq.requestURI = '/services/apexrest/derwent-change-detector';
        restreq.httpmethod = 'POST';
        restreq.requestBody = Blob.valueOf(QuoteRequest);
        
        Test.startTest();
        Restcontext.request = restreq;
        derwentchangedetectorapi.doCallout();
        derwentchangedetectorapi.getCreatableFieldsSOQL('Account');
        Test.stopTest();
    }
    
    @isTest
    static void AgencyTest(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());

        String AgencyRequest = '{\r\n\"Entity\":\"Agency\",\r\n\"EntityId\":\"2131313131\"\r\n}';
        RestRequest restreq = new RestRequest();
        restreq.requestURI = '/services/apexrest/derwent-change-detector';
        restreq.httpmethod = 'POST';
        restreq.requestBody = Blob.valueOf(AgencyRequest);
        
        Test.startTest();
        Restcontext.request = restreq;
        derwentchangedetectorapi.doCallout(); 
        derwentchangedetectorapi.getCreatableFieldsSOQL('Account');
        Test.stopTest();
    }

    @isTest
    static void CustomerException(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        
        Test.startTest();
        
			for(integer i = 0; i < 50; i++){
		        String CustomerRequest = '{\r\n\"Entity\":\"Customer\",\r\n\"EntityId\":\"2131313131'+i+'\"\r\n}';
		        RestRequest restreq = new RestRequest();
		        restreq.requestURI = '/services/apexrest/derwent-change-detector';
		        restreq.httpmethod = 'POST';
		        restreq.requestBody = Blob.valueOf(CustomerRequest);        

		        Restcontext.request = restreq;
			    derwentchangedetectorapi.doCallout();
				derwentchangedetectorapi.getCreatableFieldsSOQL('Account');        
			}
			
		Test.stopTest();

    }
	
    @isTest
    static void BookingException(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        
        Test.startTest();
        
			for(integer i = 0; i < 50; i++){
		        String CustomerRequest = '{\r\n\"Entity\":\"Booking\",\r\n\"EntityId\":\"2131313131'+i+'\"\r\n}';
		        RestRequest restreq = new RestRequest();
		        restreq.requestURI = '/services/apexrest/derwent-change-detector';
		        restreq.httpmethod = 'POST';
		        restreq.requestBody = Blob.valueOf(CustomerRequest);        

		        Restcontext.request = restreq;
			    derwentchangedetectorapi.doCallout();
				derwentchangedetectorapi.getCreatableFieldsSOQL('Account');        
			}
			
		Test.stopTest();

    }
	
    @isTest
    static void testException(){
        
        Test.setMock(HttpCalloutMock.class, new DerwentChangeDetectorApiMockCalloutTest());
        
        Test.startTest();
        
			for(integer i = 0; i < 50; i++){
		        String CustomerRequest = '{\r\n\"Entity\":\"Case\",\r\n\"EntityId\":\"\"\r\n}';
		        RestRequest restreq = new RestRequest();
		        restreq.requestURI = '/services/apexrest/derwent-change-detector';
		        restreq.httpmethod = 'POST';
		        restreq.requestBody = Blob.valueOf(CustomerRequest);        

		        Restcontext.request = restreq;
			    derwentchangedetectorapi.doCallout();
				derwentchangedetectorapi.getCreatableFieldsSOQL('Account');        
			}
			
		Test.stopTest();

    }
    
}