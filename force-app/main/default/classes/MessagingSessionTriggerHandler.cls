/**************************************************************************************************
* Name               : MessagingSessionTriggerHandler 
* Description        : This is handler class for MessagingSessionTrigger       
* Created Date       : 12-Dec-2019                                                                 
* Created By         : Sri Bala                                                     
* -----------------------------------------------------------------------------------------------
**************************************************************************************************/
public class MessagingSessionTriggerHandler {

    /**************************************************************************************************
* Name               : createNewCase 
* Description        : Creates new case
* Params             : List<MessagingSession>
* Return             : -
**************************************************************************************************/
    public static List<Case> lCasesToInsert = new List<Case>();
    public static Map<String, String> mChannelIdCaseFieldMappingString = new Map<String, String>();
    public static Map<String, Map<String, String> > mChannelIdFieldAPINameToValue = new  Map<String, Map<String, String>>();  
    public static Map<String, Schema.SObjectField> caseFieldMaps =Schema.SObjectType.Case.fields.getMap(); //the key in this map is lower case
    
    public static void createNewCase(List<MessagingSession> newMessages, Map<Id,MessagingSession> mMessageSessionNewMap){
        populateMapsFromMetadata();

        system.debug('££££ caseFieldMaps:  ' + caseFieldMaps);

        List<MessagingSession> lMessageSession = new List<MessagingSession>();
        
        //These need to be queried again to get the EndUserAccountId,EndUserContactId
        lMessageSession = [SELECT ID, 
                                CaseId,
                                MessagingChannelId, 
                                Is_Outbound__c,
                                EndUserAccountId, 
                                EndUserContactId 
                            FROM MessagingSession 
                            WHERE ID IN: Trigger.new];
        
        for(MessagingSession msgSession: lMessageSession){
            system.debug('Message  = ' + msgSession);
            if(msgSession.CaseId == null && msgSession.Is_Outbound__c == false){
                Map<String, String> mFieldNameToValue = new Map<String, String>();
                mFieldNameToValue = mChannelIdFieldAPINameToValue.get(msgSession.MessagingChannelId);
                if(mFieldNameToValue != null){
                    system.debug('Iff mFieldNameToValue  = ' + mFieldNameToValue);
                    Case cse = new Case();
                    cse.SourceId = msgSession.Id;
                    if(msgSession.EndUserAccountId != null) cse.AccountId = msgSession.EndUserAccountId;
                    if(msgSession.EndUserContactId != null) cse.ContactId = msgSession.EndUserContactId;
                    system.debug('Iff mFieldNameToValue  = ' + mFieldNameToValue);
                    
                    for(String apiName: mFieldNameToValue.keySet()){
                        system.debug('apiName  = ' + apiName);
                        String apiNameLowerCase = apiName.toLowerCase();
                        system.debug('apiNameLowerCase  = ' + apiNameLowerCase);
                        if(caseFieldMaps.get(apiNameLowerCase) == null) continue;
                        cse.put(apiNameLowerCase,mFieldNameToValue.get(apiName));
                    }
                    system.debug('cse  = ' + cse);
                    lCasesToInsert.add(cse);
                }
            } 
        }
        try{
            if(lCasesToInsert.size() >0){
                List<Case> lCasesWithSource = new List<Case>();
                
                system.debug('#### lCasesToInsert >>>>>>> '+lCasesToInsert);
                insert lCasesToInsert;

                for(Case cse: lCasesToInsert){
                    mMessageSessionNewMap.get(cse.SourceId).CaseId = cse.Id;
                    system.debug('mMessageSessionNewMap.get(cse.SourceId).CaseId  = ' + mMessageSessionNewMap.get(cse.SourceId).CaseId);
                }
            }
        }catch(Exception ex){
            system.debug('Exception at Line Number - ' + ex.getLineNumber() + ' : ' + ex.getMessage());
        }
    }

    //Outbound notifcaitions will be trigger from Case. The sessions need to be linked to the case
    //At the time of implmentation, there is no relationship between case and automated notification
    //Assumption needs to be made that the messaging session will be linked with the last modified Case
    public static void linkOutboundMessageNotificationToCase(List<MessagingSession> newMessages, Map<Id,MessagingSession> mMessageSessionNewMap){
        Map<Id,Id> mMessagingUserCaseId = new Map<Id, Id>();
        List<Id> lMessagingUserId = new List<Id>();

        for(MessagingSession msgSession: newMessages){
            if(msgSession.CaseId==null && msgSession.Is_Outbound__c){
                
                lMessagingUserId.add(msgSession.MessagingEndUserId);
            }
        }

        //This will fire for every scenario where case is null
        for(Case cse: [SELECT Id, Messaging_User__c 
                        FROM Case 
                        WHERE Messaging_User__c IN: lMessagingUserId
                        AND Messaging_Notification_Last_Sent_Date__c > YESTERDAY
                        ORDER BY Messaging_Notification_Last_Sent_Date__c DESC ]){ //It should not 
            //newMessages[0].CaseId = '5001X00000607qUQAQ';
            //There is already already a value in the map move to the next record
            if(mMessagingUserCaseId.get(cse.Messaging_User__c)!= null) continue; 
            
            mMessagingUserCaseId.put(cse.Messaging_User__c, cse.Id);
        }

        for(MessagingSession msgSession: newMessages){
            if(msgSession.CaseId==null && msgSession.Is_Outbound__c){
               msgSession.CaseId = mMessagingUserCaseId.get(msgSession.MessagingEndUserId);
            }
        }
    }

    public static void populateMapsFromMetadata(){
        //Query Channel Metadata here. This is because it is not possible to get the channel Id in before/after update
        for(Messaging_Channel_Case_Mapping__mdt cseMap:    [    SELECT  Channel_Id__c, 
                                                                        Case_Field_Mapping__c
                                                                FROM Messaging_Channel_Case_Mapping__mdt]){

            mChannelIdCaseFieldMappingString.put(cseMap.Channel_Id__c,cseMap.Case_Field_Mapping__c);
        }
        
        for(String channelId: mChannelIdCaseFieldMappingString.keyset()){
                String originalString = mChannelIdCaseFieldMappingString.get(channelId);
                system.debug('££££ originalString: ' + originalString);
                Map<String, String> mFieldAPINameToValue = new Map<String, String>();
                if(originalString !=null){
                    originalString = originalString.deleteWhitespace();
                    while(originalString.substringBetween(';',';')!=null){
                        system.debug('££££ while loop originalString: ' + originalString);
                        String mappingPair = originalString.substringBetween(';',';');
                        //This should have a befoe and after colon
                        String fieldAPIName = '';
                        String fieldValue = '';
                        fieldAPIName = mappingPair.substringBeforeLast(':');
                        if(fieldAPIName.length()>0) fieldAPIName = fieldAPIName.trim();

                        fieldValue = mappingPair.substringAfterLast(':');
                        if(fieldValue.length()>0) fieldValue = fieldValue.trim();
                        system.debug('££££ fieldAPIName: ' + fieldAPIName);
                        system.debug('££££ fieldValue: ' + fieldValue);

                        if(fieldAPIName.length()>0 && fieldValue.length()>0){
                            mFieldAPINameToValue.put(fieldAPIName, fieldValue);
                        }
                        originalString = originalString.remove(';' + mappingPair + ';');
                    }
                }
                mChannelIdFieldAPINameToValue.put(channelId,mFieldAPINameToValue);
                system.debug('££££ mChannelIdFieldAPINameToValue: ' + mChannelIdFieldAPINameToValue);
        }
    }

}