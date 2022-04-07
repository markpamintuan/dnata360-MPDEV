/**
 * @author: Mark Anthony Pamintuan
 * @date: 28 February 2021
 * @description: This trigger is used to handle different events for the Groups_Enquiry_Form__c  Object
 * @history:                
 */
trigger GroupsEnquiryFormTrigger on Groups_Enquiry_Form__c (before insert, before update, after insert, after update, before delete,after delete) {

    if(trigger.IsBefore && trigger.IsInsert){

        GroupsEnquiryFormTriggerHandler.onBeforeInsert(trigger.New);
   
    } 

    if(trigger.IsAfter && trigger.IsInsert){

        GroupsEnquiryFormTriggerHandler.onAfterInsert(trigger.New);
   
    }   

    if(trigger.IsBefore && trigger.IsUpdate){

        system.debug('***!*!*!BEFORE UPDATE' + trigger.Old[0].Case__c);
        system.debug('***!*!*!BEFORE UPDATE' + trigger.New[0].Case__c);
   
    } 

    if(trigger.IsAfter && trigger.IsUpdate){

        system.debug('***!*!*!AFTER UPDATE' + trigger.Old[0].Case__c);
        system.debug('***!*!*!AFTER UPDATE' + trigger.New[0].Case__c);       
   
    }       

}