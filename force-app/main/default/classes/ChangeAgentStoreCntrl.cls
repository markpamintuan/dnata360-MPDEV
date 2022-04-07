public without sharing class ChangeAgentStoreCntrl{
	
    public static set<User> UserSet = new Set<User>();
    public static set<UserRole> UserRoleSet = new Set<UserRole>();
    
    @AuraEnabled
    public static List<ChangeAgentStoreCntrl.UserLookupResultWrapper> fetchLookUpValues(String keyword){
        List<ChangeAgentStoreCntrl.UserLookupResultWrapper> userWrapperList = new List<ChangeAgentStoreCntrl.UserLookupResultWrapper>();
        List<user> userList = new List<user>();
        userList = getUserList();
        system.debug('keyword==>'+keyword);
        system.debug('UserSet==>'+userList);
        for(user u:userList){
            if(u.Name.containsIgnoreCase(keyword)){
                system.debug('keyword==>'+keyword);
                ChangeAgentStoreCntrl.UserLookupResultWrapper userWrapRec = new ChangeAgentStoreCntrl.UserLookupResultWrapper(u.Id, u.Name, u.Store__c);
                userWrapperList.add(userWrapRec);
                system.debug('userWrapperList==>'+userWrapperList);
            }
        }
        return userWrapperList;
    }
    
    public static List<User> getUserList(){
        List<UserRole> userRoleList = getUserRoleList();
        set<Id> userRoleIdSet = new set<Id>();
        for(UserRole ur:userRoleList){
           userRoleIdSet.add(ur.Id);
        }
        List<User> tempUserList = [Select u.Name,u.FirstName, u.Id, u.LastName, u.UserRoleId, u.UserRole.Name, u.Store__c from User u Where u.UserRoleId IN :userRoleIdSet];
   		return tempUserList;
    }
    
    @AuraEnabled
    public static List<UserRole> getUserRoleList(){
    	string userRoleId = UserInfo.getUserRoleId();
        set<Id> userRoleIdSet = new set<Id>();
        List<UserRole> UserRoleList = new List<UserRole>();
        if(userRoleId != null && userRoleId != ''){
            userRoleIdSet.add(userRoleId);
            UserRoleSet = createUserRoleList(userRoleIdSet);
            system.debug('UserRoleSet final=====>'+UserRoleSet);
        }
        UserRoleList.addAll(UserRoleSet);
        Integer i=1;
        for(UserRole ur:UserRoleList){
            system.debug('Role Name'+i+'=====>'+ur.Name); 
            i++;
        }
        return UserRoleList;
    }
    
    public static Set<UserRole> createUserRoleList(Set<Id> userRoleIdSet){
        if(userRoleIdSet.size() > 0){
            List<UserRole> tempUserRoleList = new List<UserRole>();
            Set<Id> tempUserRoleIdSet = new Set<Id>();
            tempUserRoleList = getUserRoleList(userRoleIdSet);
            UserRoleSet.addAll(tempUserRoleList);
            if(tempUserRoleList.size() > 0){
                for(UserRole ur: tempUserRoleList){
                    tempUserRoleIdSet.add(ur.Id);
                }
               UserRoleSet.addAll(createUserRoleList(tempUserRoleIdSet)); 
               system.debug('UserRoleSet in Loop=====>'+UserRoleSet);
            } else {
                return UserRoleSet;
            }
        } else {
            return UserRoleSet;
        }
        system.debug('UserRoleSet Returned=====>'+UserRoleSet);
        return UserRoleSet;
    }
    
    public static List<UserRole> getUserRoleList(Set<Id> userRoleIdSet){
        List<UserRole> tempUserList = [SELECT Id,Name,ParentRoleId FROM UserRole Where ParentRoleId IN :userRoleIdSet];
   		return tempUserList;
    }
    
    @AuraEnabled
    public static string updateUserRole(Id userId, Id roleId){
        String message = 'Record Successfully updated!!!';
        if(userId != null && roleId != null){
            try{
            User newUser = new User();
            newUser.Id = userId;
            newUser.UserRoleId = roleId; 
            update newUser;
                
            }catch(exception e){
                message = 'Update failed! please try again. If issue persist, please contact the administrator.';
            }
        } else {
           message = 'Please fill all the fields.'; 
        }
        system.debug('message===>'+message);
        return message;
    }
    
    @AuraEnabled
    public static List<ChangeAgentStoreCntrl.UserRoleWrapper> getUserRoleBySelectedUser(String userId){
        List<UserRole> TempUserRoleList = getUserRoleList();
        List<ChangeAgentStoreCntrl.UserRoleWrapper> userRoleList = new List<ChangeAgentStoreCntrl.UserRoleWrapper>();
        List<User> tempUserList = [Select u.Name,u.FirstName, u.Id, u.LastName, u.UserRoleId, u.UserRole.Name from User u Where Id =: userId];
        Map<String,String> roleStoreMap = createUserRoleMap();
        if(tempUserList != null && tempUserList.size() > 0){
            for(UserRole ur:TempUserRoleList){
                ChangeAgentStoreCntrl.UserRoleWrapper userRoleWrap = new ChangeAgentStoreCntrl.UserRoleWrapper();
                userRoleWrap.roleId = ur.Id;
                userRoleWrap.roleName = ur.Name;
                userRoleWrap.store = roleStoreMap.containsKey(ur.Name) ? roleStoreMap.get(ur.Name) : ur.Name;
                if(tempUserList[0].UserRole.Name.contains('Lead') && ur.Name.contains('Lead') && ur.Name != tempUserList[0].UserRole.Name){
                    userRoleList.add(userRoleWrap);
                } else if(!tempUserList[0].UserRole.Name.contains('Lead') && !ur.Name.contains('Lead') && ur.Name != tempUserList[0].UserRole.Name){
                    userRoleList.add(userRoleWrap);
                }
            }
        }
        return userRoleList;
    }
    
    public static Map<string,string> createUserRoleMap(){
        Map<String,String> userRoleMap = new Map<String,String>();
        List<User_Role_And_Store_Map__mdt> userRoleStoreList = new List<User_Role_And_Store_Map__mdt>([SELECT Id,Agent_Role_Name__c,Lead_Role_Name__c,Store_Name__c FROM User_Role_And_Store_Map__mdt]);
        for(User_Role_And_Store_Map__mdt userStore:userRoleStoreList){
            userRoleMap.put(userStore.Agent_Role_Name__c,userStore.Store_Name__c);
            userRoleMap.put(userStore.Lead_Role_Name__c,userStore.Store_Name__c);
        }
        return userRoleMap;
    }
    
     public class UserLookupResultWrapper{
        @AuraEnabled
        public string rid {get; set;}
        @AuraEnabled
        public string rname {get; set;}
        @AuraEnabled
        public string rrole {get; set;}
        
        public UserLookupResultWrapper(string rid, string rname,String rrole){
            this.rid = rid;
            this.rname = rname;
            this.rrole = rrole;
        }
    }
    
    public class UserRoleWrapper{
        @AuraEnabled
        public string roleId {get; set;}
        @AuraEnabled
        public string roleName {get; set;}
        @AuraEnabled
        public string store {get; set;}
        
        public UserRoleWrapper(){
            this.roleId = '';
            this.roleName = '';
            this.store = '';
        }
    }
}