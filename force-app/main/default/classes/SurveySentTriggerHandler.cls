/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   Trigger Handler for Survey Sent Object.
History
<Date>          <Authors Name>     <Brief Description of Change>
4/1/2018        Jed Canlas                Initial Versioin
----------------------------------------------------------------------------*/
public class SurveySentTriggerHandler { 
    
    
    public static void onAfterInsert(Map<Id,Survey_Sent__c> newMap) {
        evaluateResponses(newMap);    
    }
    
    public static void onAfterUpdate(Map<Id,Survey_Sent__c> oldMap, Map<Id,Survey_Sent__c> newMap) { 
        evaluateUpdatedResponses(oldMap,newMap);    
    }
    
    public static void evaluateResponses(Map<Id,Survey_Sent__c> newMap) {
    	                 
        set<String> setLOB = new set<String>();
        set<String> setSurveyName = new set<String>();
        set<Date> setSurveyDate = new set<Date>();
		list<Case> caseList = new list<Case>();
		list<Case> caseUpdate = new list<Case>();
		        
        for(Survey_Sent__c s: newMap.values()){
        	if(string.IsNotEmpty(s.Survey_Group__c)){
            	setLOB.add(s.Survey_Group__c);
        	}
        	if(string.IsNotEmpty(s.Survey_Name__c)){
            	setSurveyName.add(s.Survey_Name__c);
        	}
        	if(s.Survey_Date__c != null){
            	setSurveyDate.add(s.Survey_Date__c);
        	}           	         
             
        }        
        
        String whereClause = '(Survey_Group__c != \'\' OR Survey_Group__c != null) AND Survey_Group__c IN: setLOB AND ' +
					 		 '(Survey_Name__c != \'\' OR Survey_Name__c != null) AND Survey_Name__c IN: setSurveyName AND ' +
					 		 'CX_Survey_Date__c != null AND CX_Survey_Date__c IN: setSurveyDate AND ' +
					 		 'Record_Type_Name__c = \'marhaba - NPS\'';
		
        caseList = database.query(CRK_UtilityClass.constructQueryString('Case', whereClause));

        if(caseList.size() > 0){
            for(Case sResponse: caseList){
                for(Survey_Sent__c sSurvey: newMap.Values()){
                    if(sResponse.Survey_Group__c == sSurvey.Survey_Group__c
                    && sResponse.Survey_Name__c == sSurvey.Survey_Name__c
                    && sResponse.CX_Survey_Date__c == sSurvey.Survey_Date__c){
                        sResponse.Survey_Sent__c = sSurvey.Id;
                        caseUpdate.add(sResponse);
                    }
                    
                }
            }    
        }
        
        if(caseUpdate.size()>0){
            try{
                update caseUpdate;
            }catch (exception e){
                system.debug(e.getMessage()); 
            }
        }  
    }
    
    public static void evaluateUpdatedResponses(Map<Id,Survey_Sent__c> oldMap, Map<Id,Survey_Sent__c> newMap) {   
        
        evaluateResponses(newMap);
        set<String> setLOB = new set<String>();
        set<String> setSurveyName = new set<String>();
        set<Date> setSurveyDate = new set<Date>();
        list<Case> caseList = new list<Case>();
        list<Case> caseUpdate = new list<Case>();
        
        for(Survey_Sent__c s: oldMap.values()){
            setLOB.add(s.Survey_Group__c);    
            setSurveyName.add(s.Survey_Name__c); 
            setSurveyDate.add(s.Survey_Date__c); 
        }               
        
		String whereClause = 'Survey_Group__c != \'\' AND Survey_Group__c IN: setLOB AND ' +
							 'Survey_Name__c != \'\' AND Survey_Name__c IN: setSurveyName AND ' +
							 'CX_Survey_Date__c != null AND CX_Survey_Date__c IN: setSurveyDate AND ' +
							 'Record_Type_Name__c = \'marhaba - NPS\'';
							        
        caseList = database.query(CRK_UtilityClass.constructQueryString('Case', whereClause));
               
        if(caseList.size()>0){
            for(Case sResponse: caseList){
                sResponse.Survey_Sent__c = null;
                caseUpdate.add(sResponse);
            }    
        }
        if(caseUpdate.size()>0){            
            try{
                update caseUpdate;
            }catch (exception e){
                system.debug(e.getMessage());
            }

        }  
        
        
    }

}