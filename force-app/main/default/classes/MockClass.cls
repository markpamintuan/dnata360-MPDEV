@isTest
global class MockClass implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        string endpoint =  request.getEndpoint();
        if(endpoint.contains('v1.0/messagedispatcher')){
          response.setBody(' {"batch":{"batchid":"692e938d-34cd-19e3-0172-11176c74d201","messageheaders":[{"uri":"http://api.esendex.com/v1.0/messageheaders/12de709a-f9c2-13cb-00ea-11176c74cb01","id":"12de709a-f9c2-13cb-00ea-11176c74cb01"}]},"errors":null}');
        }
        return response; 
    }
}