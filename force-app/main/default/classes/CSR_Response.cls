/**************************************************************************************************
* Name               : CSR_Response 
* Description        : This is the class generated for the json response for getting CSRs          
* Created Date       : 02-Jun-2018                                                                 
* Created By         : PwC - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR      DATE            COMMENTS                                                             
* v1.0        Kaavya      08-Aug-2018     Initial version
* v1.1        Kaavya      09-Dec-2018     T-00263- Category Text in the CSR Response   
* v1.2 -- TR changes
* v1.3        Kaavya      10-Oct-2019     T-00691 - Allocated To,Version No in the CSR Response                                                      
**************************************************************************************************/
public class CSR_Response {

    public class Csrs {
        public Integer CsrId{get;set;}
        public Integer BookingId{get;set;}
        public Integer CategoryId{get;set;}
        public String CategoryText{get;set;} //Added as part of v1.1
        public String Subject{get;set;}
        public String Text{get;set;}
        public Boolean TextAlerts{get;set;}
        public Integer Status{get;set;}
        public String  CreatedDate{get;set;}
        public List<cls_Questions> Questions;
        public List<cls_Notes> Logs;
        public String AgentName{get;set;}
        public String TrackingTag{get;set;}
        public Boolean isPublic{get;set;}  // added by SB for TR
        public Integer OwnedById{get;set;}//added by SB for TRP
        public DateTime NextActionDate{get;set;}//added by SB for TRP
        public Integer CreatedById{get;set;}//added by SB for TRP
        public String OwnedBy{get;set;} //Added as part of v1.3
        public String Version{get;set;} //Added as part of v1.3
    }

    public class cls_Questions {
        public Integer CsrId{get;set;}
        public String QuestionText{get;set;}
        public String Answer{get;set;}
        public String QuestionDate{get;set;}
        public String AnswerDate{get;set;}
        public Integer Id{get;set;}
        public String AgentName{get;set;} // added by SB for TR
        public Integer CreatedById{get;set;}//added by SB for TRP
    }

    public class cls_Notes {
        public Integer CsrId{get;set;}
        public String Subject{get;set;}
        public String Text{get;set;}
        public String CreatedDate{get;set;}
        public Boolean CreatedByCustomer{get;set;}
        public Boolean isPublic{get;set;}
        public String AgentName{get;set;}
        public Integer LogId{get;set;}
        public Boolean SystemGenerated{get;set;}
        public Integer CreatedById{get;set;}//added by SB for TRP
        
    }
   

    public List<Csrs> Csrs;
    public List<Integer> NotFoundCsrs;

    
    public static CSR_Response parse(String json) {
        return (CSR_Response) System.JSON.deserialize(json, CSR_Response.class);
    }
}