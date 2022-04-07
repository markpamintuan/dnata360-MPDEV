@isTest
global class DerwentChangeDetectorApiMockCalloutTest implements HttpCalloutMock {
    

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        // 
        String body = req.getBody();
        System.debug('body' + body);
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        String customerresponse='{\r\n\"Csrs\": [\r\n{\r\n\"CsrId\": 32751,\r\n\"BookingId\":666666,\r\n\"CategoryId\": 42,\r\n\"Subject\": \"string\",\r\n\"IsPublic\": true,\r\n\"Text\": \"string\",\r\n\"TextAlerts\": true,\r\n\"Status\": 1,\r\n\"CreatedDate\": \"2018-05-25T16:43:55.669\",\r\n\"Questions\": [\r\n{\r\n\"Id\": 0,\r\n\"CsrId\": 32751,\r\n\"QuestionText\": \"string\",\r\n\"Answer\": \"string\",\r\n\"QuestionDate\": \"2018-05-25T16:43:55.669Z\",\r\n\"AnswerDate\": \"2018-05-25T16:43:55.669Z\"\r\n}\r\n],\r\n\"Logs\": [\r\n{\r\n\"LogId\": 0,\r\n\"CsrId\": 32751,\r\n\"Subject\": \"string\",\r\n\"Text\": \"string\",\r\n\"CreatedDate\": \"2018-05-25T16:43:55.669Z\",\r\n\"CreatedByCustomer\": true,\r\n\"SystemGenerated\": false,\r\n\"IsPublic\": true,\r\n\"AgentName\": \"string\"\r\n}\r\n],\r\n\"AgentName\": \"string\",\r\n\"TrackingTag\": \"string\"\r\n},\r\n{\r\n\"LogId\": 0,\r\n\"CsrId\": 32751,\r\n\"Subject\": \"string\",\r\n\"Text\": \"string\",\r\n\"CreatedDate\": \"2018-05-25T16:43:55.669Z\",\r\n\"CreatedByCustomer\": true,\r\n\"SystemGenerated\": true,\r\n\"IsPublic\": false,\r\n\"AgentName\": \"string\"\r\n}\r\n],\r\n\"AgentName\": \"string\",\r\n\"TrackingTag\": \"string\"\r\n}\r\n],\r\n\"NotFoundCsrs\": [\r\n1588333\r\n]\r\n}';
        res.setBody(customerresponse); 
        res.setStatusCode(200);
        return res;
    }
    
        
}