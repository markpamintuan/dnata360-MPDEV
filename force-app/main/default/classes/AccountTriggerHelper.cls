/**************************************************************************************************
* Name               : AccountTriggerHelper 
* Description        : This is the helper class for Account trigger           
* Created Date       : 08-Aug-2018                                                                 
* Created By         : PwC                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        PwC        08-Aug-2018    Initial version
* v1.1        SriBala    20-Mar-2019    Checking for Accounts with DFO id
* v1.2        Kaavya     24-Apr-2019    Fix for DFO Account check
* v1.3        Kaavya     01-Jul-2019    Fix for DFO account same email
* v1.5        Merul      15-Sep-2019    Removing deleted DFO account from trigger context
* v1.6        SriBala    21-Oct-2019    Fix for Email Brand on update of email
* v1.7        Keith      1-Nov-2019     Adding logic to ensure the country code and phone numbers are kept in sync
* v1.8        Keith      19-Dec-2019    Fix for click to dial for phone number validation
* v1.9        Keith      22-Jan-2020    Bug Fix for checking the values of the country codes
* v1.10       Sri Bala   05-Jan-2019    Marketing Optin Process
* v1.11       Evendo     02-Feb-2019    Updating Loyalty Id field from skywards number field before update.
* v1.12       Ravi       05-Jan-2020    Updated populateExternalId to avoid the SOQLs
* v1.13       Ravi       20-Feb-2020    Update the logic of Master Account Creation
* v1.14       Sri Bala   26-Feb-2019    Commented PersonHasOptedOutOfEmail part of code in marketing optin process
* v1.15       Sri Bala   04-Mar-2020    Re-push set to true for DFO Accounts
* v1.16       Mark       16-Feb-2021    Added method populateAccountBusinessUnit
**************************************************************************************************/
public class AccountTriggerHelper {

    private static Set<String> queryParameters {get;set;}
    private static Map<String, List<String>> mapFieldValue {get;set;}
    public static Boolean DFOAccount{get;set;}
    public static Boolean BlockAccountTrigger = false;
    
    public static Boolean RunMarketingProcessLogic = true;
    
    static Set<String> countryCodeValues;//1.7
    //This method will prepare a soql to fetch the account details
    //It uses a custom settings, called as Customer Matching fields where admin can store the field names
    //by which the company wants to filter the records.
    
    public static String getQueryString(){
        
        mapFieldValue = new Map<String, List<String>>();
        //Select Salutation, FirstName, LastName, Id, Org_Is_Master_Account__c, Org_Master_Account__c, PersonEmail, PersonMobilePhone From Account
        String query = 'Select Id, Salutation, FirstName, LastName,RecordTypeId, Org_Brand__c, Org_Is_Master_Account__c,Org_Master_Account__c, PersonMobilePhone, DFO_Id__c,Child_IDs__c,';
        List<Customer_Matching_Fields__c> cmf = Customer_Matching_Fields__c.getall().values();
        system.debug(cmf);
        cmf.sort();
        for(Customer_Matching_Fields__c rec : cmf){
            system.debug(rec.Field__c);
            //queryParameters.add(rec.Field__c);
            query += rec.Field__c + ',';
            mapFieldValue.put(rec.Field__c, new List<String>());
        }
        
        query = query.removeEnd(',') + ' From Account ';
        system.debug(query);
        return query;
    }
    
    //this method will be called from the trigger code
    //this will first check for the duplicate records with same details
    //if there are no existing duplicates it will simply inserts the records,
    //if there is already a records exists with same details based on the custom settings fields
    //like Email, Mobile and Brand
    //If there is already a record exists with xyz@abc.com for Brand 1 
    //and you are trying to insert a new record with same details and Brand 2
    //the below code will create a new record with Business Unit as Master
    
