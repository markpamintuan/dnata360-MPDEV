/**************************************************************************************************
* Name               : NewQuotePDFControllerCC
* Description        : controller to render new quote pdf for eCommerce
* Created Date       : 01-Oct-2019                                                                
* Created By         : Jed Canlas                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Jed             01-Oct-2019     Initial version                                                                                                                         
**************************************************************************************************/
public without sharing class NewQuotePDFControllerCC {  
 
    
    
    public Quote_Header__c q {get;set;}
    public List<ObjectWrapper> objList {get;set;}
    public Account acc {get;set;}

    
    
    public NewQuotePDFControllerCC() {
        objList = new List<ObjectWrapper>(); 
  
        
        String qId = ApexPages.currentPage().getParameters().get('qId'); 
        q = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Quote_Header__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Quote_Header__c where Id =: qId limit 1');
        
        string accId = q.Customer__c;
        acc = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',') + ' FROM Account where Id =: accId limit 1');
        Set<Id> productIdSet = new Set<Id>();
        
        for(Order_Line_Item__c o: Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Order_Line_Item__c where Quote__c =: qId')){
            productIdSet.add(o.Product__c);
        }
        Map<Id,Product2> pMap = new Map<Id,Product2>([Select id,Name,DisplayURL,Display_Image__c,Brand__c FROM Product2 where Id IN: productIdSet]);
        
        List<Pricebookentry> pbookList = new List<Pricebookentry>([SELECT Product2.Id,Product2.Name,Product2.DisplayUrl,Product2.Brand__c FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id IN:productIdSet]);
        
        List<Order_Line_Item__c> oliList = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') +
                                                          ' FROM Order_Line_Item__c where Quote__c =: qId');
        for(Order_Line_Item__c o: oliList){
            ObjectWrapper tempObjWrapper = new ObjectWrapper(o);
            tempObjWrapper.trList.addAll(o.Order_Travellers__r);    
            tempObjWrapper.passengerNames = '';
            tempObjWrapper.servicesList = new List<String>();
            if(o.Add_on_Service__c != null){
                
                
                if(string.valueOf(o.Add_on_Service__c).contains(';')){
                  for(String s: o.Add_on_Service__c.split(';')){
                    tempObjWrapper.servicesList.add(s);
                  }  
                }else{
                    tempObjWrapper.servicesList.add(string.valueOf(o.Add_on_Service__c));
                }
            }
                    
            
            //if(o.Flight_Origin__c != null){
                //Datetime dt = Datetime.newInstance(o.Flight_Date__c,o.Time__c);

                //tempObjWrapper.arrivalDetails =' | ' + dt.format('dd MMM yyyy') + ' | ' + dt.format('HH:mm');
            //}
            
            
            if(tempObjWrapper.passengerNames.length() > 3){
                tempObjWrapper.passengerNames = tempObjWrapper.passengerNames.substring(0,tempObjWrapper.passengerNames.length()-2);    
            }
            
            
            String adultStr = '';
            String childrenStr = '';
            
            if(o.Number_of_Adults__c > 1){
                adultStr = ' Adults, ';
            }else{
                adultStr = ' Adult, ';
            }
            if(o.Number_of_Children__c > 1){
                childrenStr = ' Children ';
            }else{
                childrenStr = ' Child ';
            }

            
            tempObjWrapper.passengerAge =  string.valueOf(o.Number_of_Adults__c) + adultStr + string.valueOf(o.Number_of_Children__c) + childrenStr;
            
            
            for(Attachment a: [select id,name,parentid,body from attachment where parentid =: o.Id]){               
                tempObjWrapper.att.add(a);     
            }
            
            tempObjWrapper.prod = pMap.get(o.Product__c);      
            objList.add(tempObjWrapper);
            
        }
        
        
    } 
    
    
    public class ObjectWrapper
    {
        public Order_Line_Item__c obj {get; set;}
        public List<Order_Traveller__c> trList {get;set;}
        public List<Attachment> att {get;set;}
        public Product2 prod {get;set;}
        public Decimal objTotal {get;set;}
        public String passengerAge {get;set;}
        public String passengerNames {get;set;}
        public String arrivalDetails {get;set;}
        public List<String> servicesList {get;set;}
        
        
        public ObjectWrapper(Order_Line_Item__c obj){            
            this.obj = obj;
            this.trList = new List<Order_Traveller__c>();            
            this.att = new List<Attachment>(); 
            this.objTotal = (obj.Quantity__c*obj.Unit_Price__c).setScale(0);
            
        }
    }
    
    
    
    
}