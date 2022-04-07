@isTest
global class Reconciliation_HTTPResponse_Test implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Bookings":[{"BookingId": 18207307,"Version": 5185512327}],"NextPageId": 5185512327}');
        res.setStatusCode(200);
        return res;
    }
}