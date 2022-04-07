/**
* @author: Mark Anthony Pamintuan
* @date: 5 April 2020
* @description: Batch class to identify which bookings qualified for Trust Pilot surveys
* @history:                
*/
global class TrustPilotSurveyBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc){
        database.executebatch(new TrustPilotSurveyBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string queryString = 'SELECT EKH_Trust_Pilot_Sent_Date__c, Org_Email__c, Org_Customer_Email_Formula__c FROM Booking__c WHERE ';
        
        for(Survey_Mapping__mdt trustPilot : [SELECT SOQL__c FROM Survey_Mapping__mdt WHERE Survey_Type__c = 'Trust Pilot']){
            if(string.IsNotEmpty(trustPilot.SOQL__c)){
                queryString += '(' + trustPilot.SOQL__c + ')' + ' OR ';
            }
        }

        queryString = queryString.substring(0,queryString.length() - 4);
 		String strDateTime = string.valueOf(system.now()).replace(' ', 'T') + 'Z';
 		String strLastFourDays = string.valueOf(system.now().addDays(-4)).replace(' ', 'T') + 'Z';
 		       
        if(queryString.contains('dateToday') && queryString.contains('lastFourDays')){
        	queryString = queryString.replace('dateToday',strDateTime).replace('lastFourDays',strLastFourDays);
        }
        
        system.debug('******Query String: ' + queryString);
        return database.getQueryLocator(queryString);
        
    }

    global void execute(Database.BatchableContext BC, list<Booking__c> scope){
        
        list<Booking__c> lstQualifiedBookings = new list<Booking__c>();

        for(Booking__c booking : scope){ 
        	system.debug('******booking: ' + booking);         
            booking.EKH_Trust_Pilot_Sent_Date__c = system.today();
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