/***
 *  This is the test class for the ResultController apex class
**/
@isTest class ResultController_Test {
    
    @testSetup static void createData() {
        
        // insert account 
        Account acc = new Account();
        acc.Name = 'testSF';
        acc.Phone = '123456789';
        insert acc;
        
        // insert contact
        Contact con =  new Contact();
        con.LastName = 'testSF';
        con.Email = 'abc@gmail.com';
        insert con;
        
        //insert Opportunity
        Opportunity opp = new Opportunity();
        opp.Name='testSF';
        opp.CloseDate = Date.today().addDays(5);
        opp.StageName = 'Prospecting';
        
        insert opp;
    }
    
    // calling seach method
    @isTest static void Validate_seachRecords() {
        
        // getting the account
        Account acc = [SELECT Id FROM Account WHERE Name = 'testSF'];
        // getting the contact
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'testSF'];
        // getting the opportunity
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testSF'];
        
        List<Id> fixedSearchResults= new List<Id>();
        fixedSearchResults.add(acc.Id);
        fixedSearchResults.add(con.Id);
        fixedSearchResults.add(opp.Id);
        
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        
        // preapring the seach data
        List<Wrapper_Utility.FormFieldResultWrapper> lstSeachParam = new List<Wrapper_Utility.FormFieldResultWrapper>();
        
        // creat the seach parameters
        Wrapper_Utility.FormFieldResultWrapper obj =  new Wrapper_Utility.FormFieldResultWrapper();
        
        // adding firstname
        obj.type = 'firstname';
        obj.Name = 'testSF';
        lstSeachParam.add(obj);
        
        // adding last name
        obj =  new Wrapper_Utility.FormFieldResultWrapper();
        obj.type = 'lastname';
        obj.Name = 'testSF';
        lstSeachParam.add(obj);
        
        // adding phone
        obj =  new Wrapper_Utility.FormFieldResultWrapper();
        obj.type = 'phone';
        obj.Name = '123456789';
        lstSeachParam.add(obj);
        
        // adding email
        obj =  new Wrapper_Utility.FormFieldResultWrapper();
        obj.type = 'email';
        obj.Name = 'abc@gmail.com';
        lstSeachParam.add(obj);
        
        // setting searc h params
        ResultController.getObjectsData(lstSeachParam, null);   
        
        Test.stopTest();
    }
    
    
    // calling seach method
    @isTest static void Validate_seachRecordsParentHide() {     
        
        // getting the account
        Account acc = [SELECT ID FROM Account WHERE Name = 'testSF'];
        
        //create case
        Case c = new Case();        
        c.AccountId = acc.Id;
        c.Origin = 'Phone';
        c.subject = 'testSF';
        insert c;
        
        // insert email message
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'abc@gmail.com'; 
        newEmail.Incoming = True;
        newEmail.ToAddress= 'abc@gmail.com'; 
        newEmail.Subject = 'testSF'; 
        newEmail.TextBody = '23456 ';
        newEmail.ParentId = c.Id ;
        insert newEmail;
        
        // preapring the seach data
        List<Wrapper_Utility.FormFieldResultWrapper> lstSeachParam = new List<Wrapper_Utility.FormFieldResultWrapper>();
        
        // creat the seach parameters
        Wrapper_Utility.FormFieldResultWrapper obj =  new Wrapper_Utility.FormFieldResultWrapper();
        
        // adding last name
        obj =  new Wrapper_Utility.FormFieldResultWrapper();
        obj.type = 'lastname';
        obj.Name = 'testSF';
        lstSeachParam.add(obj);        
        
        obj =  new Wrapper_Utility.FormFieldResultWrapper();
        obj.type = 'phone';
        obj.Name = '1234567890';
        lstSeachParam.add(obj);  
        
        // setting search params
        ResultController.getObjectsData(lstSeachParam, null);   
        ResultController_Utility.fetchObjectFieldDetails(new List<Search.SearchResult>()); 
       
    }
    
    @isTest static void Validate_Wrappers() { 
      Wrapper_Utility.FormFieldsWrapper ffWrap = new Wrapper_Utility.FormFieldsWrapper();
        ffWrap.Email_Address = 'abc@a.com';
        ffWrap.First_Name = 'acc';
        ffWrap.Last_Name = 'con';
        ffWrap.Phone_Number = '122344';
        
        Wrapper_Utility.selectedRecordsDetails srdWrap = new Wrapper_Utility.selectedRecordsDetails();
        srdWrap.objectName = 'Contact';
        srdWrap.recList = new List<string>();
        
              
            
    }

}