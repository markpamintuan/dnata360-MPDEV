/**
* @author: Mark Anthony Pamintuan
* @date: 2 June 2020
* @description: Controller of AddSprint lightning component
* @history:                
*/
public class AddSprintController {

    @AuraEnabled
    public static void createSprints(integer numberOfSprints){
        
        list<ss_Sprint__c> lstNewSprints = new list<ss_Sprint__c>();
        list<ss_Sprint__c> existingSprints = [SELECT Name, ss_Start_Date__c, ss_End_Date__c FROM ss_Sprint__c WHERE ss_End_Date__c != null AND ss_Start_Date__c != null ORDER BY ss_End_Date__c DESC];
        integer startingSprintNumber = integer.valueOf(existingSprints[0].Name.split(' ')[1]) + 1;
        Date startingStartDate = existingSprints[0].ss_End_Date__c.addDays(3);
        
        for(integer i = 0; i < numberOfSprints; i++){
            ss_Sprint__c sprint = new ss_Sprint__c();
            sprint.ss_Start_Date__c = startingStartDate;
            sprint.ss_End_Date__c = startingStartDate.addDays(11);
            sprint.Sprint_Cycle__c = 'Sprint ' + startingSprintNumber;          
            sprint.Name = 'Sprint ' + startingSprintNumber + ' (' + sprint.ss_Start_Date__c.day() + '/' + sprint.ss_Start_Date__c.month() + '-' + sprint.ss_End_Date__c .day() + '/' + sprint.ss_End_Date__c .month() + ')';            
            
            lstNewSprints.add(sprint);
            startingStartDate = sprint.ss_End_Date__c.addDays(3);
            startingSprintNumber++;
        }
        
        insert lstNewSprints;
        
    }

}