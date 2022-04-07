/**************************************************************************************************
* Name               : TaskTriggerHandler 
* Description        : This is the handler class for Task trigger         
* Created Date       : 08-Oct-2018                                                                 
* Created By         : Mark                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Mark        30-Apr-2019   Initial version
* v1.1        Keith       11-Sep-2019   Update task with case for avaya
* v1.2        Keith       12-Sep-2019   calculate avaya task position related to case
* v1.3        Sri Bala    24-Sep-2019   Check if the task is inbound to link it with avaya. 
* v1.4        Keith       31-Oct-2019   Populate the avaya call task with the actual called number of the customer. 
* v1.5        Evendo      26-Dec-2019   T-00906 - Customer journey should be Post Call for CSAT Survey Response
* v1.6		  Mark		  24-Sep-2020	Optimized/refactored after logics for faster processing time
* v1.7        Mark        28-Oct-2020   Added additional logic to populate brand on task
*****************************************************************************************************/
/**
* @author: Mark Anthony Pamintuan
* @date: 30 April 2019
* @description: Class to house all the event handler of Task trigger
* @history:                
*/
public class TaskTriggerHandler {
    
    //Before Insert
    public static void onBeforeInsert(List<Task> lstNewTasks){
        populateCSATSurveyUCIDonTask(lstNewTasks);       
        populateReminderTimeOnTask(lstNewTasks); // Added By Sri Bala       
        populateBrandOnTask(lstNewTasks);         
        populateAvayaCaseonTask(lstNewTasks); // v1.1        
        avayaMappingOfActualPhoneNumbers(lstNewTasks, null); //v1.4
        
    }
    
    //Before Update
    public static void onBeforeUpdate(list<Task> lstOldTasks,
                                      list<Task> lstNewTasks, 
                                      map<Id,Task> oldTaskMap,
                                      map<Id,Task> newTaskMap){
        //v1.7
        list<Task> tasksWithoutBrand = new list<Task>();
        
        for(Task t : lstNewTasks){
            if(string.IsEmpty(t.Brand__c) && (string.IsNotEmpty(t.WhoId) || string.IsNotEmpty(t.CSAT_Survey_Name__c))){
                tasksWithoutBrand.add(t);
            }
        }

        if(tasksWithoutBrand.size() > 0){
            populateBrandOnTask(tasksWithoutBrand);
        }
        //end v1.7


        populateCSATSurveyUCIDonTask(lstNewTasks);
        populateReminderTimeOnTask(lstNewTasks);   // Added by Sri Bala 
        //populateAvayaCaseonTask(lstNewTasks); // v1.1
        avayaMappingOfActualPhoneNumbers(lstNewTasks, oldTaskMap); //v1.4                               
                                          
    }
    
    //After Insert
    public static void onAfterInsert(list<Task> lstNewTasks){		
        //v1.6
        set<Id> whatIDs = new set<Id>();
        
        for(Task newTask : lstNewTasks){
            if(newTask.CallObject != null && newTask.WhatId != null && newTask.CallType == 'Inbound'){
                whatIDs.add(newTask.WhatId);
            }
        }    
        //calculateAvayaTaskPosition(lstNewTasks); //v1.2
        if(!whatIDs.isEmpty()){
            calculateAvayaTaskPosition(whatIDs);
        }
        //End v1.6 
    }
    
    //After Update
    public static void onAfterUpdate(list<Task> lstOldTasks,
                                     list<Task> lstNewTasks, 
                                     map<Id,Task> oldTaskMap,
                                     map<Id,Task> newTaskMap){

        //v1.6
        set<Id> taskIdsToCreateSR = new set<Id>();
        set<Id> whatIDs = new set<Id>();
        
        for(Task newTask : lstNewTasks){

            Task oldTask = oldTaskMap.get(newTask.Id);

            if(newTask.CSAT_Survey_Raw_Score__c != null && oldTask.CSAT_Survey_Raw_Score__c != newTask.CSAT_Survey_Raw_Score__c){
                taskIdsToCreateSR.add(newTask.Id);
            }

            if(newTask.CallObject != null && newTask.WhatId != null && newTask.CallType == 'Inbound' && oldTask.Call_Position_Number__c != newTask.Call_Position_Number__c){
                whatIDs.add(newTask.WhatId);
            }

        }

        //createSurveyResponse(lstNewTasks,oldTaskMap);
        if(!taskIdsToCreateSR.isEmpty()){
            createSurveyResponse(taskIdsToCreateSR);
        }

        //calculateAvayaTaskPosition(lstNewTasks); //v1.2
        if(!whatIDs.isEmpty()){
            calculateAvayaTaskPosition(whatIDs);
        }                   
        //End v1.6                    
                                         
    }
    
