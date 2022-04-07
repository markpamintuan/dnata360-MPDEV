/**************************************************************************************************
* Name               : NewBookingExtCC
* Description        : eCommerce new booking controller
* Created Date       : 01-Oct-2019
* Created By         : Jed Canlas
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR           DATE           COMMENTS
* v1.0        Jed             01-Oct-2019     Initial version
* v1.1        Kaavya          25-dec-2019     Fix for order brand to take from case business unit  
* v1.2        Sri Bala        31-Dec-2019     Populating Booked Date
**************************************************************************************************/
public class NewBookingExtCC {
    
    public Order o {get; set;}
    public Quote_Header__c q {get; set;}
    public String orderNumber {get; set;}
    public String ParentRecId {get; set;}
    public String ParentRecIdTr {get; set;}
    public String ActionRowUniqueId {get; set;}
    public String ActionRowUniqueIdTr {get; set;}
    public String oId {get; set;}
    public String qId {get; set;}
    public String productId {get; set;}
    public String productIdUnique {get; set;}
    public Decimal total {get; set;}
    public Decimal totalGross {get; set;}
    public Decimal totalNet {get; set;}
    public Decimal totalTax {get; set;}
    public list<String> FieldList {get; set;}
    public list<String> FieldListTr {get; set;}
    public list<ObjectWrapper> ObjectList {get; set;}
    public list<ObjectWrapperTr> ObjectListTr {get; set;}
    public List<Order_Line_item__c> oliList;
    public List<Order_Traveller__c> trList;
    public List<Attachment> attList;
    public List<selectOption> timeOptions { get; set; }
    public List<Date> oliStartDates {get; set;}
    public List<Date> oliEndDates {get; set;}  
    public DateTime startDate {get;set;}
    public DateTime endDate {get;set;}
    private Integer AddedRowCount;
    private Integer AddedRowCountTr;
    private final Case cse;
    
