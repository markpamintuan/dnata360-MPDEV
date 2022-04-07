/**************************************************************************************************
* Name               : AvayaCsatSurveyAPIEndpoints 
* Description        : This is the endpoint class for avaya survey   
* Created Date       : 30-Oct-2019                                                                 
* Created By         : Keith Rogers                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                DATE                      COMMENTS                
* v1.0        Keith Rogers          30-Oct-2019               Initial version
**************************************************************************************************/
@RestResource(urlMapping='/tasks/*')
global class AvayaCsatSurveyAPIEndpoints {
    
    @HttpPost
    global static AvayaCsatDataStructure.SurveyResponse doPost(){
        RestRequest request = RestContext.request;
        String requestbody = request.requestBody.toString(); 

        AvayaCsatDataStructure.CsatParams surveyBodyRequest
            = (AvayaCsatDataStructure.CsatParams)JSON.deserialize(requestbody, AvayaCsatDataStructure.CsatParams.class);
        
        String callobjectIdentifier = '';
        callobjectIdentifier = surveyBodyRequest.CSAT_Survey_UCID;
        

        if(callobjectIdentifier.length()>0){
            Task tsk = new Task();
            tsk.CSAT_Survey_UCID__c = surveyBodyRequest.CSAT_Survey_UCID;
            tsk.CSAT_Survey_Name__c = surveyBodyRequest.CSAT_Survey_Name;
            tsk.CSAT_Survey_VDN__c = surveyBodyRequest.CSAT_Survey_VDN;
            tsk.CSAT_AgentId__c = surveyBodyRequest.CSAT_AgentId;
            tsk.CSAT_Survey_Created_Date__c = Date.valueOf(surveyBodyRequest.CSAT_Survey_Created_Date);
            tsk.CSAT_Survey_Raw_Score__c = Decimal.valueOf(surveyBodyRequest.CSAT_Survey_Raw_Score);
            system.debug('******** Task: ' + tsk);
            try{
                upsert tsk Task.Fields.CSAT_Survey_UCID__c; 
            }catch(Exception e){
                system.debug('******** Exception Message: ' + e.getMessage());
                return new AvayaCsatDataStructure.SurveyResponse('false',String.valueOf(e));
                
            }
        }
        return new AvayaCsatDataStructure.SurveyResponse('true','Successfully updated');
    }
    
}