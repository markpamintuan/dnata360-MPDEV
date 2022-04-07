/*******
 * Name         :   ReconciliationTriggerHelper
 * Description  :   This is the helper class for ReconciliationTrigger
 ******/
public class ReconciliationTriggerHelper {
    public static void scheduleBatch(List<Reconciliation__c> reconciliationlist){
        Reconciliation__c recons = reconciliationlist.get(0);
        if(recons.Status__c == 'Completed' && recons.Finish_Date__c == null){
                Integer bookingcount = Integer.valueOf(recons.Count_of_Records__c);
                String currentPageId = recons.Page_Number__c;
                String nextPageId = recons.Next_Page_Id__c;    
                Integer reconHour = Datetime.now().hour();
                Integer reconMinute = Datetime.now().minute();
                Integer reconSecond = Datetime.now().second();
                //Check if minute goes beyond 59 to not error cron
                if((reconMinute + (bookingcount*Integer.valueOf(Label.Reconcilation_Minute_Limit))) > 59){
                    Integer additionalHours = Integer.valueOf((reconMinute+(bookingcount*Integer.valueOf(Label.Reconcilation_Minute_Limit)))/60);
                    reconMinute = Math.mod(reconMinute + (bookingcount*Integer.valueOf(Label.Reconcilation_Minute_Limit)),60);
                    reconHour = reconHour + additionalHours;
                }else{
                    reconMinute = reconMinute + (bookingcount*Integer.valueOf(Label.Reconcilation_Minute_Limit));
                }
            
                if(reconHour > 23){
                    reconHour = Math.mod(reconHour,24);
                }
                
                
                if(currentPageId != nextPageId){
                    string jobName = 'Reconciliation Callouts';
                    jobName = jobName += ' - ' + datetime.now().format() + ' ' + recons.Name;                         
                    String hour = String.valueOf(reconHour);
                    String min = String.valueOf(reconMinute); 
                    String ss = String.valueOf(reconSecond);
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    system.schedule(jobName, nextFireTime, new Booking_Reconciliation_Batch());
                }else{
                    if((reconHour + Integer.valueOf(Label.Reconcilation_Hourly_Limit)) > 23){
                        reconHour = Math.mod((reconHour + Integer.valueOf(Label.Reconcilation_Hourly_Limit)),24);
                    }
                    string jobName = 'Reconciliation Callouts';
                    jobName = jobName += ' - ' + datetime.now().format()  + ' ' + recons.Name;    
                    String hour = String.valueOf(reconHour + Integer.valueOf(Label.Reconcilation_Hourly_Limit));
                    String min = String.valueOf(reconMinute); 
                    String ss = String.valueOf(reconSecond);
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    system.schedule(jobName, nextFireTime, new Booking_Reconciliation_Batch());				                
                }
            }
        
    }
}