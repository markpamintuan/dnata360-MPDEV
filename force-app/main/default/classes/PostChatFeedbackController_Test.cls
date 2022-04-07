@isTest
public class PostChatFeedbackController_Test {
    static testmethod void PostChatFeedbackController(){
        
        Id accountidtest = TestDataFactory.createEKUK_AccountId();
        BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
        
		TestDataFactory.createEntitlement(accountidtest, bhs.Id);
        TestDataFactory.createCaseEKH(accountidtest);
        
        Case testcase = [select id from case where accountid = :accountidtest];
        Livechatvisitor testvisitor = new Livechatvisitor();
        insert testvisitor;
        
        LiveChatTranscript testTranscript = new LiveChatTranscript(livechatvisitorid = testvisitor.id);
        insert testTranscript;
        
        Apexpages.currentPage().getParameters().put('chatKey',testTranscript.chatkey);
        PostChatFeedbackController test = new PostChatFeedbackController();
        test.redirecttosurvey();
        
    }
}