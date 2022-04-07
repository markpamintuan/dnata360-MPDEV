/**************************************************************************************************
 * Name               : DeleteCompletedRequestLogsBatch
 * Description        : This is API class to delete the completed request logs part to current week. This class will run everyday morning to delete the logs
 * Created Date       : 03-Mar-2020
 * Created By         : PwC
 * -----------------------------------------------------------------------------------------------
 ******************************************************************************************************/
global without sharing class DeleteCompletedRequestLogsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

	public string sQuery = '';
	public list<string> Status = new list<string> { 'Completed' }; 
	public date CutoffDate;
	public string DocumentId;
	string body;// = 'Id,Name,Entity__c,Entity_Id__c,Error_Log__c,Type__c,Status__c,CreatedDate\n';
	Integer iPart = 1;
	Integer iBatchSize = 2000;
	string libraryName = 'Archived Request Logs';

	global void execute(SchedulableContext sc){
        database.executebatch( new DeleteCompletedRequestLogsBatch(), iBatchSize );
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {

		CutoffDate = (CutoffDate == null ? ( system.today().addDays(-2) ) : CutoffDate); // if null then take the logs till 2 days back

		if(sQuery == '') {
			sQuery = 'select Id,Name,Entity__c,Entity_Id__c,Error_Log__c,Type__c,Status__c,CreatedDate from Request_Log__c where status__c IN : Status AND CreatedDate <=:CutoffDate order by CreatedDate';
		}
		initBody();
		System.debug('sQuery is : '+ sQuery);

		return Database.getQueryLocator(sQuery);
	}

	global void execute(Database.BatchableContext BC, list<Request_Log__c> scope) {
		
		for(Request_Log__c obj : scope){
			body += obj.Id+','+obj.Name+','+obj.Entity__c+','+obj.Entity_Id__c+','+obj.Error_Log__c+','+obj.Type__c+','+obj.Status__c+','+obj.CreatedDate+'\n';
			if(checkHeapSize()){
				updateDocument();
				initBody();
				iPart ++;
			}
		}
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		updateDocument();
	}

	public void initBody(){
		body = 'Id,Name,Entity__c,Entity_Id__c,Error_Log__c,Type__c,Status__c,CreatedDate\n';
	}

	public void updateDocument(){
		
		ContentVersion objCV = new ContentVersion();
		objCV.VersionData = Blob.valueOf(body);
		objCV.Title = 'Request Logs - '+CutoffDate.format()+' Part - '+iPart; 
		objCV.ContentLocation= 's';
		objCV.PathOnClient='Request Logs - '+CutoffDate.format()+' Part - '+iPart+'.csv';
		insert objCV;

		ContentWorkspaceDoc objCWD = new ContentWorkspaceDoc();
		objCWD.ContentDocumentId = getContentDocumentId(objCV.Id);
		objCWD.ContentWorkspaceId = getContentWorkspaceId(libraryName);
		insert objCWD;
	}

	public string getContentDocumentId(string cvId){
		for(ContentVersion objCV : [select ContentDocumentId from ContentVersion where Id=:cvId])
			return objCV.ContentDocumentId;
		return null;
	}

	public string getContentWorkspaceId(string strLibraryName){
		string WorkspaceId;
		for(ContentWorkspace objCW : [select Id,Name from ContentWorkspace where Name=:strLibraryName]){
			WorkspaceId = objCW.Id;		
		}

		/*if(WorkspaceId == null){
			//Create a Content Library
			ContentWorkspace objCW = new ContentWorkspace();
			objCW.Name = strLibraryName;
			objCW.Description = strLibraryName;
			insert objCW;
			WorkspaceId = objCW.Id;
		}*/

		return WorkspaceId;
	}

	public boolean checkHeapSize(){
		long allowed = Limits.getLimitHeapSize();
		long used = Limits.getHeapSize();
		system.debug('allowed '+allowed);
		system.debug('used '+used);
		system.debug('used '+ ((allowed*0.9) < used));
		if((allowed*0.9) <= used ){
			return true;
		}else
		return false;
	}

}