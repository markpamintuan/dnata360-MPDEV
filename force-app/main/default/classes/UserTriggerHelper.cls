/**************************************************************************************************
* Name               : UserTriggerHelper
* Description        : This is a helper class for user trigger     
* Created Date       : 01-April-2019                                                                 
* Created By         : Maruf Bagwan                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION      AUTHOR               DATE             COMMENTS                
* v1.0        Maruf Bagwan     01-April-2019      Initial version                                                                                                                             
**************************************************************************************************/
public class UserTriggerHelper {
    
    public static void updateUserStore(List<User> newUserList, Map<Id,User> oldUserMap, Boolean isInsert){
        Map<string,string> roleStoreMap = createUserRoleStoreMap();
        Set<Id> userRoleIdSet = new Set<Id>();
        for(user us:newUserList){
            userRoleIdSet.add(us.UserRoleId);
        }
        Map<Id,string> userRoleIdNameMap = createUserRoleMap(userRoleIdSet);
        for(user us:newUserList){
            if(isInsert){
                if(userRoleIdNameMap.containsKey(us.UserRoleId)){
                     string roleName = userRoleIdNameMap.get(us.UserRoleId);
                     us.Store__c = roleStoreMap.containsKey(roleName) ? roleStoreMap.get(roleName) : '';
                }
            } else if(oldUserMap != null && oldUserMap.containsKey(us.Id)){
                if((oldUserMap.get(us.Id).userRoleId != us.userRoleId) && us.userRoleId != null){
                    string roleName = userRoleIdNameMap.get(us.UserRoleId);
                    us.Store__c = roleStoreMap.containsKey(roleName) ? roleStoreMap.get(roleName) : roleName;
                }
            } else {
                 us.Store__c = us.UserRole.Name;
            }
        }
    }
    
     public static Map<string,string> createUserRoleStoreMap(){
        Map<String,String> userRoleMap = new Map<String,String>();
        List<User_Role_And_Store_Map__mdt> userRoleStoreList = new List<User_Role_And_Store_Map__mdt>([SELECT Id,Agent_Role_Name__c,Lead_Role_Name__c,Store_Name__c FROM User_Role_And_Store_Map__mdt]);
        for(User_Role_And_Store_Map__mdt userStore:userRoleStoreList){
            userRoleMap.put(userStore.Agent_Role_Name__c,userStore.Store_Name__c);
            userRoleMap.put(userStore.Lead_Role_Name__c,userStore.Store_Name__c);
        }
        return userRoleMap;
    }
    
    public static Map<Id,string> createUserRoleMap(Set<Id> userRoleIdSet){
        Map<Id,string> userRoleIdNameMap = new Map<Id,string>();
        List<UserRole> userRoleList = new List<UserRole>([SELECT Id,Name FROM UserRole WHERE Id IN:userRoleIdSet]);
        for(UserRole ur:userRoleList){
            userRoleIdNameMap.put(ur.Id,ur.Name);
            //userRoleIdNameMap.put(ur.Id,ur.Name);
        }
        return userRoleIdNameMap;
    }
}