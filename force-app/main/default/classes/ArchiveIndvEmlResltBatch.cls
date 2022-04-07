global class ArchiveIndvEmlResltBatch implements Database.Batchable<sObject> 
{

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //and id = \'a0t2X00000AcOaTQAV\'
        String query = 'SELECT et4ae5__CampaignMemberId__c,Related_Object_ID__c,Error_message__c,IsError__c,Related_Send_ID__c,Clicked_Text__c ,et4ae5__Contact_ID__c,CreatedById,CurrencyIsoCode,Customer_Domain__c,et4ae5__DateBounced__c,et4ae5__DateOpened__c,et4ae5__DateSent__c,et4ae5__DateUnsubscribed__c,et4ae5__Email__c,et4ae5__Email_Asset_ID__c,et4ae5__Email_ID__c,Name,et4ae5__FromAddress__c,et4ae5__FromName__c, Hard_Bounce_Text__c,et4ae5__Lead__c,et4ae5__Lead_ID__c,et4ae5__NumberOfUniqueClicks__c,et4ae5__NumberOfTotalClicks__c,Opened_Text__c,OwnerId,et4ae5__SendDefinition__c, Soft_Bounce_Text__c ,et4ae5__SubjectLine__c,et4ae5__Tracking_As_Of__c,et4ae5__TriggeredSendDefinitionName__c,et4ae5__Contact__c,et4ae5__MergeId__c,et4ae5__TriggeredSendDefinition__c FROM et4ae5__IndividualEmailResult__c where IsError__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> emailList) {
       
        List<Email_Result_Archive__b> bigObjList = new List<Email_Result_Archive__b>();
        Set<String> mergeIDSet =  new Set<String>();
        List<et4ae5__IndividualLink__c  > indLinkToUpt = new List<et4ae5__IndividualLink__c  >();
        
        
        for(et4ae5__IndividualEmailResult__c emailObj : emailList)
        {        
            Email_Result_Archive__b bigObj = new Email_Result_Archive__b ();
            bigObj.Individual_Email_Result__c = emailObj.Id;
            bigObj.Individual_Email_Result_ID__c = emailObj.Id;
            bigObj.Contact__c           = emailObj.et4ae5__Contact__c;
            bigObj.MergeId__c           = emailObj.et4ae5__MergeId__c;
            bigObj.Clicked__c             = emailObj.Clicked_Text__c;
            bigObj.CampaignMemberId__c  = emailObj.et4ae5__CampaignMemberId__c;
            bigObj.Contact_ID__c      = emailObj.et4ae5__Contact_ID__c;
            bigObj.CreatedById__c     = emailObj.CreatedById;
            bigObj.Currency__c            = emailObj.CurrencyIsoCode;
            bigObj.Customer_Domain__c     = emailObj.Customer_Domain__c;
            bigObj.Date_Bounced__c        = emailObj.et4ae5__DateBounced__c;
            bigObj.Date_Opened__c         = emailObj.et4ae5__DateOpened__c;
            bigObj.Date_Sent__c       = emailObj.et4ae5__DateSent__c;
            bigObj.Date_Unsubscribed__c = emailObj.et4ae5__DateUnsubscribed__c;
            bigObj.Email__c           = emailObj.et4ae5__Email__c;
            bigObj.Email_Asset_ID__c  = emailObj.et4ae5__Email_Asset_ID__c;
            bigObj.Email_ID__c            = emailObj.et4ae5__Email_ID__c;
            bigObj.Email_Name__c      = emailObj.Name;
            bigObj.From_Address__c        = emailObj.et4ae5__FromAddress__c;
            bigObj.From_Name__c       = emailObj.et4ae5__FromName__c;
            bigObj.Hard_Bounce__c         = emailObj.Hard_Bounce_Text__c;
            bigObj.Lead__c                = emailObj.et4ae5__Lead__c;
            bigObj.Lead_ID__c             = emailObj.et4ae5__Lead_ID__c;
            bigObj.Links_Clicked__c       = emailObj.et4ae5__NumberOfUniqueClicks__c;
            bigObj.OwnerId__c             = emailObj.OwnerId;
            bigObj.Opened__c              = emailObj.Opened_Text__c;
            bigObj.Send_Definition__c = emailObj.et4ae5__SendDefinition__c;
            bigObj.Soft_Bounce__c         = emailObj.Soft_Bounce_Text__c;
            bigObj.Subject_Line__c        = emailObj.et4ae5__SubjectLine__c;
            bigObj.Tracking_As_Of__c  = emailObj.et4ae5__Tracking_As_Of__c;
            bigObj.Triggered_Send_Name__c= emailObj.et4ae5__TriggeredSendDefinitionName__c;
            bigObj.TriggeredSendDefinition__c= emailObj.et4ae5__TriggeredSendDefinition__c;
            bigObj.Number_of_Total_Clicks__c = emailObj.et4ae5__NumberOfTotalClicks__c;
            
            
            //Additional mapping.
            bigObj.Related_Object_ID__c = emailObj.Related_Object_ID__c;
            bigObj.Related_Send_ID__c   = emailObj.Related_Send_ID__c;
            
            //collecting Merge ID.
            if( bigObj.MergeId__c <> NULL )
            {
               mergeIDSet.add(bigObj.MergeId__c);
            }
            bigObjList.add(bigObj);
        }
        
        
        //updating IndLink
        for(et4ae5__IndividualLink__c  indvLnk : [SELECT id,
                                                         Merge_Id__c,
                                                         et4ae5__Individual_Email_Result__r.et4ae5__MergeId__c
                                                    FROM et4ae5__IndividualLink__c 
                                                   WHERE et4ae5__Individual_Email_Result__r.et4ae5__MergeId__c IN:mergeIDSet ])
        {
            indvLnk.Merge_Id__c = indvLnk.et4ae5__Individual_Email_Result__r.et4ae5__MergeId__c;
            indLinkToUpt.add(indvLnk);
            
        }
       
        
       
        
        
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        if(!Test.isRunningTest()  )
        {
            srList = database.insertImmediate(bigObjList);
        }
        else
        {
            Database.SaveResult sr = (Database.SaveResult)
                    JSON.deserialize('{"success":true,"id":""}', Database.SaveResult.class);
            srList.add(sr);         
        }
        
        Boolean isSuccess = true;
        String errorString = ''; 
        Integer i;
        List<et4ae5__IndividualEmailResult__c> indEmailToDel = new List<et4ae5__IndividualEmailResult__c>();
        List<et4ae5__IndividualEmailResult__c> indEmailError = new List<et4ae5__IndividualEmailResult__c>();
        
        
        
        for(Integer j = 0; j < srList.size() ; j++)
        {
            Database.SaveResult sr = srList[j];
            if(sr.isSuccess())
            {
               indEmailToDel.add(emailList[j]);
            }
            else if( sr.getErrors() != NULL && sr.getErrors().size() > 0 )
            {
                
                emailList[j].IsError__c = true;
                for(Database.Error dataErr : sr.getErrors())
                {
                  errorString  = errorString + (dataErr.getMessage()!=NULL ? dataErr.getMessage() :'') + ';';
                }
                
                emailList[j].Error_message__c = errorString;
                indEmailError.add(emailList[j]);
            }
            
        }
        
        if(indLinkToUpt != NULL && indLinkToUpt.size() > 0 )
        {
            update indLinkToUpt; 
        }
        
        
        if(indEmailToDel != NULL && indEmailToDel.size() > 0 )
        {
            delete indEmailToDel; 
        }
        
        if(indEmailError!= NULL && indEmailError.size() > 0 )
        {
            update indEmailError; 
        }
        
        
    }   
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}