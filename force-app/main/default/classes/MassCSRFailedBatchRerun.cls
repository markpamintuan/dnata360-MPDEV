/**************************************************************************************************
* Name               : MassCSRFailedBatchRerun 
* Description        : This is the batch class for updating failed mass csrs    
* Created Date       : 24-Sept-2019                                                              
* Created By         : Evendo D'mello                                                    
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Evendo      24-Sept-2019    Initial Draft
**************************************************************************************************/
global class MassCSRFailedBatchRerun implements Database.Batchable<sObject>,Database.Stateful  {
    public string parentid;
    List<Id> casesIdToDelete;
    List<Case> casesToDelete;
    global  set<id> allIds=new set<id>();
    global  set<id> allFailedId=new set<id>();
    global  set<id> allSuccessId=new set<id>();
    global integer totalSizeRecords=0;
    global integer passed =0;
    global integer failed =0;
    global Map<String,String> ErrorIdToReason;
    global Map<String,String> SuccessCasesToBcc;
    global List<String> FailedCCtoCases;
    global integer batchcount=0 ;
    global integer recordcount=0;    
    global integer previousTotalCount=0;

    
	public MassCSRFailedBatchRerun(string parentId){
        this.parentid = parentId;
    }
 
    
    global List<Case> start(Database.BatchableContext BC){
        previousTotalCount = 0;
        List<String> BookingIds = new List<String>();
         List<Case> requestCases = new List<Case>();
        casesToDelete = new List<Case>();
        ErrorIdToReason = new Map<String,String>();
        SuccessCasesToBcc = new Map<String,String>();
        FailedCCtoCases = new List<String>();
        casesIdToDelete = new List<Id>();
        Bulk_Case_Job__c bcp = [Select id,Request_Type__c,description__c,Subject__c,Category__c,Case_Owner_Id__c from Bulk_Case_Job__c where id =:parentid];
        String recordtype = [Select id from recordtype where name =: bcp.Request_Type__c].id;
        for(Bulk_Case_Job_Item__c bcc: [Select id,bookingid__c,status__c,Case__c from Bulk_Case_Job_Item__c where Bulk_Case_Job__c = :parentid]){
            previousTotalCount+=1;
        }
        
        for(Bulk_Case_Job_Item__c bcc: [Select id,bookingid__c,status__c,Case__c from Bulk_Case_Job_Item__c where Bulk_Case_Job__c = :parentid and (status__c != 'New' and status__c != 'Success' and status__c != 'Duplicate' and status__c != 'invalid') ]){
            if(bcc.status__c == 'Customer Communication Failed'){
                casesIdToDelete.add(bcc.Case__c); 
            }
            BookingIds.add(bcc.bookingid__c);
        }
        
        for(Case c:[Select id from Case where id in :casesIdToDelete]){
            casesToDelete.add(c);
        }
        
        for(Booking__C bk: [Select id,Org_Account_Name__c from Booking__c where booking_id__c in :BookingIds]){
            
            Case c = new Case();
            c.RecordTypeId = recordtype;
            c.Org_Booking__c = bk.id;
            c.Subject = bcp.Subject__c;
            c.Category__c = bcp.Category__c;
            c.AccountId = bk.Org_Account_Name__c;
            c.OwnerId = bcp.Case_Owner_Id__c;
            if(bcp.Description__c != null){
            	c.Description = bcp.Description__c;
            }
            requestCases.add(c);
            recordcount+=1;
        }
        
        return requestCases;
      
    }
    
     global void execute(Database.BatchableContext BC, List<Case> scope){
         if(casesToDelete.size() 	>0 ){
         	delete casesToDelete;
         }
         Bulk_Case_Job__c bcp = [Select id,Request_Type__c,description__c,Send_SMS__c from Bulk_Case_Job__c where id =:parentid];
         List<Bulk_Case_Job_Item__c> bcc = [Select id,bookingid__c,status__c from Bulk_Case_Job_Item__c where Bulk_Case_Job__c = :parentid  and (status__c != 'New' and status__c != 'Success' and status__c != 'Duplicate' and status__c != 'invalid')];
         database.SaveResult[] myResult=database.insert(scope,false);
         List<Customer_Communication__c> cclist = new List<Customer_Communication__c>();
         system.debug('scope size' + myResult.size()); 
         system.debug('Myresult size ' + myResult.size());
         for(Integer i=0; i < myResult.size(); i++) {
             if(myResult.get(i).isSuccess()) {
                System.debug('Records are updated Successfully');
                  if(bcp.Request_Type__c == 'Travel Republic - Service Request'){        
                             Customer_Communication__c cc = new Customer_Communication__c();
                             cc.Message__c = bcp.Description__c;
                             cc.Send_SMS__c = bcp.Send_SMS__c;
                             cc.Service_Request__c = myResult.get(i).Id;
                             cclist.add(cc);                       
                 } 
                passed += 1;
                 System.debug(myResult.get(i).Id);
                 System.debug(bcc.get(i + 10*(batchcount)).Id);
                SuccessCasesToBcc.put(bcc.get(i + 10*(batchcount)).Id,myResult.get(i).Id);
                allSuccessId.add(myResult.get(i).Id);
             } 
             else if(!myResult.get(i).isSuccess()) {
                Database.Error errors =  myResult.get(i).getErrors().get(0);
                System.debug('Error Occurs While Processing The Record'+errors.getMessage());
               // System.debug('Failure Record Ids While Updating'+myResult.get(i).Id);
                failed += 1;
                allFailedId.add(bcc.get(i + 10*(batchcount)).Id);
               ErrorIdToReason.put(bcc.get(i + 10*(batchcount)).Id, errors.getMessage());
             }
         }
          
        System.debug(cclist.size());
        system.debug(10*batchCount);
        if(cclist.size() > 0){
            database.SaveResult[] myResult2=database.insert(cclist,false);
            for(Integer i=0; i < myResult2.size(); i++) {
                 if(myResult2.get(i).isSuccess()) {
                    System.debug('Records are updated Successfully');
                    } 
                 else if(!myResult2.get(i).isSuccess()) {
                    Database.Error errors =  myResult2.get(i).getErrors().get(0);
                  	FailedCCtoCases.add(cclist.get(i).Service_Request__c);
                    passed -= 1;
                    failed += 1;
                        
                 }
         	}
            
        }
        batchcount+=1;
      
     }
    
    global void finish(Database.BatchableContext BC){
         //system.debug('bcc list ' + [Select id,bookingid__c,status__c from Bulk_Case_Job_Item__c where Bulk_Case_Job__c = :parentid]);
        system.debug(SuccessCasesToBcc.size());
        List<Bulk_Case_Job_Item__c> bcclist = new List<Bulk_Case_Job_Item__c>();
        for(Bulk_Case_Job_Item__c bcc: [Select id,bookingid__c,status__c from Bulk_Case_Job_Item__c where Bulk_Case_Job__c = :parentid  and (status__c != 'New' and status__c != 'Success' and status__c != 'Duplicate' and status__c != 'invalid') ]){
            system.debug('bcc id ' + bcc.id);
            
            if(allFailedId.contains(bcc.id)){
                bcc.Status__c = 'Failed';
                bcc.Error_Reason__c = ErrorIdToReason.get(bcc.id);
            }else{
                
                bcc.Case__c = SuccessCasesToBcc.get(bcc.id);
                if(FailedCCToCases.contains(SuccessCasesToBcc.get(bcc.id))){
                    bcc.Status__c = 'Customer Communication Failed';
                }else{
                    bcc.Status__c = 'Success';
                    bcc.Error_Reason__c ='';
                }
            }
            bcclist.add(bcc);
        }
        update bcclist;
        
        
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        Bulk_Case_Job__c bcp = [Select id,Request_Type__c,description__c,Subject__c,Category__c,Case_Owner_Id__c,OwnerId from Bulk_Case_Job__c where id =:parentid];
        User us = [select id,email,firstname from user where id= :bcp.OwnerId];
         String[] toAddresses = new String[] {us.email};            
         mail.setToAddresses(toAddresses);
         mail.setReplyTo(us.email);
         mail.setSenderDisplayName('Apex batch message');
         mail.setSubject('Apex Batch Message');
         mail.setPlainTextBody('Dear ' + us.FirstName + ',\r\n \r\nYour Batch Class Report: \r\n \r\n'+ 'Request type: ' + bcp.Request_Type__c + '\r\nSubject: ' + bcp.Subject__c + '\r\n \r\n \r\nDescription: ' + bcp.Description__c +  
                               '\r\n \r\n \r\nBefore Rerun stats: \r\n \r\nTotal Records Count: '+previousTotalCount + '\r\nRecords Failed: '+ recordcount + '\r\n \r\nPost Rerun stats: \r\n \r\nTotal Records: ' +  recordcount +'\r\nTotal Passed: ' + String.valueOf(passed) + ' . Total Failed: ' + String.valueOf(failed) + '\r\n \r\nYou can navigate to the batch parent object by clicking on this link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + bcp.id);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    
}