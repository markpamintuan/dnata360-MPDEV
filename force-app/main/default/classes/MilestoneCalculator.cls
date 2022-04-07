/**************************************************************************************************
* Name               : MilestoneCalculator 
* Description        : Class for dynamic stamping of target date/hour        
* Created Date       : 30-Jul-2018                                                                                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        N/A          30-Jul-2018    Initial version
* v1.1        Mark         21-Mar-2021    Updated business unit map key to Queue_ID__c           
**************************************************************************************************/
global class MilestoneCalculator implements Support.MilestoneTriggerTimeCalculator {
	   
	global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){

		try{
			Case c = [SELECT Priority, Org_Current_Team_Name__c, Org_Business_Unit__c, Current_Queue_ID__c FROM Case WHERE Id=:caseId];
			Business_Unit__c businessUnit = new Business_Unit__c();
            
			Map<String,Business_Unit__c> businessUnitMap = new Map<String,Business_Unit__c>();
			businessUnitMap = BusinessUnitMappingUtility.getBusinessUnitMap();
            
			//v1.1 - changed key Org_Current_Team_Name__c to Current_Queue_ID__c
			if(businessUnitMap != null && businessUnitMap.containsKey(c.Current_Queue_ID__c )){
				System.debug('In MilestoneCalculator Map**********');
				businessUnit = businessUnitMap.get(c.Current_Queue_ID__c);
			} 
            
			system.debug('### businessUnit: ' + businessUnit);

			MilestoneType mt = new MilestoneType();				
			mt = BusinessUnitMappingUtility.getMilestoneTypeRecord(milestoneTypeId);//[SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
			system.debug('### mt: ' + mt);
			
			if(businessUnit.Org_SLA_Mins__c != null && mt.Name != null && mt.Name.equals('Email Response')){ //should only do this for email response
				system.debug('### businessUnit: ' + businessUnit);
				return Integer.ValueOf(businessUnit.Org_SLA_Mins__c);
			}else{
				return 240;	//default 4 hours
			}			
		}catch(Exception e){
			System.debug('### Exception: ' + e);
			return 240;//default 4 hours
		}
		return 240;//default 4 hours
		              
	}
}