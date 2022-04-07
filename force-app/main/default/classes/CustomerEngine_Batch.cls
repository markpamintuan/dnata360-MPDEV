global class CustomerEngine_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    List<String> entityString = new List<String>();
    id masterRecordTypeId;
    map<string,List<account>> accMap = new  map<string,List<account>>();
    List<User> userList = new List<User>();
     List<id> AccountList = new List<id>();
    public CustomerEngine_Batch(List<id> testacc){
    AccountList = testacc;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      String masterRecordOwner = Label.MasterRecordOwner;
        system.debug('AccountList!!!!!!!!!!!!!!!!!!'+AccountList);
      userList =[select id from user where name=:masterRecordOwner];
      masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId();
      return Database.getQueryLocator('Select Salutation, FirstName, LastName, Id, Org_Is_Master_Account__c, Org_Master_Account__c, PersonEmail, PersonMobilePhone From Account where id in:AccountList');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
     masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId();
        List<Account> lstNewAccountsToCreate = new List<Account>();
        List<Account> lstUpdateChild = new List<Account>();
        List<Account> lstExistingAccountsnew = new List<Account>();
        set<string> emailSet = new set<string>();
        
         string query ='';
         
        for(sobject accRef : scope){
        Account  acc = (Account)accRef;
        if(acc.PersonEmail != null){
        emailSet.add(acc.PersonEmail);
        }
        }
        
        if(emailSet.size() > 0){
        query ='Select Salutation, FirstName, LastName, Id, Org_Is_Master_Account__c, Org_Master_Account__c, PersonEmail, PersonMobilePhone From Account where PersonEmail in:emailSet and Org_Master_Account__c = null and recordtypeid !=:masterRecordTypeId'; 
        }
        if(query != ''){
        lstExistingAccountsnew = new List<Account>((List<Account>)Database.query(query));
        }
        if(lstExistingAccountsnew.size() > 0){
        for(Account accountRef : lstExistingAccountsnew){
         
         if(accMap.containsKey(accountRef.PersonEmail)){
         accMap.get(accountRef.PersonEmail).add(accountRef);
         }
         else{
         accMap.put(accountRef.PersonEmail,new List<Account>{accountRef});
         }
         
         
        }
        }
    
      if(accMap.size() > 0){
      for(string personEmail:accMap.keyset())
      { 
        if(accMap.get(personEmail).size() == 1){
            for(Account a : accMap.get(personEmail)){
                a.Org_Is_Master_Account__c = true;
                lstUpdateChild.add(a);
            }
        } else {
            
            //if no record exists, create a new record
          
            Account acc = accMap.get(personEmail)[0];
                system.debug('testaccount'+acc);
                    
                    Account newMasterAccount = new Account();
                    newMasterAccount.Salutation = acc.Salutation;
                    newMasterAccount.FirstName = acc.FirstName;
                    newMasterAccount.LastName = acc.LastName;
                    newMasterAccount.Org_Is_Master_Account__c = true;
                    newMasterAccount.PersonEmail = acc.PersonEmail;
                    newMasterAccount.PersonMobilePhone = acc.PersonMobilePhone;
                    newMasterAccount.RecordTypeId = masterRecordTypeId;
                    newMasterAccount.Org_Business_Unit__c = 'Master';
                    if(userList.size() > 0){
                    newMasterAccount.ownerId = userList[0].id;
                    }
                    lstNewAccountsToCreate.add(newMasterAccount);
                    
                
            
            
        }
    
      }
      
      }
      
        if(!lstNewAccountsToCreate.isEmpty()){
                system.debug(lstNewAccountsToCreate);
                insert lstNewAccountsToCreate;
                
                Set<String> accIds = new Set<String>();
                for(Account a : lstNewAccountsToCreate){
                
                    if(accMap.get(a.PersonEmail) != null){
                    for(Account accRef:accMap.get(a.PersonEmail)){
                     accRef.Org_Master_Account__c = a.id;
                     accRef.Org_Is_Master_Account__c = false;
                     lstUpdateChild.add(accRef);
                    }
                    
                    }
                }
              
        }
        
        
        if(lstUpdateChild.size() > 0){
        update lstUpdateChild;
        }
    }

   global void finish(Database.BatchableContext BC){
   

   
   }
   
}