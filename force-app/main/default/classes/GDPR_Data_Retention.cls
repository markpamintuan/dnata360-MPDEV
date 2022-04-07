/**************************************************************************************************
* Name               : GDPR_Data_Retention 
* Description        : This is the batch class for data archiving        
* Created Date       : 18-Oct-2019                                                                 
* Created By         : PwC                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS    
*****************************************************************************************************/
global class GDPR_Data_Retention implements Database.Batchable<sobject>{
 public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        return database.getQueryLocator('Select Id,Record_Id__c,Brand__c,CreatedDate from GDPR_Archive_Records__c');
        
    }
    
    public void execute(Database.BatchableContext BC,List<GDPR_Archive_Records__c> acclist)
    {  
        
        system.debug('acclist returned >>>>>>>>>'+acclist);
        Map<String,Decimal> yearMap = new Map<String,Decimal>();
        List<sObject> sobjectMap = new List<sobject>();
        List<GDPR_Archive_Records__c> recordsToBeDeletedList = 	new List<GDPR_Archive_Records__c>();
        List<Sobject> sobjList = new List<Sobject>();
        Datetime startTime = system.now();
        Decimal years = 0.0;
        Integer months = 0;
        
        for(Data_Retention_Year__mdt dataRetyear : [Select Label,Year__c from Data_Retention_Year__mdt]){
            yearMap.put(dataRetyear.Label,dataRetyear.Year__c);
        }
       
        for(GDPR_Archive_Records__c archRec :acclist){
            Id archiveObjID = archRec.Record_Id__c;
            sobject sObj = archiveObjID.getSobjectType().newSobject(archiveObjID);
            sobjectMap.add(sObj);
            if(archRec.CreatedDate != null)
            	 months = archRec.CreatedDate.Date().monthsBetween(startTime.Date());
            if(archRec.Brand__c != null)
            	 years = yearMap.get(archRec.Brand__c);
            if(months != 0){
                if(Math.floor(months/12.0) == years - 1){
                    recordsToBeDeletedList.add(archRec);
                }
            }
           
        }
        deleteRecordsAfterSnapshotInsert(sobjectMap);
        
        system.debug('accountsToBeDeletedList >>>>>> '+recordsToBeDeletedList);
        try{
            if(recordsToBeDeletedList.size() > 0){
                system.debug('Before Delete >>>>>>>>>'+recordsToBeDeletedList);
                delete recordsToBeDeletedList;
            }
        }
         catch(Exception ex)
        {
            System.debug('Exception ex >>>>> '+ex+' @ Line Number >>>>. '+ex.getLineNumber());
        }
        
    }    
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    
    public static void deleteRecordsAfterSnapshotInsert(List<Sobject> recordIdMap){
        try{
            if(recordIdMap.size() > 0)
            	delete recordIdMap;
        }
        catch(Exception ex)
        {
            System.debug('Exception ex >>>>> '+ex+' @ Line Number >>>>. '+ex.getLineNumber());
        }
        
    }
    
    
}