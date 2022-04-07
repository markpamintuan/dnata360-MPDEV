public class IndvLinkTableController
{
    
    @AuraEnabled
    public static wrapperClass getIndvLinks(String mergeId)
    {
       
        wrapperClass returnwrapperClass = new  wrapperClass ();
        List<et4ae5__IndividualLink__c> indvLnkList = [SELECT id,
                                                              Name,
                                                              et4ae5__Unique_Link_ID__c,
                                                              et4ae5__ExactTargetLinkID__c,
                                                              et4ae5__Last_Clicked__c,
                                                              Merge_Id__c 
                                                         FROM et4ae5__IndividualLink__c 
                                                         WHERE Merge_Id__c =:mergeId
                                                      ];

        returnwrapperClass.indvLnkList = indvLnkList; 
        return returnwrapperClass;    
    }
    
  
    public class wrapperClass{
        @AuraEnabled public List<et4ae5__IndividualLink__c> indvLnkList{get;set;}
    }  
    
   
}