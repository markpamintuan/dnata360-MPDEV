@isTest
private class CSR_ResponseNew_Test {

    static testMethod void CSR_ResponseNew_method() {
    CSR_Response.Csrs csr = new CSR_Response.Csrs();
    csr.CategoryId =0;
    csr.Subject ='';
    csr.Text ='';
    csr.Questions = new  List<CSR_Response.cls_Questions>();
    csr.Logs = new List<CSR_Response.cls_Notes>();
    csr.Status=0;
    csr.CreatedDate='';
    csr.AgentName ='';
    csr.TrackingTag ='';
    csr.OwnedBy='';
    csr.Version='';
    csr.CsrId=0;
    csr.BookingId=0;
    csr.CategoryText='';
    csr.TextAlerts=false;
    csr.isPublic=false;
    csr.OwnedById=0;
    csr.NextActionDate=null;
    csr.CreatedById=0;
    
    CSR_Response.cls_Questions clq= new CSR_Response.cls_Questions();
    clq.Id =0;
    clq.QuestionText ='';
    clq.CsrId =0;
    clq.Answer ='';
    clq.QuestionDate ='';
    clq.AnswerDate ='';
    clq.AgentName='';
    clq.CreatedById=0;
    
    CSR_Response.cls_Notes clNotes = new CSR_Response.cls_Notes();
    clNotes.CsrId =0;
    clNotes.LogId =0;
    clNotes.CreatedByCustomer =false;
    clNotes.AgentName ='';
    clNotes.CreatedDate ='';
    clNotes.Text ='';
    clNotes.Subject ='';
    clNotes.CreatedById=0;
    
    }
    
}