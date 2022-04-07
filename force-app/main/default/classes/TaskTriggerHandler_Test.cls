/**
 * @author: Mark Anthony Pamintuan
 * @date: 30 April 2019
 * @description: Test class for TaskTriggerHandler class
 * @history:                
 */
@isTest
public class TaskTriggerHandler_Test {

    static testMethod void testPopulateCSATSurveyUCIDonInsert(){

    	Id accountRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

    	Account newAccount = new Account(RecordtypeId = accountRecordtypeId, LastName = 'Testaccount', PersonEmail = 'test1account@test.com');
    	insert newAccount;

    	list<Task> lstNewTasks = new list<Task>();
    	for(integer i = 0; i < 10; i++){
    		Task newTask = new Task();
    		newTask.Subject = 'test' + i;
    		newTask.WhoId = newAccount.PersonContactId;
    		newTask.ActivityDate = system.today();
    		newTask.CallObject = 'externalId12345' + i;
            newTask.CallStartTime__c = String.valueOf(System.now());//Added by Sb
            newTask.CallDurationInSeconds = 360; //Added by Sb 
  			lstNewTasks.add(newTask);
    	}
        
        //Added by SB
        Case cs =  new Case();
        cs.ContactId = newAccount.PersonContactId;
        insert cs;
        //end 


    	test.startTest();

    		insert lstNewTasks;

    	test.stopTest();
    	//verify that CSAT_Survey_UCID__c field was updated based on CallObject field
        for(Task tsk : [SELECT CSAT_Survey_UCID__c, CallObject FROM Task WHERE WhatId =: newAccount.Id]){
        	system.assertEquals(tsk.CSAT_Survey_UCID__c, tsk.CallObject);
        }

    }

    static testMethod void testPopulateCSATSurveyUCIDonUpdate(){

    	Id accountRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

    	Account newAccount = new Account(RecordtypeId = accountRecordtypeId, LastName = 'Testaccount', PersonEmail = 'test1account@test.com');
    	insert newAccount;
		system.debug('@!@!@!@!@!@newAccount.PersonContactId: ' + newAccount.PersonContactId);
    	list<Task> lstNewTasks = new list<Task>();
    	for(integer i = 0; i < 10; i++){
    		Task newTask = new Task();
    		newTask.Subject = 'test' + i;
    		newTask.WhoId = newAccount.PersonContactId;
    		newTask.ActivityDate = system.today();
    		//newTask.CallObject = 'externalId12345' + i;
  			lstNewTasks.add(newTask);
    	}

    	insert lstNewTasks;

    	test.startTest();
    		integer j = 0;
    		for(Task taskObj : lstNewTasks){
    			taskObj.CallObject = 'externalId12345' + j;
                taskObj.CSAT_Survey_Raw_Score__c = 1 + j;
    			j++;
    		}
    		update 	lstNewTasks;

    	test.stopTest();
    	//verify that CSAT_Survey_UCID__c field was updated based on CallObject field
        for(Task tsk : [SELECT CSAT_Survey_UCID__c, CallObject FROM Task WHERE WhatId =: newAccount.Id]){
        	system.assertEquals(tsk.CSAT_Survey_UCID__c, tsk.CallObject);
        }

    }

	static testMethod void testAvayaMappingPhoneNumber(){

		Avaya_Phone_Number_Mapping__c avayaMapping = new Avaya_Phone_Number_Mapping__c();
		avayaMapping.Actual_Called_Number__c = Decimal.valueOf('3439999424');
		avayaMapping.Avaya_Internal_Number__c = Decimal.valueOf('1234567');
		insert avayaMapping;

		//insert
		Task tsk = new Task();
		tsk.Called__c = '1234567';
		tsk.subject = 'test call';
		tsk.Priority = 'low';
		tsk.Status = 'Completed';
		insert tsk;

		//null checks on update
		tsk.Called__c = '';
		update tsk;

		//add the number again
		tsk.Called__c = '1234567';
		update tsk;

		//add a number to called field that is not in the mapping
		tsk.Called__c = '87473434';
		update tsk;

	}


    static testMethod void testCreateSRAndPopulateBrand(){

    	Id accountRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId();

    	Account newAccount = new Account(RecordtypeId = accountRecordtypeId, LastName = 'Testaccount', PersonEmail = 'test1account@test.com', Org_Brand__c = 'dnata');
    	insert newAccount;
		Id personContactID = [SELECT PersonContactId FROM Account LIMIT 1].PersonContactId;
    	list<Task> lstNewTasks = new list<Task>();
    	for(integer i = 0; i < 10; i++){
    		Task newTask = new Task();
    		newTask.Subject = 'test' + i;
    		newTask.WhoId = personContactID;
    		newTask.ActivityDate = system.today();
    		//newTask.CallObject = 'externalId12345' + i;
  			lstNewTasks.add(newTask);
    	}

    	insert lstNewTasks;

    	test.startTest();
    		integer j = 0;
    		for(Task taskObj : lstNewTasks){
    			taskObj.CallObject = 'externalId12345' + j;
                taskObj.CSAT_Survey_Raw_Score__c = 1 + j;
    			j++;
    		}
    		update 	lstNewTasks;

    	test.stopTest();

    }

    static testMethod void testCalculateAvayaPosition(){

    	Id accountRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId();

		Case cse = new Case(Subject = 'test', Org_Case_Status__c = 'New', Org_Brand__c = 'dnata');
		insert cse;
    	list<Task> lstNewTasks = new list<Task>();
    	for(integer i = 0; i < 10; i++){
    		Task newTask = new Task();
			newTask.Subject = 'test' + i;
    		newTask.WhatId = cse.Id;
    		newTask.ActivityDate = system.today();
			newTask.CallObject = 'externalId12345' + i;
			newTask.CallType = 'Inbound';
			newTask.CallStartTime__c = string.valueOf(system.now());
  			lstNewTasks.add(newTask);
    	}

		

		test.startTest();

		insert lstNewTasks;
		delete lstNewTasks;

    	test.stopTest();

    }	

}