    //After Delete
    public static void onAfterDelete(list<Task> lstNewTasks){
			
        //v1.6
        set<Id> whatIDs = new set<Id>();
    
        for(Task newTask : lstNewTasks){
            if(newTask.CallObject != null && newTask.WhatId != null && newTask.CallType == 'Inbound'){
                whatIDs.add(newTask.WhatId);
            }
        }    
        //calculateAvayaTaskPosition(lstNewTasks); //v1.2
        if(!whatIDs.isEmpty()){
            calculateAvayaTaskPosition(whatIDs);
        }
        //End v1.6

    }
    
    /**
    * @author: Mark Anthony Pamintuan
    * @date: 30 April 2019
    * @description: method to populate CSAT_Survey_UCID__c field from CallObject value
    * @history:                
    */
    static void populateCSATSurveyUCIDonTask(list<Task> lstNewTasks){
        
        for(Task t : lstNewTasks){
            if(string.IsNotEmpty(t.CallObject)){
                t.CSAT_Survey_UCID__c = t.CallObject;
            }   
        }
        
    }
    
    /**
    * @author: Mark Anthony Pamintuan
    * @date: 13 May 2019
    * @description: method to create Survey response record
    * @history:                
    */
    @future
    static void createSurveyResponse(set<Id> taskIDs){ //v1.6
        system.debug('\n\n\n ************ createSurveyResponse ************ \n\n\n');
        list<Survey_Response__c> lstSurveyResponses = new list<Survey_Response__c>();
        set<Id> whoIds = new set<Id>();
        map<Id,Account> contactAccountMap = new map<Id,Account>();
        map<Id,Account> relatedAccountsMap = new map<Id,Account>();
        
        list<Task> lstNewTasks = [SELECT Id, Brand__c, CreatedDate, WhoId, CSAT_Survey_Raw_Score__c FROM Task WHERE Id IN: taskIDs];

        for(Task newTask : lstNewTasks){
            if(string.IsNotEmpty(newTask.WhoId)){
                whoIds.add(newTask.WhoId);
            }
        }
        system.debug('&!&!&!&!&whoIds: ' + whoIds);
        if(!whoIds.IsEmpty()){
            for(Account customer : [SELECT Id, PersonContactId, Org_CSAT_Recent_Score__c FROM Account WHERE PersonContactId IN: whoIds]){
                contactAccountMap.put(customer.PersonContactId,customer);
            }
        }
        
        for(Task t : lstNewTasks){
            Survey_Response__c sr = new Survey_Response__c();
            sr.Org_Survey_Model__c = 'CSAT';
            sr.Brand__c = t.Brand__c;
            sr.CSAT_Survey_Created_Date__c = t.CreatedDate;
            sr.Org_Customer_Journey__c = 'Post Call'; // v1.5  
            sr.Org_Rating__c = t.CSAT_Survey_Raw_Score__c;
            sr.Org_Survey_Task_Id__c = t.Id;
            if(contactAccountMap.containsKey(t.WhoId)){
                Account relatedAccount = contactAccountMap.get(t.WhoId);
                sr.Org_Account__c = contactAccountMap.get(t.WhoId).Id;
                relatedAccount.Org_CSAT_Recent_Score__c = t.CSAT_Survey_Raw_Score__c;
                relatedAccountsMap.put(relatedAccount.Id,relatedAccount);
            }
            lstSurveyResponses.add(sr);
        }
        
        insert lstSurveyResponses;
        
        
        if(relatedAccountsMap.size() > 0){
            update relatedAccountsMap.values();
        }
        
    }
    
