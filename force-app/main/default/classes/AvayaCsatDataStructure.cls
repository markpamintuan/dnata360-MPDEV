global class AvayaCsatDataStructure {

    global class CsatParams{
        global String CSAT_Survey_UCID;
        global String CSAT_Survey_Name; 
        global String CSAT_Survey_VDN;
        global String CSAT_AgentId;
        global Date CSAT_Survey_Created_Date;
        global String CSAT_Survey_Raw_Score;

    }

    global class SurveyResponse{
        global String Success;
		global String Message;        
        
        global SurveyResponse(String Success,String Message){
            this.Success = Success;
            this.Message = Message;
        }
    }
}