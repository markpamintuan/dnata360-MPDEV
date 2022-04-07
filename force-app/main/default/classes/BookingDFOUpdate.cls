/**************************************************************************************************
* Name               : BookingDFOUpdate 
* Description        : This is the queueable class for linking case to booking based on dfo         
* Created Date       : 24-Feb-2019                                                                 
* Created By         : Sri Bala                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE            COMMENTS                
* v1.0        Sri Bala      24-Feb-2019     Initial version
* v1.1        Sri Bala      13-Oct-2019		Added condition brand is dnata and Booking should be linked only if no booking is linked to the case.
* v1.2        Sri Bala      29-Oct-2019     T-00785 - Link Booking to Case if the PNR Reference Number matches.
*****************************************************************************************************/
public class BookingDFOUpdate implements Queueable  {
    public Map<Id,Booking__c> bookIdList;
    public BookingDFOUpdate(Map<Id,Booking__c> bookIdList)
    {
        this.bookIdList = bookIdList;
    }
    
    
    public void execute(QueueableContext context) {
        List<Booking__c> booklist = new  List<Booking__c>();
        List<String> splitted = new List<String>();
        List<DFoAccount__c> acclist = new List<DFoAccount__c>();
        for(Booking__c book : bookIdList.values())
        {
            for(DFoAccount__c acc :[Select id,Account__c,child_id__c from DFoAccount__c where child_Id__c =: book.Org_External_System_ID__c]) 
            {
                System.debug('Child IDs '+acc.child_id__c);
                system.debug('@@ID'+book.Org_External_System_ID__c);
                Booking__c bk = new booking__c(Id = book.Id);
                bk.Org_Account_Name__c = acc.Account__c;
                booklist.add(bk);
                system.debug('@@Account Name:'+bk.Org_Account_Name__c );
                system.debug('bookIdList'+bookIdList);
                system.debug('@@'+acc.Id);
                
            }
            
        }
        bookIdList.putall(booklist);
        if(bookIdlist.size()>0)
        	update bookIdlist.values();
        system.debug('After DFO update'+booklist);
        List<Booking__c> bookingsToLink = [Select Id,Name,Org_Account_Name__c,Booking_Header__c,RecordTypeId from Booking__c 
                                           where Id IN :bookIdlist.keySet()];
		system.debug('bookingsToLink'+bookingsToLink);
        system.debug('After DFO update'+booklist);
        linkBooktoCase(bookingsToLink);
        
    }
    
    public static void linkBookToCase(List<Booking__c> bookIdList)
    {
        system.debug('entered function');
        List<Case> caseList = new List<Case>([Select Id,dTME_Supplier_Ref__c,Org_Type__c,Org_Booking__c from Case where Org_Type__c='Booking Enquiry' and dTME_Supplier_Ref__c!=null ]);
        system.debug('case list'+caseList);
        List<Case> updatecs = new List<Case>();
        String bookingrecordTypeid = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();        
        for(Booking__c book : bookIdList)
        {
            if(caseList.size()>0){
                for(Case cs:caseList){
                    system.debug('ref'+cs.dTME_Supplier_Ref__c+'bk ref '+book.Name);
                    if(cs.dTME_Supplier_Ref__c == book.Name){ // && cs.AccountId == book.Org_Account_Name__c){ // Commented as a part of v1.2
                        system.debug('## if condition');
                        if(book.RecordTypeId == bookingrecordTypeid){
                            system.debug('Entered');
                        	cs.Org_Booking__c = book.Booking_Header__c; //v1.1
                        }
                        else 
                            cs.Org_Booking__c = book.id; //v1.1
                        system.debug('bk id'+cs.Org_Booking__c);
                        updatecs.add(cs);
                    }
                }
            }
        }
        try{
            system.debug('Before case update'+updatecs);
            if(updatecs.size()>0)
            	update updatecs;
            
        }
        
        catch(Exception e){
            system.debug('Exception '+e + ' Line Number :: '+e.getLineNumber());
        }
       
    }
}