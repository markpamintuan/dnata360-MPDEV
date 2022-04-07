/**
* @author: Mark Anthony Pamintuan
* @date: 5 April 2020
* @description: Batch class to identify which cases qualified for Post Complaint surveys
* @history:                
*/
global class PostComplaintSurveyBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc){
        database.executebatch(new PostComplaintSurveyBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string queryString = 'SELECT Org_Case_Complaint_Survey_Sent_Date__c, Org_Brand__c FROM Case WHERE ';
        
        for(Survey_Mapping__mdt postComplaint : [SELECT SOQL__c FROM Survey_Mapping__mdt WHERE Survey_Type__c = 'Post Complaint']){
            if(string.IsNotEmpty(postComplaint.SOQL__c)){
                queryString += '(' + postComplaint.SOQL__c + ')' + ' OR ';
            }
        }

        queryString = queryString.substring(0,queryString.length() - 4);
 		String strDateTime = string.valueOf(system.now()).replace(' ', 'T') + 'Z';
 		String strLastFourDays = string.valueOf(system.now().addDays(-4)).replace(' ', 'T') + 'Z';
 		       
        if(queryString.contains('dateToday') && queryString.contains('lastFourDays')){
        	queryString = queryString.replace('dateToday',strDateTime).replace('lastFourDays',strLastFourDays);
        } else if(queryString.contains('dateToday')){
        	queryString = queryString.replace('dateToday',strDateTime);
        }
        
        system.debug('******Query String: ' + queryString);
        return database.getQueryLocator(queryString);
        
    }

    global void execute(Database.BatchableContext BC, list<Case> scope){
        
        list<Case> lstQualifiedComplaints = new list<Case>();

        for(Case complaint : scope){                      
            complaint.Org_Case_Complaint_Survey_Sent_Date__c = system.today();
            lstQualifiedComplaints.add(complaint);
        }
        system.debug('******lstQualifiedComplaints: ' + lstQualifiedComplaints.size());
        if(lstQualifiedComplaints.size() > 0){
            update lstQualifiedComplaints;
        }

    }

    global void finish(Database.BatchableContext BC){
    
    }
}