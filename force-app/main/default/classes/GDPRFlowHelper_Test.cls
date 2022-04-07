@isTest
public class GDPRFlowHelper_Test {
    
    @testSetup static void createData() {
        
        // insert account 
        Account acc = new Account();
        acc.Name = 'testSF';
        acc.Phone = '123456789';
        insert acc;
        system.debug('#### acc inserted' + acc);

        //create case
        Case c = new Case();        
        c.AccountId = acc.Id;
        c.Origin = 'Phone';
        c.subject = 'testSF';
        insert c;
    }
        
    @isTest 
    static void Validate_selectedRecords() { 
        // getting the account
        Account acc = new Account();
        acc = [SELECT Id FROM Account WHERE Name = 'testSF' limit 1];
        system.debug('££££ acc: ' + acc);


        // getting the contact
        Case cse = new Case();
        cse = [SELECT Id FROM Case WHERE AccountId = :acc.Id limit 1];
        system.debug('££££ cse: ' + cse);

        Wrapper_Utility.selectedRecordsDetails srdWrap = new Wrapper_Utility.selectedRecordsDetails();
        srdWrap.objectName = 'Account';
        srdWrap.recList = new List<string>();
        srdWrap.recList.add(acc.Id);
        
        Wrapper_Utility.selectedRecordsDetails srdWrap1 = new Wrapper_Utility.selectedRecordsDetails();
        srdWrap1.objectName = 'Case';
        srdWrap1.recList = new List<string>();
        srdWrap1.recList.add(cse.Id);
        
        List<Wrapper_Utility.selectedRecordsDetails> recsToProcess = new List<Wrapper_Utility.selectedRecordsDetails>();
        recsToProcess.add(srdWrap);
        recsToProcess.add(srdWrap1);
        
        try{
            GDPRFlowHelper flowHelper = new GDPRFlowHelper(recsToProcess);
        }
        catch(Exception Ex){
            
        }
    }
}