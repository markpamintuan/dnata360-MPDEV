/*------------------------------------------------------------------------
Author:        Jed Canlas
Company:       DNATA
Description:   test class
History
<Date>          <Authors Name>     <Brief Description of Change>
9/27/2018        Jed Canlas              Initial Versioin
----------------------------------------------------------------------------*/
@isTest
public class CRK_UtilityClass_Test {

  public static case createCase() {
        Id rt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Incidents').getRecordTypeId();         
        Case c = new Case(priority = 'High',recordtypeId = rt);        
        return c;      
    }

    
    
    static testMethod void test1() {  
        map<String,Recordtype_Utility_Mapping__mdt> recordtypeUtilMap = CRK_UtilityClass.getRTUtilityMap('Case');
        list<case> dummyCase = database.query(CRK_UtilityClass.constructQueryString('Case', ' Id != null limit 1'));      
    }
    

    
    
}