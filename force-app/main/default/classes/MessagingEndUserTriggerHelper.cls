public with sharing class MessagingEndUserTriggerHelper {
    
    
    public static void updateAccount(List<MessagingEndUser> newMessagingEndUser, Map<Id,MessagingEndUser> messagingEndUserOldMap, Map<Id,MessagingEndUser> messagingEndUserNewMap){
       //if account added, update contact id
       
       for(MessagingEndUser mesEndUser: newMessagingEndUser){
            if(mesEndUser.AccountId == null){
                mesEndUser.ContactId= null; 
                continue;
            } 
            if(mesEndUser.AccountId != messagingEndUserOldMap.get(mesEndUser.Id).AccountId){
                if(mesEndUser.AccountId== null){
                    mesEndUser.ContactId = null;
                }else{
                   mesEndUser.ContactId = mesEndUser.Person_Contact_Id__c;
                }
            }
        }
        
        /* Original code
        for(MessagingEndUser mesEndUser: newMessagingEndUser){
            if(mesEndUser.ContactId == null){
                mesEndUser.AccountId = null; 
                continue;
            } 
            if(mesEndUser.ContactId != messagingEndUserOldMap.get(mesEndUser.Id).ContactId){
                if(mesEndUser.ContactId == null){
                    mesEndUser.AccountId = null;
                }else{
                    mesEndUser.AccountId = mesEndUser.AccountId_On_Contact__c;
                }
            }
        }
        */
    }

    //When the user first links a contact to the messaging user, it will be required to update any of the message session cases that
    //do not have a contact id
    public static void updateCases(List<MessagingEndUser> newMessagingEndUser, Map<Id,MessagingEndUser> messagingEndUserOldMap, Map<Id,MessagingEndUser> messagingEndUserNewMap){
        List<Case> lCasesToPopulateContactAccountId = new List<Case>();
        List<Id> lMessagingEndUserIds = new List<Id>();
        
        for(MessagingEndUser mesEndUser: newMessagingEndUser){
            if(mesEndUser.ContactId != null && messagingEndUserOldMap.get(mesEndUser.Id).ContactId ==null){
                lMessagingEndUserIds.add(mesEndUser.Id);
            }
        }

        Map<ID, MessagingSession> sessionWithMessageUser = new Map<ID, MessagingSession>([  SELECT   Id, 
                                                                                                MessagingEndUser.AccountId,
                                                                                                MessagingEndUser.ContactId 
                                                                                            FROM MessagingSession 
                                                                                            WHERE MessagingEndUserId IN :lMessagingEndUserIds]);
        system.debug('£££££ sessionWithMessageUser: ' + sessionWithMessageUser);


        lCasesToPopulateContactAccountId =[ SELECT  Id, 
                                                    SourceId, 
                                                    AccountId, 
                                                    ContactId 
                                            FROM CASE 
                                            WHERE SourceId IN   (   SELECT Id
                                                                    FROM MessagingSession 
                                                                    WHERE MessagingEndUserId IN :lMessagingEndUserIds
                                                                )
                                            AND (Case.AccountId = NULL OR Case.ContactId = NULL)];


        system.debug('£££££ lCasesToPopulateContactAccountId: ' + lCasesToPopulateContactAccountId);


        if(lCasesToPopulateContactAccountId.size()>0){
            system.debug('£££££ lCasesToPopulateContactAccountId: ' + lCasesToPopulateContactAccountId);
            system.debug('£££££ messagingEndUserNewMap: ' + messagingEndUserNewMap);
            List<Case> lCasesToUpdateWithAccountContactId = new List<Case>();
            for(Case cse: lCasesToPopulateContactAccountId){
                cse.AccountId = sessionWithMessageUser.get(cse.SourceId).MessagingEndUser.AccountId;
                cse.ContactId = sessionWithMessageUser.get(cse.SourceId).MessagingEndUser.ContactId;
                lCasesToUpdateWithAccountContactId.add(cse);
            }
            if(lCasesToUpdateWithAccountContactId.size()>0) update lCasesToUpdateWithAccountContactId; 
        }     
    } 

}