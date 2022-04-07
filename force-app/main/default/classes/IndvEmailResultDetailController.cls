public without sharing class IndvEmailResultDetailController 
{
    
    public class RequestWrap
    {

        @AuraEnabled public String MergeID{ get; set; }
        @AuraEnabled public String RelObjID{ get; set; }
        @AuraEnabled public String RelSendID{ get; set; }

       
    }
    
    public class RespondWrap
    {

        @AuraEnabled Email_Result_Archive__b emailResultObj {get;set;}
        @AuraEnabled List<IndvEmailResultDetailController.EmailResultConfigWrap> emailResWrapLst {get;set;}
       // @AuraEnabled Attachment thumbNailAttch {get;set;}
    }
    
    public class EmailResultConfigWrap
    {
        @AuraEnabled String label{ get; set; }
        @AuraEnabled String fieldApi{ get; set; }
        @AuraEnabled Object value { get; set; }
        @AuraEnabled String referenceId { get; set; }

       
    }
    
    
    @AuraEnabled
    public static IndvEmailResultDetailController.RespondWrap fetchEmailResultArchive(String requestWrapParam) 
    {
        //declaration of wrapper
        IndvEmailResultDetailController.RequestWrap reqWrap = new IndvEmailResultDetailController.RequestWrap();
        IndvEmailResultDetailController.RespondWrap respWrap =  new IndvEmailResultDetailController.RespondWrap();
        List<IndvEmailResultDetailController.EmailResultConfigWrap> emailResWrapLst = new List<IndvEmailResultDetailController.EmailResultConfigWrap>();
        
        
        //Schema field call.
         Map<String, Schema.SObjectField> allEmlRsltArchFieldsMap = Schema.SObjectType.Email_Result_Archive__b.fields.getMap();
        
        
        //deseriliaze.
        reqWrap = (RequestWrap) JSON.deserializeStrict(requestWrapParam, IndvEmailResultDetailController.RequestWrap.class);
        string MergeID = reqWrap.MergeID;
        string RelObjID = reqWrap.RelObjID ;
        string RelSendID = reqWrap.RelSendID;
        system.debug('@@@@@@@@@@@ reqWrap '+reqWrap);
        
        
        //Populating custom metadata type.
        Map<String, Email_Result_Archive_Config__mdt > emailArchivefieldsMap = new Map<String, Email_Result_Archive_Config__mdt >();
        for(Email_Result_Archive_Config__mdt emailArch : [SELECT Field_Api__c,
                                                                 Field_label__c,
                                                                 Field_Reference_Api__c,
                                                                 Display_Order__c 
                                                            FROM Email_Result_Archive_Config__mdt
                                                        ORDER BY Display_Order__c ASC NULLS LAST])
        {
            emailArchivefieldsMap.put(emailArch.Field_Api__c,emailArch);
        }
        
        
        //string fieldsToQuery = String.join(new List<String>(emailArchivefieldsMap.keySet()), ',');
        string fieldsToQuery = '';
        List<String> emlArchLst = new List<String>(emailArchivefieldsMap.keySet());
        for(Integer i = 0 ; i < emlArchLst.size() ; i++)
        {
            Email_Result_Archive_Config__mdt emailArch = emailArchivefieldsMap.get(emlArchLst[i]);
            fieldsToQuery = fieldsToQuery + emlArchLst[i];
            fieldsToQuery = fieldsToQuery + (emailArch.Field_Reference_Api__c != NULL ? ','+emailArch.Field_Reference_Api__c : '');
            fieldsToQuery = fieldsToQuery + ( i < emlArchLst.size() - 1 ? ',' : '');
           
        }
        
        Email_Result_Archive__b emailResultObj;
        if( !Test.isRunningTest())
        {
            //string query = 'SELECT ' +  fieldsToQuery + ' FROM Email_Result_Archive__b WHERE Related_Object_ID__c =: RelatedObjectID' ;
            string query = 'SELECT '+fieldsToQuery +' FROM Email_Result_Archive__b WHERE Related_Object_ID__c =: RelObjID AND Related_Send_ID__c =: RelSendID AND MergeId__c =: MergeID' ;
            emailResultObj = (Email_Result_Archive__b) Database.query(query);
            
        }
        else
        {
             emailResultObj = new Email_Result_Archive__b();
                
        }
        system.debug('######### emailResultObj ');
        system.debug('######### emailResultObj resu'+emailResultObj );
        
        respWrap.emailResultObj = emailResultObj;
        
        for( String fldApi : emailArchivefieldsMap.keySet() )
        {
            IndvEmailResultDetailController.EmailResultConfigWrap emailResWrap = new IndvEmailResultDetailController.EmailResultConfigWrap();
        
            emailResWrap.fieldApi = fldApi;
            emailResWrap.label = emailArchivefieldsMap.get(fldApi).Field_label__c ;
            
            
            //Getting schema property.
            system.debug('@@@@@@@@ fldApi '+fldApi);
            system.debug('@@@@@@@@ fldApi '+allEmlRsltArchFieldsMap.get(fldApi) );
            
            
            if( fldApi.contains('__r.')  )
            {
                if(!Test.isRunningTest())
                {
                    String[] fldApiSplt = fldApi.split('__r.');
                    SObject refSobj = emailResultObj.getSobject(fldApiSplt[0]+'__r');
                    if(refSobj != NULL)
                    {
                        emailResWrap.value = emailResultObj.getSobject(fldApiSplt[0]+'__r').get(fldApiSplt[1]);
                        emailResWrap.referenceId = (String) emailResultObj.get( emailArchivefieldsMap.get(fldApi).Field_Reference_Api__c );
                
                    }
                    
                }
                
            }
            else
            {
                Schema.DescribeFieldResult descFldReslt = allEmlRsltArchFieldsMap.get(fldApi).getDescribe();
                Schema.DisplayType fielddataType = descFldReslt.getType();

                // For date/time display User prefered DT.
                if(fielddataType == Schema.DisplayType.DateTime)
                {
                     
                    DateTime dt= (DateTime)emailResultObj.get(fldApi);
                    //Integer offset = UserInfo.getTimezone().getOffset(dt); 
                    //Datetime local = dt.addSeconds(offset/1000);
                    emailResWrap.value = (dt != NULL ? dt.format() : NULL);  
                }
                else
                {
                    emailResWrap.value = emailResultObj.get(fldApi);
                }
                
            }
            emailResWrapLst.add(emailResWrap);
            
            
        }
        respWrap.emailResWrapLst = emailResWrapLst;
        return respWrap;
    }

}