/**
* @author: Mark Anthony Pamintuan
* @date: 14 June 2020
* @description: Milestone Calculator for SF Support
* @history:                
*/
global class SFSupport_MilestoneCalculator implements Support.MilestoneTriggerTimeCalculator {
   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){

        MilestoneType mt = new MilestoneType();
        integer milestoneTimeToSet = 0;
        mt = [SELECT Name FROM MilestoneType WHERE Id =: milestoneTypeId];
         
        Case c = [SELECT Id, CreatedDate, LastModifiedDate, sf_ReleaseDate__c FROM Case WHERE Id =: caseId];

        //SF Change Request 
        if(mt.Name == 'In Progress'){
            Long dt1Long = c.LastModifiedDate.getTime();
            Long dt2Long = c.sf_ReleaseDate__c.getTime(); 
            Long milliseconds = dt2Long - dt1Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            
            milestoneTimeToSet = integer.valueOf(minutes);   
        }
        
        return milestoneTimeToSet;
        
    }

}