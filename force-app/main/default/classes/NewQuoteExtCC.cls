/**************************************************************************************************
* Name               : NewQuoteExtCC
* Description        : eCommerce new quote controller
* Created Date       : 01-Oct-2019
* Created By         : Jed Canlas
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR           DATE           COMMENTS
* v1.0        Jed             01-Oct-2019     Initial version
**************************************************************************************************/
public without sharing class NewQuoteExtCC {
    
    public Quote_Header__c o {get; set;}
    public Decimal total {get; set;}
    public Decimal totalGross {get; set;}
    public Decimal totalNet {get; set;}
    public Decimal totalTax {get; set;}
    public list<String> FieldList {get; set;}
    public String ParentRecId {get; set;}
    public list<ObjectWrapper> ObjectList {get; set;}
    public String ActionRowUniqueId {get; set;}
    private Integer AddedRowCount;
    public List<Order_Line_item__c> oliList;
    public String qId {get; set;}
    public String productId {get; set;}
    public String productIdUnique {get; set;}
    private final Case cse;
    public List<selectOption> timeOptions { get; set; }
    
    public NewQuoteExtCC(ApexPages.StandardController stdController) {
        
        List<String> fields = new List<String> { 'Id','AccountId','Org_Brand__c','Org_Business_Unit_dropdown__c','Org_Destination_list__c','Reason','Org_Booking__c', 'AccountId', 'CaseNumber','Org_Case_Status__c','Org_Case_Close_Reason__c', 'Closing_Comments__c','Org_Current_Team_Name__c','Staff_Region__c','Record_Type_Name__c'};
            if (!Test.isRunningTest()) {
                stdController.addFields(fields);
            }
        this.cse = (Case)stdController.getRecord();
        qId = ApexPages.currentPage().getParameters().get('qId');
        timeOptions = new List<selectOption>();
        for (integer i = 1; i < 25; i++) {
            timeOptions.add(new selectOption(string.valueOf(i)+':00', string.valueOf(i)+':00'));
            
        }
                
        
        total = 0;
        totalGross = 0;
        totalNet = 0;
        totalTax = 0;
        AddedRowCount = 0;
        
        FieldList = new List<String>();
        for(Schema.FieldSetMember s: getFields())
        {
            FieldList.add(s.fieldPath);
        }
        ObjectList = new List<ObjectWrapper>();
        oliList = new List<Order_Line_item__c>();
        
        Account a = [select id,name,personemail from account where id=: cse.AccountId limit 1];
        o = new Quote_Header__c();
        if(qId != null) {
            totalTax = 0;
            o = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Quote_Header__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Quote_Header__c where Id =: qId limit 1');
            
            List<Order_Line_Item__c> existingOli = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + ' from Order_Line_Item__c where Quote__c =: qId order by CreatedDate ASC');
            if(existingOli.size()>0) {
                for(Order_Line_Item__c eOli: existingOli) {
                    string pInitId = eOli.Product__c;
                    Product2 pInit = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: pInitId limit 1');
                    ObjectWrapper TmpObjWrap = new ObjectWrapper(eOli, true);
                    TmpObjWrap.obj = eOli;
                    TmpObjWrap.objProduct = pInit;
                    AddedRowCount += 1;
                    total += eOli.Quantity__c*eOli.Unit_Price__c;
                    TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
                    ObjectList.add(TmpObjWrap);
                }
            }
            if(o.TotalMargin__c != null) {
                totalTax = o.TotalMargin__c;
            }
            totalGross = total + totalTax;
        }else{
            o.Case__c = cse.Id;
            o.Customer__c = cse.AccountId;
            o.RecordTypeId = Schema.SObjectType.Quote_Header__c.getRecordTypeInfosByName().get('eCommerce Quote').getRecordTypeId();
            o.Brand__c = cse.Org_Business_Unit_dropdown__c;
        }
        ParentRecId = o.Id;       
        
    }
    
    
    public static string getUniqueStr(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8) + h.SubString(8,12) + h.SubString(12,16) + h.SubString(16,20) + h.substring(20);
        return guid;
    }
    
    public void checkProductBrand(){
        
        total = 0;
        totalGross = 0;
        //Pricebookentry op = new Pricebookentry();
        Product2 p = new Product2();
        
        
        if(productId != '') {
            try{
                //op = [SELECT Id,Name,Product2.Id,Product2.Name,Product2.Brand__c,UnitPrice FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id =: productId limit 1];
                p = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: productId limit 1');
            }catch (exception e) {}
            
            
        }
        for(ObjectWrapper o: ObjectList) {
            if(productIdUnique == o.uniqueId) {
                o.obj.Quantity__c = 1;
                //o.obj.Unit_Price__c = op.UnitPrice;
                o.obj.Unit_Price__c = 0;
                
            }
            if(o.obj.Unit_Price__c >0) {
                
                total = total + o.obj.Quantity__c*o.obj.Unit_Price__c;
            }
            
            if(o.uniqueId == productIdUnique && productId != '') {
                o.objProduct = p;
                o.obj.Name = p.Name;
                productId = '';
                productIdUnique = '';
            }
        }
        
        
        if(o.TotalMargin__c > 0) {
            totalGross = total + o.TotalMargin__c;
        }else{
            totalGross = total;
        }
    }
    
    
    public Static List<Schema.FieldSetMember> getFields()
    {
        return SObjectType.Order_Line_Item__c.FieldSets.OrderLineitemFieldset.getFields();
    }
    
    public void DoAdd(){
        ObjectWrapper TmpObjWrap = new ObjectWrapper(new Order_Line_Item__c(), true);
        TmpObjWrap.obj.put('Quote__c', ParentRecId);
        AddedRowCount += 1;
        TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
        ObjectList.add(TmpObjWrap);
        
    }
    
    Set<Order_Line_Item__c> oliRemoveList = new Set<Order_Line_Item__c>();
    
    
    /***
* DoRemove - remove usaved added rows of the list
***/
    public void DoRemove()
    {
        //total = 0;
        if (ActionRowUniqueId == null || ActionRowUniqueId.trim().length() == 0)
        {
            return;
        }
        for (Integer i = 0; i < ObjectList.size(); i++)
        {
            
            if (ActionRowUniqueId == ObjectList[i].uniqueId)
            {
                if((ObjectList[i].obj.Quantity__c*ObjectList[i].obj.Unit_Price__c) < total) {
                    total = total - (ObjectList[i].obj.Quantity__c*ObjectList[i].obj.Unit_Price__c);
                }
                
                if(ObjectList[i].obj.Id != null) {
                    
                    oliRemoveList.add(ObjectList[i].obj);
                }
                
                ObjectList.remove(i);
                break;
            }
        }
        ActionRowUniqueId = null;
    }
    
    
    
    public class ObjectWrapper
    {
        public Order_Line_Item__c obj {get; set;}
        public Boolean IsEditMode {get; set;}
        public String AddedRowNumber {get; set;}
        public String uniqueId {get; set;}
        public boolean isCSD {get; set;}
        public Product2 objProduct {get; set;}
                
        public ObjectWrapper(Order_Line_Item__c obj, Boolean IsEditMode)
        {
            if(obj.Id == null) {
                obj.Quantity__c = 0;
                obj.Unit_Price__c = 0;
                obj.Number_of_Adults__c = 0;
                obj.Number_of_Children__c = 0;
                
            }
            if(obj.Product__c != null) {
                String productId = obj.Product__c;
                this.objProduct = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: productId limit 1');
            }            
            this.obj = obj;
            this.IsEditMode = IsEditMode;
            this.uniqueId = getUniqueStr();
            //this.isCSS = [SELECT Product2.Id,Product2.Brand__c FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id =: obj.Product__c AND Product2.Brand__c = 'City Sightseeing'].size()>0;
            this.isCSD = [SELECT Id,Brand__c FROM Product2 WHERE Id =: obj.Product__c AND Brand__c = 'City Sightseeing Dubai'].size()>0;
            
        }
    }
    
    public PageReference saveAll(){
        
        saveBookingItem();
        saveOli();
        List<Order_Line_Item__c> oliRemoveListFinal = new List<Order_Line_Item__c>();
        oliRemoveListFinal.addAll(oliRemoveList);
        if(oliRemoveListFinal.size()>0) {
            delete oliRemoveListFinal;
        }
        PageReference pageRef = new PageReference('/'+cse.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference saveAndPreview(){
        
        saveBookingItem();
        saveOli();
        List<Order_Line_Item__c> oliRemoveListFinal = new List<Order_Line_Item__c>();
        oliRemoveListFinal.addAll(oliRemoveList);
        if(oliRemoveListFinal.size()>0) {
            delete oliRemoveListFinal;
        }
        PageReference pageRef = new PageReference('/apex/NewQuotePDFCC?qId='+o.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    public PageReference saveAndAttach(){
        saveBookingItem();
        saveOli();
        List<Order_Line_Item__c> oliRemoveListFinal = new List<Order_Line_Item__c>();
        oliRemoveListFinal.addAll(oliRemoveList);
        if(oliRemoveListFinal.size()>0) {
            delete oliRemoveListFinal;
        }
        attachPdf(o.Id,cse.Id);
        PageReference pageRef = new PageReference('/'+cse.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    //@TestVisible @future(callout=true)
    private static void attachPdf(string quoteId, string caseId){
        Quote_Header__c qHeader = [select id from Quote_Header__c where id =: quoteId limit 1];
        PageReference pdf = new PageReference('/apex/NewQuotePDFCC?qId='+qHeader.Id);
        Attachment att = new Attachment();
        att.Name = 'Quote' + ' - ' + system.today() + '.pdf';
        if(!Test.isRunningTest()) {
            att.Body = pdf.getContentAsPDF();
        }else{
            att.Body = Blob.valueOf('Unit Test Attachment Body');
        }
        att.ParentId = caseId;
        insert att;
    }
    
    
    
    @TestVisible
    private void saveBookingItem(){        
        o.TotalCost__c = totalGross;
        if(o.TotalMargin__c>0) {
            o.Price__c = totalGross - o.TotalMargin__c;
        }else{
            o.Price__c = totalGross;
        }
        upsert o;
    }
    @TestVisible private void saveOli(){
        oliList = new List<Order_Line_Item__c>();
        for(ObjectWrapper oPr: ObjectList) {
            oPr.obj.Quote__c = o.Id;
            oliList.add(oPr.obj);
        }
        upsert oliList;
    }
    
    @RemoteAction
    public static Set<String> getFromFlights(string flightname){
        Set<String> airports = new Set<String>();
        if(flightname.length() > 1) {
            string newflightname = '%'+flightname+'%';            
            for(lookup__c fa: [select name from lookup__c where (name LIKE :newflightname AND (name != '' OR name != null)  And Type__c ='Airport') OR (code__c LIKE :newflightname And Type__c ='Airport') ORDER BY name ASC LIMIT 10]) {
                airports.add(fa.name);
            }
        }
        return airports;
        
    }
    
    
}