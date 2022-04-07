@isTest
public class GDPR_DataRetentionScheduler_Test {
	static testMethod void testMethod1() 
    {
        
       Test.startTest();
            GDPR_DataRetentionScheduler dtrSchld = new GDPR_DataRetentionScheduler();
        	system.schedule('Test - '+system.now(),'0 0 0 ? * * *', dtrSchld);
       Test.stopTest();
    }
}