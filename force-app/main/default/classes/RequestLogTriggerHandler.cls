/*
    Author      : Kaavya Raghuram
    Company     : PwC
    Date        : 9-May-2018
    Description : Trigger Handler class for Request Log object
    -------------------------------------------------------------------------
* VERSION     AUTHOR          DATE            COMMENTS
* v1.1        Ravindra        29-Jan-2020     Added the logic to repush the log if it gets fail    
*/
public without sharing class RequestLogTriggerHandler{
    
    public static set<string> setExceptionMessages = new set<string>();

    //Method for before insert logic
    public static void Execute_BI(list<Request_Log__c> TriggerNew){
        //v1.3
        populateRepushFlag(TriggerNew, null);
    }
    
     //Method for after insert logic
    public static void Execute_AI(list<Request_Log__c> TriggerNew){
        
        List<Id> custlist = new List<Id>(); 
        List<Id> triplist = new List<Id>(); 
        List<Id> csrlist = new List<Id>();
        List<Id> quotelist = new List<Id>();

        for(Request_Log__c req : TriggerNew){
            if(req.Is_Synchronous__c)
                continue;
            if(req.Entity__c=='Customer')
                custlist.add(req.id);
            else if(req.Entity__c=='Booking')
                triplist.add(req.id);   
            else if(req.Entity__c=='Csr')
                csrlist.add(req.id);    
            else if(req.Entity__c=='Quote')
                quotelist.add(req.id);  
        }
        if(custlist.size()>0)
            system.enqueueJob(new AsyncDerwentWebservice (custlist,'Customer_Upsert',null));
        
        if(triplist.size()>0)
            system.enqueueJob(new AsyncDerwentWebservice (triplist,'Booking_Upsert',null));
        
        if(csrlist.size()>0)
            system.enqueueJob(new AsyncDerwentWebservice (csrlist,'CSR_Upsert',null));
        
        if(quotelist.size()>0)
            system.enqueueJob(new AsyncDerwentWebservice (quotelist,'Quote_Upsert',null));
    }
    
     //Method for before update logic
    public static void Execute_BU(list<Request_Log__c> TriggerNew,map<Id,Request_Log__c> TriggerOldMap){
        //v1.3
        populateRepushFlag(TriggerNew, TriggerOldMap);
    }
    
    //Method for after update logic
    public static void Execute_AU(list<Request_Log__c> TriggerNew,map<Id,Request_Log__c> TriggerOldMap){
    }

    //v1.3
    public static void populateRepushFlag(list<Request_Log__c> lstNewReqLogs, map<Id,Request_Log__c> mapOldReqLogs){
        
        for(Request_Log__c objLog : lstNewReqLogs){
            if(objLog.Entity_Id__c != null && objLog.Entity__c != null && 
                (mapOldReqLogs == null || (mapOldReqLogs != null && mapOldReqLogs.containsKey(objLog.Id) && mapOldReqLogs.get(objLog.Id).Error_Log__c != objLog.Error_Log__c ) ) &&
                objLog.Error_Log__c != null && objLog.Status__c == 'Failed'
            ){
                if(setExceptionMessages.isEmpty()) getExceptionMetadata();

                for(string msg : setExceptionMessages){
                    if(objLog.Error_Log__c.toLowerCase().contains(msg)){
                        objLog.Repush__c = true;
                    }
                }
            }
            if(objLog.Status__c == 'Completed'){
                objLog.Repush__c = false;
            }
        }
    }

    public static set<string> getExceptionMetadata(){
        setExceptionMessages = new set<string>();
        for(Repush_Exception_List__mdt objMD : [select DeveloperName,Exception_Message__c from Repush_Exception_List__mdt where Is_Active__c = true AND Check_in_DB__c = false AND Exception_Message__c != null ]){
            setExceptionMessages.add( objMD.Exception_Message__c.toLowerCase() );
        }
        return setExceptionMessages;
    }
}