    public static void linkMasterAccountAfter(List<Account> lstAccounts){
        
        String masterRecordOwner = Label.MasterRecordOwner;
        
        List<User> userList =[select id from user where name=:masterRecordOwner];
        
        String query = getQueryString();
        system.debug('query prepared from method ');
        system.debug(query);
        //query = 'Select Salutation, FirstName, LastName, Id, Org_Is_Master_Account__c, Org_Master_Account__c, PersonEmail, PersonMobilePhone From Account';
        
        map<string, list<Account>> mapAccounts =new map<string, list<Account>>();

        
        //capture the key fields and their values in order to extract the existing records        
        for(Account a : lstAccounts){
            for(String key : mapFieldValue.keySet()){
                List<String> tempLst = mapFieldValue.get(key);
                tempLst.add((String)a.get(key));
                mapFieldValue.put(key, tempLst);
            }
        }
        
        //once a query is prepared and the criteria in the query
        
        system.debug(mapFieldValue);
        query += ' WHERE ';
        for(String key : mapFieldValue.keySet()){
            query += key + ' IN ' + getValuesInQuotes(mapFieldValue.get(key)) + ' OR '; 
        }
        
        query = query.removeEnd(' OR ');
        system.debug(query);
        
        //execute the query and get the results        
        List<Account> lstNewAccountsToCreate = new List<Account>();
        List<Account> lstExistingAccounts = new List<Account>((List<Account>)Database.query(query));
        system.debug(lstExistingAccounts);
        system.debug(lstExistingAccounts.size()); 
        

        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId();
        map<string, Account> mapMasterAccounts = new map<string, Account>();
        map<string, Account> mapMasterAccountInsert = new map<string, Account>();
        map<Id, Account> mapAccountToUpdate = new map<Id, Account>();

        //if no existing records found, means there are no master records
        //so for all the new records mark them as Master Account...
        
        //Note: By default the first account will be the Master account.
        
        for(Account objA : lstExistingAccounts){
            for(String key : mapFieldValue.keySet()){
                string keyValue = objA.get(key) != null ? string.valueOf(objA.get(key)) : null;
                if(keyValue == null)
                    continue;
                if(!mapAccounts.containsKey(keyValue))
                    mapAccounts.put(keyValue, new list<Account>());
                mapAccounts.get(keyValue).add(objA);
            }
        }

        system.debug('mapAccounts  is : '+mapAccounts.keySet());

        if(!mapAccounts.isEmpty()){
            for(string key : mapAccounts.keySet()){
                if(mapAccounts.get(key).size() > 1){
                    for(Account objAcc : mapAccounts.get(key)){
                        if(objAcc.RecordTypeId == masterRecordTypeId){
                            mapMasterAccounts.put(key, objAcc);
                        }

                        if(!mapMasterAccountInsert.containsKey(key)){
                            Account newMasterAccount = new Account();
                            newMasterAccount.Salutation = objAcc.Salutation;
                            newMasterAccount.FirstName = objAcc.FirstName;
                            newMasterAccount.LastName = objAcc.LastName;
                            newMasterAccount.Org_Is_Master_Account__c = true;
                            newMasterAccount.PersonEmail = objAcc.PersonEmail;
                            newMasterAccount.PersonMobilePhone = objAcc.PersonMobilePhone;
                            newMasterAccount.RecordTypeId = masterRecordTypeId;
                            newMasterAccount.Org_Business_Unit__c = 'Master';
                            if(userList.size() > 0){
                                newMasterAccount.ownerId = userList[0].id;
                            }
                            mapMasterAccountInsert.put(key, newMasterAccount);
                        }
                    }
                }
            }

            for(string key : mapMasterAccounts.keySet()){
                if(mapMasterAccountInsert.containsKey(key))
                    mapMasterAccountInsert.remove(key);
            }
    
            if(!mapMasterAccountInsert.isEmpty()){
                insert mapMasterAccountInsert.values();
                for(string key : mapMasterAccountInsert.keySet()){
                    mapMasterAccounts.put(key, mapMasterAccountInsert.get(key) );
                }
            }
    
            for(string key : mapAccounts.keySet()){
                for(Account objAcc : mapAccounts.get(key)){
                    if(mapMasterAccounts.get(key) != null && mapMasterAccounts.get(key).Id != null && objAcc.Id != mapMasterAccounts.get(key).Id && objAcc.Org_Master_Account__c == null ){
                        mapAccountToUpdate.put(
                            objAcc.Id, 
                            new Account(
                                Id = objAcc.Id,
                                Org_Is_Master_Account__c = false,
                                Org_Master_Account__c = mapMasterAccounts.get(key).Id
                            )
                        );
                    }else if( mapMasterAccounts.get(key) == null){
                        mapAccountToUpdate.put(
                            objAcc.Id, 
                            new Account(
                                Id = objAcc.Id,
                                Org_Is_Master_Account__c = true
                            )
                        );
                    }
                }
            }
    
            if(!mapAccountToUpdate.isEmpty()){
                update mapAccountToUpdate.values();
            }

        }


        /*if(lstExistingAccounts.size() == 1){
            for(Account a : lstExistingAccounts){
                a.Org_Is_Master_Account__c = true;
            }
            update lstExistingAccounts;
            system.debug('existing account updated ' + lstExistingAccounts.size() ) ;
        } else {
            
            //if no record exists, create a new record
            system.debug('testaccount1'+lstExistingAccounts);
            //1.13
            Account newMasterAccount;
            
            string MasterAccountId;
            
            map<string, list<Account>> mapUniqueAccounts = new map<string, list<Account>>();
            
            
    
            for(Account objAcc : lstExistingAccounts) {
                for(string key : mapFieldValue.keySet()){
                    list<Account> lst = mapUniqueAccounts.containsKey(key) ? mapUniqueAccounts.get(key) : new list<Account>();
                    lst.add(objAcc);
                    mapUniqueAccounts.put(key, lst);
                    
                    if(objAcc.RecordTypeId == masterRecordTypeId){
                        mapMasterAccounts.put(key, objAcc);
                    }
                    
                }
            }
    
            for(string key : mapMasterAccounts.keySet()){
                if(mapMasterAccountInsert.containsKey(key))
                mapMasterAccountInsert.remove(key);
            }
    
            if(!mapMasterAccountInsert.isEmpty()){
                insert mapMasterAccountInsert.values();
                for(string key : mapMasterAccountInsert.keySet()){
                    mapMasterAccounts.put(key, mapMasterAccountInsert.get(key) );
                }
            }
    
            for(string key : mapUniqueAccounts.keySet()){
                for(Account objAcc : mapUniqueAccounts.get(key)){
                    if(mapMasterAccounts.get(key) != null && mapMasterAccounts.get(key).Id != null && objAcc.Id != mapMasterAccounts.get(key).Id && objAcc.Org_Master_Account__c == null ){
                        mapAccountToUpdate.put(
                            objAcc.Id, 
                            new Account(
                                Id = objAcc.Id,
                                Org_Is_Master_Account__c = false,
                                Org_Master_Account__c = mapMasterAccounts.get(key).Id
                            )
                        );
                    }
                }
            }
    
            if(!mapAccountToUpdate.isEmpty()){
                update mapAccountToUpdate.values();
            }
            /*
            for(Account acc : lstExistingAccounts) {
                system.debug('testaccount '+acc);
                if(acc.Org_Is_Master_Account__c && acc.DFO_Id__c == null && acc.Child_IDs__c==null){
                    if(acc.RecordTypeId == masterRecordTypeId){
                        MasterAccountId = acc.Id;
                        break;
                    }
                    newMasterAccount = new Account();
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
                    //lstNewAccountsToCreate.add(newMasterAccount);
                    //break;
                }
            }
    
            if(string.isEmpty(MasterAccountId) && newMasterAccount != null){
                lstNewAccountsToCreate.add(newMasterAccount);
                insert lstNewAccountsToCreate;
            }
    
            if(MasterAccountId != null){
                Set<String> accIds = new Set<String>();
                for(Account a : lstExistingAccounts){
                    if(a.Id != MasterAccountId && (a.DFO_Id__c == null || a.Child_IDs__c == null)){
                        accIds.add(a.Id);
                    }
                }
            }
            
            if(!lstNewAccountsToCreate.isEmpty()){
                system.debug(lstNewAccountsToCreate);
                insert lstNewAccountsToCreate;
                
                Set<String> accIds = new Set<String>();
                for(Account a : lstExistingAccounts){
                    if(a.Id != null && (a.DFO_Id__c == null || a.Child_IDs__c == null)){
                        accIds.add(a.Id);
                    }
                }
                /*for(Account acc : lstExistingAccounts){
                    accIds.add(acc.Id);
                    //acc.Org_Master_Account__c = lstNewAccountsToCreate[0].Id;
                }* /             
                    updateExistingAccountMaster(accIds, lstNewAccountsToCreate[0].Id);
                //update lstExistingAccounts;* /
            }* /
        }*/
    }
    