    /**
    * @author: Mark Anthony Pamintuan
    * @date: 14 May 2019
    * @description: method to populate Brand based on customer's brand
    * @history:                
    */
    static void populateBrandOnTask(list<Task> lstNewTasks){
        system.debug('\n\n\n ************ populateBrandOnTask ************ \n\n\n');
        set<Id> whoIds = new set<Id>();
        map<Id,Account> contactIdAccountMap = new map<Id,Account>();

        map<String,String> surveyNameBrandMap = getSurveyNameBrandMap(); //v1.7
        
        for(Task newTask : lstNewTasks){
            if(string.IsNotEmpty(newTask.WhoId)){
                whoIds.add(newTask.WhoId);
            }
        }
        system.debug('&!&!&!&!&whoIds: ' + whoIds);
        if(!whoIds.IsEmpty()){
            for(Account customer : [SELECT Org_Brand__c, PersonContactId FROM Account WHERE PersonContactId IN: whoIds]){
                contactIdAccountMap.put(customer.PersonContactId,customer);
            }
        }
        
        for(Task t : lstNewTasks){
            if(contactIdAccountMap.containsKey(t.WhoId)){
                t.Brand__c = contactIdAccountMap.get(t.WhoId).Org_Brand__c;
            } else if(string.IsNotEmpty(t.CSAT_Survey_Name__c) && surveyNameBrandMap.containsKey(t.CSAT_Survey_Name__c)){ //v1.7
                t.Brand__c = surveyNameBrandMap.get(t.CSAT_Survey_Name__c);
            } else {
                t.Brand__c = '';
            } 
        }   
        
    }

    /* @author: Sri Bala
    * @date: 24-Sept-2019
    * @description: populate reminder time on task if the brand is trp.              
    */
    static void populateReminderTimeOnTask(List<Task> lstNewTasks){
        for(Task t : lstNewTasks){
            system.debug('task brand @@@'+t.Brand__c);
            if(t.Brand__c == 'trp'){
                t.ReminderDateTime = t.Org_Due_Date_Time__c;
                t.IsReminderSet = true;
                t.ActivityDate = Date.valueof(t.Org_Due_Date_Time__c);
            }   
        }
    }
    
    /* @author: Keith Rogers
    * @date: 31 October 2019
    * @description: populate the actual number called by the customer on the call record.
    * @history:                
    */
    //v1.4  
    static void avayaMappingOfActualPhoneNumbers(list<Task> lstNewTasks, map<Id,Task> oldTaskMap){
        system.debug('\n\n\n ************ avayaMappingOfActualPhoneNumbers ************ \n\n\n');
        //Integer ensures no leading zeros
        Map<Decimal, Decimal> mAvayaNumberToActualNumber = new Map<Decimal, Decimal>();


        for(Task t : lstNewTasks){
            //this is for before insert
            if(oldTaskMap == null && string.IsNotEmpty(t.Called__c) && t.Called__c != null){
                mAvayaNumberToActualNumber.put(Decimal.valueOf(t.Called__c), null);
            }
            //This is for beforeupdate
            if(oldTaskMap != null && t.Called__c != oldTaskMap.get(t.Id).Called__c){
                if(t.Called__c == null) t.Customer_Dialled_Number__c = '';
                if(t.Called__c != null) mAvayaNumberToActualNumber.put(Decimal.valueOf(t.Called__c), null);
            }
                
            system.debug('£££££ mAvayaNumberToActualNumber: ' + mAvayaNumberToActualNumber);
            //Need to keep track of all numbers as an update may happen that caused the mapping to change.   
        }

        if(mAvayaNumberToActualNumber.size()> 0){
            List<Decimal> lAvayaPhoneNumbersWithoutLeadingZero = new List<Decimal>();
            lAvayaPhoneNumbersWithoutLeadingZero.addAll(mAvayaNumberToActualNumber.keySet());
            system.debug('££££ lAvayaPhoneNumbersWithoutLeadingZero: ' + lAvayaPhoneNumbersWithoutLeadingZero);

            for(Avaya_Phone_Number_Mapping__c avayphonemap: [SELECT ID, 
                                                                Actual_Called_Number__c, 
                                                                Avaya_Internal_Number__c
                                                            FROM Avaya_Phone_Number_Mapping__c
                                                            WHERE Avaya_Internal_Number__c IN: lAvayaPhoneNumbersWithoutLeadingZero]){
                
                if(avayphonemap.Avaya_Internal_Number__c != null && avayphonemap.Actual_Called_Number__c!=null){
                    mAvayaNumberToActualNumber.put(
                                            avayphonemap.Avaya_Internal_Number__c, 
                                            avayphonemap.Actual_Called_Number__c
                    );
                }
            }//for loop
        
            //Populate the mapped value on task
            for(Task t: lstNewTasks){
                if(mAvayaNumberToActualNumber.get(Decimal.valueOf(t.Called__c)) == null) t.Customer_Dialled_Number__c = '';
                
                if(mAvayaNumberToActualNumber.get(Decimal.valueOf(t.Called__c)) != null){
                    Decimal customerDialledNumber = mAvayaNumberToActualNumber.get(Decimal.valueOf(t.Called__c));
                    t.Customer_Dialled_Number__c = String.valueOf(customerDialledNumber);
                }

            }

        }

    }


    
    /********************Marketing Phone number TRACKER************************/  

