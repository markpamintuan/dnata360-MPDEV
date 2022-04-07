/**************************************************************************************************
 *  Author      : Kaavya Raghuram
    Company     : PwC
    Date        : 9-May-2018
    Description :This is a master trigger for the Request Log object
 * Whenever a record is inserted or updated this trigger will invoke a queable class
 * which then will call the webservice and fetch the data accordingly
 * 
 * *************************************************************************************************/

trigger RequestLogTrigger on Request_Log__c (before insert,after insert,before update,after update) {
    /*
    if(trigger.isAfter && trigger.isInsert && (!(System.isBatch() || System.isFuture())) ){
        
    }
    */
    
    if(trigger.isBefore){
        if(trigger.isInsert)
            RequestLogTriggerHandler.Execute_BI(Trigger.New);
        if(trigger.isUpdate)
            RequestLogTriggerHandler.Execute_BU(Trigger.New,Trigger.OldMap);
    }
    if(trigger.isAfter){
        if(trigger.isInsert)
            RequestLogTriggerHandler.Execute_AI(Trigger.New);
        if(trigger.isUpdate)
            RequestLogTriggerHandler.Execute_AU(Trigger.New,Trigger.OldMap);
    }

    
}