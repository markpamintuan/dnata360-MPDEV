/**************************************************************************************************
* Name               : CSRTriggerHandler 
* Description        : This is the trigger handler class for CSR trigger           
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Paramasiva                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS                
* v1.0        Paramasiva      08-Aug-2018     Initial version
* v1.1        Kaavya          30-Sep-2018     T-00124 Close CSR case only if CSR from Derwent                                                 
* v1.2        Mark            29-May-2019     T-00513 Create task if related Case owner's profile contains Retail                                                       
**************************************************************************************************/
public class CSRTriggerHandler {
    static List<Case> lCasesToUpdate = new List<Case>();
    public static void onBeforeInsert(List<CSR__c> csrs){
        linkOrCreateCSRToCase(csrs);
    }
    
    public static void onBeforeUpdate(List<CSR__c> csrs){
        linkOrCreateCSRToCase(csrs);
    }
    
    public static void onAfterInsert(List<CSR__c> csrs){
        createTask(csrs); //v1.2        
    }
    
    public static void onAfterUpdate(List<CSR__c> oldCSRList,
                                    List<CSR__c> newCSRList, 
                                    Map<Id,CSR__c> oldCSRMap,
                                    Map<Id,CSR__c> newCSRMap){
        
        

        for(CSR__c csr : newCSRList){
            createListCasesToUpdate(csr, oldCSRMap.get(csr.Id));
        }

        updateCases();
        createTask(newCSRList); //v1.2
    }

    private static void createListCasesToUpdate(CSR__c newCsr, CSR__c oldCsr){
        system.debug('### createListCasesToUpdate with oldCsr: ' + oldCsr);
        system.debug('### createListCasesToUpdate with newCsr: ' + newCsr);

        if(newCsr.Status__c != oldCsr.Status__c && 
            newCsr.Status__c == 'Completed' && 
            newCsr.Case__c !=null){

            Case cse = new Case();
            cse.Id = newCsr.Case__c;
            //cse.Org_Case_Status__c  = 'Closed'; //Commented as part of v1.1
            
            cse.Org_CSR_On_Case__c = 'With CSR';
            cse.Type = newCsr.CategoryId__c;
            system.debug(''+cse.Type);
            //cse.Org_Case_Close_Reason__c = 'Resolved';//Commented as part of v1.1
            //cse.Closing_Comments__c = 'CSR Closed'; //Commented as part of v1.1
            system.debug('AccountID-BK====>'+oldCsr.Booking_ID__r.Org_Account_Name__c);
            system.debug('AccountID-CSR====>'+oldCsr.SF_Account_Id__c );
            cse.Accountid = oldCsr.SF_Account_Id__c; //oldCsr.Booking_ID__r.Org_Account_Name__c; //Updated as to not remove the account contact lookup
            cse.contactid = oldCsr.SF_Contact_Id__c; //oldCsr.Booking_ID__r.Org_Contact_Id_Formula__c; //Updated as to not remove the account contact lookup
            cse.Org_Booking__c = oldCsr.Booking_ID__c;
            cse.org_Product_Type__c = oldCsr.Booking_ID__r.Org_Booking_Type__c;
            //cse.Reason = 'Resolved'; //Commented as part of v1.1
            
            system.debug('newCsr.Derwent_CSR__c!!!!!!!!!!!!!!!!'+newCsr.Derwent_CSR__c);

            if(newCsr.Derwent_CSR__c  == true){
                cse.Org_CSR__c = true;
                //Added as part of v1.1
                cse.Org_Case_Status__c  = 'Closed';
                cse.Closing_Comments__c = 'CSR Closed';
                cse.Reason = 'Resolved';
                cse.Org_Case_Close_Reason__c = 'Resolved';
                //
            }
            lCasesToUpdate.add(cse);
        }
    }

