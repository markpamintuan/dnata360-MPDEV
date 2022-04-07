@isTest 
public class AsyncDerwentWS_SFCustomer_Schdl_Test 
{
    
    
    @testSetup static void dataSetup() 
    {
    

        Account a = new Account(name='test acc',phone='9494146144',Org_Brand__c = 'dnata',Re_Push__c = true);
        insert a;
        Contact con = new Contact(accountid=a.id,lastname='test con',email='lnarasimha823@gmail.com');
        insert con;
        
        
        

    }
    
    
    static testMethod void testMethod1() 
    {
        
       Test.startTest();
            AsyncDerwentWebService_SFCustomer_Schdl.scheduleIt();
       Test.stopTest();
    }
}