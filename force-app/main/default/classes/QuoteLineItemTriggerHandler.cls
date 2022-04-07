public class QuoteLineItemTriggerHandler {
    
    // this method will be used to create a quote product records
    // Quote products are stored for reporting purpose
    // this object will be storing the data from both platforms
    // From Salesforce's or dnata's Quote page and data from Derwent db
    // 
    public static void insertQuoteProduct(List<Quote_Line_Item__c> lstItems){
        List<Quote_Product__c> lstProdsToInsert = new List<Quote_Product__c>();
        List<Quote_Product_Segment__c> lstProdSegmentsToInsert = new List<Quote_Product_Segment__c>();
        
        
        //iterate over all the line items
        //based on the line item type, prepare a list of Quote product
        for(Quote_Line_Item__c qli : lstItems){
            
            if(qli.Type__c == 'Hotel' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Establishment__c = qli.Hotel_Name__c;
                qp.Check_In_Date__c = qli.Check_In__c;
                qp.Check_Out_Date__c = qli.Check_Out__c;
                qp.Type__c = 'Hotel';
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quote__c = qli.Quote_Reference__c;
                lstProdsToInsert.add(qp);
            } else if(qli.Type__c == 'Flight' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Flight';
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                lstProdsToInsert.add(qp);
                
            } else if(qli.Other_Service_Type__c == 'Transfer' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Transfer';
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'Airport Parking' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Airport Parking';
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'Car Hire' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null) {
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Car Hire';
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'Marhaba' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Marhaba';
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'Bundle' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Bundle';//
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'AdHoc' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'AdHoc';//AdHoc
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            } else if(qli.Other_Service_Type__c == 'Other' && qli.Type__c == 'Other Services' && qli.Product_Id__c == null){
                Quote_Product__c qp = new Quote_Product__c();
                qp.Type__c = 'Other';//AdHoc
                qp.Quote_Line_Item__c = qli.Id;
                qp.Quoted_Cost__c = qli.dtme_price__c;
                qp.Quote__c = qli.Quote_Reference__c;
                qp.Title__c = qli.Other_Service_Type__c;
                
                lstProdsToInsert.add(qp);
            }
        }
        
        //once the list is prepared, insert the quote products
        //
        //Note: For Flight products we have Segments as a option 
        //so once we insert quote products, we have to insert Quote Product Segment
        
        if(!lstProdsToInsert.isEmpty()){
            Database.SaveResult[] sr = Database.insert(lstProdsToInsert);
            system.debug(sr);
            
            //preparing a map to maintain key values of Quote Line Items
            
            Map<String, Quote_Line_Item__c> mapQuoteLineItemWithId = new Map<String, Quote_Line_Item__c>();
            for(Quote_Line_Item__c qli : lstItems){
                mapQuoteLineItemWithId.put(qli.Id, qli);
            }
            
            //iterate over the quote products
            //if it is of type Flight, then create Quote Product Segment record for that record.
            for(Quote_Product__c qp : lstProdsToInsert){
                if(qp.Type__c == 'Flight'){
                    Quote_Product_Segment__c qps = new Quote_Product_Segment__c();
                    Quote_Line_Item__c item = mapQuoteLineItemWithId.get(qp.Quote_Line_Item__c);
                    qps.Carrier_Name__c = item.Airline__c;
                    qps.Flight_Number__c = item.Flight_No__c;
                    qps.Departure_Date__c = item.Departure_Date_Time__c;
                    qps.Arrival_Date__c = item.Arrival_Date_Time__c;
                    qps.Departure_Airport_Title__c = item.From_Airport__c;
                    qps.Destination_Airport_Title__c = item.To_Airport__c;
                  //  qps.Quote_Product__c = qp.Id;
                    qps.Quote_Line_Item__c = item.Id;
                    
                    lstProdSegmentsToInsert.add(qps);
                    
                }
            }
            
            if(!lstProdSegmentsToInsert.isEmpty()){
                insert lstProdSegmentsToInsert;
            }
        }
    }
}