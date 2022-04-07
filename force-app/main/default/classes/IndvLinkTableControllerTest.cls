@isTest 
public class IndvLinkTableControllerTest 
{
    
    
    @testSetup static void dataSetup() 
    {
    

        Account a = new Account(name='test acc',phone='9494146144');
        insert a;
        Contact con = new Contact(accountid=a.id,lastname='test con',email='lnarasimha823@gmail.com');
        insert con;
        
        et4ae5__Automated_Send__c autSend = new et4ae5__Automated_Send__c();
        insert autSend ;
        
        et4ae5__IndividualEmailResult__c indv = new et4ae5__IndividualEmailResult__c();
        indv.IsError__c = false ;
        indv.et4ae5__MergeId__c= 'Test';
        indv.et4ae5__Contact__c = con.Id;
        indv.et4ae5__TriggeredSendDefinition__c= autSend.Id;
        insert indv;
        
        et4ae5__IndividualLink__c indvLnk = new et4ae5__IndividualLink__c();
        indvLnk.et4ae5__Unique_Link_ID__c = 'Test';
        indvLnk.et4ae5__Individual_Email_Result__c = indv.Id;
        insert indvLnk;
        

    }
    
    
    static testMethod void testMethod1() 
    {
        
        
        
        Test.startTest();

            IndvLinkTableController.getIndvLinks('Test');
            
       Test.stopTest();
    }
}