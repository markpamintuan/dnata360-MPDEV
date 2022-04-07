public class MailRuleRecordUpsertController {

     /**
      * Name : getMailBox_picklist_Values
      * Description : this method will be used to Get Mail Box object  Email field vaues
      **/

    @AuraEnabled
    public static List<ValueWrapper> getMailBox_picklist_Values() { 
        system.debug('getMailBox_picklist_Values method call');
        List<ValueWrapper> picklistOptions = new List<ValueWrapper>();
        
        ValueWrapper vw = new ValueWrapper();
            vw.label = '--None--';
            vw.value = '';
            picklistOptions.add(vw);    
        
        
        for(Email_Mailbox__c res : [SELECT Id, Email__c FROM Email_Mailbox__c]) {
            ValueWrapper vw2 = new ValueWrapper();
            vw2.label = res.Email__c;
            vw2.value = res.Id;
            picklistOptions.add(vw2);
        }
        system.debug('picklistOptions:- '+picklistOptions);
        return picklistOptions;
    }
    
    /***
     * Wrapper class Name : ValueWrapper
     * Description : This class will be used to store Label and value of picklist value which is Mail box object record in value variable 
     * stroe the record id and in lable store the email value
     **/
    public class ValueWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    /*Name : getEmailRule
     * Description : This method will be used  to get Email rule object record by their id
     * */
    @AuraEnabled
    public static Wrapper getEmailRule(String recId){ 
        Wrapper wrap = new Wrapper();
        if(!String.isBlank(recId)){
            List<Email_Rule__c> rdrList = [SELECT Id,
                                                   Filters_Json__c,
                                                   Hard_Coded_Rules__c,
                                                   Object_Name__c,
                                                   Rule_Logic__c,Email_MailBox__c,
                                                   Active__c,Name
                                                   FROM Email_Rule__c 
                                                   WHERE Id =:recId LIMIT 1];
            
            if(!rdrList.isEmpty() && !String.isBlank(rdrList[0].Filters_Json__c)){
                wrap = getEmailRuleWrapper(rdrList[0].Filters_Json__c, recId,rdrList[0].Email_MailBox__c,rdrList[0].Name,rdrList[0].Active__c);
            }else{
                wrap.recID = rdrList[0].Id;
                wrap.mailBox = rdrList[0].Email_MailBox__c;
                wrap.Name = rdrList[0].Name;
                wrap.isActive = rdrList[0].Active__c;
            }
        }
        return wrap;
    }

    /*****
     * Name : getEmailRuleWrapper
     * Description : This method will be used to creating the Wrapper from Email Rule Record
     */     
    public static Wrapper getEmailRuleWrapper(String rulesJSON, String recId,String emailRuleId,string name, boolean isActive){
        System.debug('emailRuleId :: '+emailRuleId);
        System.debug('recId :: '+recId);
        Wrapper wrap = new Wrapper();
        
        wrap.recID = recId;
        wrap.mailBox = emailRuleId;
        wrap.Name = name;
        wrap.isActive = isActive;
        List<RulesUtility.ReportFilterWrap>  rulesWrapList = RulesUtility.parse(rulesJSON);
        
        if(rulesWrapList != null && !rulesWrapList.isEmpty()){
            for(RulesUtility.ReportFilterWrap rule : rulesWrapList){
                if(rule.Column == 'ToAddress'){
                   // wrap.mailBox = rule.value;
                    wrap.toAddress = true;
                }
                if(rule.Column == 'BccAddress'){
                   // wrap.mailBox = rule.value;
                    wrap.bccAddress = true;
                }
                if(rule.Column == 'CcAddress'){
                   // wrap.mailBox = rule.value;
                    wrap.ccAddress = true;
                }
                
                if(rule.Column == 'Subject'){
                    if(wrap.subject == null)
                    wrap.subject = rule.value;
                    else
                        wrap.subject += ',' + rule.value;
                }
                
                if(rule.Column == 'fromAddress'){
                    wrap.fromAddress = rule.value;
                }
                
            }
        }
        System.debug('getEmailRuleWrapper called :: ');
        
        System.debug('wrap :: '+wrap);
        return wrap;
    }
    
    /***
     * Name : upsertEmailRule
     * Description : This method will be used to Create / update the Email Rule Record 
     */ 
    @AuraEnabled
    public static String upsertEmailRule(Wrapper wrap){
        
        System.debug('wrap :: '+wrap);
        
        List<RulesUtility.ReportFilterWrap>  rulesWrapList = new List<RulesUtility.ReportFilterWrap>();
        String logic = '';
        Integer i=0;
        string Mail;
        List<Email_Mailbox__c> EmailList =[SELECT Id,Email__c FROM Email_Mailbox__c WHERE Id =: wrap.mailBox ];
        if(!EmailList.isEmpty()){
            Mail = EmailList[0].Email__c;
        }
        if(!String.isBlank(wrap.mailBox)){
            if(wrap.toAddress){
                RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
                fw.Column = 'ToAddress';
                fw.Operator = 'contains';
                fw.value = Mail;
                rulesWrapList.add(fw);
            }
            /*
            if(wrap.bccAddress){
                RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
                fw.Column = 'BCC_Email__c';
                fw.Operator = 'contains';
                fw.value = Mail;
                rulesWrapList.add(fw);
            }
            */
            if(wrap.ccAddress){
                RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
                fw.Column = 'CcAddress';
                fw.Operator = 'contains';
                fw.value = Mail;
                rulesWrapList.add(fw);
            }
            
            if(rulesWrapList.size() == 1){
                i++;
                logic += i; 
            }else if(rulesWrapList.size() > 1){
                logic += '(';
                i++;
                for(;i<=rulesWrapList.size();i++){
                    logic += String.valueOf(i);
                    if(rulesWrapList.size() != i)
                        logic += ' OR ';
                }
                logic += ')';
                i--;
            }
        }
        
        System.debug('i 68 line === > '+i);
        
        if(!String.isBlank(wrap.subject)){
            List<String> spltList = wrap.subject.split(',');
            if(!spltList.isEmpty()){
             List<String> spltListTemp = new list<string>();
                for(string strr  :spltList ){
                    if(!string.isBlank(strr)){
                        spltListTemp.add(strr.trim());
                    }
                }
                spltList = spltListTemp;
            }
            System.debug('spltList :: '+spltList);
            if(!spltList.isEmpty() && i > 0){
                logic += ' AND ';
            }
            if(spltList.size() == 1){
                i++;
                logic += i;
                
                RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
                fw.Column = 'Subject';
                fw.Operator = 'contains';
                fw.value = spltList[0];
                rulesWrapList.add(fw);
            }
            if(spltList.size() > 1){
                logic += '(';
                
                for(Integer z=1;z<=spltList.size();z++){
                    RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
                    fw.Column = 'Subject';
                    fw.Operator = 'contains';
                    fw.value = spltList[z-1];
                    rulesWrapList.add(fw);
                    //System.debug('i 87 line === > '+i);
                    i++;
                    logic += String.valueOf(i);
                    if(spltList.size() != z)
                        logic += ' OR ';
                }
                logic += ')';
            }
        }
        
        //System.debug('i 96 line === > '+i);
        
        if(!String.isBlank(wrap.fromAddress)){
            RulesUtility.ReportFilterWrap fw = new RulesUtility.ReportFilterWrap();
            fw.Column = 'FromAddress';
            fw.Operator = 'equals';
            fw.value = wrap.fromAddress;
            rulesWrapList.add(fw);
            
            if(!String.isBlank(logic)){
                logic += ' AND ';
            }
             i++;
            logic += String.valueOf(i);
        }
        
        
        /*System.debug('i -->> '+i);
        System.debug('logic -->> '+logic);
        System.debug('rulesWrapList.size -->> '+rulesWrapList.size());
        System.debug('rulesWrapList -->> '+rulesWrapList);*/
        
        /****** upsert Delete Rule Record *****/
        Email_Rule__c rdr = new Email_Rule__c();
        if(!String.isBlank(wrap.recID))
        rdr.Id = wrap.recID;
        
        if(!String.isBlank(wrap.Name)){
            rdr.Name = wrap.Name;
        }else{
            throw new AuraHandledException('Please Enter Name Value');
        }
        
        
        
        
        
        rdr.Active__c = wrap.isActive;
        
        if(!rulesWrapList.isEmpty())
        rdr.Filters_Json__c = Json.serialize(rulesWrapList);
        
        rdr.Object_Name__c = 'EmailMessage';
        System.debug('EmailId:-- '+ wrap.mailBox);
        if(wrap.recID == null ){
            rdr.Email_MailBox__c = wrap.mailBox;
        }
        
        if(!String.isBlank(logic))
        rdr.Rule_Logic__c =  logic;
        
        try{
            //UPSERT
            upsert rdr;
            return rdr.Id;
        }catch(Exception e){
            System.debug('Error Message :: '+e.getMessage());
            System.debug('Error Line Number :: '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    
    public class Wrapper {
        @AuraEnabled
        public String recID {set;get;}
        @AuraEnabled
        public String mailBox {set;get;}
        @AuraEnabled
        public String subject {set;get;}
        @AuraEnabled
        public String fromAddress {set;get;}
        @AuraEnabled
        public Boolean toAddress {set;get;}
        @AuraEnabled
        public Boolean bccAddress {set;get;}
        @AuraEnabled
        public Boolean ccAddress {set;get;}
        @AuraEnabled
        public Boolean isActive {set;get;}
        @AuraEnabled
        public String Name {set;get;}
        
        public Wrapper(){
            toAddress = false;
            bccAddress = false;
            ccAddress = false;
            isActive = false;
        }
    }
}