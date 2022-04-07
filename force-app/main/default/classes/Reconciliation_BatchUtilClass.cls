/**************************************************************************************************
* Name               : Reconciliation_BatchUtilClass 
* Description        : This is the utility class for Reconciliation_Batch       
* Created Date       : 26-Aug-2019                                                                 
* Created By         : Sri Bala                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0		  Sri Bala		26-Aug-2019	   Initial Draft
**************************************************************************************************/
global class Reconciliation_BatchUtilClass {
    global static integer bookingCount = 0;
    global static string Rec_currentPageNumber = '';
    global static string Rec_nextPageNumber = '';
    public static string endurl;
    public static string usrname;
    public static string pwd;
    public static string tenantidstring;
   	public static string getAllBookings(BookingIdResponse deserializeBookings,String currentPageNumber) {
        try{
            	List<Map<String, Object>> bookingsMapList = new List<Map<String, Object>>();
            	List<Booking__c> QueriedBookings = new List<Booking__c>();
				List<String> BookingIdsList = new List<String>();            	
            	String NextPageId  = '';
            	Map<String,Decimal> ExistingBookingsMap = new Map<String,Decimal>();
            	List<Decimal> VersionIdsList = new List<Decimal>();
            	Set<String>  bookingIdstoUpdate = new Set<String>();
            	
            	/***********************************************/
            
                
            	List<BookingIdResponse.cls_Bookings> BookingsList = deserializeBookings.Bookings;
            	system.debug('<<<<Bookings>>>'+BookingsList);
                if(BookingsList.size() > 0){
                    for(BookingIdResponse.cls_Bookings booking : BookingsList){
                        VersionIdsList.add(booking.Version);
                        BookingIdsList.add(booking.BookingId);
                    }
                }
            	NextPageId = deserializeBookings.NextPageId;
				system.debug('<<<Next Page Id>>>>'+deserializeBookings.NextPageId);
            	system.debug('<<<<VersionIdsList>>>>'+VersionIdsList);
            	System.debug('<<<<Booking Id>>>>>'+BookingIdsList);
            	String recId = '';
            	Rec_currentPageNumber = currentPageNumber;
            	Rec_nextPageNumber = NextPageId;           	
                recId = createReconciliation(NextPageId,currentPageNumber);
            	QueriedBookings = [Select Id,Derwent_Version_Number__c,Booking_ID__c from Booking__c where Derwent_Version_Number__c IN:VersionIdsList];
			   	for(Booking__c bkng: QueriedBookings){
			        ExistingBookingsMap.put(bkng.Booking_ID__c,bkng.Derwent_Version_Number__c);
			    }
			    system.debug('<<<Existing Bookings>>>>'+ExistingBookingsMap);
            	for(String bookings : BookingIdsList){
            		if(!ExistingBookingsMap.containsKey(String.valueof(bookings))){
            			system.debug('Entered');
            			system.debug('<<<Version Number>>>'+bookings);
            			bookingIdstoUpdate.add(String.valueof(bookings));
            		}
            	}
            	system.debug('<<<<Queried Booking List Size>>>>>'+QueriedBookings.size());
            	system.debug('<<<< Booking List>>>>>'+QueriedBookings);
            	system.debug('booking to Update'+bookingIdstoUpdate);
            	system.debug('Size of bookings to update'+bookingIdstoUpdate.size());
            	Integer countOfBookings = bookingIdstoUpdate.size();
            	bookingCount = bookingIdstoUpdate.size();
            	createRequestLogforBookings(bookingIdstoUpdate,recId);
            	String updatedReconId = updateReconciliation(bookingIdstoUpdate,recId,countOfBookings);
            	
            	
            	
            	
            	
            }
            catch(Exception ex) {
                System.debug('Callout error: '+ ex + 'Line Number '+ ex.getLineNumber());
            } 
            return 'success';
    }
	public static void createRequestLogforBookings(Set<String> bookingIds,String recId){
		 List<Request_Log__c> requestlogstocreate = new List<Request_Log__c>();
				for(String createbkngs : bookingIds){
			 		Request_Log__c reqlog = new Request_Log__c();
	                reqlog.Entity__c = 'BookingReconciliation';
	                reqlog.Entity_Id__c = createbkngs;
                    reqlog.Reconciliation_Update__c = true;
                    reqLog.Reconciliation_SF_ID__c = recId;
	                requestlogstocreate.add(reqlog);
                    
				}
        		Integer start = System.Now().minute();
				system.debug('<<<Size of Request Logs>>>>'+requestlogstocreate.size());
				if(requestlogstocreate.size()>0){
					try{
							insert requestlogstocreate;
					}
					catch(Exception e){System.debug('<<<Exception>>>'+e);}
					
				}
				
	}
	
	public static string UpdateReconciliation(Set<String> bookingIds,String recId,Integer countOfBookings){
		Reconciliation__c newRec = new Reconciliation__c(Id = recID);
        Reconciliation__c rectocheck = [select status__c from reconciliation__c where id = :recid];
        if(rectocheck.Status__c != 'Completed'){
            newRec.Entity_IDs__c = '';
            for(String bookingId : bookingIds){
                
                newRec.Entity_IDs__c += bookingId +',';
            }
            newRec.Count_of_Records__c = countOfBookings;
            newRec.Status__c = 'Completed';
            update newRec;
           
            system.debug('Reconciliation Record'+newRec);
        }
        return newRec.Id;
	}
    
	public static string createReconciliation(String NextPageId,String currentPageNumber){
		Reconciliation__c newRec = new Reconciliation__c();
		newRec.Status__c = 'Started';
        newRec.Next_Page_Id__c = NextPageId;
        newRec.Actual_Start_Date__c = System.now();
        newRec.Page_Number__c = currentPageNumber;
        newRec.Entity_Type__c = 'Booking'; //Need to change futher for CSR,Quotes,etc..
		insert newRec;
		return newRec.Id;
	}
    public static void getDerwentsetting(String servicename){
        Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c,tenant_id_String__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
        endurl=derwent.Endpoint_URL__c;
        usrname=derwent.Username__c;      
        pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
        tenantidstring = derwent.Tenant_Id_String__c;
        system.debug('***Derwent***'+derwent);
        
        system.debug('***PWD***'+pwd);
        
    }
	
    
    public static string webServiceCallout(String PageNumber){
        getDerwentsetting('Get_Reconciliation_Booking');
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
       	String endpointurl = '';
        String pageId = '5258488060';
        String tenantId = '1';
        system.debug('page Number: '+PageNumber);
        if(PageNumber != ''){
            system.debug('Entered %$$!');
            endpointurl = endurl + '?pageId='+PageNumber+'&'+tenantidstring;
        }
       		 
        else
            endpointurl = endurl + '?pageId='+pageId+'&'+tenantidstring;
        system.debug('<<<<<<End Point URL>>>>>'+endpointurl);
        request.setEndpoint(endpointurl);
        Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setTimeout(60 * 1000);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        BookingIdResponse deserializeBookings = BookingIdResponse.parse(res.getbody());
        string status = Reconciliation_BatchUtilClass.getAllBookings(deserializeBookings,PageNumber);
        System.debug('status ' + status);
        System.debug('<<<<<<<Response>>>>>>'+res.getbody());
        system.debug('<<<<deserializeBookingsMap>>>>>>'+deserializeBookings);
        return deserializeBookings.NextPageId;
    }
   
    
    
    

}