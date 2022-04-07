/**
 * @author: Mark Anthony Pamintuan
 * @date: 29 December 2019
 * @description: Test class of SFSupportPageController             
 */
@isTest
private class SFSupportPageController_Test{

    static testMethod void testCreateCaseSuccess(){
		ss_Sprint__c sp = new ss_Sprint__c();
		sp.Name = 'To be Planned';
		insert sp;
        PageReference pageRef = Page.SFSupportPage;
        //pageRef.getParameters().put('type','changerequest');
        Test.setCurrentPage(pageRef);
        
        SFSupportPageController ctrl = new SFSupportPageController();

        test.startTest();
        	ctrl.attachment.Name = '';
        	ctrl.caseRecord.ss_Requestor_Full_Name__c = 'Test Testdata';
        	ctrl.caseRecord.SuppliedEmail = 'test@testdata.com';
        	ctrl.createCase();
        test.stopTest();
        
        //verify that case was created
        system.assertNotEquals(ctrl.caseRecord.Id, null);  
        
    }

    static testMethod void testCreateCaseException(){
		ss_Sprint__c sp = new ss_Sprint__c();
		sp.Name = 'To be Planned';
		insert sp;
        PageReference pageRef = Page.SFSupportPage;
        Test.setCurrentPage(pageRef);
        
        SFSupportPageController ctrl = new SFSupportPageController();

        test.startTest();
        	ctrl.caseRecord.ss_Requestor_Full_Name__c = 'Test Testdata';
        	ctrl.createCase();
        test.stopTest();
        
        //verify that exception was thrown
        system.assertNotEquals(String.valueof(ApexPages.getMessages()[0]), '');
        
    }    

    static testMethod void testCreateCaseSuccess2(){
		ss_Sprint__c sp = new ss_Sprint__c();
		sp.Name = 'To be Planned';
		insert sp;
        PageReference pageRef = Page.SFSupportPage;
        pageRef.getParameters().put('type','changerequest');
        Test.setCurrentPage(pageRef);
        
        SFSupportPageController ctrl = new SFSupportPageController();

        test.startTest();
        	ctrl.attachment.Name = '';
        	ctrl.caseRecord.ss_Requestor_Full_Name__c = 'Testdata';
        	ctrl.caseRecord.SuppliedEmail = 'test@testdata.com';
        	ctrl.createCase();
        test.stopTest();
        
        //verify that case was created
        system.assertNotEquals(ctrl.caseRecord.Id, null);  
        
    }

