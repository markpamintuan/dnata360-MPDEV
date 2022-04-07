/**
* @author: Mark Anthony Pamintuan
* @date: 4 June 2020
* @description: Test class for AddSprintController
* @history:                
*/
@IsTest
private class AddSprintController_Test {

    static testMethod void testAddSprints(){
        
        ss_Sprint__c sprint = new ss_Sprint__c(Name = 'Sprint 1',
                                                ss_Start_Date__c = system.today(),
                                                ss_End_Date__c = system.today().addDays(11));
        insert sprint;
        
        test.startTest();
            AddSprintController.createSprints(1);   
        test.stopTest();
        
        //verify that sprint record was created
        list<ss_Sprint__c> lstNewSprints = [SELECT Sprint_Cycle__c FROM ss_Sprint__c ORDER BY ss_End_Date__c DESC];
        system.assertEquals('Sprint 2', lstNewSprints[0].Sprint_Cycle__c);
        
    }

}