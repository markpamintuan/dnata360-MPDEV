/**************************************************************************************************
* Name               : AccountAuraExtensionControllerCC
* Description        : This is a controller used for lightning components
* Created Date       : 01-Oct-2019
* Created By         : Jed Canlas
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR           DATE           COMMENTS1

* v1.0        Jed             01-Oct-2019     Initial version
**************************************************************************************************/
public class AccountAuraExtensionControllerCC {
    
    static Date TIMENOW = Date.Today();
    
    @AuraEnabled
    public static List<Case> getOpenCases(String accId){
        List<Case> openCases = new List<Case>();
        system.debug(' Account Id From Lightnig component******');
        system.debug(accId);
        system.debug(' Account Id From Lightnig component******');
        for(Case oCase : [Select Id, Subject, Status, Org_Case_Status__c,Org_Type__c, CaseNumber, OwnerId, Owner.Name, CreatedDate, Createdby.Name, Priority,
                          Origin,Org_Source__c,Opened_Date__c,Display_Text__c //Added as part of v1.2
                          From Case Where AccountId = :accId AND Org_Case_Status__c != 'Closed' ORDER By CreatedDate DESC LIMIT 5]) { //as part of v1.2 //LIMIT 10]){ //T-00222
                              openCases.add(oCase);
                          }
        return openCases;
    }
    
    @AuraEnabled
    public static List<Order> getActiveBookings(String recId,String recno){     //changed as part of v1.2 //(String accId){
        String accountid='';
        if(recId!=null) {
            if(recId.startsWith('001')) //if the record is of Account
                accountid =recId;
            else if(recId.startsWith('500')) {    //if the record is of Case
                Case caserec= [select id, accountid from Case where id =:recId and accountid !=null];
                if(caserec!=null)
                    accountid =caserec.accountid;
            }
        }
        integer count = 50000;
        if(recno!='All')
            count=integer.valueof(recno);
        List<Order> actBookings = new List<Order>();
        if(accountid!='') {
            DateTime dtNow = system.today();
            string q = constructQueryString('Order', 'AccountId =: accountid and Service_End_Date__c > :dtNow'); 
            system.debug(q);
            for(Order book :  database.query(q)) {
                actBookings.add(book);
            }
        }
        system.debug(' getActiveBookings actBookings******: ' + actBookings);
        return actBookings;
    }
    
    
    @AuraEnabled
    public static List<Order> getHistoricalBookings(String accId){  
        List<Order> actBookings = new List<Order>();
        if(accId != '') {
            DateTime dtNow = system.today();
            string q = constructQueryString('Order', 'AccountId =: accId and Service_End_Date__c < :dtNow'); 
            for(Order book :  database.query(q)) {
                actBookings.add(book);
            }
        }
        system.debug('-----------------------' + actBookings);
        return actBookings;
    }
    
    
    
    public static String constructQueryString(string objName,string whereClause)
    {
        SObjectType obj = Schema.getGlobalDescribe().get(objName);
        Map<String,Schema.SObjectField> mfields = obj.getDescribe().fields.getMap();
        string queryStr ='Select ';
        for(String s: mfields.keySet())
        {
            queryStr += mfields.get(s)+',';
        }
        queryStr = queryStr.substring(0,queryStr.length()-1);
        queryStr += ' From '+objName;
        if(!string.isEmpty(whereClause) && whereClause != null && whereClause != '')
        {
            queryStr +=  ' Where '+whereClause;
        }
        return queryStr;
    }
}