/**************************************************************************************************
* Name               : AccountTrigger 
* Description        : This is a trigger for account       
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Mahadev                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Mahadev          08-Aug-2018    Initial version                                                  
* v1.1        Kaavya           31-Oct-2018    Rehlaty - Disabling Derwent push for accounts  
* v1.2        Kaavya           22-Nov-2018    T-00298 - Preventing Derwent push for mass create/edit   
* v1.3        Sri Bala         22-Jul-2019    To update trp customer on Derwent when TRP_Send_exclusive_discounts_offers__c is changed (NOT TO SYNC with Marketing Cloud)
* v1.4        Sri Bala         09-Sep-2019    Not to push dummy accounts to derwent.
* v1.5        Merul            15-Sep-2019    For clearing the deleted account from trigger context
* v1.6        Sri Bala         16-Oct-2019    Commenting v1.3 as a part of marketing cloud change as marketing consent field is in sync with the derwent
* v1.7        Keith            1-Nov-2019     Keeping phone number formats in sync.
* v1.8        Sri Bala         05-Feb-2020    Marketing Optin Process
* v1.9		  Evendo		   16-Feb-2020    Updating Loyalty Id field from skywards number field before update.
* v1.10       Sri Bala         03-mar-2020    Avoiding Recursion for Marketing process
* v1.11       Mark             16-Feb-2021    Added calling of method AccountTriggerHelper.populateAccountBusinessUnit on before insert
**************************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete) 
{
    //before inserting an account, check for duplication
    //use a custom setting to check the rules, based on the rules
    //if any matching record found, throw an error
    
    List<Id> custlist = new List<Id>();
    
    /*if(trigger.isUpdate && AccountTriggerHelper.BlockAccountTrigger){
        return;
    }*/

    if(trigger.IsBefore && Trigger.isDelete){
        system.debug('### is before delete');
        AccountTriggerHelper.preventDeletion(trigger.old);
    }
    
    if((trigger.IsBefore && Trigger.IsInsert) || (trigger.IsBefore && Trigger.IsUpdate))
    {
          //AccountTriggerHelper.populateExternalId(trigger.new);
        AccountTriggerHelper.validatePhone(trigger.new);  
        if(trigger.IsBefore && Trigger.IsInsert){ //v1.6
            AccountTriggerHelper.syncMobilePhoneCountryAndNumber(Trigger.new, null); //v1.7
            AccountTriggerHelper.syncPhoneCountryAndNumber(Trigger.new, null); //v1.7
            //v1.8
            if(Label.Enable_Marketing_Optin == 'TRUE'){//v1.10
                //if(UserInfo.getProfileId() != Label.Marketing_Data_Load_ProfileId)//v1.10
                	//AccountTriggerHelper.RunMarketingProcessLogic = false;//v1.10
                AccountTriggerHelper.marketingoptinprocess(trigger.new,trigger.oldMap);
                
            }
            AccountTriggerHelper.populateAccountBusinessUnit(trigger.New); //v1.11
            
        }

        if(trigger.isBefore && trigger.isUpdate){ //v1.6
            AccountTriggerHelper.syncMobilePhoneCountryAndNumber(Trigger.new,Trigger.oldMap); //v1.7
            AccountTriggerHelper.syncPhoneCountryAndNumber(Trigger.new, Trigger.oldMap); //v1.7
            AccountTriggerHelper.updateLoyaltyId(Trigger.new,Trigger.oldMap); //v1.9
            //v1.8
            if(Test.isRunningTest() ||  Label.Enable_Marketing_Optin == 'TRUE'){//v1.10
                 //if(UserInfo.getProfileId() != Label.Marketing_Data_Load_ProfileId)//v1.10
                	//AccountTriggerHelper.RunMarketingProcessLogic = false;
                AccountTriggerHelper.marketingoptinprocess(trigger.new,trigger.oldMap);
                
            }
        } 
    }
    
    //v1.5
     if( (trigger.IsBefore && Trigger.IsUpdate))
    {
        AccountTriggerHelper.populateExternalId(trigger.new);
    }
    
   if(trigger.isAfter){
        if(trigger.isInsert ){
            
            //Run_Customer_Engine__c - This is a Hierarchy custom settings, 
            //which will hold the flag on whether to run the customer engine logic or not
            //Check trigger recursion, and call the method to create or link master account records.
            if(Run_Customer_Engine__c.getInstance().Run__c && AvoidRecursion.isFirstRun()){
                system.debug(datetime.now());
                AccountTriggerHelper.linkMasterAccountAfter(Trigger.New);
            }
            //added by Sri bala
            //v1.4
            String dummyEmail = '';
            List<Request_Log__c> requestLogCreation = new List<Request_Log__c>();
            //end of v1.4
            AccountTriggerHelper.respondWrapper accRespWrap = AccountTriggerHelper.DFOAccountCreation(Trigger.New); 
            // Getting Deleted Account.
            
            //Merul: For clearing the deleted account from trigger context....v1.5
            List<Account> cleanAcc = trigger.new;
            if( accRespWrap.accDeleteMap != NULL )
            {
                cleanAcc = AccountTriggerHelper.cleanDFOAccount(trigger.new,accRespWrap.accDeleteMap);
            }
            AccountTriggerHelper.populateExternalId(cleanAcc);
            
            
            //identifying if it is a new customer
            for(Account acc:trigger.new)
            {
                 //v1.4
                if(acc.Org_Derwent_Customer_No__c != null)
                    dummyEmail = acc.Org_Derwent_Customer_No__c + '@noreply.com';
                if(acc.Org_Derwent_Customer_No__c != null && acc.PersonEmail == dummyEmail){
                    system.debug('Entered');
                    Request_Log__c reqlog = new Request_Log__c();
                    reqlog.Entity__c = 'Customer';
                    reqlog.Entity_Id__c = acc.Org_Derwent_Customer_No__c;
                    requestLogCreation.add(reqlog);
                }
                //end of v1.4
                if(acc.Org_Derwent_Customer_No__c==null){
                    system.debug('BRAND==='+acc.Org_Brand__c);
                    system.debug('Recordtype==='+acc.recordtypeId);
                    
                    //commented as part of v1.1
                    /*String rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId();
                    if(acc.recordtypeId!=rectypeId)
                        custlist.add(acc.id); */
                    
                    //Added as part of v1.1
                    if(acc.Org_Brand__c !=null){
                        String brand =acc.Org_Brand__c.toLowerCase();
                        Person_Account_Record_Types__c par = Person_Account_Record_Types__c.getValues(brand);
                        if(par!=null){
                            // v1.1 checking if customer should be pushed to Derwent based on brand
                            if(par.Push_to_Derwent__c){ 
                                
                                //v1.2 checking if account should be pushed to Derwent based on ownerid
                                Disable_Integration__c DI = Disable_Integration__c.getInstance(acc.OwnerId);
                                if(DI.Disable__c!=true )
                                    custlist.add(acc.id);
                            }    
                        }
                        //Pushing all new customers to Derwent
                       if(custlist.size()>0 )
                        system.enqueueJob(new AsyncDerwentWebservice (custlist,'Customer_Create',''));
                        system.debug('list'+custlist);
                    }
                    
                    
                    }
                                
            }
             
             
        }
        if(trigger.isUpdate ){
            //identifying if it is an existing customer
             //to add method  to include only specific updates
             //Getting the field mapping to be used
            List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c from Derwent_Field_Mapping__mdt where SF_Object__c='Account' order by Order__c asc];
            String dummyEmail = ''; //v1.4       
            for(Account acc:trigger.new){
                
                if(acc.Org_Derwent_Customer_No__c!=null && trigger.oldmap.get(acc.id).Org_Derwent_Customer_No__c!=null){
                    dummyEmail = acc.Org_Derwent_Customer_No__c + '@noreply.com';//v1.4
                    Boolean CustUpd=false;
                    system.debug('Inside derwent cust id');
                    //Checking if any fields mapped with Derwent is updated
                    for(Derwent_Field_Mapping__mdt DFM:mappings ) {
                        system.debug('<<New>>'+acc.get(DFM.SF_Field_API_Name__c));
                        system.debug('<<Old>>'+trigger.oldmap.get(acc.id).get(DFM.SF_Field_API_Name__c));
                         if(acc.get(DFM.SF_Field_API_Name__c)!=trigger.oldmap.get(acc.id).get(DFM.SF_Field_API_Name__c))
                         CustUpd=true;
                        //added as a part of v1.4
                        if(acc.PersonEmail == dummyEmail)
                         CustUpd = false;
                        //end of v1.4
                        /********************** Hard coded to set the value of EmailSignUp in Derwent for trp ******************************
                         *********************CREATED A NEW FIELD TRP_Send_exclusive_discounts_offers__c  NOT TO SYNC WITH MARKETING CLOUD *********************************************/
                        //Added as a  part of v1.3
                         /*if(acc.TRP_Send_exclusive_discounts_offers__c!=trigger.oldmap.get(acc.id).TRP_Send_exclusive_discounts_offers__c)
                         CustUpd=true;*/ 
                        //end of v1.3 commented as a part of v1.6
                    }
                    if(acc.Updated_from_Derwent__c!=trigger.oldmap.get(acc.id).Updated_from_Derwent__c)
                        CustUpd=false;
                       
                    if(CustUpd){
                        //v1.2 checking if account should be pushed to Derwent based on ownerid
                        Disable_Integration__c DI = Disable_Integration__c.getInstance(acc.LastModifiedById);
                        if(DI.Disable__c!=true)
                            custlist.add(acc.id);
                        //Pushing all updated customers to Derwent
                        if(custlist.size()>0)
                            system.enqueueJob(new AsyncDerwentWebservice (custlist,'Customer_Update',acc.Org_Derwent_Customer_No__c));
                    }
                }
              
            }
             
        }
       
        
    } 
    
}