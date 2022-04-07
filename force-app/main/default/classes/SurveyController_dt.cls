global class SurveyController_dt { 
    
    public Survey__c Survey {get;set;}
    public Survey_Response__c SR {get;set;} 
    public sObject obj {get;set;}   
    public String sObjectType {get;set;}
    public string PolicyURL {get;set;}  
    public integer rating {get;set;}    
    public boolean isDuplicateResponse {get;set;} 
    public string DisplayText {get;set;}  
    public boolean IsValidPage {get;set;}
    public boolean IsSubmitted {get;set;}
    public boolean IsError {get;set;}
    public List<sObject> responseCount {get;set;}
    public Account acc {get;set;}
    
    
    public SurveyController_dt() {
        
        Survey = new Survey__c();
        SR = new Survey_Response__c();
        rating = 0;
        PolicyURL = '';
        DisplayText = '';
        sObjectType = '';
        acc = new Account();
        IsValidPage = false;
        IsSubmitted = false;
        IsError = false;
        
        if (!string.isblank(ApexPages.currentPage().getParameters().get('sId'))){
            String sId = ApexPages.currentPage().getParameters().get('sId');
            try{
                Survey = database.query(constructQueryString('Survey__c','id=: sId')); 
            }catch (exception e){
                system.debug(e.getMessage());
            }
            
        } 
        
        if (!string.isblank(ApexPages.currentPage().getParameters().get('parentId'))){
            String pId = ApexPages.currentPage().getParameters().get('parentId');
            sObjectType = ((Id)pId).getSobjectType().getDescribe().getName();
            try{
                obj = database.query(constructQueryString(sObjectType,'id=: pId limit 1')); 
                string accId = string.valueOf(obj.get('Org_Person_Account_Contact_Id__c'));
                acc = [select id FROM account where PersonContactId =: accId limit 1]; 
            }catch (exception e){
                system.debug(e.getMessage());
            }
            
        } 
        
        if (!string.isblank(ApexPages.currentPage().getParameters().get('rate'))){
            rating = integer.valueOf(ApexPages.currentPage().getParameters().get('rate'));
            
        } 
        
        
        if(rating < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter a rating value before you add a comment'));
        }else{
            
            
            
            
            if(rating >= 0 && rating <= 10){
                SR.Org_Rating__c = rating;
                IsValidPage = true;
                
                if(Survey.Survey_Model__c == 'CES'){
                    DisplayText = 'Is there anything else you would like to tell us about your experience with dnata Travel so far?';
                }
                
                if(Survey.Survey_Model__c == 'CNPS'){
                    if(rating >= 0 && rating <=6){
                        DisplayText = 'Thank you for this rating, which indicates we are not meeting your expectations. Please could you provide us with some examples of where we are not performing as well as you would expect?';      
                    }
                    if(rating >= 7 && rating <=8){
                        DisplayText = 'Thank you for this rating, which indicates we can do better and we want to ensure we do in the future. Please could you provide us with some examples where we could improve our service?';      
                    }
                    if(rating >= 9 && rating <=10){
                        DisplayText = 'Thank you for this rating. We are keen to continue providing you with a high level of service. Please could you provide us with some examples of what we are doing particularly well?';      
                    }                    
                }
                
                
                
            }
        } 
        try{
            responseCount = [select id from Survey_Response__c where survey__c =: survey.Id and Org_Booking__c =: obj.Id];
        }catch (exception e){
            system.debug(e.getMessage());
        }
        
        if (responseCount.size() > 0){  
            IsValidPage = false;
            IsSubmitted = false;
            IsError = true;
        }
        
        
    }
    
    public Pagereference save() {
        
        
        try{         
            IsValidPage = false;            
            responseCount = [select id from Survey_Response__c where survey__c =: survey.Id and Org_Booking__c =: obj.Id]; 
            if (responseCount.size() > 0){                 
                IsSubmitted = false;
                IsError = true;
            }else{
                sr.Org_Survey_Model__c = survey.Survey_Model__c;
                sr.Brand__c = survey.Brand__c;
                sr.Org_Customer_Journey__c = survey.Customer_Journey__c;
                sr.survey__c = survey.Id;
                sr.Org_Booking__c = obj.Id;                    
                sr.Org_Account__c = acc.Id;
                insert SR;
                IsSubmitted = true;
            } 
            return null; 
        }
        catch(exception e){
            
            throw e;
        }
        
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