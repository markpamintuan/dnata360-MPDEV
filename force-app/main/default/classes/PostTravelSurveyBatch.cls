/**
* @author: Mark Anthony Pamintuan
* @date: 5 April 2020
* @description: Batch class to identify which bookings qualified for Post Travel surveys
* @history:                
*/
global class PostTravelSurveyBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc){
        database.executebatch(new PostTravelSurveyBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        string queryString = 'SELECT Org_Post_Travel_NPS_Survey_Sent_Date__c, Org_Email__c, Org_Customer_Email_Formula__c FROM Booking__c WHERE ';
        
        for(Survey_Mapping__mdt postTravel : [SELECT SOQL__c FROM Survey_Mapping__mdt WHERE Survey_Type__c = 'Post Travel']){
            if(string.IsNotEmpty(postTravel.SOQL__c)){
                queryString += '(' + postTravel.SOQL__c + ')' + ' OR ';
            }
        }
        
        queryString = queryString.substring(0,queryString.length() - 4);
        
        if(queryString.contains('dateToday') && queryString.contains('lastFourDays') && queryString.contains('lastThreeDays')){
        	queryString = queryString.replace('dateToday',string.valueOf(system.today())).replace('lastFourDays',string.valueOf(system.today().addDays(-4))).replace('lastThreeDays',string.valueOf(system.today().addDays(-3)));
        } else if(queryString.contains('dateToday') && queryString.contains('lastFourDays')){
        	queryString = queryString.replace('dateToday',string.valueOf(system.today())).replace('lastFourDays',string.valueOf(system.today().addDays(-4)));
        } else if(queryString.contains('dateToday') && queryString.contains('lastThreeDays')){
        	queryString = queryString.replace('dateToday',string.valueOf(system.today())).replace('lastThreeDays',string.valueOf(system.today().addDays(-3)));
        }
        
        system.debug('******Query String: ' + queryString);
        return database.getQueryLocator(queryString);
        
    }

    global void execute(Database.BatchableContext BC, list<Booking__c> scope){
        
        list<Booking__c> lstQualifiedBookings = new list<Booking__c>();

        for(Booking__c booking : scope){
        	system.debug('******booking: ' + booking);            
            booking.Org_Post_Travel_NPS_Survey_Sent_Date__c = system.today();
			if(booking.Org_Email__c == null){
				booking.Org_Email__c = booking.Org_Customer_Email_Formula__c;
			}       
            lstQualifiedBookings.add(booking);
        }
        system.debug('******lstQualifiedBookings.size(): ' + lstQualifiedBookings.size());
        if(lstQualifiedBookings.size() > 0){
            update lstQualifiedBookings;
        }

    }

    global void finish(Database.BatchableContext BC){
    
    }
}