@isTest
private class OptInConfirmationControllerTest 
{
    
   

    @isTest
    private static void testMethodConfirm() 
    { 
        String RecTypeId= [SELECT Id 
                             FROM RecordType 
                            WHERE (Name='Person Account') 
                              AND (SobjectType='Account')].Id;

        Account acc = new Account();
        acc.RecordTypeID=RecTypeId;
        acc.FirstName='Test FName';
        acc.LastName='Test LName';
        acc.Initial_Opt_In_Date__c = system.now();
        acc.Initial_Opt_In_Reason__c = 'sdjsa';
        acc.Initial_Opt_In_Source__c = 'Pending'; 
        acc.No_Email_on_Account__c = true;
        acc.Marketing_Consent__c = true;
        acc.PersonMobilePhone = '123999123';
        acc.Org_Brand__c='EKH';
        //acc.PersonEmail = 'test@test12.com';
        //acc.No_Email_on_Account__c = true;
        insert acc;
        
        Test.startTest();
            
            OptInConfirmationController optInConfmContr = new OptInConfirmationController();
            Test.setCurrentPageReference(new PageReference('Page.OptInConfirmation')); 
            System.currentPageReference().getParameters().put('recId', acc.Id);
            System.currentPageReference().getParameters().put('optInAction', 'Confirm');
            optInConfmContr.onLoad();
            
            
            
        Test.stopTest();
    }    
    
    
    @isTest
    private static void testMethodDecline() 
    { 
        String RecTypeId= [SELECT Id 
                             FROM RecordType 
                            WHERE (Name='Person Account') 
                              AND (SobjectType='Account')].Id;

        Account acc = new Account();
        acc.RecordTypeID=RecTypeId;
        acc.FirstName='Test FName';
        acc.LastName='Test LName';
        acc.Initial_Opt_In_Date__c = system.now();
        acc.Initial_Opt_In_Reason__c = 'sdjsa';
        acc.Initial_Opt_In_Source__c = 'Pending'; 
        acc.No_Email_on_Account__c = true;
        acc.Marketing_Consent__c = true;
        acc.PersonMobilePhone = '123999123';
        acc.Org_Brand__c='EKH';
        //acc.PersonEmail = 'test12@test.com';
        //acc.No_Email_on_Account__c = true;
        insert acc;
        
        Test.startTest();
            
            OptInConfirmationController optInConfmContr = new OptInConfirmationController();
            Test.setCurrentPageReference(new PageReference('Page.OptInConfirmation')); 
            System.currentPageReference().getParameters().put('recId', acc.Id);
            System.currentPageReference().getParameters().put('optInAction', 'Decline');
            optInConfmContr.onLoad();
            
            
            
        Test.stopTest();
    }       
}