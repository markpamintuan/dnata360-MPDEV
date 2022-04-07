/**************************************************************************************************
* Name               : UnsubscribePageController
* Description        : This is the class for opting out a customer from Surveys          
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Keith Rogers                                                      
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Keith         08-Aug-2018    Initial version
* v1.1        Kaavya        01-Apr-2019    Changed from Survey Opt In to Survey Opt Out
* v1.2        Mark          09-May-2019    Added checking on Booking Domain Name to dynamically display logo
* v1.3        Sri Bala      26-Aug-2019    TRP Brand
* v1.4        Merul         01-Oct-2019    Enabling multi-language based on booking domain
* v1.5        Kaavya        25-Dec-2019    CC - Enabling unsubscribe for surveys related to Order
* v1.6        Mark          10-Jan-2021    created variables to map metadata field to fix display on page
**************************************************************************************************/
public class UnsubscribePageController{

    public String customerId;

    //v1.2
    public Booking__c bookingObj;
    public map<String,Brand_Domain_Name_Setting__mdt> brandDomainNameMap;
    public Account accountObj;
    public Brand_Domain_Name_Setting__mdt brandDomainName {get; set;}
    public String logoURL {get; set;}
    //v1.4
    public Boolean isShowArabic {get; set;}
    public String lang {get; set;}
    public Order Orderobj; //v1.5
    
    //v1.6
    public String brandLabel {get; set;}
    public String privacyURL {get; set;}
    public String privacyLabel {get; set;}
    public String strThankyou {get; set;}
    public String strMainText {get; set;}

