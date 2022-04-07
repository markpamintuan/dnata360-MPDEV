global class SurveysPageController { 
    
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
    public Survey_Question_Mapping__mdt SQM {get;set;}
    public String thankYouText {get;set;}
    public String duplicateResponseText {get;set;}
    
    public String logoURL {get; set;}
    public String footerText {get;set;}
    public String policyLink {get;set;}
    public String websiteLink {get;set;}
    public String srQueyString {get;set;}
    public String dynamicStyleSheet {get;set;}
    public String customerID {get; set;}
    public String submitButtonText {get; set;}
    public String visitWebsiteButtonText {get; set;}
    public String policyText {get; set;}
    
    public SurveysPageController() {
        
        Survey = new Survey__c();
        SR = new Survey_Response__c();
        rating = 0;
        PolicyURL = '';
        DisplayText = '';
        sObjectType = '';
        thankYouText = '';
        duplicateResponseText = '';
        acc = new Account();
        IsValidPage = false;
        IsSubmitted = false;
        IsError = false;

        srQueyString = 'SELECT Id FROM Survey_Response__c ';
        String sQueryString;

        if (!string.isblank(ApexPages.currentPage().getParameters().get('sId'))){
            String sId = ApexPages.currentPage().getParameters().get('sId');
            try{
                Survey = database.query(constructQueryString('Survey__c','id=: sId'));
                string brand = Survey.Brand__c;
                string cJourney = Survey.Customer_Journey__c;
                string surveyModel = Survey.Survey_Model__c;

                if(brand == 'ekh'){
                    sQueryString = constructQueryString('Survey_Question_Mapping__mdt','Brand__c = \'' + brand + '\' AND Customer_Journey__c = \'' + cJourney + '\' AND Survey_Model__c = \'' + surveyModel + '\' AND Domain_Id__c = \'' + Survey.Domain_Id__c + '\'');
                } else {
                    sQueryString = constructQueryString('Survey_Question_Mapping__mdt','Brand__c = \'' + brand + '\' AND Customer_Journey__c = \'' + cJourney + '\' AND Survey_Model__c = \'' + surveyModel + '\'');
                }
                system.debug('*!*!*!*!*!*sQueryString: ' + sQueryString);
                SQM = database.query(sQueryString);

                duplicateResponseText = SQM.Duplicate_Response_Text__c;
                thankYouText = SQM.Thank_You_Text__c;

                logoURL = getResourceURL(SQM.Resource_Name__c);
                footerText = SQM.Footer_Text__c;
                policyLink = SQM.Policy_Link__c;
                websiteLink = SQM.Website_Link__c;
                dynamicStyleSheet = getResourceURL(SQM.Stylesheet_Name__c);
                if(string.IsNotEmpty(SQM.Submit_Button_Text__c)){
                    submitButtonText = SQM.Submit_Button_Text__c;
                } else {
                    submitButtonText = 'Submit';
                }
                
                if(string.IsNotEmpty(SQM.Visit_Website_Button_Text__c)){
                    visitWebsiteButtonText = SQM.Visit_Website_Button_Text__c;
                } else {
                    visitWebsiteButtonText = 'Visit our Website';
                }

                if(string.IsNotEmpty(SQM.Policy_Link_Text__c)){
                    policyText = SQM.Policy_Link_Text__c;
                } else {
                    policyText = 'Privacy Policy';
                }               
            }catch (exception e){
                system.debug(e.getMessage());
            }         
        } 
        
        if (!string.isblank(ApexPages.currentPage().getParameters().get('parentId'))){
            String pId = ApexPages.currentPage().getParameters().get('parentId');
            sObjectType = ((Id)pId).getSobjectType().getDescribe().getName();
            if(sObjectType != 'Account'){ 
                try{
                    obj = database.query(constructQueryString(sObjectType,'id=: pId limit 1'));
                    
                    if(sObjectType == 'Booking__c'){
                        customerID = string.valueOf(obj.get('Org_Account_Name__c'));
                    } else if(sObjectType == 'Case'){
                        customerID = string.valueOf(obj.get('AccountId'));
                    }
                    
                }catch (exception e){
                    system.debug(e.getMessage());
                }
            } else {
                acc = [SELECT Id, Survey_Date__pc, Survey_Count__pc, Survey_Group__pc FROM Account WHERE Id =: pId];
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
                DisplayText = (String)SQM.get('Rating_'+rating+'__c');
            }
        } 

        try{
            String whereClause = 'WHERE Survey__c = \'' + survey.Id + '\' AND ';
            if(sObjectType == 'Account'){
                whereClause += 'Org_Account__c = \'' + acc.Id + '\' AND (CALENDAR_YEAR(Survey_Date__c) = ' + acc.Survey_Date__pc.year() + ' AND CALENDAR_MONTH(Survey_Date__c) = ' + acc.Survey_Date__pc.month() + ' AND DAY_IN_MONTH(Survey_Date__c) = ' + acc.Survey_Date__pc.day() + ')';
            } else if(sObjectType == 'Booking__c'){
                whereClause += 'Org_Booking__c = \'' + obj.Id + '\'';
            } else if(sObjectType == 'Case'){
                whereClause += 'Org_Case__c = \'' + obj.Id + '\'';
            }

            srQueyString = srQueyString + whereClause;

            responseCount = database.query(srQueyString);
            //responseCount = [select id from Survey_Response__c where survey__c =: survey.Id and Org_Booking__c =: obj.Id];
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
            responseCount = database.query(srQueyString);            
            //responseCount = [select id from Survey_Response__c where survey__c =: survey.Id and Org_Booking__c =: obj.Id]; 
            if (responseCount.size() > 0){                 
                IsSubmitted = false;
                IsError = true;
            }else{
                sr.Org_Survey_Model__c = survey.Survey_Model__c;
                sr.Brand__c = survey.Brand__c;
                sr.Org_Customer_Journey__c = survey.Customer_Journey__c;
                sr.survey__c = survey.Id;
                if(sObjectType == 'Account'){
                    sr.Org_Account__c = acc.Id;
                    if(acc.Survey_Date__pc != null){
                        sr.Survey_Date__c = acc.Survey_Date__pc;
                    }
                    if(acc.Survey_Count__pc != null){
                        sr.Survey_Count__c = acc.Survey_Count__pc;
                    }
                    if(string.IsNotEmpty(acc.Survey_Group__pc)){
                        sr.Survey_Group__c = acc.Survey_Group__pc;
                    }
                } else if(sObjectType == 'Booking__c'){
                    sr.Org_Booking__c = obj.Id;
					sr.Org_Account__c = customerID;                   
                } else if(sObjectType == 'Case'){
                    sr.Org_Case__c = obj.Id;
                    sr.Org_Account__c = customerID;
                }

                insert SR;
                IsSubmitted = true;
            } 
            return null; 
        }
        catch(exception e){
            
            throw e;
        }
        
    }   
    
    public static String constructQueryString(string objName,string whereClause){
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

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 14 September 2020
     * @description: method that return URL of specific static resources
     * @history:                
     */ 
    public static String getResourceURL(String resourceName){

        list<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        if(resourceList.size() == 1){
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }

        else return '';
    }    

}