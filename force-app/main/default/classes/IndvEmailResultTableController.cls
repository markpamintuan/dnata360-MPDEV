public class IndvEmailResultTableController {
    
    @AuraEnabled
    public static wrapperClass getBigObject(String AccountId){
       
        wrapperClass returnwrapperClass = new  wrapperClass ();
        String ContactID = [SELECT PersonContactId  FROM Account WHERE ID=:AccountId].PersonContactId;
        List<Email_Result_Archive__b> bigObjectList = [SELECT Contact__c,
                                                              Related_Object_ID__c,
                                                              Email_Name__c,
                                                              Date_Sent__c,
                                                              Opened__c,
                                                              Date_Opened__c,
                                                              MergeId__c,
                                                              Related_Send_ID__c 
                                                         FROM Email_Result_Archive__b 
                                                        WHERE Related_Object_ID__c =:ContactID];

        returnwrapperClass.bigObjectList  = bigObjectList ; 
        return returnwrapperClass;    
    }
    
  
    public class wrapperClass{
        @AuraEnabled public List<Email_Result_Archive__b> bigObjectList{get;set;}
    }  
    
   
}