    public UnsubscribePageController(){

        //v1.2
        brandDomainName = new Brand_Domain_Name_Setting__mdt();
        brandDomainNameMap = getBrandDomainNameSettingMap();
        isShowArabic = false;
        if(ApexPages.currentPage().getParameters().get('bkid') != null){
            bookingObj = getBooking(ApexPages.currentPage().getParameters().get('bkid'));
            // v1.4 For Language code.
            if(bookingObj.Org_Domain_Id__c != NULL)
            {
                List<Domain_Setting__mdt> dmSetting = [ 
                                                          SELECT id,
                                                                 MasterLabel,
                                                                 DeveloperName,
                                                                 Language_code__c,
                                                                 Org_Domain_Id__c 
                                                            FROM Domain_Setting__mdt
                                                           WHERE Org_Domain_Id__c  =:bookingObj.Org_Domain_Id__c 
                                                           LIMIT 1
                                                        ];
                                                
                 if( dmSetting != NULL && dmSetting.size() > 0 )
                 {
                    lang =  dmSetting[0].Language_code__c; 
                 }  
                 
                 system.debug('LLL=='+lang);                             
            
            }
            //end of v1.4
            if(bookingObj.Org_Brand__c == 'dnata'){
                brandDomainName = brandDomainNameMap.get(bookingObj.Org_Brand__c);
                logoURL = getResourceURL(bookingObj.Org_Brand__c);
            } else if(brandDomainNameMap.containsKey(bookingObj.Org_Brand__c + bookingObj.Org_Domain_Name__c)){
                brandDomainName = brandDomainNameMap.get(bookingObj.Org_Brand__c + bookingObj.Org_Domain_Name__c);
                logoURL = getResourceURL(bookingObj.Org_Brand__c + bookingObj.Org_Domain_Name__c);
            }
            //v1.3
            else if(bookingObj.Org_Brand__c == 'trp'){
                system.debug('brandDomainNameMap'+brandDomainNameMap);
                brandDomainName = brandDomainNameMap.get('trp');
                logoURL = getResourceURL('trp');
            }
            //end
            else {
                brandDomainName = brandDomainNameMap.get('ekhUAE');
                logoURL = getResourceURL('ekhUAE');
            }
        }
        //v1.5 Adding condition for Order
        else if(ApexPages.currentPage().getParameters().get('Ordid') != null){
            OrderObj = getOrder(ApexPages.currentPage().getParameters().get('Ordid')); 
            brandDomainName = brandDomainNameMap.get(OrderObj.SFCC_Brand__c);
            logoURL = getResourceURL(OrderObj.SFCC_Brand__c.replace(' ','_'));
        } 
        //end of v1.5   
        else {
            accountObj = getAccount(ApexPages.currentPage().getParameters().get('cid'));
            if(brandDomainNameMap.containsKey(accountObj.Org_Brand__c.toLowerCase() + accountObj.Customer_Domain__c)){
                brandDomainName = brandDomainNameMap.get(accountObj.Org_Brand__c.toLowerCase() + accountObj.Customer_Domain__c);
                logoURL = getResourceURL(accountObj.Org_Brand__c.toLowerCase() + accountObj.Customer_Domain__c);
            } 
            //v1.3
            else if(accountObj.Org_Brand__c == 'trp'){
                brandDomainName = brandDomainNameMap.get('trp');
                logoURL = getResourceURL('trp');
            }
            else {
                brandDomainName = brandDomainNameMap.get('ekhUAE');
                logoURL = getResourceURL('ekhUAE');
            }
            
        }

        //v1.6
        if(!isShowArabic){ 
            brandLabel = brandDomainName.Privacy_Label__c;
            if(string.IsNotEmpty(brandDomainName.Privacy_Policy_Label__c)){
                privacyLabel = brandDomainName.Privacy_Policy_Label__c; 
            } else {
                privacyLabel = 'Privacy Policy';
            }            
        } else {
            brandLabel = brandDomainName.Privacy_Label_Arabic__c;
            privacyLabel = brandDomainName.Privacy_Policy_Label_Arabic__c; 
        }

        privacyURL = brandDomainName.Privacy_URL__c;

        if(string.IsNotEmpty(brandDomainName.Thank_you_Text__c)){
            strThankyou = brandDomainName.Thank_you_Text__c;
        } else {
            strThankyou = Label.Unsubscribe_Thank_You;
        }

        if(string.IsNotEmpty(brandDomainName.Unsubscribe_Main_Text__c)){
            strMainText = brandDomainName.Unsubscribe_Main_Text__c;
        } else {
            strMainText = Label.Unsubscribe_Main_Text;
        }        
        //End v1.6
            
        //End v1.2
            
    }
/**************************************************************************************************
* Name               : unsubscribeCustomer 
* Description        : unsubscribes customer i.e. sets Survey_Opt_Out__pc to true
* Params             : -
* Return             : -
**************************************************************************************************/
    public void unsubscribeCustomer(){
        try{
            customerId = ApexPages.currentPage().getParameters().get('cid');
            system.debug('#### customerId: ' + customerId);

            Account acc = new Account();
            acc.Id = customerId;
            //acc.Org_Survey_Opt_In__c = false; //commented as part of v1.1
            acc.Survey_Opt_Out__pc=true; //Added as part of v1.1
            update acc;
        }catch(Exception e){

        }
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 9 May 2019
     * @description: method that return Booking record. //v1.2
     * @history:                
     */    
    public Booking__c getBooking(String bookingId){
        return [SELECT Org_Brand__c, Org_Domain_Name__c,Org_Domain_Id__c FROM Booking__c WHERE Id =: bookingId];
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: method that return Account record //v1.2
     * @history:                
     */    
    public Account getAccount(String accountId){
        return [SELECT Id, Org_Brand__c, Customer_Domain__c FROM Account WHERE Id =: accountId];
    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 15 May 2019
     * @description: method that return map of String and Custom Metadata //v1.2
     * @history:                
     */ 
    public map<String,Brand_Domain_Name_Setting__mdt> getBrandDomainNameSettingMap(){

        map<String,Brand_Domain_Name_Setting__mdt> brandDomainNameSettingMap = new map<String,Brand_Domain_Name_Setting__mdt>();

        for(Brand_Domain_Name_Setting__mdt brandDomainName : [SELECT Brand__c, Domain_Name__c, Privacy_Label__c, Privacy_URL__c,Privacy_Policy_Label__c, Thank_you_Text__c, Unsubscribe_Main_Text__c FROM Brand_Domain_Name_Setting__mdt]){
            if(string.IsNotEmpty(brandDomainName.Domain_Name__c)){
                brandDomainNameSettingMap.put(brandDomainName.Brand__c + brandDomainName.Domain_Name__c, brandDomainName);
            } else {
                brandDomainNameSettingMap.put(brandDomainName.Brand__c, brandDomainName);
            }
            
        }

        return brandDomainNameSettingMap;

    }

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 20 May 2019
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
    
    /**
     * @author: Kaavya Raghuram
     * @date: 25 Dec 2019
     * @description: method that return Order record. //v1.5
     * @history:                
     */    
    public Order getOrder(String orderId){
        return [SELECT Id,SFCC_Brand__c FROM Order WHERE Id =: orderId];
    }

}