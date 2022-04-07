/**************************************************************************************************
* Name               : CustomerRelationTriggerHandler 
* Description        : This is the handler class for relationship triggerand contains logic for validation and also creating Account and link it with the Parent Account        
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Paramasiva                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Paramasiva       08-Aug-2018    Initial version                                                  
* v1.1        Kaavya           29-Oct-2018    T-00079: create relationship without email    
* v1.2        Sri Bala		   04-Mar-2019    DFO Update
**************************************************************************************************/

public class CustomerRelationTriggerHandler {

    public static void onBeforeInsert(List<relation__c> lCases){

       
        Set<String> accEmails = new Set<String>();
        Set<String> accBrands = new Set<String>();
        List<Account> lstAccountsToCreate = new List<Account>();
        Map<String, String> lstExistingAccounts = new Map<String, String>();
        Set<string> parentAccountId = new Set<string>();
        Map<string,account> parentAccountMap = new Map<string,account>();
        
        for(Relation__c relat : lCases){
        
            if(relat.UniqueId__c!=null && !relat.UniqueId__c.CONTAINS('DFO') && (relat.Org_Name__c != Null) &&(relat.Org_Email__c != Null ||  relat.Org_Last_Name__c != null ||  relat.Org_Mobile__c != null ||   relat.Org_Age_Actual__c != null ||  relat.Org_First_Name__c != null ||  relat.Org_Gender__c != null)){
              relat.addError('Please choose the existing customer or enter new email. You cannot choose both for creating relationship');
            }
            
             if(relat.UniqueId__c!=null && !relat.UniqueId__c.CONTAINS('DFO') && (relat.Org_Name__c == Null) &&(relat.Org_Email__c == null)){
              relat.addError('Kindly provide the email address');
            }
            
            system.debug('%%%%%%%%%%'+relat.Org_Email__c+relat.Org_Last_Name__c+relat.Org_Mobile__c);
           
            
            
            if(relat.UniqueId__c!=null && !relat.UniqueId__c.CONTAINS('DFO') && relat.Org_Name__c == Null && relat.Org_Last_Name__c == null){
               relat.addError('Kindly provide the last name');
            }
            /* commented as part of v1.1
            if((relat.Org_Name__c == Null) &&(relat.Org_Mobile__c == null)){
              relat.addError('Kindly provide the mobile number');
            } */
            
            if(String.isNotBlank(relat.Org_Email__c)){
                accEmails.add(relat.Org_Email__c);
            }     
            
            //getting The Parent Account Id
            if(relat.Org_AccountName__c != null){
            parentAccountId.add(relat.Org_AccountName__c);    
            }           
        }
        
        
        
        
        //Selecting the parent Details
        
        for(Account acc : [Select Id, Name, PersonEmail,Org_Brand__c,recordtypeid From Account Where id in:parentAccountId]){
            parentAccountMap.put(acc.id, acc);
            accBrands.add(acc.Org_Brand__c); //Added as part of v1.1
            
        }
        
        for(Account acc : [Select Id, Name,Org_Brand__c, PersonEmail From Account Where PersonEmail != NULL AND PersonEmail IN :accEmails AND Org_Brand__c in:accBrands AND id NOT in:parentAccountId]){ // Added as part of v1.1- Org_Brand__c in:accBrands AND id NOT in:parentAccountId
            lstExistingAccounts.put(acc.PersonEmail, acc.Id);           
        }
        
        for(Relation__c rel : lCases){
            system.debug('step 1');
            if(rel.Org_Name__c != null && (rel.Org_ParentAccountId__c == null || rel.Org_ParentAccountId__c == '')){
             rel.UniqueId__c = rel.Org_AccountName__c+''+rel.Org_Name__c;
             }
            //changed from String.isNotBlank(rel.Org_Email__c) as a part of null pointer exception
            if(rel.Org_Email__c != '' && rel.Org_Email__c!=null){
                //added  && rel.UniqueId__c!=null && !rel.UniqueId__c.contains('DFO') as a part of null pointer exception
            if(rel.Org_Name__c == null && (rel.Org_ParentAccountId__c == null || rel.Org_ParentAccountId__c == '') && rel.UniqueId__c!=null && !rel.UniqueId__c.contains('DFO')){
                rel.Org_Name__c = lstExistingAccounts.get(rel.Org_Email__c);
                rel.UniqueId__c = rel.Org_AccountName__c+''+rel.Org_Name__c;
                if(rel.Org_ParentAccountId__c == null || rel.Org_ParentAccountId__c == ''){
                if(lstExistingAccounts.get(rel.Org_Email__c) == null && rel.Org_Email__c!=parentAccountMap.get(rel.Org_AccountName__c).PersonEmail ){ //Email check added as part of v1.1
                    string brand = parentAccountMap.get(rel.Org_AccountName__c).Org_Brand__c;
                    string recId = parentAccountMap.get(rel.Org_AccountName__c).recordtypeid;
                    system.debug('step 2 no account found');
                    if(rel.Org_Last_Name__c != null && rel.Org_Email__c != null && rel.Org_Mobile__c != null){
                        lstAccountsToCreate.add(new Account(FirstName = rel.Org_First_Name__c,Org_Brand__c=brand ,recordtypeid=recId, LastName = rel.Org_Last_Name__c, PersonEmail = rel.Org_Email__c, PersonMobilePhone = rel.Org_Mobile__c));
                    }
                }
               }
            }
            }
        }
        
        if(!lstAccountsToCreate.isEmpty()){
            insert lstAccountsToCreate;
            system.debug('step 3 will create new account now');
            
            for(Account acc : lstAccountsToCreate){
                lstExistingAccounts.put(acc.PersonEmail, acc.Id);
            }
            
            for(Relation__c rel : lCases){
                if(rel.Org_ParentAccountId__c == null || rel.Org_ParentAccountId__c == ''){
                rel.Org_Name__c = lstExistingAccounts.get(rel.Org_Email__c);
                rel.UniqueId__c = rel.Org_AccountName__c+''+rel.Org_Name__c;
                }
            }
            system.debug('step 4 updated account ref now');
        }
    
    
    }
    //added as a part of v1.2
    public static void onAfterInsert(List<relation__c> lCases)
    {
        Map<Id,relation__c> relIdList = new Map<Id,relation__c>();
        for(relation__c rel : lCases){
            if(rel.Org_ParentAccountId__c != '' && rel.Org_ParentAccountId__c != null)
            		relIdList.put(rel.id,rel);
            
        }
        //added as part of v1.2
            if(relIdList != null && relIdList.size() >0 )
            {
                Id jobID = System.enqueueJob(new RelationDFOUpdate(relIdList));
                system.debug('Id@@'+jobID);
            }
            //end of v1.2
    }
    
}