global class AsynWebService_Airline_Scheduler implements Schedulable, Database.AllowsCallouts {   
    
    global void execute(SchedulableContext ctx){       
         System.enqueueJob(new AsyncDerwentWebServiceGetAirlines()); 
   }  
   
}