global class AsynWebService_Airport_Scheduler implements Schedulable, Database.AllowsCallouts {   
    
    global void execute(SchedulableContext ctx){       
      System.enqueueJob(new AsyncDerwentWebServiceGetAirports()); 
   }  
   
}