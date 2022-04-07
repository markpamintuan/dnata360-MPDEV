@isTest 
public class ReconciliationBatch_Test 
{
	static testMethod void testMethod1() 
    {
        String pageNumber = '51808554422131232123';
        List<Reconciliation__c> lstRec= new List<Reconciliation__c>();
        
            Reconciliation__c rec = new Reconciliation__c();
            rec.Next_Page_Id__c = pageNumber;
        
        
            
        /***
         * This is a test class for recociliation batch class.
        **/
        insert rec;
        
        Test.startTest();
	    Test.setMock(HttpCalloutMock.class, new Reconciliation_HTTPResponse_Test());
        Booking_Reconciliation_Batch obj = new Booking_Reconciliation_Batch();        	
        DataBase.executeBatch(obj);             
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
    {
        String pageNumber = '5185512327';
        List<Reconciliation__c> lstRec= new List<Reconciliation__c>();
        
            Reconciliation__c rec = new Reconciliation__c();
            rec.Next_Page_Id__c = pageNumber;
            
        /***
         * This is a test class for recociliation batch class.
        **/
        insert rec;
        
        Test.startTest();
        Booking_Reconciliation_Batch obj = new Booking_Reconciliation_Batch();
		Test.setMock(HttpCalloutMock.class, new Reconciliation_HTTPResponse_Test());           
        DataBase.executeBatch(obj);            
        Test.stopTest();
    }
    
    
}