    static testMethod void testCreateCaseSuccess3(){
        ss_Sprint__c sp = new ss_Sprint__c();
		sp.Name = 'To be Planned';
		insert sp;
		Account pAccount = new Account(FirstName = 'Test', LastName = 'Testdata', PersonEmail = 'test@testdata.com',isYammerAccount__c = true, RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SF Support').getRecordTypeId());
        insert pAccount;
        
        PageReference pageRef = Page.SFSupportPage;
        pageRef.getParameters().put('type','changerequest');
        Test.setCurrentPage(pageRef);
        
        SFSupportPageController ctrl = new SFSupportPageController();
		ctrl.userObjStr = '{"type":"user","id":1687004064,"network_id":2256624,"state":"active","guid":null,"job_title":"SENIOR SOFTWARE ENGINEER","location":null,"interests":"","summary":"","expertise":"","full_name":"Christian Jed Canlas","activated_at":"2018/10/31 08:26:34 +0000","auto_activated":false,"show_ask_for_photo":false,"first_name":"Christian Jed","last_name":"Canlas","network_name":"dnata Travel Global","network_domains":[],"url":"https://www.yammer.com/api/v1/users/1687004064","web_url":"https://www.yammer.com/dnatatravelglobal/users/1687004064","name":"christianjedcanlas","mugshot_url":"https://mug0.assets-yammer.com/mugshot/images/48x48/8f4j78-2gldt4pf-BkwVWmGRDJkZBMSn","mugshot_url_template":"https://mug0.assets-yammer.com/mugshot/images/{width}x{height}/8f4j78-2gldt4pf-BkwVWmGRDJkZBMSn","birth_date":"","birth_date_complete":"","timezone":"Abu Dhabi","external_urls":[],"admin":"false","verified_admin":"false","supervisor_admin":"false","o365_tenant_admin":"false","can_broadcast":"false","department":"D38-NETWORK PLANNING & PROJECTS","email":"christianjed.canlas@dnata.com","guest":false,"aad_guest":false,"can_create_new_network":false,"can_browse_external_networks":true,"significant_other":"","kids_names":"","previous_companies":[],"schools":[],"contact":{"im":{"provider":"","username":""},"phone_numbers":[],"email_addresses":[{"type":"other","address":"christianjedcanlas+dnatatravelglobal@users.yammer.com"}],"has_fake_email":false},"stats":{"following":1,"followers":1,"updates":0},"settings":{"xdr_proxy":""},"canonical_network_name":"Emirates Group","web_preferences":{"absolute_timestamps":false,"network_settings":{"message_prompt":"What are you working on?","allow_attachments":"true","attachment_types_allowed":"ALL","show_communities_directory":false,"allow_yammer_apps":true,"enable_groups":true,"admin_can_delete_messages":"true","allow_inline_document_view":true,"enable_private_messages":true,"allow_external_sharing":true,"enable_chat":true},"enter_does_not_submit_message":"true","preferred_my_feed":"algo","prescribed_my_feed":"algo","sticky_my_feed":false,"prefer_modern_client":null,"enable_chat":"true","dismissed_feed_tooltip":false,"dismissed_group_tooltip":false,"dismissed_profile_prompt":false,"dismissed_invite_tooltip":false,"dismissed_apps_tooltip":false,"dismissed_invite_tooltip_at":null,"dismissed_browser_lifecycle_banner":null,"make_yammer_homepage":true,"locale":"en-US","has_yammer_now":false,"has_mobile_client":false,"user_preferred_locale":"en-US"},"follow_general_messages":false,"group_memberships":[{"type":"group","id":12096708608,"email":"salesforceforum+dnatatravelglobal@yammer.com","full_name":"Salesforce Forum","network_id":2256624,"name":"salesforceforum","description":"","privacy":"private","url":"https://www.yammer.com/api/v1/groups/12096708608","web_url":"https://www.yammer.com/dnatatravelglobal/#/threads/inGroup?type=in_group&feedId=12096708608","mugshot_url":"https://mug0.assets-yammer.com/mugshot/images/48x48/1gRQx0ntFXdkgfNHjSJH5TKRCF2Zl49r","mugshot_url_template":"https://mug0.assets-yammer.com/mugshot/images/{width}x{height}/1gRQx0ntFXdkgfNHjSJH5TKRCF2Zl49r","mugshot_id":"1gRQx0ntFXdkgfNHjSJH5TKRCF2Zl49r","show_in_directory":"true","created_at":"2019/11/14 05:53:01 +0000","members":6,"color":"#377CA1","external":false,"moderated":true,"header_image_url":"https://mug0.assets-yammer.com/mugshot/images/group-header-megaphone.png","category":"unclassified","default_thread_starter_type":"normal","restricted_posting":false,"company_group":false,"admin":true,"member":true,"pending":false,"can_add_members":true,"can_invite":true},{"type":"group","id":6862125,"email":"globaloperations-clark+dnatatravelglobal@yammer.com","full_name":"Global Operations - Clark","network_id":2256624,"name":"globaloperations-clark","description":"Use this group to communicate with everyone in the Clark Customer Care Centre","privacy":"private","url":"https://www.yammer.com/api/v1/groups/6862125","web_url":"https://www.yammer.com/dnatatravelglobal/#/threads/inGroup?type=in_group&feedId=6862125","mugshot_url":"https://mug0.assets-yammer.com/mugshot/images/48x48/r9SpZnpVXHgG9XndgwtTzKw9wDlzvHbc","mugshot_url_template":"https://mug0.assets-yammer.com/mugshot/images/{width}x{height}/r9SpZnpVXHgG9XndgwtTzKw9wDlzvHbc","mugshot_id":"r9SpZnpVXHgG9XndgwtTzKw9wDlzvHbc","show_in_directory":"true","created_at":"2015/12/14 11:01:20 +0000","members":830,"color":"#ab51b8","external":false,"moderated":true,"header_image_url":"https://mug0.assets-yammer.com/mugshot/images/group-header-coffee.png","category":"team","default_thread_starter_type":"normal","restricted_posting":false,"company_group":false,"admin":false,"member":true,"pending":false,"can_add_members":false,"can_invite":false}],"pending_group_memberships":[],"invited_group_memberships":[],"show_invite_lightbox":false,"age_bucket":"notRequired"}';
        ctrl.userId = '1687004064';
        test.startTest();
        ctrl.validateUser();
        	ctrl.attachment.Name = '';
        	ctrl.caseRecord.ss_Requestor_Full_Name__c = 'Test Testdata';
        	ctrl.caseRecord.SuppliedEmail = 'test@testdata.com';
        	ctrl.createCase();
        test.stopTest();
        
        //verify that case was created
        system.assertNotEquals(ctrl.caseRecord.Id, null);  
        
    }
    
}