    static void populateAvayaCaseonTask(List<Task> lstNewTasks){
        system.debug('\n\n\n ************ populateAvayaCaseonTask ************ \n\n\n');
        List<Id> taskAccountList = new List<Id>();
        Set<Id> recentlyViewedCaseId = new Set<Id>();
        String callStartTime = '';
        //List of RecentlyViewed cases
        for(Task tsk : lstNewTasks){
            if(tsk.CallObject!=null && tsk.CallObject!=' ')
                taskAccountList.add(tsk.WhoId);
        }
        
        system.debug('taskAccountList'+taskAccountList);
        List<Case> caseList = new List<Case>();
        if(taskAccountList.size() > 0){
            caseList = [Select Id,ContactId,LastViewedDate,IsParentCase__c from Case WHERE
                        ContactId IN :taskAccountList AND LastViewedDate != null ORDER BY LastViewedDate ASC ];
        }
        
        system.debug('caseList'+caseList);
        
        if(caseList.size() > 0){
            for(Task t : lstNewTasks){
                for(Case cs : caseList){
                    callStartTime = t.CallStartTime__c.replace('T',' ');
                    if(t.CallObject!=null && cs.IsParentCase__c && t.CallType == 'Inbound' && cs.ContactId == t.WhoId && cs.LastViewedDate >= Datetime.valueof(callStartTime) && cs.LastViewedDate <= Datetime.valueof(callStartTime ).addSeconds(t.CallDurationInSeconds)){
                        system.debug('Entered');    
                        t.WhatId = cs.Id;
                    }
                }
            }
        }
        
        system.debug('caseList'+caseList);
        // link only the cases with no booking
    }

    //v1.2
    static integer runTimes = 0;

    /**************************************************************************************************
    * Name               : calculateAvayaTaskPosition 
    * Description        : calculates the position of task based on call start time
    * Params             : List<Task>
    * Return             : -
    **************************************************************************************************/
    static void calculateAvayaTaskPosition(set<Id> caseIDs){ //v1.6
        system.debug('\n\n\n ************ calculateAvayaTaskPosition ************ \n\n\n');
        String callStartTime;
        Integer positionNumber = 1;
        Integer noOftasks = 0;
        List<Task> taskPositionList = new List<Task>();

        map<Id,Case> caseIdMap = new map<Id,Case>();
        list<Task> taskList = new list<Task>();
        system.debug('*****!*!*!*!WhatIDs: ' + caseIDs);

        for(Case cse : [SELECT Id, Org_Booking__c, Org_Booking__r.Org_Booked_Date__c FROM Case WHERE Id IN: caseIDs]){
            caseIdMap.put(cse.Id,cse);
        }
        system.debug('*****!*!*!*!caseIdMap: ' + caseIdMap);
        taskList = [SELECT Id, Call_Position_Number__c, WhatId, CallStartTime__c, Attribution_Percentage__c FROM Task WHERE WhatId IN: caseIDs ORDER BY CallStartTime__C ASC];
        noOftasks = taskList.size();
        for(Task t : taskList){
            system.debug('*****!*!*!*!TASK: ' + t);
            if(String.isBlank(t.CallStartTime__c)){ //added to check callstarttime if blank
                t.CallStartTime__c = string.valueOf(system.now());
            }
            callStartTime = t.CallStartTime__c.replace('T',' ');
            if(caseIdMap.containsKey(t.WhatId)){
                Case relatedCase = caseIdMap.get(t.WhatId);
                if(relatedCase.Org_Booking__c == null || (relatedCase.Org_Booking__c != null && (DateTime.valueOf(callStartTime) <= relatedCase.Org_booking__r.Org_Booked_Date__c))){
                    t.Call_Position_Number__c = positionNumber;
                    system.debug('*****!*!*!taskCount: '+noOftasks);
                    system.debug('*****!*!*!positionNumber: '+positionNumber);
                    //Check if the size of tasks based on number of tasks calculate the atrribution percentage
                    if(noOftasks == 1){
                        t.Attribution_Percentage__c = 100;
                    }else if(noOftasks == 2){
                        t.Attribution_Percentage__c = 50;
                    }else if(noOftasks > 2){
                        if(positionNumber == 1 || positionNumber == noOftasks){
                            t.Attribution_Percentage__c = 40;
                        }else {
                            t.Attribution_Percentage__c = 20 / (noOftasks - 2);
                        }
                    }
                    system.debug('*****!*!*!Attribution_Percentage__c: '+t.Attribution_Percentage__c);
                    positionNumber++;
                    taskPositionList.add(t);
                }    
            }
        }

        try{
            if(taskPositionList.size() > 0){
                update taskPositionList;
            }
        }
        catch(Exception e){
            System.debug('Exception '+e+'Line Number '+e.getLineNumber());
        }

    }

