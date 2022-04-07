/**
* @author: Mark Anthony Pamintuan
* @date: 5 April 2020
* @description: Batch class to identify which bookings qualified for Post Booking surveys
* @history:                
*/
global class PostBookingSurveyBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc){
		database.executebatch(new PostBookingSurveyBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
		
        string queryString = 'SELECT Org_Post_Booking_NPS_Survey_Sent_Date__c, Org_Travel_Start_Date__c, Org_Booked_Date__c, Org_Email__c, Org_Customer_Email_Formula__c FROM Booking__c WHERE ';
        
        for(Survey_Mapping__mdt postBooking : [SELECT SOQL__c FROM Survey_Mapping__mdt WHERE Survey_Type__c = 'Post Booking']){
            if(string.IsNotEmpty(postBooking.SOQL__c)){
            	queryString += '(' + postBooking.SOQL__c + ')' + ' OR ';
            }
        }
        
        queryString = queryString.substring(0,queryString.length() - 4);
 		String strTodayDateTime = string.valueOf(system.now()).replace(' ', 'T') + 'Z';
 		String strLastFourDays = string.valueOf(system.now().addDays(-4)).replace(' ', 'T') + 'Z';
     
        if(queryString.contains('dateTimeToday') && queryString.contains('dateToday') && queryString.contains('lastFourDays')){
        	queryString = queryString.replace('dateTimeToday',strTodayDateTime).replace('dateToday',string.valueOf(system.today())).replace('lastFourDays',strLastFourDays);
        } else if(queryString.contains('dateTimeToday') && queryString.contains('dateToday')){
        	queryString = queryString.replace('dateTimeToday',strTodayDateTime).replace('dateToday',string.valueOf(system.today()));
        }
                
        system.debug('******Query String: ' + queryString);
        return database.getQueryLocator(queryString);
        
    }

    global void execute(Database.BatchableContext BC, list<Booking__c> scope){
    	
		list<Booking__c> lstQualifiedBookings = new list<Booking__c>();

		for(Booking__c booking : scope){			
			if(booking.Org_Travel_Start_Date__c != null && booking.Org_Booked_Date__c != null){	
				Date bookedDate = date.valueOf(booking.Org_Booked_Date__c);
				if(bookedDate.daysBetween(date.valueOf(booking.Org_Travel_Start_Date__c)) > 7){
					booking.Org_Post_Booking_NPS_Survey_Sent_Date__c = system.today();
					if(booking.Org_Email__c == null){
						booking.Org_Email__c = booking.Org_Customer_Email_Formula__c;
					}
					lstQualifiedBookings.add(booking);
					system.debug('********qualified Booking: ' + booking);
				}
			}
		
		}
		system.debug('********lstQualifiedBookings: ' + lstQualifiedBookings);
		if(lstQualifiedBookings.size() > 0){
			update lstQualifiedBookings;
		}

    }

    global void finish(Database.BatchableContext BC){
    
    }
}