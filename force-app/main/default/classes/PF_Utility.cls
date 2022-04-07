/**Purpose - Utility Class for resuable methods**/
public class PF_Utility {

    //To clone the records and its related list
    public static List<sObject> cloneObject(String objName, Id objId, Boolean isParent, String parentLookUpField, String parentRecordId){
        SObjectType objData = Schema.getGlobalDescribe().get(objName);
        DescribeSObjectResult objDes = objData.getDescribe();
        Map<String, SObjectField> fieldMap = objDes.fields.getMap();
        
        List<String> fieldList = new List<String>();
        for(String fieldName : fieldMap.keySet()) {
            System.debug('List of Fields - ' +fieldName);
            if(fieldMap.containsKey(fieldName) && fieldMap.get(fieldName).getDescribe().isCreateable()){
                fieldList.add(fieldName);
            }
        }
        
        String sobjQuery;
        if(isParent){
            sobjQuery   = 'select ' + String.join(fieldList, ',') + ' from '+ objName +' where Id =\''+ objId +'\' limit 1';
        }else{
            sobjQuery   = 'select ' + String.join(fieldList, ',') + ' from '+ objName +' where '+ parentLookUpField +' =\''+ objId +'\'';
        }
        
        system.debug('SOBJECT Query'+sobjQuery);
        
        List<sObject> sObjList = new List<sObject>();
        if(fieldList.size() > 0){
            sObjList = Database.query(sobjQuery); 
        }
        system.debug('sObject List - '+sObjList);
        
        List<sObject> clonedObjList = new List<sObject>();
        sObject clonedsObj;
        
        for(sObject obj : sObjList){
            //clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber)
            clonedsObj  = obj.clone(false, true, false, false);
            if(!isParent && clonedsObj!=null){
                // update parentLookUpField with parentRecordId
                if(String.isNotBlank(parentLookUpField) && String.isNotBlank(parentRecordId)){
                    clonedsObj.put(parentLookUpField,parentRecordId);
                }
            }
            clonedObjList.add(clonedsObj);
        }
        return clonedObjList;
    }
        
    //To return the describe sObject result
    public static Schema.DescribeSObjectResult getDescribeSObjectResultFromId(Id recordId){
        Schema.SObjectType objDescribe = recordId.getSObjectType();
        return objDescribe.getDescribe();
    }

    //To return the name of the object
    public static String getObjectNameFromId(Id recordId){
        Schema.DescribeSObjectResult objName = getDescribeSObjectResultFromId(recordId);
        return objName.getName(); 
    }
    
    //To return the object's label, which may or may not match the object name
    public static String getObjectLabelFromId(Id recordId){
        Schema.DescribeSObjectResult objLabel = getDescribeSObjectResultFromId(recordId);
        return objLabel.getLabel(); 
    }

    //To return a list of all related child records
    public static List<Schema.ChildRelationship> getChildRelationshipsFromId(Id recordId){
        Schema.DescribeSObjectResult objRelation = getDescribeSObjectResultFromId(recordId);
        return objRelation.getChildRelationships();
    }
    
    //To check if there is weekend between the Start of Week and the End Date passed
    public static Boolean hasWeekend(Date endDate){
        Boolean isWeekend = false;
        system.debug('End Date Passed: '+endDate); 
        Date startOfWeek = endDate.toStartOfWeek();
        system.debug('Start of Week: '+startOfWeek);
        Integer dayOfWeek = startOfWeek.daysBetween(endDate);
        system.debug('Day of Week: '+dayOfWeek);   
        isWeekend = (dayOfWeek == 0 || dayOfWeek == 6) ? true : false;
        system.debug('isWeekend: '+isWeekend); 
        return isWeekend;
    } 
   
    //To add number of Business Days
    public static Date addBusinessDays(Date startDate, integer numberOfDays ){
        Date endDate = startDate;
        system.debug('Start Date: '+endDate);
        Integer days = numberOfDays < 0 ? -1 : 1;
        system.debug('Is Number of Days greater than or less than 0: '+days);
        while(numberOfDays != 0){
            endDate = endDate.addDays(days);
            system.debug('Number of Days: '+numberOfDays);            
            system.debug('End Date: '+endDate);
            if (!hasWeekend(endDate)){
                numberOfDays -= days;
            }
        }
        return endDate;
    }
    
    @AuraEnabled
    public static boolean checkPageAccess(String psName){
        boolean notHavingAccess = false;
        set<Id> psIds = new set<Id>();
        List<PermissionSetAssignment> psAssignments = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: userInfo.getUserId()];
        for(PermissionSetAssignment psRec : psAssignments ){
            psIds.add(psRec.PermissionSetId);
        }
        List<PermissionSet> psList = [SELECT Name FROM PermissionSet WHERE Id IN: psIds];
            for(PermissionSet psRec : psList ){
                if(psRec.Name == psName ){
                    notHavingAccess = true;    
                }
            }
        return notHavingAccess;    
    }
}