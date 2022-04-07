@isTest
private class ChangeAgentStoreCntrl_Test {
    static testMethod void fetchUserRole() {
        UserRole parentRole = new UserRole(DeveloperName = 'MyCustomRoleParent', Name = 'My Role Parent');
		insert parentRole;
        UserRole role = new UserRole(DeveloperName = 'MyLeadCustomRole', Name = 'My Lead Role', ParentRoleId = parentRole.Id);
		insert role;
        UserRole roleChild = new UserRole(DeveloperName = 'MyCustomChildRole', Name = 'My Child Role', ParentRoleId = role.Id);
		insert roleChild;
        
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'dTME - Retail Manager'].Id,
                          LastName = 'last',
                          Email = 'test@test.com',
                          Username = 'test@test.com' + System.currentTimeMillis(),
                          CompanyName = 'TEST',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US',
                          UserRoleId = parentRole.Id
                        );
        insert u;
        
        User uRole = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'dTME - Retail Agent'].Id,
                          LastName = 'last2',
                          Email = 'test2@test.com',
                          Username = 'test2@test.com' + System.currentTimeMillis(),
                          CompanyName = 'TEST2',
                          Title = 'title2',
                          Alias = 'alias2',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US',
                          UserRoleId = roleChild.Id
                        );
        insert uRole;
        
       /* User_Role_And_Store_Map__mdt userRoleMetaData = new User_Role_And_Store_Map__mdt();
        userRoleMetaData.Agent_Role_Name__c = 'My Child Role';
        userRoleMetaData.Lead_Role_Name__c = 'My Lead Role';
        userRoleMetaData.Store_Name__c = 'Test Store';
        
        insert userRoleMetaData;*/
        
        system.runAs(u){
            List<UserRole> userRoleList = ChangeAgentStoreCntrl.getUserRoleList();
            List<ChangeAgentStoreCntrl.UserLookupResultWrapper> userList = ChangeAgentStoreCntrl.fetchLookUpValues('last2');
            system.debug('userRoleList==>'+userRoleList);
            system.debug('userList==>'+userList);
            ChangeAgentStoreCntrl.updateUserRole(userList[0].rid,userRoleList[0].Id);
            ChangeAgentStoreCntrl.getUserRoleBySelectedUser(userList[0].rid);
        }
    }
}