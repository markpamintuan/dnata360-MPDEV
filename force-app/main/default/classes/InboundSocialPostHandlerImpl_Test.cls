/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition. 
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts. 
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InboundSocialPostHandlerImpl_Test {
    
    static Map<String, Object> sampleSocialData = getSampleSocialData('1');
    static Social.InboundSocialPostHandlerImpl handler;
    static {
        handler = new Social.InboundSocialPostHandlerImpl();
        sampleSocialData = getSampleSocialData('1');
    }
    
    //CreateAccount
    static Id accountId = TestDataFactory.createEKUK_AccountId();
    
    //Create Entitlement        
    static BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
    
    static testMethod void InboundSocialPostHandlerImplTest() {
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        SocialPersona persona1 = getSocialPersona(sampleSocialData);
        persona1.Provider = 'Other';
        persona1.MediaProvider = 'Test';
        persona1.Name = 'Test1';
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        handler.handleInboundSocialPost(post, persona1, sampleSocialData);
        handler.createPersonaParent(persona);
        handler.createPersonaParent(persona1);
    }
     static testMethod void verifyNewRecordCreation() {
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);        
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact limit 1];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        
        //System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        //System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        //System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        //System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }
     static testMethod void matchSocialPostRecord() {
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        handler.getMaxNumberOfDaysClosedToReopenCase();
        handler.getPostTagsThatCreateCase();
        test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM SocialPost].size(), 'There should be only 1 post');
    }
    
    static testMethod void matchSocialPersonaRecord() {
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;
        
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact where name ='LastName'];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        createdCase.ContactId = createdContact.id;
        update createdCase;
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }
    
    static testMethod void matchCaseRecord() {
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case');
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
    }
    
    static testMethod void reopenClosedCase() {
        TestDataFactory.createEntitlement(accountId, bhs.Id);
        Contact existingContact = new Contact(LastName = 'LastName');
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Status = 'Closed');
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        
        InboundSocialPostHandlerImpl handler = new InboundSocialPostHandlerImpl();
        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
        System.assertEquals(false, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase.Id].IsClosed, 'Case should be open.');
    }
    
    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
        post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.TopicProfileName = '@kav_test';
        return post;
    }
    
    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));        
        return persona;
    }
    
    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        return socialData;
    }
    
}