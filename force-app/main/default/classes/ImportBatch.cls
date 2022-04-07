global without sharing class ImportBatch implements Database.Batchable<string>, Database.Stateful{
    
    global final blob dataDocuments;
    global Integer countRows;
    global Bulk_Case_Job__c bcp;
    
    global ImportBatch (blob data,Bulk_Case_Job__c bcptemp){
        this.dataDocuments=data;
        this.bcp = bcptemp;
       
        countRows = 0;
    }
    
    @AuraEnabled
    public static List<String> checkBookingIdList(List<String> BookingIdList) {
    	
        List<Booking__c> bookings = [Select id,Booking_ID__c from Booking__c where Booking_ID__c IN :BookingIdList];
       
        //Check for no bookings
        Map<String,String> BookingIdToId = new Map<String,String>();
        List<String> noBookingIds = new List<String>();
        for(Booking__c book: bookings){
            BookingIdToId.put(book.Booking_ID__c, book.Id);
        }
        
        for(String tempbookingids:BookingIdList){
            if(!BookingIdToId.containsKey(tempbookingids)){
                noBookingIds.add(tempbookingids);
            }
        }
        
        System.debug(noBookingIds);
        if(noBookingIds.size() != 0){
            return noBookingIds;
        }else{
           return null;
        }
    }
    
    
    global Iterable<string>  start(Database.BatchableContext BC){
        string nameFile=this.dataDocuments.toString();       
        System.debug('nameFile ::: '+nameFile);
        return new CSVIterator(this.dataDocuments.toString().remove('"'), '\n');
    }
    
    global void execute(Database.BatchableContext BC,List<String> scope){
        System.debug('Listvalue:-> '+scope);
        List<String> BookingIds = new List<String>();
        for(String row: scope){
            countRows = countRows + 1;
            List<String> fields = row.remove('"').split(',');
            BookingIds.add(fields[0]);
            
        }
        BookingIds.remove(0);
        
        Set<String> myset = new Set<String>();
        List<String> finalList = new List<String>();
        myset.addAll(BookingIds);
        BookingIds.clear();
        BookingIds.addAll(mySet); 

        BookingIds.sort();
        List<String> noBookings = checkBookingIdList(BookingIds); 
        if(noBookings != null){
            for(string bookingid: bookingids){
                if(noBookings.contains(bookingid)){
                    
                }else{
                    finalList.add(bookingid);
                }
                
            }
        }else{
            finalList.addAll(bookingids);
        }
        
        System.debug(finalList);
        List<Bulk_Case_Job_Item__c> bcclist = new List<Bulk_Case_Job_Item__c>();
        for(String booking: finalList){
            Bulk_Case_Job_Item__c bcc = new Bulk_Case_Job_Item__c();
            bcc.BookingId__c = booking;
            bcc.Bulk_Case_Job__c = bcp.id;
            bcc.Status__c = 'New';
            bcclist.add(bcc);
        }
        
        insert bcclist;
        
        
        /****** EVENDO. THIS IS WHERE WE INSERT INTO THE CHILD CUSTOM OBJECT *****
         * 
        List<Csv__c> CsvObjectList = new list<Csv__c>();
        for(String row : scope){
            countRows = countRows + 1;
            
            List<String> fields = row .split(',');
            System.debug('fields ::-> '+fields);
            System.debug('fieldsSize ::-> '+fields.size());
            System.debug('countRows ::-> '+countRows);
            
            //Edit from here------------------------------
            Csv__c li=new Csv__c();
            if(fields != null && !fields.isEmpty()){
            li.name =fields[0];
            CsvObjectList.add(li);
            }
        }
        System.debug('CsvObjectList ::-> '+CsvObjectList);
        //Insert CsvObjectList;
        if(CsvObjectList.getSObjectType().getDescribe().isCreateable()){       
            insert CsvObjectList; 
        }
        */
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        System.debug('Finish Method Called.....');
        System.debug('number of Rows : '+countRows);
        
        Database.executeBatch(new MassCSRCreateBatchClasS(bcp.id),10);
        
        // Send an email to the Apex job's submitter notifying of job completion.  
       /* AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Import' + a.Status);
        mail.setHTMLBody('Dear User,  <br/> <br/> Your import has finished. During the porcess there were ' + 
                         + a.NumberOfErrors + ' errors.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
        
    }        
    
}