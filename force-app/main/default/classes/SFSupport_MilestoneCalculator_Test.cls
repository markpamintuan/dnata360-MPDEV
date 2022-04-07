/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   test class for MilestoneCalculator
History
<Date>          <Authors Name>     <Brief Description of Change>
9/27/2018        Jed Canlas              Initial Versioin
----------------------------------------------------------------------------*/
@isTest
public class SFSupport_MilestoneCalculator_Test {

  public static case createCase() {
        Id rt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Incidents').getRecordTypeId();         
        Case c = new Case(priority = 'High',recordtypeId = rt);        
        return c;      
    }

    
   public static void callMT (string caseId){
        MilestoneType mt = [SELECT Id, Name FROM MilestoneType where Name='In Progress' LIMIT 1];  
        SFSupport_MilestoneCalculator calculator = new SFSupport_MilestoneCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(caseId, mt.Id);  
    }

    
    static testMethod void test1() {                      
        Case c = createCase();
        insert c;
        DateTime dt = DateTime.newInstance(2018,5,5,7,59,0);
    Test.setCreatedDate(c.Id, dt);
        callMT(c.Id);        
    }
    

    
    
}