    //this method is used to return the string from list of array values
    //ex: abc;pqr;lmn = ('abc','pqr','lmn')
    private static String getValuesInQuotes(List<String> lst){ 
        string condition ='(';
        for(String strid : lst){
            condition += '\''+strid+'\',';
        }
        condition = condition.substring(0,condition.length()-1);
        condition += ')';
        return condition;
    }
    
    
    //Populate External Id
    public static void populateExternalId(List<account> accNewList)
    {
       List<Account> lstAccToUpdate = new List<Account>();
       Set<Id> accSet = new Set<ID>();
       for(Account acc: accNewList)
       {
           accSet.add(acc.Id); 
           //Added by sri bala v1.6
           if(trigger.isUpdate && trigger.isBefore){
               if(acc.PersonEmail != null)
               {
                   system.debug('Entered the condition');
                   acc.EmailBrand__c = acc.PersonEmail+''+acc.Org_Brand__c;
                   system.debug('Email Brand'+acc.EmailBrand__c);
               }
               else if(acc.PersonEmail == null)
               {
                   acc.EmailBrand__c = '';
                   system.debug('Email Brand'+acc.EmailBrand__c);
               }
           }
           // end of v1.6
       }
        
       
       for(Account acc: [SELECT id,
                                MobileBrand__c,
                                EmailBrand__c,
                                PersonMobilePhone,
                                Org_Brand__c,
                                PersonEmail   
                           FROM account 
                          WHERE id IN:accSet])// This is for querying accounts that are created after the DFO Logic (After insert)
       {
           system.debug('Brand +++ '+acc.Org_brand__c);
           if(acc.PersonMobilePhone != null)
           {
               acc.MobileBrand__c = acc.PersonMobilePhone+''+acc.Org_Brand__c;
           }
           if(acc.PersonEmail != null)
           {
               acc.EmailBrand__c = acc.PersonEmail+''+acc.Org_Brand__c;
           }
           
           if(trigger.isAfter)
           {
             
              Account accTemp = new Account(id=acc.Id,
                                            MobileBrand__c = acc.MobileBrand__c,
                                            EmailBrand__c = acc.EmailBrand__c);
              lstAccToUpdate.add(accTemp);                               
           } 
          
       }
       
       if(lstAccToUpdate.size() > 0)
       {
           system.debug('Update DFO Accounts  '+lstAccToUpdate);
           update lstAccToUpdate;
       }
      
    }
    
    //This method is asyn method as if we update the accounts in same context it will lead to recursion
    //The below method will update the given list of accounts with given masterrecord id
    
    
    /* v1.16 commented out to improve code coverage. not being called anywhere
    @future
    public static void updateExistingAccountMaster(Set<String> accIds, String masterReqId){
        List<Account> lst = new List<Account>();
        system.debug(accIds);
        for(String recId : accIds){
            Account a = new Account(Id = recId);
            a.Org_Master_Account__c = masterReqId;
            a.Org_Is_Master_Account__c = false;
            lst.add(a);
        }
        update lst;
    }
    */

    public static void preventDeletion(List<Account> lAccounts){
        system.debug('### is before delete lAccounts: ' + lAccounts);
        for(Account acc: lAccounts){
            system.debug('### is before delete acc: ' + acc);
            if(acc.Org_Prevent_Deletion__c){
                acc.addError('This account cannot be deleted');
            }  
        }
    }
    //1.7 KR bad values should be removed before this method is called.
    public static void syncMobilePhoneCountryAndNumber(List<Account> lAccounts, Map<Id,Account> oldAccountMap){
        if(countryCodeValues == null) populatePhoneCountryCodes();
        for(Account acc: lAccounts){
            Boolean picklistValuesAreChanged = false;
            
            //do before insert first
            if(oldAccountMap == null){
                if(acc.Mobile_Country_Code__c != null && acc.Mobile_Phone_Number__c !=null){ //These will only be null from the integration
                    acc.PersonMobilePhone = acc.Mobile_Country_Code__c + ' ' + acc.Mobile_Phone_Number__c;
    
                    //Create Avaya format numbers
                    acc.Avaya_Mobile_Phone_Formats__c =createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                    acc.Mobile_Phone_Number_ClickToDial__c = createClickToDialField(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c); //v1.8
                    picklistValuesAreChanged = true;
                }
    
                if(acc.PersonMobilePhone != null && picklistValuesAreChanged == false){ //The integration code should come in here. 
                    String sFullNumber = ''; //declared to prevent a null pointer
                    sFullNumber = acc.PersonMobilePhone;
                    Integer indexOfSpace = -1;
                    if(sFullNumber != null) indexOfSpace = sFullNumber.indexOf(' ');
                    
                    if(indexOfSpace != -1){
                        String sCountryCode = sFullNumber.left(indexOfSpace);
                        String sRemainingNumber = sFullNumber.Right(sFullNumber.length() - (indexOfSpace+1));
                        
                        try{
                            if(countryCodeValues.contains(sCountryCode)){ //Check IF the value is contained in the picklist
                                acc.Mobile_Country_Code__c = sCountryCode;
                                acc.Mobile_Phone_Number__c = sRemainingNumber.replaceFirst('^0+', '').replaceAll('[^a-zA-Z0-9\\s+]', '');
                                //Create Avaya format numbers
                                acc.Avaya_Mobile_Phone_Formats__c =createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                                acc.Mobile_Phone_Number_ClickToDial__c = createClickToDialField(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c); //v1.8
                            }else{
                                acc.Mobile_Country_Code__c = '';
                                acc.Mobile_Phone_Number__c = '';
                            }
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        }
                    }else{
                        acc.Mobile_Country_Code__c = '';
                        acc.Mobile_Phone_Number__c = '';
                    }
                   
                }
            }  
    
            if(oldAccountMap != null){
                //picklist values have changed
                if(acc.Mobile_Country_Code__c != oldAccountMap.get(acc.Id).Mobile_Country_Code__c || 
                    acc.Mobile_Phone_Number__c != oldAccountMap.get(acc.Id).Mobile_Phone_Number__c ){
                        acc.PersonMobilePhone = acc.Mobile_Country_Code__c + ' ' + acc.Mobile_Phone_Number__c;
                        
                        //Create Avaya format numbers
                        acc.Avaya_Mobile_Phone_Formats__c = createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                        acc.Mobile_Phone_Number_ClickToDial__c = createClickToDialField(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c); //v1.8
                        picklistValuesAreChanged = true;
                }
    
                if(acc.PersonMobilePhone != oldAccountMap.get(acc.Id).PersonMobilePhone && 
                    picklistValuesAreChanged == false){
                    String sFullNumber = acc.PersonMobilePhone;
                    Integer indexOfSpace = -1;
                    if(sFullNumber != null) indexOfSpace = sFullNumber.indexOf(' ');
    
                    if(indexOfSpace != -1){
                        String sCountryCode = sFullNumber.left(indexOfSpace);
                        String sRemainingNumber = sFullNumber.Right(sFullNumber.length() - (indexOfSpace+1));
                        try{
                            if(countryCodeValues.contains(sCountryCode)){ //Check IF the value is contained in the picklist
                                acc.Mobile_Country_Code__c = sCountryCode;
                                acc.Mobile_Phone_Number__c = sRemainingNumber.replaceFirst('^0+', '').replaceAll('[^a-zA-Z0-9\\s+]', '');
                                //Create Avaya format numbers
                                acc.Avaya_Mobile_Phone_Formats__c =createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                                acc.Mobile_Phone_Number_ClickToDial__c = createClickToDialField(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c); //v1.8
                            }else{
                                acc.Mobile_Country_Code__c = '';
                                acc.Mobile_Phone_Number__c = '';
                            }
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        }
                    }else{
                        try{
                            acc.Mobile_Country_Code__c = '';
                            acc.Mobile_Phone_Number__c = '';
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        } 
                    } 
                }
    
            } 
        } 
    }
    
