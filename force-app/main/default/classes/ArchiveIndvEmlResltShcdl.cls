global class ArchiveIndvEmlResltShcdl implements Schedulable 
{
  //Every 15 mins
  //public static final String CRON_EXPR = '0 15 * * * ?';
  public static final String CRON_EXPR =  System.Label.ArchiveIndvEmlResltCronString;

  /*
    Call this from Anonymous Apex to schedule at the default regularity
  */
  global static String scheduleIt() 
  {
    ArchiveIndvEmlResltShcdl job = new ArchiveIndvEmlResltShcdl();
    String sName = 'Individual Email Result Schedule - '+system.now();
    return System.schedule(sName, CRON_EXPR, job);
  }
  
  global void execute(SchedulableContext sc) 
  {
    // This is good practice if you are likely to be processing a
    // lot of records at a time'
    ArchiveIndvEmlResltBatch b = new ArchiveIndvEmlResltBatch();
    Database.executeBatch(b);
  }
  
}