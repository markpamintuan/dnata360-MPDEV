@isTest
public class AvayaCsatSurveyAPIEndpointsTest {

	static testMethod void testSurveyPost() {

        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        AvayaCsatDataStructure.CsatParams postBodyJSON = new AvayaCsatDataStructure.CsatParams();
        postBodyJSON.CSAT_Survey_UCID = '1234567';
        postBodyJSON.CSAT_Survey_Name = 'Sampel survey name';
        postBodyJSON.CSAT_Survey_VDN = 'VDN';
        postBodyJSON.CSAT_AgentId = '12';
        postBodyJSON.CSAT_Survey_Created_Date = Date.valueOf('2016-10-30');
        postBodyJSON.CSAT_Survey_Raw_Score = '4';

        String JsonMsg=JSON.serialize(postBodyJSON);
        
        req.requestURI = '/services/apexrest/tasks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res; 

        AvayaCsatSurveyAPIEndpoints.doPost();

    }
}