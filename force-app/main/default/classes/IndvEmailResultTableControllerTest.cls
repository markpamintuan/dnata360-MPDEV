@isTest 
public class IndvEmailResultTableControllerTest 
{
    
    
    @testSetup static void dataSetup() 
    {
       /* Account a = new Account(name='test acc',phone='9494146144');
        insert a;
        Contact con = new Contact(accountid=a.id,lastname='test con',email='lnarasimha823@gmail.com');
        insert con;*/
        
        
        
        
       
    }
    
    
    static testMethod void testMethod1() 
    {
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        Account newAccount = new Account(
        
                                      RecordTypeID=RecTypeId,
                                    
                                      FirstName='Test FName',
                                    
                                      LastName='Test LName',
                                    
                                      PersonMailingStreet='test@yahoo.com',
                                    
                                      PersonMailingPostalCode='12345',
                                    
                                      PersonMailingCity='SFO',
                                    
                                      PersonEmail='test@yahoo.com',
                                    
                                      PersonHomePhone='1234567',
                                    
                                      PersonMobilePhone='12345678' 
        
                                );

        insert newAccount;
        String ContactID = [SELECT PersonContactId  FROM Account WHERE ID=:newAccount.Id].PersonContactId;
        
        et4ae5__Automated_Send__c autSend = new et4ae5__Automated_Send__c();
        insert autSend ;
        
        et4ae5__IndividualEmailResult__c indv = new et4ae5__IndividualEmailResult__c();
        indv.IsError__c = false ;
        indv.et4ae5__MergeId__c= 'Test';
        indv.et4ae5__Contact__c = ContactID;
        indv.et4ae5__TriggeredSendDefinition__c= autSend.Id;
        insert indv;
        
        et4ae5__IndividualLink__c indvLnk = new et4ae5__IndividualLink__c();
        indvLnk.et4ae5__Unique_Link_ID__c = 'Test';
        indvLnk.et4ae5__Individual_Email_Result__c = indv.Id;
        insert indvLnk;
       
       
       
       
       Test.startTest();
            IndvEmailResultTableController.getBigObject(newAccount.Id);
       Test.stopTest();
    }
    
    
    
}