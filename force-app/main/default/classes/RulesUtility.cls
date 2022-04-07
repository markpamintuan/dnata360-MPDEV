/**************************************************************************************************
* Name               : RulesUtility 
* Description        : This method deletes the email messages records after query with custom filters           
* Created Date       : 7-Dec-2019                                                                 
* Created By         : Keith Rogers                                                    
* ----------------------------------------------------------------------------------------------- 
**************************************************************************************************/
public class RulesUtility {
    
    /****
    * This method deletes the email messages records after query with custom filters
        */ 
    public static void deleteFiltersQuery(String Object_Name, Set<Id> setRecsIDs, List<EmailMessage> lEmails){
        system.debug('##555 lEmails : ' + lEmails );
        system.debug('###555 lEmails : ' + lEmails );
        
        //get list of Emails
        
        Set<String> sEmailsAddressOnToCCBCC = new Set<String>();
        List<String> lEmailboxesToQuery= new List<String>();

        for(EmailMessage msg: lEmails){
            if(msg.EmailToCaseMailbox__c != null)
                sEmailsAddressOnToCCBCC.add(msg.EmailToCaseMailbox__c);
            if(sEmailsAddressOnToCCBCC.size()>0) lEmailboxesToQuery.addAll(sEmailsAddressOnToCCBCC);
            
        }
        
        //List of delete rules where object name matches
        List<Email_Rule__c> rulesList = RulesUtility.DeleteEmailRuleList(Object_Name, lEmailboxesToQuery);
        system.debug('###22 rulesList : ' + rulesList );
        system.debug('###22 objectName : ' + Object_Name );
        
        if(!rulesList.isEmpty()){
            String whereCaluses = '';
            for(Email_Rule__c rdr : rulesList){
                if(!String.isBlank(rdr.SOQL__c)){
                    List<String> tempList = rdr.SOQL__c.split('WHERE');
                    if(tempList.size() > 1){
                        if(whereCaluses == ''){
                            whereCaluses += tempList[1];
                        }else{
                            whereCaluses += (' OR ' + tempList[1]);
                        }
                    } 
                }
            }
            
            if(whereCaluses != ''){
                // making query
                string query = 'SELECT Id,parentId FROM '+ Object_Name +' WHERE ('+ whereCaluses + ') AND ID IN:setRecsIDs';
                system.debug('\n--Final query--'+query);
                
                //query.replace('LIMIT 1',' AND ID IN:setRecsIDs'); 
                
                List<sObject> objList = Database.query(query);
                System.debug('objList :: '+objList);
                if(!objList.isEmpty()){
                    
                    // this will save the records to be deleted
                    //List<sobject> lstObj = new List<sobject>();
                    Set<Id> setCaseIds = new Set<Id>();
                    
                    for(sObject sobj : objList){
                        //lstObj.add(new case(id = (string)sobj.get('parentId')));
                        Id objID = (Id)sobj.get('parentId');
                        if(objID != null)
                            setCaseIds.add(objID);
                        
                    }
                    //system.debug('\n--lstObj--'+lstObj);
                    system.debug('\n--setCaseIds--'+setCaseIds);
                    
                    // if we ahve record to be deleted
                    /*if(!lstObj.isEmpty()){
                        delete lstObj;
                        System.debug('email message records deleted.');
                    } */
                    if(!setCaseIds.isEmpty()){
                        //Calling Future Method to delete Cases
                        RulesUtility.deleteCases(setCaseIds);
                    }
                }
            }
        }
    }   
    
