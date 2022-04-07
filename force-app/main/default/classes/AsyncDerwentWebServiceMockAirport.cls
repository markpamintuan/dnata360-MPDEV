@isTest
global class AsyncDerwentWebServiceMockAirport implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"Stations": [{"Title": "108 Mile Ranch","Code": "ZMH","CountryCode": "CA","Latitude": 51.4444,"Longitude": -121.2021,"ShortTitle": "108 Mile Ranch"},{"Title": "Aachen (Merzbrueck)","Code": "AAH","CountryCode": "DE","Latitude": 50.4923,"Longitude": 6.1111,"ShortTitle": "Merzbrueck"}]}'); 
        res.setStatusCode(200);
        return res;
    }     
}