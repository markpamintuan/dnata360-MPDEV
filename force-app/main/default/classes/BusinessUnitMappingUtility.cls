/*************************************************************************************************
* Change History                                                        
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.1        Maruf        10-Mar-2019    Code added to reduce SOQL query
* v1.2        Sri Bala     25-Sep-2019    Added Domain__c in SOQL Query
* v1.3        Sri Bala     20-Feb-2020    Adding Email_Routing_Address in SOQL Query
* v1.4        Mark	       21-Mar-2021    Updated business unit map key to Queue_ID__c
**************************************************************************************************/
public class BusinessUnitMappingUtility{

    public static Map<String, Business_Unit__c> mQueueNameToSLARecord = new Map<String, Business_Unit__c>();
    public static Map<String, Business_Unit__c> mQueueIdToQueueRecord = new Map<String, Business_Unit__c>();
    public static Map<String, String> mQueueNameToQueueId= new Map<String, String>();
    public static Map<String, Business_Unit__c> mEmailToEmailRecord = new Map<String, Business_Unit__c>();
    public static Map<String, Business_Unit__c> mQueueToTeamRecord = new Map<String, Business_Unit__c>(); //added by Sri Bala
    public static Set<String> setEKHEmailToCase = new Set<String>();
    public static Boolean bQueryRanAlready = false;
    public static Map<String, String> mEmailToEmailRoutingRecord = new Map<String, String>(); //v1.3
    public static Map<String,Business_Unit__c> businessUnitMap = new Map<String,Business_Unit__c>(); //v1.1
    public static Map<Id,MilestoneType> MilestoneTypeMap = new Map<Id,MilestoneType>(); //v1.1
    public static Map<String, Business_Unit__c> queueIdToSLARecord = new Map<String, Business_Unit__c>();
    
    //public static Entitlement entitlement = new Entitlement(); 
    public static void populateBusinessQueueMap(){
        
        if(!bQueryRanAlready){
/*
            String sEntitlementName = Label.EntitlementName;
            system.debug('#### BusinessUnitMappingUtility sEntitlementName: ' + sEntitlementName);            
            entitlement = [SELECT Id FROM Entitlement WHERE Name =: sEntitlementName limit 1];
            system.debug('#### BusinessUnitMappingUtility entitlement: ' + entitlement); 
*/
			for(Business_Unit__c busUnit: [SELECT Id,
                                                  Org_Queue_Name__c,
                                                  Org_Brand__c,
                                                  Queue_ID__c,
                                                  Org_Team_Name__c,
                                                  Org_Business_Unit_Email__r.name,
                                                  Org_Business_Hour_Id__c,
                                                  RecordType.Name,
                                                  SLA_Hrs__c,
                                                  Org_SLA_Mins__c,
                                                  Org_Email__c,
                                           		  Domain__c, //v1.2 
                                                  Email_Routing_Address__c, //v1.3
                                                  Omni_Queue__c
                                          	FROM Business_Unit__c
                                            WHERE RecordType.Name IN ('Team','Email','SLA')]){
                
                
	            if(busUnit.RecordType.Name == 'Email'){
	                mEmailToEmailRecord.put(busUnit.Org_Email__c, busUnit);
	                mEmailToEmailRoutingRecord.put(busUnit.Email_Routing_Address__c,busUnit.Org_Email__c);
	            }

                if(busUnit.RecordType.Name == 'Team' && busUnit.Queue_ID__c != '' && 
                    busUnit.Queue_ID__c != null && busUnit.Org_Queue_Name__c !=''){
                    mQueueIdToQueueRecord.put(String.valueOf(busUnit.Queue_ID__c).left(15), busUnit);
                    mQueueNameToQueueId.put(busUnit.Org_Queue_Name__c, String.valueOf(busUnit.Queue_ID__c).left(15));
                        if(busUnit.Org_Team_Name__c != '' && busUnit.Org_Team_Name__c!=null)
                     		mQueueToTeamRecord.put(busUnit.Org_Queue_Name__c,busUnit);  //added by sribala
                }  

                if(busUnit.RecordType.Name == 'Email' && busUnit.Org_Brand__c =='ekh'){
                    setEKHEmailToCase.add(busUnit.Org_Email__c);
                }

                if(busUnit.RecordType.Name == 'SLA'){
                    mQueueNameToSLARecord.put(busUnit.Org_Queue_Name__c, busUnit);
                    queueIdToSLARecord.put(busUnit.Queue_ID__c, busUnit); //v1.4
                }
            }

            bQueryRanAlready = true;
        }
    }
    
    //v1.1
    public Static Map<String,Business_Unit__c> getBusinessUnitMap(){
        System.debug('In businessUnitMap size**********'+businessUnitMap.size());
        if(businessUnitMap == null || businessUnitMap.size() == 0){
            System.debug('In BusinessUnitMappingUtility Query**********');
            businessUnitMap = new Map<String,Business_Unit__c>();
            for(Business_Unit__c bu:[SELECT Id,Org_Queue_Name__c,Org_Email__c,Queue_ID__c, Org_SLA_Type__c, Org_Business_Hour_Id__c, RecordType.Name, SLA_Hrs__c, Org_SLA_Mins__c FROM Business_Unit__c WHERE Org_SLA_Type__c = 'Email']){
                if(!businessUnitMap.containsKey(bu.Queue_ID__c)){
                	businessUnitMap.put(bu.Queue_ID__c, bu); //v1.4 changed key from Org_Queue_Name__c to Queue_ID__c
               }
            }
        }
        return businessUnitMap;
    }
    
    public Static MilestoneType getMilestoneTypeRecord(String milestoneTypeId){
        System.debug('In MilestoneTypeMap size**********'+MilestoneTypeMap.size());
        MilestoneType mtRec = new MilestoneType();
        if(MilestoneTypeMap == null || MilestoneTypeMap.size() == 0){
            MilestoneTypeMap = new Map<Id,MilestoneType>([SELECT Name FROM MilestoneType]);
        }
        System.debug('MilestoneTypeMap Value**********'+MilestoneTypeMap);
        if(MilestoneTypeMap.containsKey(milestoneTypeId)){
            mtRec = MilestoneTypeMap.get(milestoneTypeId);   
             System.debug('mtRec**********'+mtRec);
        }    
        return mtRec;                                                     
    }
    
}