    /***
     * Future Method to Delete Cases parent of Email Messages
     */ 
    @Future
    public static void deleteCases(Set<Id> setRecsIDs){
        System.debug('deleteCases Future Method called...');
        List<Case> lstCases = [SELECT Id FROM Case WHERE Id IN :setRecsIDs];
        if(!lstCases.isEmpty()){
            Database.delete(lstCases, false);
        }
    }
    
    
    /*****
     * Get List of Delete Rule Object Records where object name matches
      
    public static List<Record_Delete_Rule__c> DeleteRuleList(String Object_Name){
        List<Record_Delete_Rule__c> rulesList = new List<Record_Delete_Rule__c>();
        if(Object_Name != null){
            rulesList = [SELECT Id, Name,Filters_Json__c,
                         Object_Name__c,Rule_Logic__c,SOQL__c 
                         FROM Record_Delete_Rule__c 
                         WHERE Object_Name__c =:Object_Name];
        }
        
        return rulesList;
    }
    */
    
     /*****
     * Get List of Email Rule Object Records where object name matches
     * */
     public static List<Email_Rule__c> DeleteEmailRuleList(String Object_Name, List<String> lEmailboxesToQuery){
     system.debug('###3 lEmailboxesToQuery: ' +  lEmailboxesToQuery);
     
        List<Email_Rule__c> rulesList = new List<Email_Rule__c>();
        if(Object_Name != null){
            
            rulesList = [SELECT Id, Name,Filters_Json__c,
                                Object_Name__c,Rule_Logic__c,
                                SOQL__c,Email_MailBox__c, Email_Mailbox__r.Email__c
                             FROM Email_Rule__c 
                             WHERE Email_Mailbox__r.Email__c IN: lEmailboxesToQuery
                             AND Active__c=true];
            system.debug('###3 rulesList : ' + rulesList);
        }
        return rulesList;
    }
    
    /****
        * Validating the Order of Open & closed Brackets in rule logic String
        */ 
    public static Boolean validateBracketsInLogic(List<String> lstChars){
        List<String> lstBrackets = new List<String>();
        
        for(String temp : lstChars){
            if(temp == '(' || temp == ')')
                lstBrackets.add(temp);
        }
        
        System.debug('lstBrackets :: '+lstBrackets);
        if (BalancedParan.areParenthesisBalanced(lstBrackets)) 
            return true;
        else
            return false;
    }
    