    //1.7 KR bad values should be removed before this method is called.
    public static void syncPhoneCountryAndNumber(List<Account> lAccounts, Map<Id,Account> oldAccountMap){
        if(countryCodeValues == null) populatePhoneCountryCodes();
        for(Account acc: lAccounts){
            Boolean picklistValuesAreChanged = false;
            
            //do before insert first
            if(oldAccountMap == null){
                if(acc.Phone_Country_Code__c != null && acc.Phone_Number__c !=null){ //These will only be null from the integration
                    acc.Phone = acc.Phone_Country_Code__c + ' ' + acc.Phone_Number__c;
    
                    //Create Avaya format numbers
                    acc.Avaya_Phone_Number_Formats__c =createAvayaFormatPhoneNumbers(acc.Phone_Country_Code__c, acc.Phone_Number__c);
                    picklistValuesAreChanged = true;
                }
    
                if(acc.Phone != null && picklistValuesAreChanged == false){ //The integration code should come in here. 
                    String sFullNumber = ''; //declared to prevent a null pointer
                    sFullNumber = acc.Phone;
                    Integer indexOfSpace = -1;
                    
                    if(sFullNumber != null) indexOfSpace = sFullNumber.indexOf(' ');
                    if(indexOfSpace != -1){
                        String sCountryCode = sFullNumber.left(indexOfSpace);
                        String sRemainingNumber = sFullNumber.Right(sFullNumber.length() - (indexOfSpace+1));
                        
                        try{
                            if(countryCodeValues.contains(sCountryCode)){ //check if valid picklist value
                                acc.Phone_Country_Code__c = sCountryCode;
                                acc.Phone_Number__c = sRemainingNumber.replaceFirst('^0+', '').replaceAll('[^a-zA-Z0-9\\s+]', '');
                                //Create Avaya format numbers
                                acc.Avaya_Phone_Number_Formats__c =createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                        
                            }else{
                                acc.Phone_Country_Code__c = '';
                                acc.Phone_Number__c = '';
                            }
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        }
                    }else{
                        acc.Phone_Country_Code__c = '';
                        acc.Phone_Number__c = '';
                    }
                   
                }
            }  
    
            if(oldAccountMap != null){
                //picklist values have changed
                if(acc.Phone_Country_Code__c != oldAccountMap.get(acc.Id).Phone_Country_Code__c || 
                    acc.Phone_Number__c != oldAccountMap.get(acc.Id).Phone_Number__c ){
                        acc.Phone = acc.Phone_Country_Code__c + ' ' + acc.Phone_Number__c;
                        
                        //Create Avaya format numbers
                        acc.Avaya_Phone_Number_Formats__c = createAvayaFormatPhoneNumbers(acc.Phone_Country_Code__c, acc.Phone_Number__c);
                        picklistValuesAreChanged = true;
                }
    
                if(acc.Phone != oldAccountMap.get(acc.Id).Phone && 
                    picklistValuesAreChanged == false){
                    String sFullNumber = acc.Phone;
                    Integer indexOfSpace = -1;
                    
                    if(sFullNumber != null) indexOfSpace = sFullNumber.indexOf(' ');
                    
                    if(indexOfSpace != -1){
                        String sCountryCode = sFullNumber.left(indexOfSpace);
                        String sRemainingNumber = sFullNumber.Right(sFullNumber.length() - (indexOfSpace+1));
                        try{
                            if(countryCodeValues.contains(sCountryCode)){ //check if valid picklist value
                                acc.Phone_Country_Code__c = sCountryCode;
                                acc.Phone_Number__c = sRemainingNumber.replaceFirst('^0+', '').replaceAll('[^a-zA-Z0-9\\s+]', '');
                                //Create Avaya format numbers
                                acc.Avaya_Phone_Number_Formats__c =createAvayaFormatPhoneNumbers(acc.Mobile_Country_Code__c, acc.Mobile_Phone_Number__c);
                        
                            }else{
                                acc.Phone_Country_Code__c = '';
                                acc.Phone_Number__c = '';
                            }
                        
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        }
                    }else{
                        try{
                            acc.Phone_Number__c = '';
                            acc.Phone_Country_Code__c = '';
    
                            // do something here with country code.
                            
                            // Add a condition here that strips the 0's and check for the phone number formats.
                            // We should guess the number based on the domain of the customer. (we need to keep a map of this)
                            // it can only be a guess
                            // Remove leading zeros.
                        }catch(Exception e){
                            System.debug('£££ the following error has occured: ' + e);
                        } 
                    } 
                }
    
            } 
        } 
    }
    
    /* v1.16 commented out to improve code coverage. not being called anywhere
    //v1.7
    private static String removeLeadingZerosFromNumber(String phoneNumber){
        String phoneNumberWithoutLeadingZeros = '';
        while(phoneNumber.startsWith('0')){
            phoneNumber = phoneNumber.removeStart('0');
            phoneNumberWithoutLeadingZeros = phoneNumber;
        }
        return phoneNumberWithoutLeadingZeros;
    }
    */