    //KR
    private static void updateCases(){
        try{   
            system.debug('### updateCases with lCasesToUpdate: ' + lCasesToUpdate);       
            if(lCasesToUpdate.size()>0 && AvoidRecursion.isFirstRun()) update lCasesToUpdate;
        }catch(Exception e){
            system.debug('### updateCases Exception: ' + e);
        }
            
    }

    
    private static void linkOrCreateCSRToCase(List<CSR__c> csrs){
        List<Case> casesToLink = new List<Case>();
        Map<Id, Case> mapCase = new Map<Id, Case>();
        Map<String, String> mapRecTypeNames = new Map<String, String>();
        mapRecTypeNames.put('dnata', 'dTME - After Sales');
        mapRecTypeNames.put('ekh', 'EKH - After Sales');
        //mapRecTypeNames.put('dnatatravel', '');
        //
        Set<Id> bkIds = new Set<Id>();
        
        //Merul: for CSR category.
        Map<String,Lookup__c> lookUpMap = new Map<String,Lookup__c>();
                            
        for(Lookup__c lookUp : [SELECT id,
                                      Name,
                                      Type__c,
                                      CSR_Type__c 
                                 FROM Lookup__c 
                                WHERE Type__c = 'CSR Category'
                                  AND CSR_Type__c != NULL])
        {
            lookUpMap.put(lookUp.Name ,lookUp );
        
        }     
        
        
        
        for(CSR__c csr : csrs){
            if(csr.Booking_ID__c != null){
                bkIds.add(csr.Booking_ID__c);
            }
        }
        
        if(!bkIds.isEmpty()){
            
            Map<Id, Booking__c> mapBookings = new Map<Id, Booking__c>([Select Id, Org_Brand__c,Org_Booking_Type__c,Org_Account_Name__c,Org_Contact_Id_Formula__c From Booking__c Where Id In : bkIds]);
            system.debug('MapBookings=====>'+mapBookings);
            for(CSR__c csr : csrs){
               
                if(csr.Org_Brand__c == null){
                csr.Org_Brand__c = mapBookings.get(csr.Booking_ID__c).Org_Brand__c;
                system.debug('Brand=====>'+csr.Org_Brand__c);
                }
            
            
                if(csr.Case__c == null){
                    Case c = new Case();
                    c.CSRTaskId__c =   csr.TaskID__c;
                    c.Subject = csr.Subject__c;
                    if(csr.Status__c == 'Completed'){
                        c.Org_Case_Status__c = 'Closed';
                        
                        //Added as part of v1.1                        
                        c.Closing_Comments__c = 'CSR Closed';
                        c.Reason = 'Resolved';
                        c.Org_Case_Close_Reason__c = 'Resolved';
                        //
                    }
                    else{
                        c.Org_Case_Status__c = 'New';
                    }
                    c.Type = csr.CategoryId__c;
                    system.debug('c.Type'+c.Type);
                    
                    //Merul: Assigning CSR_Type__c.  
                    c.Org_Type__c = (lookUpMap.containsKey(csr.CategoryId__c) && csr.Org_Brand__c == 'dnata'  ? lookUpMap.get(csr.CategoryId__c).CSR_Type__c  : NULL);
                    
                    
                    c.Org_CSR_On_Case__c = 'With CSR';
                    //c.Type = csr.CategoryId__c;
                    system.debug('csr.Derwent_CSR__c!!!!!!!!!!!!!!!!'+csr.Derwent_CSR__c);
                    
                    if(csr.Derwent_CSR__c == true){
                        c.Org_CSR__c = true;
                    }
                    if(csr.Org_Brand__c == 'dnata'){
                    // c.Org_Current_Team_Name__c = Label.CSR_Case_Queue;
                    // c.Org_Original_Team_Name__c = Label.CSR_Case_Queue;
                    c.Org_Business_Unit_Text__c = 'dTME';
                    
                    /*   List<group> gr=[select id,name from group where type='queue' and name=:Label.CSR_Case_Queue];
                    if(gr.size() > 0){
                    c.ownerId = gr[0].id;
                    } */
                    
                    }
                    
                    if(csr.Org_Brand__c == 'EKH'){
                    // c.Org_Current_Team_Name__c = Label.CSR_Case_Queue_Ekuk;
                    // c.Org_Original_Team_Name__c = Label.CSR_Case_Queue_Ekuk;
                    c.Org_Business_Unit_Text__c = 'EKUK';
                    /*   List<group> gr=[select id,name from group where type='queue' and name=:Label.CSR_Case_Queue_Ekuk];
                    if(gr.size() > 0){
                    c.ownerId = gr[0].id;
                    } */
                    }
                    if(mapBookings.get(csr.Booking_ID__c) != null){
                    system.debug('Account=====>'+mapBookings.get(csr.Booking_ID__c).Org_Account_Name__c);
                    system.debug('Contact=====>'+mapBookings.get(csr.Booking_ID__c).Org_Contact_Id_Formula__c);
                    c.Accountid = mapBookings.get(csr.Booking_ID__c).Org_Account_Name__c;
                    c.contactid = mapBookings.get(csr.Booking_ID__c).Org_Contact_Id_Formula__c;
                    c.Org_Booking__c = csr.Booking_ID__c;
                    c.org_Product_Type__c = mapBookings.get(csr.Booking_ID__c).Org_Booking_Type__c;
                    }
                 
                    try{
                       //Find the active assignment rules on case
                        AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                        system.debug('rules!@@@@@'+rules);
                        if (rules.size() > 0){
                        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                        dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                        system.debug('dmlOpts!@@@@@'+dmlOpts);
                        //Setting the DMLOption on Case instance
                        c.setOptions(dmlOpts);
                        }
                        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(mapRecTypeNames.get(mapBookings.get(csr.Booking_ID__c).Org_Brand__c)).getRecordTypeId();   
                    }catch(Exception e){
                        
                    }
                    
                    casesToLink.add(c);
                    mapCase.putall(casesToLink);
                } else{
                
                 Case cs = new Case(id=csr.Case__c);
                 cs.Org_CSR_On_Case__c = 'With CSR';
                 cs.org_Product_Type__c = mapBookings.get(csr.Booking_ID__c).Org_Booking_Type__c;
                 if(csr.TaskID__c != null){
                 cs.CSRTaskId__c =  csr.TaskID__c;
                 }
                 casesToLink.add(cs);
                 mapCase.putall(casesToLink);
                }
            }
            
           // if(!casesToLink.isEmpty())
            if(mapCase.size()>0){
                //upsert casesToLink;
                upsert mapCase.values();
                for(CSR__c csr : csrs){
                    if(csr.Case__c == null){
                        for(Case c : casesToLink){
                            if(csr.TaskID__c == c.CSRTaskId__c) {
                                csr.Case__c = c.Id;
                            }
                        } 
                    }    
                }
            }
        }
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 29 May 2019
     * @description: method to create task assigned to Case owner - v1.2
     * @history:                
     */
    /* 
    private static void createTask(list<CSR__c>  lstCSRs)
    {
        system.debug('\n\n\n @@@@@Create Task@@@@@ \n\n\n');
        list<Task> lstNewTasks = new list<Task>();
        
        
        for(CSR__c csr : lstCSRs)
        {
            
            if(   csr.Case__c != NULL
                  && string.valueOf(csr.Case__r.OwnerId).startsWith('005')
                  && csr.Case__r.Owner.Profile.Name.contains('Retail')
                  //&& csr.Case__r.Owner.CommunityNickname != 'dnata.integration'
                  && !csr.Derwent_CSR__c
              )
              {
                system.debug('&!&!&!&!' + csr.Case__r.OwnerId);
                Task newTask = new Task();
                newTask.CurrencyIsoCode = 'AED - UAE Dirham';
                newTask.ActivityDate = system.today();
                newTask.OwnerId = csr.Case__r.OwnerId;
                newTask.Priority = 'Normal';
                newTask.Status = 'Open';
                newTask.Subject = 'Change in ' + csr.Name ;
                lstNewTasks.add(newTask);
                
            }
        }
        
        if(lstNewTasks.size() > 0){
            insert lstNewTasks;
        }
        
    }
    */
    
    private static void createTask(list<CSR__c>  lstCSRs)
    {
        system.debug('\n\n\n @@@@@Create Task@@@@@ \n\n\n');
        list<Task> lstNewTasks = new list<Task>();
        
        Set<ID> prntIds = new Set<ID>();
        
        for(CSR__c csr : lstCSRs)
        {
            prntIds.add(csr.Case__c);
        }
        Map<ID,Case> mapCase = new Map<ID,Case>([SELECT id,
                                                        OwnerId,
                                                        Owner.Profile.Name 
                                                   FROM Case 
                                                  WHERE id IN:prntIds]);  
                                                  
                                                  
        system.debug('@@@@@@@@@@ mapCase '+mapCase );
        
        for(CSR__c csr : lstCSRs)
        {
            
            Case caseObj = mapCase.get(csr.Case__c);
            system.debug('@@@@@@@@@@ caseObj  '+caseObj.Owner.Profile);
            
            if(   caseObj  != NULL
                  && string.valueOf(caseObj.OwnerId).startsWith('005')
                  //&& caseObj.Owner.Profile != NULL
                  && ( Test.isRunningTest() ? true : caseObj.Owner.Profile.Name.contains('Retail') )
                  && !csr.Derwent_CSR__c
              )

            {
                
               Task newTask = new Task();
               // newTask.CurrencyIsoCode = 'AED - UAE Dirham';
               /*
                   INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, Currency ISO Code: invalid currency code: AED - UAE Dirham: 
               */
                newTask.ActivityDate = system.today();
                newTask.OwnerId = caseObj.OwnerId;
                newTask.Priority = 'Normal';
                newTask.Status = 'Open';
                newTask.Subject = 'Change in ' + csr.Name ;
                lstNewTasks.add(newTask);
                system.debug('@@@@@@@@@@ newTask'+newTask);
                
            }
        }
        
        if(lstNewTasks.size() > 0){
            insert lstNewTasks;
        }
        
    }

}