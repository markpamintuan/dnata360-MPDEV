@istest
public class AgentCommunicationTest {
   @isTest static void  getAllMessages(){
       
       case objcase = new case();
       objcase.status= 'new';
       insert objcase;
       
       
       Customer_Communication__c Cobj = new Customer_Communication__c(); 
       cobj.Message__c= 'Hello';
       cobj.Service_Request__c= objcase.Id;
       insert cobj;
       Test.startTest();
       AgentCommunication.getAllMessages(objcase.Id);
       AgentCommunication.getEmailFolder();
       AgentCommunication.fetchUser();
       Test.stopTest();
   }
   
   @isTest static void SaveAgentMessage(){
       
       
       case objcase = new case();
       objcase.status= 'new';
       insert objcase;
       
       Customer_Communication__c Cobj = new Customer_Communication__c(); 
       cobj.Response_Required__c= true;
       cobj.Message__c='Hello';
       cobj.Service_Request__c=objcase.ID;
       insert cobj; 
       Test.startTest();
       AgentCommunication.SaveAgentMessage(objcase.ID , 'replyMsgText' , true,true);
       AgentCommunication.getEmailFolder();
       AgentCommunication.fetchUser();
       Test.stopTest();
   }
   
}