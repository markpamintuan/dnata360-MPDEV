public class ConsolidatedReportCtrl {
    @AuraEnabled
    public Static List<Report> getConsolidatedReport(String folderName){
        system.debug('folderName : '+folderName);
        
        List<Report> lstReports = new List<Report>();
        
        if(!String.isBlank(folderName))
        	lstReports = [Select Id, Name from Report where FolderName =: folderName];
        system.debug('lstReports : '+lstReports);
        return lstReports;
    }
}