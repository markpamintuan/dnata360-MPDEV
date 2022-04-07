/**************************************************************************************************
* Name               : NewBookingPDFControllerCC
* Description        : Controller to render pdf for new booking eCommerce
* Created Date       : 01-Oct-2019                                                                
* Created By         : Jed Canlas                                                     
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Jed             01-Oct-2019     Initial version                                                                                                                         
**************************************************************************************************/
public without sharing class NewBookingPDFControllerCC { 
    public Order o {get;set;}
    public List<ObjectWrapper> objList {get;set;}
    public Account acc {get;set;}
    Public List<Payment_Information__c> piList {get;set;}
    
    
    public NewBookingPDFControllerCC() {
        objList = new List<ObjectWrapper>();
        piList = new List<Payment_Information__c>();
        
        String oId = ApexPages.currentPage().getParameters().get('oId'); 
        o = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order').getDescribe().fields.getMap().keySet()), ',') + ' FROM Order where Id =: oId limit 1');
        piList = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Payment_Information__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Payment_Information__c where Order__c =: oId order by CreatedDate DESC');
        string accId = o.AccountId;
        acc = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',') + ' FROM Account where Id =: accId limit 1');
        Set<Id> productIdSet = new Set<Id>();
        
        for(Order_Line_Item__c o: Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Order_Line_Item__c where Order__c =: oId')){
            productIdSet.add(o.Product__c);
        }
        Map<Id,Product2> pMap = new Map<Id,Product2>([Select id,Name,DisplayURL,Display_Image__c,Brand__c FROM Product2 where Id IN: productIdSet]);
        
        List<Pricebookentry> pbookList = new List<Pricebookentry>([SELECT Product2.Id,Product2.Name,Product2.DisplayUrl,Product2.Brand__c FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id IN:productIdSet]);
        
        List<Order_Line_Item__c> oliList = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + 
                                                          ',(SELECT Id From Attachments order by createddate desc limit 1)' + 
                                                          ',(SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Traveller__c').getDescribe().fields.getMap().keySet()), ',') + ' From Order_Travellers__r)' + 
                                                          ' FROM Order_Line_Item__c where Order__c =: oId');
        for(Order_Line_Item__c o: oliList){
            ObjectWrapper tempObjWrapper = new ObjectWrapper(o);
            tempObjWrapper.trList.addAll(o.Order_Travellers__r);   
            integer adults = 0;
            integer children = 0;
            integer infants = 0;
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
            tempObjWrapper.prod = pMap.get(o.Product__c);          
            for(Order_Traveller__c ot: o.Order_Travellers__r){
                If(ot.Order_Line_Item__c == o.Id){
                    tempObjWrapper.passengerNames += ot.Org_First_Name__c + ' ' + ot.Org_Last_Name__c + ', ';
                    if(tempObjWrapper.prod.Brand__c == 'marhaba'){
                        if(ot.Org_Age_Category__c == 'Adult'){
                            adults++;
                        }
                        if(ot.Org_Age_Category__c == 'Infant'){
                            infants++;
                        }
                    }
                    if(tempObjWrapper.prod.Brand__c == 'Arabian Adventures'){
                        if(ot.Org_Age__c < 5){
                            infants++;
                        }
                       if(ot.Org_Age__c > 4 && ot.Org_Age__c < 12){
                            children++;
                        }
                        if(ot.Org_Age__c > 11){
                            adults++;
                        }
                    }
                    if(tempObjWrapper.prod.Brand__c == 'City Sightseeing Dubai'){
                        if(ot.Org_Age__c < 2){
                            infants++;
                        }
                       if(ot.Org_Age__c > 1 && ot.Org_Age__c < 12){
                            children++;
                        }
                        if(ot.Org_Age__c > 11){
                            adults++;
                        }
                    }
                    /**
                    Integer monthDiff = ot.Org_Date_of_Birth__c.monthsBetween(system.today());
                    //adult 84months 7 yeears UP
                    if(monthDiff > 144){
                        adults++;
                    }
                    if(monthDiff <= 144 && monthDiff > 24){
                        children++;
                    }
                    if(monthDiff <= 24){
                        infants++;
                    }  **/  
                }
            }
            
            //if(o.Flight_Origin__c != null){
                //Time myTime = Time.newInstance(3, 3, 3, 0);
                //Datetime dt = Datetime.newInstance(o.Service_Start_Date__c,myTime);
                //tempObjWrapper.arrivalDetails =' | ' + dt.format('dd MMM yyyy') + ' | ' + o.Service_Start_Time__c;
           //}
                        
            if(tempObjWrapper.passengerNames.length() > 3){
                tempObjWrapper.passengerNames = tempObjWrapper.passengerNames.substring(0,tempObjWrapper.passengerNames.length()-2);    
            }
                  
            
            String adultStr = '';
            String childrenStr = '';
            String infantStr = '';
            
            if(adults > 1){
                adultStr = ' Adults, ';
            }else{
                adultStr = ' Adult, ';
            }
            if(children > 1){
                childrenStr = ' Children, ';
            }else{
                childrenStr = ' Child, ';
            }
            if(infants > 1){
                infantStr = ' Infants'; 
            }else{
                infantStr = ' Infant';
            }
			
            
            tempObjWrapper.passengerAge =  string.valueOf(adults) + adultStr + string.valueOf(children) + childrenStr + string.valueOf(infants) + infantStr;                       
            for(Attachment a: [select id,name,parentid,body from attachment where parentid =: o.Id]){               
                tempObjWrapper.att.add(a);     
            }            
              
            tempObjWrapper.serviceStartDateTime = o.Service_Start_Date__c.format();
            objList.add(tempObjWrapper);           
        }                
    } 
        
    public class ObjectWrapper{
        
        public Order_Line_Item__c obj {get; set;}
        public List<Order_Traveller__c> trList {get;set;}
        public List<Attachment> att {get;set;}
        public Product2 prod {get;set;}
        public Decimal objTotal {get;set;}
        public String passengerAge {get;set;}
        public String passengerNames {get;set;}
        public String arrivalDetails {get;set;}
        public String serviceStartDateTime {get;set;}
        public List<String> servicesList {get;set;}
                
        public ObjectWrapper(Order_Line_Item__c obj){            
            this.obj = obj;
            this.trList = new List<Order_Traveller__c>();            
            this.att = new List<Attachment>(); 
            this.objTotal = (obj.Quantity__c*obj.Unit_Price__c).setScale(2);            
        }
    }    
}