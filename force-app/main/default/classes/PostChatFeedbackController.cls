public class PostChatFeedbackController{
    public string liveChatTranscriptId = '';
    public string caseId = '';
    public string accountId = '';
    public string contactId = '';
    public PostChatFeedbackController(){
        system.debug(ApexPages.currentPage().getParameters().get('buttonId'));
        system.debug(ApexPages.currentPage().getParameters().get('chatKey'));
        system.debug(ApexPages.currentPage().getParameters().get('attachedRecords'));
        string chatKey = ApexPages.currentPage().getParameters().get('chatKey');

        
        for(LiveChatTranscript lct : [SELECT Id, Name, ChatKey, CaseId, Case.AccountId, Case.ContactId FROM LiveChatTranscript WHERE ChatKey =:chatKey LIMIT 1]){
            liveChatTranscriptId = lct.Id;
            caseId = lct.CaseId;
            accountId = lct.Case.AccountId;
            contactId = lct.Case.ContactId;
        }
            
    }
    public PageReference redirectToSurvey(){
        PageReference pg = new PageReference('https://dnata.getfeedback.com/r/5Zcp1h7B?AccountID='+accountId+'&ContactID='+contactId+'&TranscriptID='+liveChatTranscriptId);
        system.debug(pg);
        pg.setRedirect(true);
        return pg;
    }
}