    //1.7
    public static void populatePhoneCountryCodes(){
        countryCodeValues = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Account.Phone_Country_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            countryCodeValues.add(pickListVal.getValue()); //V1.9 adding .getValue instead of .getLabel
        }     
    }
    
    //1.7 KR bad values should be removed before this method is called.
    static String createAvayaFormatPhoneNumbers(String countrycode, String phoneNumber){
        String sPhoneNumberOptions = '';
        sPhoneNumberOptions += '00'+countrycode + phoneNumber + '\n';
        sPhoneNumberOptions += '+'+countrycode + phoneNumber + '\n';
        sPhoneNumberOptions += '0' + phoneNumber + '\n';
        sPhoneNumberOptions +=  phoneNumber + '\n';
    
        return sPhoneNumberOptions;
    }
    
    //1.8 KR bad values should be removed before this method is called.
    //This method is used for the avaya click to dial outbound
    static String createClickToDialField(String countrycode, String phoneNumber){
        String sPhoneNumberOptions = '';
        sPhoneNumberOptions += '00'+ countrycode + phoneNumber;
        return sPhoneNumberOptions;
    }
    
    
    
    public static void validatePhone(List<Account> lAccounts){
        
        for(Account acc: lAccounts){
            
            Pattern pat = Pattern.compile('([A-Z]+)');
            Pattern pat1 = Pattern.compile('([a-z]+)');
            if(acc.personmobilephone != null){
                Matcher matcher = pat.matcher(acc.personmobilephone);
                Matcher matcher1 = pat1.matcher(acc.personmobilephone);
                
                Boolean matches = matcher.find();
                Boolean matches1 = matcher1.find();
                if(matches){
                    acc.personmobilephone = '';
                }
                
                if(matches1){
                    acc.personmobilephone = '';
                }
            }
            
        }
        
    }
    
    
    public static AccountTriggerHelper.respondWrapper DFOAccountCreation(List<Account> lAccounts)
    {
         map<Id,Account> IDSet = new map<ID,Account>();
         AccountTriggerHelper.respondWrapper  accRespWrap = new AccountTriggerHelper.respondWrapper(); 
         
         DFOAccount = false;
         //try{
            
            list<Account> deleteList = new list<Account>();
            list<Account> updateList = new list<Account>();
            map<Id,Account> accupdateMap = new map<ID,Account>();
            map<Id,Account> accDeleteMap = new map<ID,Account>();
            
            map<String,Account> dfoMap = new map<String,Account>();
            Set<String> dfoSet = new Set<String>();
            Set<String> childIdSet = new Set<String>();
            map<string,Account>emailSet = new map<string,Account>();
            List<DfoAccount__c> dfo = new List<DfoAccount__c>();
            List<Account> updateAcclist = new List<Account>();
            
            /*Added for v1.2 */
            Set<String> newDFOIdSet = new Set<String>();
            Set<String> newEmailSet = new Set<String>();
            
            Map<String,List<Account>> newEmailAccmap = new Map<String,List<Account>>(); //Added for v1.3
            Map<String,Id> dfoaccmap = new Map<String,Id>();
            Map<String,Account> emailaccmap = new Map<String,Account>();
            
            for(Account newAccount:lAccounts){
                if(newAccount.Org_Brand__c == 'dnata'){
                    if(newAccount.DFO_Id__c!=null)
                        newDFOIdSet.add(newAccount.DFO_Id__c); 
                    
                    if(newAccount.PersonEmail!=null){
                        newEmailSet.add(newAccount.PersonEmail);
                        //Added for v1.3
                        List<Account> newEmailAccList = new List<Account>();
                        if(newEmailAccmap.get(newAccount.PersonEmail)==null)
                            newEmailAccList.add(newAccount);
                        else{
                            newEmailAccList=newEmailAccmap.get(newAccount.PersonEmail);
                            newEmailAccList.add(newAccount);
                        }
                        newEmailAccmap.put(newAccount.PersonEmail,newEmailAccList );
                        //End of v1.3
                    }
                    
                    IDSet.put(newAccount.Id,newAccount);
                }
            }
            //querying all dfo accounts which matches with the new Account dfo id
            for(DfoAccount__c dfoacc: [Select id,Account__c,Child_id__c from DfoAccount__c where child_id__c in :newDFOIdSet]){
                system.debug('dfoacc'+dfoacc);
                dfoaccmap.put(dfoacc.Child_id__c,dfoacc.Account__c );
            }
            //list of all accounts having the same email address as the new account email address
            for(Account emailacc:[Select id,PersonEmail,Count_of_Child_Records__c,DFO_ID__c,Child_IDs__c from Account where Org_Brand__c='dnata' and PersonEmail in:newEmailSet AND ID NOT IN:IDSet.keySet()]){
                emailaccmap.put(emailacc.PersonEmail,emailacc);
            }            
            /* End of v1.2 */
                    
            //loop all new accounts
            for(Account newAccount:lAccounts){
                if(newAccount.Org_Brand__c == 'dnata'){//added as part of v1.2 
                //IDSet.put(newAccount.Id,newAccount); //commented as part of v1.2
                
                //enters only if the new account have DFo Id
                if(newAccount.DFO_Id__c!=null || newAccount.Child_IDs__c!=null){
                   
                    
                    /*Added for v1.2 */
                    // if dfo account match
                    if(dfoaccmap.get(newAccount.DFO_Id__c)!=null){
                        system.debug('DFO ID');
                        //link the new account to exisiting account
                        Account tempAcc = new Account();
                        tempAcc.Id = dfoaccmap.get(newAccount.DFO_Id__c);
                        tempAcc.Re_push__c = true;//v1.15
                        system.debug('temp'+tempAcc);
                        updatelist.add(tempAcc); 
                        //delete new account
                        deleteList.add(newAccount.clone(true));
                    }  
                    // if email matches with existing accounts
                    else if(emailaccmap.get(newAccount.PersonEmail)!=null){
                        system.debug('Email');
                        Account exisitngAcc= emailaccmap.get(newAccount.PersonEmail);
                        if(newAccount.DFO_Id__c!=null || newAccount.Child_IDs__c!=null){
                            
                            //add the new DFO Id to the existing acc dfo id 
                            if(exisitngAcc.Child_IDs__c!=null && exisitngAcc.Child_IDs__c!='')
                                exisitngAcc.Child_IDs__c = exisitngAcc.Child_IDs__c+';'+newAccount.DFO_ID__c;
                            else
                                exisitngAcc.Child_IDs__c = newAccount.DFO_ID__c;
                            //increase the count by 1
                            if(exisitngAcc.Count_of_Child_Records__c != null && exisitngAcc.Count_of_Child_Records__c>0)
                                exisitngAcc.Count_of_Child_Records__c = exisitngAcc.Count_of_Child_Records__c+1;
                            else
                            {
                                exisitngAcc.Count_of_Child_Records__c = 0;
                                exisitngAcc.Count_of_Child_Records__c = exisitngAcc.Count_of_Child_Records__c+1;                                    
                            }
                            
                            if(exisitngAcc.DFO_Id__c==null)
                                exisitngAcc.DFO_Id__c= newAccount.DFO_Id__c; 
                            exisitngAcc.Re_Push__c = true; //v1.15
                            DfoAccount__c dfoObj = new DfoAccount__c();
                            //insert the new DFo ID of the exisiting Account into the DfoAccount object
                            dfoObj.Account__c = exisitngAcc.Id;
                            dfoObj.Child_Id__c = newAccount.DFO_Id__c;
                            dfo.add(dfoObj);
                            system.debug('dfo'+dfo);
                            //update existing account
                            updatelist.add(exisitngAcc);
                            //delete new Account
                            deletelist.add(newAccount.clone(true));
                            
                        }
                    }
                    // if same email within the new batch of accounts 
                    // Added for v1.3
                    else if(newAccount.PersonEmail != null && newEmailAccmap.get(newAccount.PersonEmail).size()>1){
                    
                        if(newAccount.id ==newEmailAccmap.get(newAccount.PersonEmail)[0].id){
                            //Taking the 1st account in the set with same email address as the main account
                            Account firstAcc= newEmailAccmap.get(newAccount.PersonEmail)[0]; 
                            
                            Account firstaccObj = new Account(id = firstAcc.id);                        
                            firstaccObj.Child_IDs__c = firstAcc.DFO_Id__c;
                            firstaccObj.Count_of_Child_Records__c=1;
                            
                            DfoAccount__c dfochild = new DfoAccount__c();
                            dfochild.Account__c = firstAcc.Id;
                            dfochild.Child_Id__c = firstAcc.DFO_Id__c;
                            dfo.add(dfochild);
                            
                            for(integer i=1;i<newEmailAccmap.get(newAccount.PersonEmail).size();i++){
                            Account sameemailacc= newEmailAccmap.get(newAccount.PersonEmail)[i];
                              if(sameemailacc.id != firstAcc.id){ //excluding the 1st account in the set
                                if(sameemailacc.DFO_Id__c!=null || sameemailacc.Child_IDs__c!=null){
                                    
                                    //add the new DFO Id to the existing acc dfo id 
                                    firstaccObj.Child_IDs__c = firstAcc.Child_IDs__c+';'+sameemailacc.DFO_ID__c;
                                    
                                    //increase the count by 1
                                    firstaccObj.Count_of_Child_Records__c = firstaccObj.Count_of_Child_Records__c+1;                                   
                                    firstaccObj.Re_Push__c = true; //v1.15
                                                                     
                                    DfoAccount__c dfoObj = new DfoAccount__c();
                                    //insert the new DFo ID of the same email Account into the DfoAccount object
                                    dfoObj.Account__c = firstAcc.Id;
                                    dfoObj.Child_Id__c = sameemailacc.DFO_Id__c;
                                    dfo.add(dfoObj);
                                    system.debug('dfo'+dfo);
                                    
                                    //update existing account
                                    updatelist.add(firstaccObj);
                                    
                                    //delete new Account
                                    deletelist.add(sameemailacc.clone(true));
                                    
                                }
                               
                               } 
                                
                            }
                            
                       } 
                    } //end of v1.3
                    //new Accounts not having the same email address or the same DFO ID 
                    else if (dfoaccmap.get(newAccount.DFO_Id__c)==null && emailaccmap.get(newAccount.PersonEmail)==null && (newAccount.PersonEmail==null ||newEmailAccmap.get(newAccount.PersonEmail).size()<=1)) { //added new condition as part of v1.3
                        system.debug('DFO NEW');
                        DfoAccount__c dfoObj = new DfoAccount__c();
                        dfoObj.Account__c = newAccount.Id;
                        dfoObj.Child_Id__c = newAccount.DFO_Id__c;
                        dfo.add(dfoObj);
                        system.debug('dfo Account'+dfo);
                        Account accObj = new Account(id = newAccount.id);
                        accObj.Count_of_Child_Records__c = 1;
                        accObj.Child_IDs__c = newAccount.DFO_Id__c;
                       
                        updatelist.add(accObj);
                        system.debug('Obj'+accObj);
                        
                    }
                    /*End of v1.2*/
                   
                   
                }
                accUpdateMap.putall(updatelist);
                accDeleteMap.putall(deletelist);
                system.debug('DFO'+dfoSet);     
               } 
            }
            
            if(accUpdateMap.size()>0){
                    system.debug('Update list before update'+updatelist);
                    update accUpdateMap.Values();
                }
                if(updateAcclist.size()>0)
                    update updateAcclist;
                if(dfo.size()>0){
                    insert dfo;
                }
                
                system.debug('updatelist'+updatelist);
                if(accDeleteMap.size() > 0)
                {
                    system.debug('delete size'+deletelist.size());
                    system.debug('delete :'+deletelist);
                    delete accDeleteMap.values();
                    
                    accRespWrap.accDeleteMap = accDeleteMap; // v1.5
                }
                return accRespWrap;  // v1.5 
    }
    
    //Merul: removing deleted DFO account from trigger context.v1.5 
    public static List<Account> cleanDFOAccount( List<Account> lAccounts,
                                        Map<Id,Account> accDeleteMap )
    {
        List<Account> acclst = new List<Account>();
        for(Account acc : lAccounts)
        {
            if(! accDeleteMap.containsKey(acc.Id))
            {
                acclst.add(acc);
            }
        
        }
        return acclst;
    }
    
    // v1.5 
    public class respondWrapper
    {
        public map<Id,Account> accDeleteMap { get; set;}
        
    }
    
    /********************************************************************************************** 
    * @Version     : v1.10
    * @Description : Marketing Optin and opt out process 	                                      *
    * @Params      : List<Account> ,  Map<Id,Account> oldAccountMap                               *                                *
    * @Return      : void    																      *
    * @Invoked     : Before Insert , Before Update												  *
    *********************************************************************************************/
    public static void marketingoptinprocess(List<Account> lstAccounts,Map<Id,Account> oldAccountMap){
        List<Account> accountToBeUpdated = new List<Account>();
        for(Account newAccount : lstAccounts){
            String customerbrand;
            
            //Set the Customer Domain if the account is new and CM_Customer_Domain__c is not null
            if(oldAccountMap == null && newAccount.CM_Customer_Domain__c != null ){
                newAccount.Customer_Domain__c = newAccount.CM_Customer_Domain__c;
            }
            if(newAccount.Customer_Domain__c!=null)
                customerbrand = newAccount.Customer_Domain__c.tolowerCase() + ':' + newAccount.Org_Brand__c.tolowerCase();
           
           //If marketing consent is new and marketing consent is true or marketing consent is changed and brand not trp 
    
            if((((newAccount.Org_Brand__c != 'trp' && (oldAccountMap == null && newAccount.Marketing_Consent__c) || (oldAccountMap != null && newAccount.Marketing_Consent__c != oldAccountMap.get(newAccount.Id).Marketing_Consent__c) ))
                && (newAccount.Org_Brand__c == 'dnata' || newAccount.Org_Brand__c == 'EKH') )){
                    // If marketing consent is changed and is false
                    if(newAccount.Marketing_Consent__c == false){
                        newAccount.EKUK_Send_exclusive_discounts_offers__c = false;
                        if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                        	newAccount.PersonHasOptedOutOfEmail = true;
                    }
                    // If marketing consent is true and the customer domain is not germany
                    if(customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == false && newAccount.Marketing_Consent__c == true){
                        newAccount.EKUK_Send_exclusive_discounts_offers__c = true;
                        if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                        	newAccount.PersonHasOptedOutOfEmail = false;
                    }
                    
                }
            
            // If Send Exclusive Discount & Offers is true or if the Send Exclusive Discount & Offers is changed
            if((oldAccountMap == null && newAccount.EKUK_Send_exclusive_discounts_offers__c) ||
               (oldAccountMap != null && newAccount.EKUK_Send_exclusive_discounts_offers__c != oldAccountMap.get(newAccount.Id).EKUK_Send_exclusive_discounts_offers__c))
            {
                
                //if Send Exclusive Discount & Offers is true set Marketing Consent,Marketing Opt to true and person email to false
                if(newAccount.EKUK_Send_exclusive_discounts_offers__c == true){
                    newAccount.Marketing_Consent__c = true;
                    newAccount.Marketing_Opt_In__pc = true;
                    if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                    	newAccount.PersonHasOptedOutOfEmail = false;
                    
                } 
                // if Send Exclusive Discount & Offers is false set Marketing Consent and Marketing Opt in to false
                if(newAccount.EKUK_Send_exclusive_discounts_offers__c == false){
                    newAccount.Marketing_Consent__c = false;
                    newAccount.Marketing_Opt_In__pc = false;
                    if(customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == true)
                            newAccount.Opt_In_Status__c = '';
                    if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                    	newAccount.PersonHasOptedOutOfEmail = true;
                    
                } 
                        
                
            }
            // If Marketing Opt in is changed and brand is not trp set Marketing Consent and Send Exclusive discounts & offers to true
            else if(oldAccountMap != null && newAccount.Marketing_Opt_In__pc != oldAccountMap.get(newAccount.Id).Marketing_Opt_In__pc && newAccount.Org_Brand__c != 'trp' ){
               if( newAccount.Marketing_Opt_In__pc == true){
                    newAccount.Marketing_Consent__c = true;
                    newAccount.EKUK_Send_exclusive_discounts_offers__c = true;
                    if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                    	newAccount.PersonHasOptedOutOfEmail = false;
                }
                
                if( newAccount.Marketing_Opt_In__pc == false){
                    newAccount.Marketing_Consent__c = false;
                    newAccount.EKUK_Send_exclusive_discounts_offers__c = false;
                    if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                    	newAccount.PersonHasOptedOutOfEmail = true;
                }
            }
            
            //If the customer domain is germany and marketing consent is true and Send Exclusive Discount & Offers is false sets the status to pending
            if(newAccount.Marketing_Consent__c && newAccount.EKUK_Send_exclusive_discounts_offers__c == false && customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == true){
                newAccount.Opt_In_Status__c = 'Pending';
            }
            
            //If brand is not tro and the user is not integration and marketing consent is true and if it is a new account or marketing consent is updated to true on new account
            //Set Initial Opt in Date,Initial Opt in Reason, Initial Opt in Source and Offline Opt In date  
            if(newAccount.Marketing_Consent__c && (oldAccountMap == null || newAccount.Marketing_Consent__c != oldAccountMap.get(newAccount.Id).Marketing_Consent__c ) 
               && newAccount.Org_Brand__C != 'trp' && !userinfo.getName().contains('Integration')){
    
                // Initial Opt in Date
                newAccount.Initial_Opt_In_Date__c = system.now();
    
               //PersonHasOptedOutOfEmail
               if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                	newAccount.PersonHasOptedOutOfEmail = false;
    
                //if the customer domain is not germany
                if(customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == false)
                    newAccount.Org_Opt_In_Date__c = system.now();
                
                //If CM_Opt in Reason is not null and if it is a new account or if CM_Opt in Reason is updated
                //Initial Opt in Reason is set as CM_Opt In Reason else Initial Opt in Reason is Agent
                if((oldAccountMap == null && newAccount.CM_Opt_In_Reason__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Reason__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Reason__c)){
                    newAccount.Initial_Opt_In_Reason__c = newAccount.CM_Opt_In_Reason__c;
                } 
                else
                    newAccount.Initial_Opt_In_Reason__c = 'Agent';
                //If CM_Opt in Source is not null and if it is a new account or if CM_Opt in Source is updated
                //Initial Opt in Source is set as CM_Opt In Source else Initial Opt in Source is Agent
                if((oldAccountMap == null && newAccount.CM_Opt_In_Source__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Source__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Source__c )){
                    newAccount.Initial_Opt_In_Source__c = newAccount.CM_Opt_In_Source__c;
                } 
                else
                    newAccount.Initial_Opt_In_Source__c = 'Salesforce Service Cloud';
                                
                //If CM_Opt in Date is not null and if it is a new account or if CM_Opt in Date is updated
                //Offline Opt in Date is set as CM_Opt In Source
    
                if((oldAccountMap == null && newAccount.CM_Opt_In_Date__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Date__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Date__c )){
                    newAccount.Offline_Opt_In_Date__c = newAccount.CM_Opt_In_Date__c;
                } 
                
                if(customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == false){
                        newAccount.Opt_In_Status__c = 'Pending';
    
                //If CM_Opt in By is not null and if it is a new account or if CM_Opt in By is updated
                // Opt in By is set as CM_Opt In By else  Opt in By is the user
                if((oldAccountMap == null && newAccount.CM_Opt_In_By__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_By__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_By__c)){
                           newAccount.Org_Opt_In_By__c = newAccount.CM_Opt_In_By__c;
                       }
                       else
                           newAccount.Org_Opt_In_By__c = userinfo.getName() ;
               }  
                   
                
            }
    
            /*If brand is not trp and marketing consent is true and domain is not germany and if the marketing consent is updated to true
            * and if brand is EKH or brand is dnata and domain is UAE/Saudi Arabia/dnata-agent.com */
            if(newAccount.Org_Brand__c != 'trp'	&& newAccount.Marketing_Consent__c && customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == false
               && (oldAccountMap == null || newAccount.Marketing_Consent__c != oldAccountMap.get(newAccount.Id).Marketing_Consent__c ) && (newAccount.Org_Brand__c == 'EKH' || ((newAccount.Org_Brand__c == 'dnata'
                && (newAccount.Customer_Domain__c == 'UAE' || newAccount.Customer_Domain__c == 'Saudi Arabia'  || newAccount.Customer_Domain__c == 'dnata-agents.com')))))
            {
                                                          
                      newAccount.EKUK_Send_exclusive_discounts_offers__c = true;
                      newAccount.Marketing_Opt_In__pc = true;
                      newAccount.Opt_In_Status__c = 'Accepted';
                      newAccount.Org_Opt_In_Date__c = newAccount.Initial_Opt_In_Date__c;
                    /* If the uset is Integration 
                        * Send Exclusive discount & offers is set to true and Marketing Opt in is true 
                        * Opt in Status is Accepted 
                        * Opt in date is Initial Opt in Date 
                        * If the user is integration
                            * Opt in Reason is Initial Opt In Reason
                            * Opt In Source is Intial Opt In Source
                            * Opt In By is Integration User
                    */
                  if(userinfo.getName().contains('Integration')){
                      system.debug('Entered 3rd Condition');
                      system.debug('Entered Integration');
                      newAccount.Opt_In_Reason__c = newAccount.Initial_Opt_In_Reason__c;
                      newAccount.Org_Opt_In_Source__c = newAccount.Initial_Opt_In_Source__c;
                      newAccount.Org_Opt_In_By__c = 'Integration User';
                  }
                  // if the user is an agent 
                  else{
                          if((oldAccountMap == null && newAccount.CM_Opt_In_Reason__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Reason__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Reason__c )){
                              newAccount.Opt_In_Reason__c = newAccount.CM_Opt_In_Reason__c;
                          } 
                          else
                              newAccount.Opt_In_Reason__c = 'Agent';                      
                    }
            }  
                                                      
                                                          
                                                          
            /*If the customer domain is germany and Send Exclusive discounts & offers is true and Opt in Status is Accepted*/                                          
            else if( newAccount.Org_Brand__c == 'EKH' && (customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == true
                     && (oldAccountMap == null || newAccount.EKUK_Send_exclusive_discounts_offers__c != oldAccountMap.get(newAccount.Id).EKUK_Send_exclusive_discounts_offers__c )
                         && newAccount.EKUK_Send_exclusive_discounts_offers__c == true && newAccount.Opt_In_Status__c == 'Accepted'))
            {
                         newAccount.Org_Opt_In_Date__c = system.now();
                         
                         //If CM_Opt in Reason is not null and if it is a new account or if CM_Opt in Reason is updated
                         // Opt in Reason is set as CM_Opt In Reason else Opt in Reason is Initial Opt in Reason
                         if((oldAccountMap == null && newAccount.CM_Opt_In_Reason__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Reason__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Reason__c)){
                             newAccount.Opt_In_Reason__c = newAccount.CM_Opt_In_Reason__c;
                         } 
                         else
                             newAccount.Opt_In_Reason__c = newAccount.Initial_Opt_In_Reason__c;
                         //opt in source
                         //If CM_Opt in Reason is not null and if it is a new account or if CM_Opt in Reason is updated
                         // Opt in Reason is set as CM_Opt In Reason else Opt in Reason is Initial Opt in Reason
                         if((oldAccountMap == null && newAccount.CM_Opt_In_Source__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Source__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Source__c )){
                             newAccount.Org_Opt_In_Source__c = newAccount.CM_Opt_In_Source__c;
                         } 
                         else
                             newAccount.Org_Opt_In_Source__c = newAccount.Initial_Opt_In_Source__c;
                         //opt in Reason
                        //If CM_Opt in Reason is not null and if it is a new account or if CM_Opt in Reason is updated
                         // Opt in Reason is set as CM_Opt In Reason else Opt in Reason is Initial Opt in Reason
                         if((oldAccountMap == null && newAccount.CM_Opt_In_Reason__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_Reason__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_Reason__c)){
                             newAccount.Opt_In_Reason__c = newAccount.CM_Opt_In_Reason__c;
                         } 
                         else
                             newAccount.Opt_In_Reason__c = newAccount.Initial_Opt_In_Reason__c;
                         // opt in by
                         //If CM_Opt In by is not null and if it is a new account or if CM_Opt in Reason is updated
                         // Opt in By is set as CM_Opt In By else Opt in By is Initial Opt in Reason
                         if((oldAccountMap == null && newAccount.CM_Opt_In_By__c != null) || (oldAccountMap != null && newAccount.CM_Opt_In_By__c != oldAccountMap.get(newAccount.Id).CM_Opt_In_By__c)){
                             newAccount.Org_Opt_In_By__c = newAccount.CM_Opt_In_By__c;
                         }
                         else
                             newAccount.Org_Opt_In_By__c = userinfo.getName();
                     }
            
            
            
            
            //Email Opt Out is True
     
            
            if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE' && oldAccountMap != null && newAccount.PersonHasOptedOutOfEmail != oldAccountMap.get(newAccount.Id).PersonHasOptedOutOfEmail && newAccount.PersonHasOptedOutOfEmail == true){
                newAccount.EKUK_Send_exclusive_discounts_offers__c = false;
                system.debug('Marketing_Consent__c >>>>>>>>>.. '+newAccount.Marketing_Consent__c);  
            }            
            /******************* Account Marketing Opt Out Change ********************************/
            //If EKUK_Send_exclusive_discounts_offers__c or Marketing_Opt_In__pc is changed
            //The opt out fields (Opt_Out_By__pc,Opt_Out_Date__pc,Opt_Out_Source__pc) are populated
            //EKUK_Send_exclusive_discounts_offers__c and Marketing_Opt_In__pc  are set to false
            //PersonHasOptedOutOfEmail is set to true.
            
            if((oldAccountMap == null && newAccount.EKUK_Send_exclusive_discounts_offers__c) || (oldAccountMap != null && newAccount.EKUK_Send_exclusive_discounts_offers__c != oldAccountMap.get(newAccount.Id).EKUK_Send_exclusive_discounts_offers__c && newAccount.EKUK_Send_exclusive_discounts_offers__c == false) 
                || (oldAccountMap != null && newAccount.Marketing_Opt_In__pc != oldAccountMap.get(newAccount.Id).Marketing_Opt_In__pc && newAccount.Marketing_Opt_In__pc == false))
            {
                //If Marketing Opt in is false
                if(newAccount.Marketing_Opt_In__pc == false){
                    newAccount.EKUK_Send_exclusive_discounts_offers__c = false;
                    newAccount.Marketing_Consent__c = false;
                }
                // If send exclusive discounts & offers is false, it sets marketing opt in as false and marketing consent as false
            
                if(newAccount.EKUK_Send_exclusive_discounts_offers__c == false){
                    newAccount.Marketing_Opt_In__pc = false;
                    newAccount.Marketing_Consent__c = false;
                    if(customerbrand != null && Label.Inital_Optin_Exclude_Markets.contains(customerbrand) == true)
                            newAccount.Opt_In_Status__c = '';
                    
                    if(userinfo.getName().contains('Marketing Cloud System User')){
                        newAccount.Opt_Out_By__pc = 'Marketing Cloud System User';
                    }
                    else
                        newAccount.Opt_Out_By__pc = userinfo.getName();
                    
                    newAccount.Opt_Out_Date__pc = system.now();
                    
                    if(userinfo.getName().contains('Marketing Cloud System User')){
                        newAccount.Opt_Out_Source__pc = 'Marketing Cloud';
                    }
                    else 
                        newAccount.Opt_Out_Source__pc = 'Salesforce Service Cloud';
                    
                    if(Label.Disable_PersonHasOptedOutOfEmail != 'TRUE') //v1.14
                    	newAccount.PersonHasOptedOutOfEmail = true;
                }
                system.debug('Marketing_Consent__c >>>>>>>>>.. '+newAccount.Marketing_Consent__c);  
                
            }
            
            
        }
        
        
        
    }    // end of v1.10
    
     /********************************************************************************************** 
    * @Version     : v1.11																		  *
    * @Description : Updating Loyalty Id field from skywards number field before update.	      *
    * @Params      : List<Account> ,  Map<Id,Account> oldAccountMap                               *
    * @Return      : void    																      *
    * @Invoked     : Before Update												  *
    *********************************************************************************************/
    public static void updateLoyaltyId(List<Account> lAccounts, Map<Id,Account> oldAccountMap){
        for(Account acc:lAccounts){
            try{
                if(acc.Org_Emirates_Skywards_Number__c != null && acc.Loyalty_Id__c == null){
                    if(acc.Org_Emirates_Skywards_Number__c.length() >= 50){
                            acc.Loyalty_Id__c = acc.Org_Emirates_Skywards_Number__c.substring(0,50);
                    }else{
                        acc.Loyalty_Id__c = acc.Org_Emirates_Skywards_Number__c;
                    }
                    
                }
            }
            catch(Exception e){
                System.debug('Loyalty Id Error : ' + e.getMessage());
            }
        }
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 16 February 2021
     * @description: method to stamp business unit based on logged in user's business unit
     * @history:
     */ //v1.16
    public static void populateAccountBusinessUnit(list<Account> lstAccounts){

        User usr = [SELECT Name, Business_Unit_single__c, Team_Name__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        for(Account acc : lstAccounts){
            if(usr.Name != 'Integration User'){
                acc.Org_Business_Unit__c = usr.Business_Unit_single__c;
            }
        }

    }    

    }