    public NewBookingExtCC(ApexPages.StandardController stdController) {
        
        List<String> fields = new List<String> { 'Id','Order__c','AccountId','Org_Brand__c','Org_Business_Unit_dropdown__c','Org_Destinations__c','Reason','Org_Booking__c', 'AccountId', 'CaseNumber','Org_Case_Status__c','Org_Case_Close_Reason__c', 'Closing_Comments__c','Org_Current_Team_Name__c','Staff_Region__c','Record_Type_Name__c'};
            if (!Test.isRunningTest()) {
                stdController.addFields(fields);
            }
        this.cse = (Case)stdController.getRecord();
        
        oId = ApexPages.currentPage().getParameters().get('oId');
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
        AddedRowCountTr = 0;
        startDate = null;
        endDate = null;
        FieldList = new List<String>();
        for(Schema.FieldSetMember s: getFields()) {
            FieldList.add(s.fieldPath);
        }
        FieldListTr = new List<String>();
        for(Schema.FieldSetMember s: getFieldsTr()) {
            FieldListTr.add(s.fieldPath);
        }
        ObjectList = new List<ObjectWrapper>();
        ObjectListTr = new List<ObjectWrapperTr>();
        oliList = new List<Order_Line_item__c>();
        trList = new List<Order_Traveller__c>();
        attList = new List<Attachment>();
        oliStartDates = new List<Date>();
        oliEndDates = new List<Date>();
        
        
        Account a = [select id,name,personemail from account where id=: cse.AccountId limit 1];
        
        try{
            if(oId != null) {
               orderNumber =  [select id,ordernumber from order where id =: oId limit 1 ].ordernumber;
            }else{
                Integer oNumber = integer.valueOf([select id,ordernumber from order order by ordernumber DESC limit 1 ].ordernumber) + 1;
              orderNumber = string.valueOf(oNumber);
            }
            
        }catch (exception e) {
            orderNumber = '1';
        }
        
        o = new Order();
        q = new Quote_Header__c();
        
        if(oId != null) {
            o = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order').getDescribe().fields.getMap().keySet()), ',') + ' FROM Order where Id =: oId limit 1');
            List<Order_Line_Item__c> existingOli = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + ' from Order_Line_Item__c where Order__c =: oId order by CreatedDate ASC');           
            if(existingOli.size()>0) {
                for(Order_Line_Item__c eOli: existingOli) {
                    string pInitId = eOli.Product__c;
                    Product2 pInit = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: pInitId limit 1');
                    ObjectWrapper TmpObjWrap = new ObjectWrapper(eOli, true);
                    TmpObjWrap.obj = eOli;
                    TmpObjWrap.objProduct = pInit;
                    AddedRowCount += 1;
                    if(eOli.Unit_Price__c > 0) {
                        total += eOli.Quantity__c*eOli.Unit_Price__c;
                    }                    
                    TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
                    Try {
                        TmpObjWrap.att = [select id,name,body,ParentId from Attachment where ParentId =: eOli.Id order by CreatedDate DESC limit 1];
                    }catch (exception e) {}
                    List<Order_Traveller__c> otrList = [select id,Org_Age_Category__c,Org_Age__c,Org_Date_of_Birth__c,Org_First_Name__c,Org_Last_Name__c from Order_Traveller__c where Order_Line_Item__c =: eOli.Id];
                    for(Order_Traveller__c eTr: otrList) {
                        ObjectWrapperTr TmpObjWrapTr = new ObjectWrapperTr(eTr, true);
                        TmpObjWrapTr.objTr = eTr;
                        TmpObjWrapTr.parentOliId = TmpObjWrap.uniqueId;
                        AddedRowCountTr += 1;
                        TmpObjWrapTr.AddedRowNumberTr = String.valueOf(AddedRowCountTr);
                        TmpObjWrap.ObjectWrapperTrList.add(TmpObjWrapTr);
                    }
                    ObjectList.add(TmpObjWrap);
                }
            }
            
            totalTax = o.SFCC_Order_Total_Tax__c;
            if(o.SFCC_Order_Total__c > 0) {
                totalGross = o.SFCC_Order_Total_Tax__c + o.SFCC_Order_Total__c;
            }else{
                totalGross = 0;
            }
            
            
        }else if(qId != null) {
            
            q = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Quote_Header__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Quote_Header__c where Id =: qId limit 1');
            List<Order_Line_Item__c> existingOli = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Order_Line_Item__c').getDescribe().fields.getMap().keySet()), ',') + ' from Order_Line_Item__c where Quote__c =: qId order by CreatedDate ASC');            
            if(existingOli.size()>0) {
                for(Order_Line_Item__c eOli: existingOli) {
                    eOli.Quote__c = null;
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
            
            totalTax = 0;
            if(q.TotalMargin__c != null) {
                totalTax = q.TotalMargin__c;
                o.SFCC_Order_Total_Tax__c = q.TotalMargin__c;
            }
            
            totalGross = total + totalTax;
            o.SFCC_Created_By__c = 'Salesforce';
            o.Status__c = 'Confirmed';
            o.Status = 'Draft';
            o.Shipment_Status__c = 'NOT_SHIPPED';
            o.Name =  'Booking for Case - ' + this.cse.CaseNumber;
            o.Case__c = cse.Id;
            o.AccountId = cse.AccountId;
            o.SFCC_Customer_Name__c = a.Name;
            o.SFCC_Customer_Email__c = a.PersonEmail;
            o.Order_SCCSync_Status__c = 'Created';
            o.SFCC_Order_Total__c = 0;
            o.SFCC_Brand__c = this.cse.Org_Business_Unit_dropdown__c;
            o.EffectiveDate = date.today();
            o.Booked_Date__c = system.now(); //v1.2
            o.EndDate = date.today();
            //o.SFCC_Order_Number__c = orderNumber;
            
            
        }else {
            o.SFCC_Created_By__c = 'Salesforce';
            o.Status__c = 'Confirmed';
            o.Status = 'Draft';
            o.Shipment_Status__c = 'NOT_SHIPPED';
            o.Name =  'Booking for Case - ' + this.cse.CaseNumber;
            o.Case__c = cse.Id;
            o.AccountId = cse.AccountId;
            o.SFCC_Customer_Name__c = a.Name;
            o.SFCC_Customer_Email__c = a.PersonEmail; 
            o.Order_SCCSync_Status__c = 'Created';
            o.SFCC_Order_Total__c = 0;
            //o.SFCC_Brand__c = this.cse.Org_Brand__c;// commented as part of v1.1
            o.SFCC_Brand__c = this.cse.Org_Business_Unit_dropdown__c; //Added as part of v1.1
            o.EffectiveDate = date.today();
            o.Booked_Date__c = system.now(); //v1.2
            o.EndDate = date.today();
            //o.SFCC_Order_Number__c = orderNumber;
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
        totalTax = o.SFCC_Order_Total_Tax__c;
        //1210 Pricebookentry op = new Pricebookentry();
        Product2 p = new Product2();        
        
        if(productId != '') {
            //1210 op = [SELECT Id,Name,Product2.Id,Product2.Name,Product2.Brand__c,UnitPrice FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id =: productId limit 1];
            p = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: productId limit 1');
            system.debug('###################################' + p.Brand__c);
        }
        for(ObjectWrapper o: ObjectList) {
            if(productIdUnique == o.uniqueId) {
                o.obj.Quantity__c = 1;
                //1210 o.obj.Unit_Price__c = op.UnitPrice;
                o.obj.Unit_Price__c = 0; //1210               
                if(productId != '' && o.ObjectWrapperTrList.size() == 0) {//1210
                    ObjectWrapperTr TmpObjWrapTr = new ObjectWrapperTr(new Order_Traveller__c(), true);
                    TmpObjWrapTr.objTr.put('Order_Line_Item__c', ParentRecIdTr);
                    TmpObjWrapTr.parentOliId = ActionRowUniqueIdTr;
                    AddedRowCountTr += 1;
                    TmpObjWrapTr.AddedRowNumberTr = String.valueOf(AddedRowCountTr);
                    o.ObjectWrapperTrList.add(TmpObjWrapTr);                   
                }              
            }
            if(o.obj.Unit_Price__c >0) {                
                total = total + (o.obj.Quantity__c*o.obj.Unit_Price__c);
            }            
            if(o.uniqueId == productIdUnique && productId != '') {
                
                o.objProduct = p;
                //o.att = new Attachment();
                //1210 if(op.Product2.Brand__c == 'City Sightseeing'){
                if(p.Brand__c == 'City Sightseeing Dubai') {//1210
                    o.isCSD = true;
                }else{
                    o.isCSD = false;
                    o.att = new Attachment();
                }
                //1210 o.obj.Name = op.Product2.Name;
                o.obj.Name = p.Name;
                productId = '';
                productIdUnique = '';
            }
        }              
        if(o.SFCC_Order_Total_Tax__c > 0) {
            totalGross = total + o.SFCC_Order_Total_Tax__c;
        }else{
            totalGross = total;
        }        
    }
    
    
    public Static List<Schema.FieldSetMember> getFields()
    {
        return SObjectType.Order_Line_Item__c.FieldSets.OrderLineitemFieldset.getFields();
    }
    public Static List<Schema.FieldSetMember> getFieldsTr(){
        return SObjectType.Order_Traveller__c.FieldSets.OrderTravellerFieldset.getFields();
    }
    
    public void DoAdd(){
        ObjectWrapper TmpObjWrap = new ObjectWrapper(new Order_Line_Item__c(), true);
        TmpObjWrap.obj.put('Order__c', ParentRecId);
        AddedRowCount += 1;
        TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
        ObjectList.add(TmpObjWrap);
        
    }
    
    public void DoAddTr(){       
        for(ObjectWrapper o: ObjectList) {
            if(o.uniqueId == ActionRowUniqueId) {
                ObjectWrapperTr TmpObjWrapTr = new ObjectWrapperTr(new Order_Traveller__c(), true);
                TmpObjWrapTr.objTr.put('Order_Line_Item__c', ParentRecIdTr);
                TmpObjWrapTr.parentOliId = ActionRowUniqueIdTr;
                AddedRowCountTr += 1;
                TmpObjWrapTr.AddedRowNumberTr = String.valueOf(AddedRowCountTr);
                o.ObjectWrapperTrList.add(TmpObjWrapTr);
            }            
        }        
    }
    
    
    Set<Order_Line_Item__c> oliRemoveList = new Set<Order_Line_Item__c>();
    Set<Order_Traveller__c> trRemoveList = new Set<Order_Traveller__c>();
    
    
    
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
                    if(ObjectList[i].ObjectWrapperTrList.size()>0) {
                        for(ObjectWrapperTr oTr: ObjectList[i].ObjectWrapperTrList) {
                            if(oTr.objTr.Id != null) {
                                trRemoveList.add(oTr.objTr);
                            }
                            
                        }
                    }
                }
                
                ObjectList.remove(i);
                break;
            }
        }
        ActionRowUniqueId = null;
    }
    public void DoRemoveTr()
    {
        if (ActionRowUniqueIdTr == null || ActionRowUniqueIdTr.trim().length() == 0)
        {
            return;
        }
        for(ObjectWrapper o: ObjectList) {
            for (Integer i = 0; i < o.ObjectWrapperTrList.size(); i++)
            {
                if (ActionRowUniqueIdTr == o.ObjectWrapperTrList[i].uniqueIdTr)
                {
                    if(o.ObjectWrapperTrList[i].objTr.Id != null) {
                        trRemoveList.add(o.ObjectWrapperTrList[i].objTr);
                    }
                    o.ObjectWrapperTrList.remove(i);
                    break;
                }
            }
            
        }
        
        ActionRowUniqueIdTr = null;
    }
    
    
    /***
* ObjectWrapper - subclass for the sObject record with additional
* properties
***/
    public class ObjectWrapper
    {
        public Order_Line_Item__c obj {get; set;}
        public Boolean IsEditMode {get; set;}
        public String AddedRowNumber {get; set;}
        public String uniqueId {get; set;}
        public List<ObjectWrapperTr> ObjectWrapperTrList {get; set;}
        public boolean isCSD {get; set;}
        public Attachment att {get; set;}
        public Product2 objProduct {get; set;}
        
        
        
        public ObjectWrapper(Order_Line_Item__c obj, Boolean IsEditMode){
            
            if(obj.Id == null) {
                obj.Quantity__c = 0;
                obj.Unit_Price__c = 0;                
            }
            if(obj.Product__c != null) {
                String productId = obj.Product__c;
                this.objProduct = database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') + ' FROM Product2 where Id =: productId limit 1');
            }
            
            this.obj = obj;
            this.IsEditMode = IsEditMode;
            this.uniqueId = getUniqueStr();
            this.ObjectWrapperTrList = new List<ObjectWrapperTr>();            
            //12010 this.isCSS = [SELECT Product2.Id,Product2.Brand__c FROM Pricebookentry WHERE PriceBook2.IsStandard=true AND Product2.Id =: obj.Product__c AND Product2.Brand__c = 'City Sightseeing'].size()>0;
            this.isCSD = [SELECT Id,Brand__c FROM Product2 WHERE Id =: obj.Product__c AND Brand__c = 'City Sightseeing Dubai'].size()>0;                       
            this.att = new Attachment();
            //this.objSize = ObjectWrapperTrList.size();
        }
    }
    public class ObjectWrapperTr
    {
        public Order_Traveller__c objTr {get; set;}
        public Boolean IsEditModeTr {get; set;}
        public String AddedRowNumberTr {get; set;}
        public String uniqueIdTr {get; set;}
        public String parentOliId {get; set;}
        
        
        public ObjectWrapperTr(Order_Traveller__c objTr, Boolean IsEditModeTr)
        {
            this.objTr = objTr;
            this.IsEditModeTr = IsEditModeTr;
            this.uniqueIdTr = getUniqueStr();
            
        }
    }
    
    
    
    
    
    
    
    public String oliRecId {get; set;}
    public String attFileId {get; set;}
    public string fileName {get; set;}
    public string tempFile {get; set;}
    public Blob fileBody {get; set;}
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        
        set;
        
    }
    
    
    public void UploadFile(){
        
        for(ObjectWrapper o: ObjectList) {
            if(o.uniqueId == oliRecId) {
                o.att = new Attachment();
                o.att.Body = fileBody;
                o.att.Name = fileName;
                o.att.ParentId = o.obj.Id;
            }
            
        }
        
    }
    public PageReference saveAndPreview(){
                
        
        if(o.SFCC_Order_Total_Tax__c <= 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order tax not added!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        for(ObjectWrapper ooo: ObjectList) {
            
            ooo.obj.Service_Start_Date__c = datetime.valueOf(ooo.obj.Service_Start_Date__c);
            if(ooo.att.Name == null && ooo.isCSD) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the selected products requires a QR Code.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(ooo.obj.Product__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the Line Items has no product selected.');
                ApexPages.addMessage(myMsg);
                return null;
            }            
            if(ooo.obj.service_start_date__c != null){
                if(startDate == null){
                    startDate = ooo.obj.service_start_date__c;
                }else{
                    if(startDate > ooo.obj.service_start_date__c){
                        startDate = ooo.obj.service_start_date__c;
                    }
                } 
                if(endDate == null){
                    endDate = ooo.obj.service_start_date__c;
                }else{
                    if(endDate < ooo.obj.service_start_date__c){
                        endDate = ooo.obj.service_start_date__c;
                    }
                }  
            }

        }
        saveBookingItem();
        saveOli();
        saveTravellers();
        saveAttachments();
        
        PageReference pageRef1 = new PageReference('/apex/NewBookingPDFCC?oid='+o.Id);
        pageRef1.setRedirect(true);
        return pageRef1;
        
    }
    public PageReference saveAndAttach(){
        
        if(o.SFCC_Order_Total_Tax__c <= 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order tax not added!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        for(ObjectWrapper ooo: ObjectList) {
            
            ooo.obj.Service_Start_Date__c = datetime.valueOf(ooo.obj.Service_Start_Date__c);
            if(ooo.att.Name == null && ooo.isCSD) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the selected products requires a QR Code.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(ooo.obj.Product__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the Line Items has no product selected.');
                ApexPages.addMessage(myMsg);
                return null;
            }            
            if(ooo.obj.service_start_date__c != null){
                if(startDate == null){
                    startDate = ooo.obj.service_start_date__c;
                }else{
                    if(startDate > ooo.obj.service_start_date__c){
                        startDate = ooo.obj.service_start_date__c;
                    }
                } 
                if(endDate == null){
                    endDate = ooo.obj.service_start_date__c;
                }else{
                    if(endDate < ooo.obj.service_start_date__c){
                        endDate = ooo.obj.service_start_date__c;
                    }
                }  
            }
        }
        saveBookingItem();
        saveOli();
        saveTravellers();
        saveAttachments();
        
        System.enqueuejob(new QueueClass(cse.Id,o.Id));

        //attachPdf(o.Id,cse.Id); 
        PageReference pageRef2 = new PageReference('/'+cse.Id);
        pageRef2.setRedirect(true);
        return pageRef2;
    }
    
    public PageReference saveAll(){
        
        if(o.SFCC_Order_Total_Tax__c <= 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order tax not added!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        for(ObjectWrapper ooo: ObjectList) {
            
            ooo.obj.Service_Start_Date__c = datetime.valueOf(ooo.obj.Service_Start_Date__c);
            if(ooo.att.Name == null && ooo.isCSD) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the selected products requires a QR Code.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(ooo.obj.Product__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of the Line Items has no product selected.');
                ApexPages.addMessage(myMsg);
                return null;
            }            
            if(ooo.obj.service_start_date__c != null){
                if(startDate == null){
                    startDate = ooo.obj.service_start_date__c;
                }else{
                    if(startDate > ooo.obj.service_start_date__c){
                        startDate = ooo.obj.service_start_date__c;
                    }
                } 
                if(endDate == null){
                    endDate = ooo.obj.service_start_date__c;
                }else{
                    if(endDate < ooo.obj.service_start_date__c){
                        endDate = ooo.obj.service_start_date__c;
                    }
                }  
            }
        }
        saveBookingItem();
        saveOli();
        saveTravellers();
        saveAttachments();
        
        PageReference pageRef3 = new PageReference('/'+cse.Id);
        pageRef3.setRedirect(true);
        return pageRef3; 
        
        
        
    }
    
    
    public class QueueClass implements Queueable {
        
        private string caseId;
        private string bookingId;
        public QueueClass(String caseId,string bookingId){
            this.caseId = caseId;
            this.bookingId = bookingId;

    }
        
        public void execute(QueueableContext context) {
            PageReference pdf = new PageReference('/apex/NewBookingPDFCC?oId='+bookingId);
            Attachment att = new Attachment();
            att.Name = 'New Booking' + ' - ' + system.today() + '.pdf';
            if(!Test.isRunningTest()) {
                att.Body = pdf.getContentAsPDF();
            }else{
                att.Body = Blob.valueOf('Unit Test Attachment Body');
            }
            att.ParentId = caseId;
            insert att;
        }
    }
    
    /**
    @TestVisible @future(callout=true)
    private static void attachPdf(string bookingId, string caseId){
        PageReference pdf = new PageReference('/apex/NewBookingPDFCC?oId='+bookingId);
        Attachment att = new Attachment();
        att.Name = 'New Booking' + ' - ' + system.today() + '.pdf';
        if(!Test.isRunningTest()) {
            att.Body = pdf.getContentAsPDF();
        }else{
            att.Body = Blob.valueOf('Unit Test Attachment Body');
        }
        att.ParentId = caseId;
        insert att;
    }**/
    /**
    public boolean validateStartEndDates(){
        if(oliStartDates.size()>0) {
            oliStartDates.sort();
            o.EffectiveDate = oliStartDates[0];
        }
        if(oliEndDates.size()>0) {
            oliEndDates.sort();
            o.EndDate = oliEndDates[oliEndDates.size()-1];
        }else{
            o.EndDate = o.EffectiveDate;
        }
        
        return o.EffectiveDate>o.EndDate;
    }
    **/
    @TestVisible
    private void saveBookingItem(){
        
        Decimal t = 0.00;
        
        for(ObjectWrapper ooo: ObjectList) {
            if(ooo.obj.Quantity__c > 0){
                t += ooo.obj.Quantity__c*ooo.obj.Unit_Price__c;
            }else{
                t += ooo.obj.Unit_Price__c;
            }
            
        }
        
        o.SFCC_Order_Total__c = t;
        system.debug('@@@@@@@@@@@@@@@@@@@@' + o.SFCC_Order_Total__c);
        //o.SFCC_Order_Total_Tax__c = totalTax; jed 11/20/2020
        if(o.SFCC_Order_Total__c > 0) {
            o.SFCC_Order_Total_Gross_Price__c = o.SFCC_Order_Total__c + o.SFCC_Order_Total_Tax__c;
        }else{
            o.SFCC_Order_Total_Gross_Price__c = o.SFCC_Order_Total__c;
        }
        
        //if(o.Status__c == 'Invoiced') {
            //cse.Reason = 'Closed Confirmed';
        //}
        if(o.EffectiveDate == null) {
            o.EffectiveDate = date.today();
            o.Booked_Date__c = system.now(); //v1.2
        }
        
        o.service_start_date__c = startDate;
        o.service_end_date__c = endDate;
        
        List<Order_Line_Item__c> oliRemoveListFinal = new List<Order_Line_Item__c>();
        List<Order_Traveller__c> trRemoveListFinal = new List<Order_Traveller__c>();
        oliRemoveListFinal.addAll(oliRemoveList);
        trRemoveListFinal.addAll(trRemoveList);
        if(oliRemoveListFinal.size()>0) {
            delete oliRemoveListFinal;
        }
        if(trRemoveListFinal.size()>0) {
            delete trRemoveListFinal;
        }
        o.SFCC_Brand__c = this.cse.Org_Business_Unit_dropdown__c;
        upsert o;
        
        cse.Order_Total__c = o.SFCC_Order_Total__c; 
        cse.Order__c = o.Id;
        update cse;
        
    }
    
    map<Order_Line_Item__c,List<Order_Traveller__c> > oliTravellerInsertMap = new map<Order_Line_Item__c,List<Order_Traveller__c> >();
    @TestVisible private void saveOli(){
        oliList = new List<Order_Line_Item__c>();
        for(ObjectWrapper oPr: ObjectList) {
            oPr.obj.Order__c = o.Id;
            oliList.add(oPr.obj);
        }
        upsert oliList;
    }
    @TestVisible private void saveTravellers(){
        
        trList = new List<Order_Traveller__c>();
        for(ObjectWrapper oPr: ObjectList) {
            for(ObjectWrapperTr oTr: oPr.ObjectWrapperTrList) {
                oTr.objTr.Order_Line_Item__c = oPr.obj.Id;
                oTr.objTr.Name = oTr.objTr.Org_First_Name__c + ' ' + oTr.objTr.Org_last_name__c;
                trList.add(oTr.objTr);
            }
        }
        upsert trList;
    }
    @TestVisible private void saveAttachments(){
        attList = new List<Attachment>();
        Set<Attachment> clearExistingAtts = new Set<Attachment>();
        for(ObjectWrapper oPr: ObjectList) {
            Attachment tempAtt = new Attachment();
            tempAtt = oPr.att;
            if(tempAtt.ParentId == null || tempAtt.Id == null) {
                tempAtt.ParentId = oPr.obj.Id;
                if(oPr.isCSD && tempAtt.Body != null) {
                    clearExistingAtts.addAll([select id from attachment where parentid =: oPr.obj.Id]);
                    attList.add(tempAtt);
                    
                }
                
            }
        }
        
        if(attList.size()>0) {
            List<Attachment> attFinal = new List<Attachment>();
            attFinal.addAll(clearExistingAtts);
            delete attFinal;
            insert attList;
        }
        
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