@isTest
global class AsyncDerwentWebServiceMockAirline implements HttpCalloutMock {     
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"Carriers": [{"Name": "Test","Code": "ABC"},{"Name": "Test2","Code": "DEF"}]}');  
        res.setStatusCode(200);
        return res;
    }            
}