    /*
    static void calculateAvayaTaskPosition(List<Task> lstNewTasks){
        system.debug('\n\n\n ************ calculateAvayaTaskPosition ************ \n\n\n');
        Set<Id> taskId = new Set<Id>();
        List<Id> whatId = new List<Id>();
        String callStartTime ;
        List<Task> taskList = new List<Task>();
        List<Task> taskPositionList = new List<Task>();
        
        // add all the tasks that are created by call and call type is inbound to whatId list
        if(lstNewTasks.size()>0){
            for(task tsk :lstNewTasks){
                if(tsk.CallObject!=null && tsk.WhatId!=null && tsk.CallType == 'Inbound'){
                    whatId.add(tsk.WhatId);
                    runTimes++;
                }
            }
        }
        system.debug('task Id'+taskId);
        
        if(WhatId.size() > 0)
            taskList = [Select Id,WhatId from Task where WhatId =: whatId[0] AND CallObject != null ORDER BY CallStartTime__C ASC];
        
        for(task tsk : taskList){
            taskId.add(tsk.Id);
            
        }
        List<Case> caseList = [Select Id,Org_Booking__c,Org_Booking__r.Org_Booked_Date__c from Case where Id IN: whatId];
        system.debug('task Id'+taskId);
        Integer positionNumber = 1;
        Integer noOftasks = 0;
        
        List<Task> TaskNewList = [Select Id,Call_Position_Number__c,WhatId,CallStartTime__c from Task where Id IN:taskId ORDER BY CallStartTime__C ASC];
        noOftasks = TaskNewList.size();
        
        if(TaskNewList.size()>0 && caseList.size() > 0){
            for(Task tsk : TaskNewList){
                callStartTime = tsk.CallStartTime__c.replace('T',' ');
                //Check if the booking is null or check if the booked date of the booking linked to case is greater than the task Call Start Time
                if(caseList[0].Org_Booking__c == null || (caseList[0].Org_Booking__c != null && (DateTime.valueOf(callStartTime) <= caseList[0].Org_booking__r.Org_Booked_Date__c))){
                    tsk.Call_Position_Number__c = positionNumber;
                    system.debug('taskCount'+noOftasks);
                    system.debug('positionNumber'+positionNumber);
                    //Check if the size of tasks based on number of tasks calculate the atrribution percentage
                    if(noOftasks == 1)
                        tsk.Attribution_Percentage__c = 100;
                    else if(noOftasks == 2)
                        tsk.Attribution_Percentage__c = 50;
                    else if(noOftasks >2){
                        if(positionNumber == 1 || positionNumber == noOftasks)
                            tsk.Attribution_Percentage__c = 40;
                        else
                            tsk.Attribution_Percentage__c = 20/(noOftasks - 2);
                    }
                    system.debug('Attribution_Percentage__c'+tsk.Attribution_Percentage__c);
                    positionNumber++;
                    taskPositionList.add(tsk);
                }
            }
        }
        system.debug('runtimes'+runTimes);
        //integer runtime added so that afterupdate the trigger do not run recurrsively
        try{
            if(taskPositionList.size() > 0 && runTimes <2){
                update taskPositionList;
            }
        }
        catch(Exception e){
            System.debug('Exception '+e+'Line Number '+e.getLineNumber());
        }
    }
    */

    /**
    * @author: Mark Anthony Pamintuan
    * @date: 28 Oct 2020
    * @description: returns map of survey name and brand
    * @history: v1.7               
    */
    static map<String,String> getSurveyNameBrandMap(){

        map<String,String> surveyNameBrandMap = new map<String,String>();

        for(Survey_Name_Brand_Mapping__mdt mdt : [SELECT CSAT_Survey_Name__c, Brand__c FROM Survey_Name_Brand_Mapping__mdt]){
            surveyNameBrandMap.put(mdt.CSAT_Survey_Name__c,mdt.Brand__c);
        }

        return surveyNameBrandMap;

    }

}