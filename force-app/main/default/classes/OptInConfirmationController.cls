public class OptInConfirmationController 
{
    public Id recId{get;set;}
    public String optInAction{get;set;}
    
    //Show message.
    public Boolean showMsg{get;set;}
    public Boolean showErrMsg{get;set;}
    public Boolean showConfirmMsg{get;set;}
    public Boolean showDeclineMsg{get;set;}
    public Boolean showOptOutMsg{get;set;}
    
    
    public Account accountObj{get;set;}
    
    public map<String,Brand_Domain_Name_Setting__mdt> brandDomainNameMap;
    public Brand_Domain_Name_Setting__mdt brandDomainName {get; set;}
    public String logoURL {get; set;}
    
    public OptInConfirmationController()
    {
        showErrMsg = false;
        showConfirmMsg = false;
        showDeclineMsg = false;    
        showOptOutMsg = false;   
    }
    
    public PageReference onLoad()
    {
        brandDomainName = new Brand_Domain_Name_Setting__mdt();
        brandDomainNameMap = getBrandDomainNameSettingMap();
        
        recId = apexpages.currentpage().getparameters().get('recId');
        system.debug('########## accId  '+recId );
        optInAction = apexpages.currentpage().getparameters().get('optInAction');
        system.debug('########## optInAction  '+optInAction );
        accountObj = getAccount(recId);
        
        
            // Domain and logo
            if(brandDomainNameMap.containsKey(accountObj.Org_Brand__c.tolowercase() + accountObj.Customer_Domain__c))
            {
                    brandDomainName = brandDomainNameMap.get(accountObj.Org_Brand__c.tolowercase()+ accountObj.Customer_Domain__c);
                    logoURL = getResourceURL(accountObj.Org_Brand__c.tolowercase()+ accountObj.Customer_Domain__c);
                    
            } 
            else 
            {
                    brandDomainName = brandDomainNameMap.get('ekhUAE');
                    logoURL = getResourceURL('ekhUAE');
            }
            
         if(accountObj.Marketing_Consent__c)
         {    
            
            if(optInAction == 'Confirm') 
            {
                return onConfirm(accountObj );
            }
            if(optInAction == 'Decline') 
            {
                return onDecline(accountObj );
            }
        }
        else
        {
            showOptOutMsg = true;
        }
        
        
        return NULL;
       
    }
    
    public Account getAccount(String recId )
    {
        return [SELECT id,
                                
                                Initial_Opt_In_Date__c,
                                Initial_Opt_In_Reason__c,
                                Initial_Opt_In_Source__c,
                                Org_Brand__c,
                                Customer_Domain__c,
                                Marketing_Consent__c

                           FROM Account 
                          WHERE id =:recId LIMIT 1];
    }
    public PageReference onConfirm(Account accParam)
    {
      
        
        if(accParam!= NULL)
        {
                accParam.Opt_In_Status__c = 'Accepted';
                accParam.EKUK_Send_exclusive_discounts_offers__c = true;
                accParam.Org_Opt_In_Date__c = system.now(); //accParam.Initial_Opt_In_Date__c;
                accParam.Opt_In_Reason__c = accParam.Initial_Opt_In_Reason__c;
                accParam.Org_Opt_In_Source__c = accParam.Initial_Opt_In_Source__c;
               
                try
                {
                    update accParam;
                    showConfirmMsg = true;
                }
                catch(Exception ex)
                {
                    showErrMsg = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        
                } 
        }
        return NULL;
    }

    public PageReference onDecline(Account accParam)
    {
        Account acc = new Account(id = recId);
        acc.Opt_In_Status__c = 'Declined';
        acc.EKUK_Send_exclusive_discounts_offers__c = false;
        acc.Marketing_Consent__c = false;
        acc.Opt_In_Declined_DateTime__c = system.now();
                
        try
        {
            update acc;
            showDeclineMsg = true;
        }
        catch(Exception ex)
        {
            showErrMsg = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));

        }
        
        return NULL;
    }
    
    
    /**
     * 
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
    
     public map<String,Brand_Domain_Name_Setting__mdt> getBrandDomainNameSettingMap(){

        map<String,Brand_Domain_Name_Setting__mdt> brandDomainNameSettingMap = new map<String,Brand_Domain_Name_Setting__mdt>();

        for(Brand_Domain_Name_Setting__mdt brandDomainName : [SELECT Brand__c, Domain_Name__c, Privacy_Label__c, Privacy_URL__c, Privacy_Label_Arabic__c, Privacy_Policy_Label__c, Privacy_Policy_Label_Arabic__c FROM Brand_Domain_Name_Setting__mdt]){
            if(string.IsNotEmpty(brandDomainName.Domain_Name__c)){
                brandDomainNameSettingMap.put(brandDomainName.Brand__c + brandDomainName.Domain_Name__c, brandDomainName);
            } else {
                brandDomainNameSettingMap.put(brandDomainName.Brand__c, brandDomainName);
            }
            
        }

        return brandDomainNameSettingMap;

    }


}