    /***
     * Matching the no. of rules in number in logic string
     */ 
    public static Boolean validateNumbersInLogic(String formula, List<ReportFilterWrap> rfWrapList){
        //Made all character in lower case
        formula = formula.toLowerCase();
        System.debug('formula ::: '+formula);
        
        //removing all brackets from the formula logic
        formula = String.join(formula.split('\\('), ''); 
        System.debug('formula ::: '+formula);
        formula = String.join(formula.split('\\)'), ''); 
        
        // removing all AND and OR
        formula = String.join(formula.split('and'), '');
        formula = String.join(formula.split('or'), '');
        
        // this will save which sequence number is not found
        List<String> seqNotFound = new List<String>();
        
        // checking each sequence number is present
        for(Integer i=0;i<rfWrapList.size();i++){
            Integer seqNum = i + 1;
            if(formula.indexOf(String.valueOf(seqNum)) == -1){
                seqNotFound.add(String.valueOf(seqNum));
            }
            else{
                formula = formula.replace(String.valueOf(seqNum),'');
            }
        }
        
        // checking if any of the sequence is not found
        if(seqNotFound.size() > 0){
            return false;
        }
        
        // checking if any sequence number is extra
        if(formula.trim().length() > 0){
            return false;
        }
        
        return true;
    }
    
    
    /****
* This method updates Soql Details in Delete Rule Record
*/ 
    public static void updateSoqlDetails(List<Email_Rule__c> rulesList){
        System.debug('rulesList :- '+ rulesList);
        for(Email_Rule__c rdr : rulesList){
            string query;
            
            if(!String.isBlank(rdr.Filters_Json__c) && !String.isBlank(rdr.Rule_Logic__c)){
                List<ReportFilterWrap> rfWrapList = RulesUtility.parse(rdr.Filters_Json__c);
                
                List<String> lstChars = rdr.Rule_Logic__c.split('');
                System.debug('lstChars :: '+lstChars);
                
                //Validate Brackets in logic String and number of orders
                if(!rfWrapList.isEmpty() && validateBracketsInLogic(lstChars) && validateNumbersInLogic(rdr.Rule_Logic__c, rfWrapList)){ 
                    // this will save the where clauses
                    List<string> lstWhere =  new List<string>();
                    
                    // this will be used to set the field API Name
                    set<string> setFieldName = new set<string>();
                    
                  //  string whereCaluse = rdr.Rule_Logic__c;
                   string whereCaluse;
                    
                   // System.debug('whereCaluse :- '+ whereCaluse);
                    // making where clause
                    for(ReportFilterWrap rule : rfWrapList){
                        string strWhere = '';
                        if(rule.Operator == 'equals')
                            strWhere = rule.Column + ' = \'' + rule.value + '\'';
                        
                        else if(rule.Operator == 'notEqual')
                            strWhere = rule.Column + ' != \'' + rule.value + '\'';
                        
                        else if(rule.Operator == 'contains')
                            strWhere = rule.Column + ' Like \'%' + rule.value + '%\'';
                        
                        else if(rule.Operator == 'startsWith')
                            strWhere = rule.Column + ' Like \'' + rule.value + '%\'';
                        
                        
                        // saving the field API Name for query
                        setFieldName.add(rule.Column.toLowerCase());           
                        
                        // adding condition to list
                        lstWhere.add(strWhere);
                    }
                    system.debug('\n--lstWhere--'+lstWhere+'\n--setFieldName--'+setFieldName);
                    
                    List <string> whereclauselist = new list<string>();
                    // for each element of the where clause
                    for(integer i = 0 ; i<lstWhere.size() ; i ++){
                        Integer ruleNum = i+1;
                        string wc;
                        for(integer j = 0; j<lstChars.size();j++){
                             
                            system.debug('\n-ruleNum--'+ruleNum);
                            if(lstChars[j] == string.valueof(ruleNum)){
                                lstChars[j] = ' '+lstWhere[i]+' ';
                                system.debug('\n--lstChars--'+lstChars);
                                break;
                            }
                        }
                    }
                    System.debug('lstChars:- '+lstChars);
                    for(string s : lstChars){
                        if(whereCaluse == null){
                            whereCaluse = s;
                        }else{
                            whereCaluse += s; 
                        }
                    }
                    system.debug('\n--whereCaluse--'+whereCaluse);
                    
                    // making query
                    if(!String.isBlank(rdr.Hard_Coded_Rules__c))
                        query = 'SELECT Id,parentId FROM EmailMessage WHERE ( (' +whereCaluse + ' AND CreatedDate >= YESTERDAY' +')' + ' AND ' + rdr.Hard_Coded_Rules__c + ')';
                    else
                        query = 'SELECT Id,parentId FROM EmailMessage WHERE (' +whereCaluse + ' AND CreatedDate >= YESTERDAY ' + ')' ;
                    
                    /**** Check query is working or not ****/
                    try{
                       // String queryToTest = 'SELECT Id,parentId FROM EmailMessage WHERE (' +whereCaluse + ') LIMIT 1'; //Need to add a limit as the query breaks on production
                        Database.query( query);
                    }
                    catch(Exception e){
                        ///Return error
                        rdr.addError('Error : '+e.getMessage() + '. Please Check your Logic.');
                    }
                    
                    
               }else{
                    ///Return error
                    rdr.addError('Please check your Logic.');
                }
            }
            
            system.debug('\n--query--'+query);
            //Update the SOQL Field
            rdr.SOQL__c = query;
        }
        
    }
    
    public class ReportFilterWrap {
        public String Column {get;set;}
        public String Operator {get;set;}
        public String value {get;set;} 
    }
    
    public static List<ReportFilterWrap> parse(String json) {
        return (List<ReportFilterWrap>) System.JSON.deserialize(json, List<ReportFilterWrap>.class);
    }
    
}