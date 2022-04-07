/**************************************************************************************************
* Name               : CaseSLAHelper 
* Description        : This is the apex class for tracking status and owner changes on case and recording it on Case Field History object         
* Created Date       : 07-Oct-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Kaavya        07-Oct-2018    Initial version                                                
* v1.1        Kaavya        25-Oct-2018    T-00259 - Updated to remove tracking of status                                                                           
**************************************************************************************************/
public without sharing class CaseSLAHelper {
    
    //For Insert   
    public static void CreateSLAOnInsert(list < Case > TriggerNew) {
        set < string > setOwnerChangeCaseIds = new set < string > ();
        set < string > setStatusChangeCaseIds = new set < string > ();
        map < string, Case_Field_History__c> mapClosedCaseSLAs = new map < string, Case_Field_History__c> ();
        list < Case_Field_History__c> lstNewSLAs = new list < Case_Field_History__c> ();
        for(Case cs: TriggerNew) {
            //if(cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId) {
                setOwnerChangeCaseIds.add(cs.Id);
                Case_Field_History__c obj = new Case_Field_History__c();
                obj.Parent__c = cs.Id;
                obj.Change_Type__c = 'Owner';
                obj.From__c = system.now();
                obj.Owner__c = cs.Owner_Name__c;
                obj.Owner_Team_Name__c= cs.Owner_Team_Name__c;
                //obj.Previous_Value__c= TriggerOldMap.get(cs.Id).Owner_Team_Name__c;
                obj.Status__c = cs.Status;
                obj.Business_Hours_Id__c = cs.BusinessHoursId; // TBD later
                if(obj.Business_Hours_Id__c!=null){
                    decimal SLAMinutes = 480;//8.hours
                    Long sla = SLAMinutes.longvalue();
                    sla = sla*60*1000L;
                    obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                }
                if(cs.isClosed) {
                    obj.Until__c = system.now();
                    if(obj.Business_Hours_Id__c != null)
                        obj.Calculated_Business_Minutes__c = BusinessHours.diff(obj.Business_Hours_Id__c, obj.From__c, obj.Until__c) / 1000 / 60;
                    //mapClosedCaseSLAs.put(cs.Id, obj);
                }
                lstNewSLAs.add(obj);
            //}
            //if(cs.Status != TriggerOldMap.get(cs.Id).Status) {
            /* Commenting out status tracking as part of v1.1
                setStatusChangeCaseIds.add(cs.Id);
                Case_Field_History__c obj1 = new Case_Field_History__c();
                obj1.Parent__c = cs.Id;
                obj1.Change_Type__c = 'Status';
                obj1.From__c = system.now();
                obj1.Status__c = cs.Status;
                obj1.Previous_Value__c= 'New';//TriggerOldMap.get(cs.Id).Status;
                obj1.Owner__c = cs.Owner_Name__c;
                obj1.Owner_Team_Name__c= cs.Owner_Team_Name__c;
                obj1.Business_Hours_Id__c = cs.BusinessHoursId; // TBD later
                if(obj1.Business_Hours_Id__c!=null){
                    decimal SLAMinutes = 480;//8.hours
                    Long sla = SLAMinutes.longvalue();
                    sla = sla*60*1000L;
                    obj1.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                }
                //if(!cs.isClosed) {
                    lstNewSLAs.add(obj1);
                if(cs.isClosed) {
                    obj1.Until__c = system.now();
                    if(obj1.Business_Hours_Id__c != null)
                        obj1.Calculated_Business_Minutes__c = BusinessHours.diff(obj1.Business_Hours_Id__c, obj1.From__c, obj1.Until__c) / 1000 / 60;
                    //mapClosedCaseSLAs.put(cs.Id, obj);
                }
            //}
            */
        }
        
        if(lstNewSLAs != null && lstNewSLAs.size() > 0) {
            try {
                Database.UpsertResult[] srList = Database.upsert(lstNewSLAs, false);
            } catch (Exception e) {

            }
        }
    }
    
    //For updates
    public static void CreateSLAOnUpdate(list < Case > TriggerNew, map < Id, Case > TriggerOldMap) {
        set < string > setOwnerChangeCaseIds = new set < string > ();
        set < string > setStatusChangeCaseIds = new set < string > ();
        map < string, Case_Field_History__c> mapClosedCaseSLAs = new map < string, Case_Field_History__c> ();
        list < Case_Field_History__c> lstNewSLAs = new list < Case_Field_History__c> ();
        for(Case cs: TriggerNew) {
            if(cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId) {
                setOwnerChangeCaseIds.add(cs.Id);
                Case_Field_History__c obj = new Case_Field_History__c();
                obj.Parent__c = cs.Id;
                obj.Change_Type__c = 'Owner';
                obj.From__c = system.now();
                obj.Owner__c = cs.Owner_Name__c;
                obj.Owner_Team_Name__c= cs.Owner_Team_Name__c;
                obj.Previous_Value__c= TriggerOldMap.get(cs.Id).Owner_Name__c;
                obj.Previous_Team_Name__c=TriggerOldMap.get(cs.Id).Owner_Team_Name__c;
                obj.Status__c = cs.Status;
                obj.Business_Hours_Id__c = cs.BusinessHoursId; // TBD later
                if(obj.Business_Hours_Id__c!=null){
                    decimal SLAMinutes = 480;//8.hours
                    Long sla = SLAMinutes.longvalue();
                    sla = sla*60*1000L;
                    obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                }
                lstNewSLAs.add(obj);
            }
            //commenting out the status change as part of v1.1
            /*
            if(cs.Status != TriggerOldMap.get(cs.Id).Status) {
                setStatusChangeCaseIds.add(cs.Id);
                Case_Field_History__c obj = new Case_Field_History__c();
                obj.Parent__c = cs.Id;
                obj.Change_Type__c = 'Status';
                obj.From__c = system.now();
                obj.Status__c = cs.Status;
                obj.Previous_Value__c= TriggerOldMap.get(cs.Id).Status;
                obj.Owner__c = cs.Owner_Name__c;
                obj.Owner_Team_Name__c= cs.Owner_Team_Name__c;
                obj.Business_Hours_Id__c = cs.BusinessHoursId; // TBD later
                if(obj.Business_Hours_Id__c!=null){
                    decimal SLAMinutes = 480;//8.hours
                    Long sla = SLAMinutes.longvalue();
                    sla = sla*60*1000L;
                    obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                }
                if(!cs.isClosed) {
                    lstNewSLAs.add(obj);
                }else {
                    obj.Until__c = system.now();
                    if(obj.Business_Hours_Id__c != null)
                        obj.Calculated_Business_Minutes__c = BusinessHours.diff(obj.Business_Hours_Id__c, obj.From__c, obj.Until__c) / 1000 / 60;
                    mapClosedCaseSLAs.put(cs.Id, obj);
                }
            } */
        }
        if(setOwnerChangeCaseIds != null && setOwnerChangeCaseIds.size() > 0) {
            for(Case_Field_History__c sl: [Select Id, Business_Hours_Id__c, From__c, Until__c, Calculated_Business_Minutes__c from Case_Field_History__c where Parent__c IN: setOwnerChangeCaseIds and From__c != null and Until__c = null and Change_Type__c = 'Owner']) {
                sl.Until__c = system.now();
                if(sl.Business_Hours_Id__c != null)
                    sl.Calculated_Business_Minutes__c = BusinessHours.diff(sl.Business_Hours_Id__c, sl.From__c, sl.Until__c) / 1000 / 60;
                lstNewSLAs.add(sl);
            }
        }
        /* Commenting out status tracking as part of v1.1
        if(setStatusChangeCaseIds != null && setStatusChangeCaseIds.size() > 0) {
            for(Case_Field_History__c sl: [Select Id, Business_Hours_Id__c, From__c, Until__c, Calculated_Business_Minutes__c from Case_Field_History__c where Parent__c IN: setStatusChangeCaseIds and From__c != null and Until__c = null and Change_Type__c = 'Status']) {
                sl.Until__c = system.now();
                if(sl.Business_Hours_Id__c != null)
                    sl.Calculated_Business_Minutes__c = BusinessHours.diff(sl.Business_Hours_Id__c, sl.From__c, sl.Until__c) / 1000 / 60;
                lstNewSLAs.add(sl);
            }
        } */
        if(mapClosedCaseSLAs != null && mapClosedCaseSLAs.size() > 0) {
            try {
                list < Case_Field_History__c > openSLAs = new list < Case_Field_History__c > ();
                openSLAs.addAll(mapClosedCaseSLAs.values());
                for(Case_Field_History__c sla: [select Id, Until__c, Business_Hours_Id__c, From__c, Calculated_Business_Minutes__c from Case_Field_History__c where Parent__c IN: mapClosedCaseSLAs.keyset() and Until__c = null]) {
                    sla.Until__c = system.now();
                    if(sla.Business_Hours_Id__c != null)
                        sla.Calculated_Business_Minutes__c = BusinessHours.diff(sla.Business_Hours_Id__c, sla.From__c, sla.Until__c) / 1000 / 60;
                    openSLAs.add(sla);
                }
                if(openSLAs != null && openSLAs.size() > 0) {
                    Database.UpsertResult[] srList = Database.upsert(openSLAs, false);
                }
                list < Case_Field_History__c > Lst_SLA_TBD = new list < Case_Field_History__c > ();
                for(Case cs: [select Id, (select Id, Calculated_Business_Minutes__c, Status__c from Case_Field_History__r where Status__c = 'Closed'
                        and Change_Type__c = 'Status'
                        order by createddate) from Case where Id IN: mapClosedCaseSLAs.keyset()]) {
                    if(cs.Case_Field_History__r != null && cs.Case_Field_History__r.size() > 0) {
                        integer i = 0;
                        for(Case_Field_History__c sla: cs.Case_Field_History__r) {
                            if(i > 0)
                                Lst_SLA_TBD.add(sla);
                            i++;
                        }
                    }
                }
                if(Lst_SLA_TBD != null && Lst_SLA_TBD.size() > 0)
                    delete Lst_SLA_TBD;
            } catch (Exception e) {

            }
        }
        if(lstNewSLAs != null && lstNewSLAs.size() > 0) {
            try {
                Database.UpsertResult[] srList = Database.upsert(lstNewSLAs, false);
            } catch (Exception e) {

            }
        }
    }
}