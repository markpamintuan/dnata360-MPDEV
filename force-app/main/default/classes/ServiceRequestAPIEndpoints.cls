/**************************************************************************************************
* Name               : ServiceRequestAPIEndpoints 
* Description        : This is the endpoint class for the integration with the website and Service Requests     
* Created Date       : 13-jun-2019                                                                 
* Created By         : Keith Rogers                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE            COMMENTS                
* v1.0        Keith         18-Feb-2020     Added filters
* v1.1        keith         17-Mar-2020     Check if the bookings exist if not create request log to get the booking      
**************************************************************************************************/
@RestResource(urlMapping='/service-requests/*')
global class ServiceRequestAPIEndpoints {
	global static Id trpServiceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();               
    
    @HttpGet
    global static List<WebsiteDataStructure.ServiceRequest> getServiceRequests() {
        RestRequest request = RestContext.request;
        List<WebsiteDataStructure.ServiceRequest> lDataStructureResponse = new List<WebsiteDataStructure.ServiceRequest>();
        Map<String, Booking__c >  existingBookings = new Map<String, Booking__c >();//v1.1
        List<Case> lCases = new List<Case>();
        List<String> DerwentBookingsTobeCreated = new List<String>();
        List<String> lDerwentBookingIds = new List<String>();
        String caseNumberWithoutZeros = '';
        String caseNumberWithZeros = '';
        
        if(request.params.get('booking-ids') != null){        	
	    	lDerwentBookingIds = request.params.get('booking-ids').split(',',0); 
        }
        //v1.1
        for(Booking__c bk : [Select Id,Booking_ID__c,Org_Brand__c from Booking__c where Org_Brand__c = 'trp' and Booking_ID__c IN:lDerwentBookingIds]){
            existingBookings.put(bk.Booking_ID__c,bk);
        }
        system.debug(existingBookings);
        for(String str : lDerwentBookingIds){
            if(!existingBookings.containsKey(str)){
                DerwentBookingsTobeCreated.add(str);
            }
        }
            createRequestlogforNewDerwentBookingIds(DerwentBookingsTobeCreated);
        //end of v1.1
	    if(request.params.get('case-number') != null){
	    	caseNumberWithoutZeros = request.params.get('case-number');
            system.debug('### caseNumberWithoutZeros: ' + caseNumberWithoutZeros);
	    	caseNumberWithZeros = addZerosToCaseNumber(caseNumberWithoutZeros);
            system.debug('### caseNumber WITH ZEROs: ' + caseNumberWithZeros);
	    }

    	lCases =  [ SELECT 	Id,CaseNumber,
				           	Org_Booking_Id__c,
				           	Subject,
				           	Status,
				           	RecordTypeId,
				           	Receive_Text_Messages__c,
				               (Select Name,
				                Message__c,
				                Created_By_Customer__c,
				                Response_Required__c,
				                Agent_Name__c,
				                CreatedDate
				                FROM CustomerCommunications__r
				                WHERE Status__c ='Sent' 
                                OR Status__c ='Incoming'
                               	OR Status__c ='Pending') //v1.0
				    FROM Case 
				    WHERE (CaseNumber =: caseNumberWithZeros OR Org_Booking_Id__c IN :existingBookings.KeySet())
				    AND Org_Booking_Id__c != NULL
				    AND RecordTypeId = :trpServiceRequestRecordTypeId 
				    AND Is_Public__c = true];
        System.debug('lcases' + lCases);            
        parseCasesAndCustomerCommsToJSONFormat(lCases, lDataStructureResponse);
		return lDataStructureResponse;
	}
	
    
    //Check to see if there is a better way to do this. The case can be created wiht more than 8 digits.
	private static String addZerosToCaseNumber(String caseNumberWithoutZeros){
        String caseNumberWithZeros = '';
        for(integer i=0; i<8-caseNumberWithoutZeros.length(); i++){ 
            caseNumberWithZeros += '0';
        }
        caseNumberWithZeros += caseNumberWithoutZeros;
        system.debug('### addZerosToCaseNumber caseNumberWithoutZeros: ' + caseNumberWithZeros);
        return caseNumberWithZeros;
	}

    @HttpPost
    global static WebsiteDataStructure.CaseIdResponse createServiceRequests(){
        RestRequest request = RestContext.request;
        String requestbody = request.requestBody.toString();  
        String caseNumberWithoutZeros = '';
        String caseNumberWithZeros = '';   
        String salesforceCaseId = '';
        String uri = request.requestURI;  

        //Need to know if it was create via autocancellation. This is to set the cancellation status on Case.
       	if(uri.contains('/customer-communications')){
            WebsiteDataStructure.CustomerCommunicationCreationParams customerCom = (WebsiteDataStructure.CustomerCommunicationCreationParams)JSON.deserialize(requestbody, WebsiteDataStructure.CustomerCommunicationCreationParams.class);
       		caseNumberWithoutZeros =  uri.substringBetween('service-requests/', '/customer-communications');
       		caseNumberWithZeros = addZerosToCaseNumber(caseNumberWithoutZeros);
            Case cse = new Case(); 
            cse = getCaseDetails(caseNumberWithZeros);
            salesforceCaseId = cse.Id;
            System.debug('Case Id #####'+salesforceCaseId);
            System.debug('Case Id #####'+cse.Id);
       		createCustomerCommunication(cse.Id, false, customercom.Text, true);
       	}else{
            WebsiteDataStructure.CreateServiceRequestParams caseParams = (WebsiteDataStructure.CreateServiceRequestParams)JSON.deserialize(requestbody,WebsiteDataStructure.CreateServiceRequestParams.class);
       		Case cse =  new Case();  
            system.debug('### Entering creating case: ' + cse);
            cse = createServiceRequest(caseParams);
            system.debug('### Case created with cse: ' + cse);
            
            if(cse.Category_Group__c != 'Autocancel'){ //Do not send a message if it is an autocancellation request.
            	createCustomerCommunication(cse.Id, false,caseParams.Text, true);  
            }        	
            
            String autoResponseMessage = 'Hi '+cse.Account.FirstName+' \n Thanks for getting in touch. ' + '\n We’ve received your service request and we’ll get back to you within the next 2 days. ' + '\n Your Travel Republic Customer Service Team';
            createCustomerCommunication(cse.Id, true, autoResponseMessage , false);
            
       		caseNumberWithoutZeros = removeLeadingZerosFromCaseNumber(cse.CaseNumber);
            
            salesforceCaseId = cse.Id;
            System.debug('Case Id #####'+salesforceCaseId);
            System.debug('Case Id #####'+cse.Id);
       	}
        return new WebsiteDataStructure.CaseIdResponse(caseNumberWithoutZeros,salesforceCaseId); 
    }

    private static Booking__c queryBooking(WebsiteDataStructure.CreateServiceRequestParams caseParams){
        Id bookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();               
  
        Booking__c book = [Select Id,Org_Account_Name__c,Org_Person_Account_Contact_Id__c,Booking_ID__c,RecordTypeId 
                    from Booking__c 
                    where Booking_ID__c =: caseParams.BookingId 
                    AND RecordTypeId =:bookingItemRecordTypeId 
                    LIMIT 1]; 
        return book;
    }
	
    private static Case getCaseDetails(String caseNumberWithZeros){
		Case cse = new Case();
        cse = [Select Id,caseNumber,Account.FirstName, Category_Group__c from case where caseNumber=: caseNumberWithZeros limit 1]; 
        return cse;
    }
    
    private static Case createServiceRequest(WebsiteDataStructure.CreateServiceRequestParams caseparams){
     
       	Booking__c bookingItem = new Booking__c();
       	bookingItem = queryBooking(caseParams);
       	Decimal categoryId = Decimal.valueOf(caseparams.CategoryId);

       	Travel_Republic_Category__mdt category  = [	SELECT 	Category_Group__c, 
       														Category_Id__c, 
                                                            Category_Text__c, 
                                                            Product_Types__c
                                                    FROM Travel_Republic_Category__mdt
                                                    WHERE Category_Id__c =: categoryId
                                                    LIMIT 1];
        system.debug('Receive Text Messages' + caseparams.ReceiveTextAlert);
       	Case cse = new Case(
            subject=caseparams.Subject,
            RecordTypeId = trpServiceRequestRecordTypeId, 
            AccountId = bookingItem.Org_Account_Name__c,
            ContactId = bookingItem.Org_Person_Account_Contact_Id__c,
            Origin = 'Web',
            CategoryId__c = categoryId,
            Category_Group__c = category.Category_Group__c,
            Description = caseparams.Text,
            Auto_Cancellation_Status__c = category.Category_Group__c == 'Autocancel' ? 'In Progress': '',
            Category__c=category.Category_Text__c, 
            Org_Case_Status__c = 'New',
            TRP_Created_through_Website_Integration__c = true, //Added as a part of v1.1
            Is_Public__c = true,
            Org_Booking__c = bookingItem.id,
            Receive_Text_Messages__c = caseparams.ReceiveTextAlert
        ); 
        system.debug('### Before insert case: ' + cse);
        insert cse;
        case cs = [Select caseNumber,Account.FirstName, Category_Group__c from case where id=: cse.id limit 1]; 
       	return cs;
    }

    private static void createCustomerCommunication(String caseId, Boolean isAutoresponse, String message, Boolean createdByCustomer){
        	Customer_Communication__c customercomNew = new Customer_Communication__c();
            customercomNew.Service_Request__c = caseId;
        	customercomNew.Is_Autoresponse__c = isAutoresponse;
            customercomNew.Message__c = message;
            customercomNew.Created_By_Customer__c = createdByCustomer;
        	if(createdByCustomer)
                customercomNew.Status__c = 'Incoming';
        	else
        		customercomNew.Status__c ='Pending';
            insert customercomNew;
    }

    private static String removeLeadingZerosFromCaseNumber(String caseNumberWithZeros){
        String caseNumberWithoutLeadingZeros = '';
        while(caseNumberWithZeros.startsWith('0')){
        	caseNumberWithZeros = caseNumberWithZeros.removeStart('0');
        	caseNumberWithoutLeadingZeros = caseNumberWithZeros;
        }
        return caseNumberWithoutLeadingZeros;
	}

    private static void parseCasesAndCustomerCommsToJSONFormat(List<Case> lCases, List<WebsiteDataStructure.ServiceRequest> lDataStructureResponse){
        for(Case cse: lCases){
            List<WebsiteDataStructure.Note> Notes = new List<WebsiteDataStructure.Note>();
            for(Customer_Communication__c custComm: cse.CustomerCommunications__r){
                Notes.add(new WebsiteDataStructure.Note(custComm)); 
            }
            lDataStructureResponse.add(new WebsiteDataStructure.ServiceRequest(cse, Notes));
        } 
    }

    //This will be for the success or failure of the autocancel
    @HttpPatch
    global static WebsiteDataStructure.CaseIdResponse updateServiceRequest(){
        RestRequest request = RestContext.request;
        String requestbody = request.requestBody.toString();  
        String caseNumberWithoutZeros = '';
        String caseNumberWithZeros = ''; 
        String salesforceCaseId = '';
        String uri = request.requestURI;  
        caseNumberWithoutZeros =  uri.substringBetween('service-requests/', '/auto-cancel');
        caseNumberWithZeros = addZerosToCaseNumber(caseNumberWithoutZeros);
        Integer countMessagesFromCustomer = 0;
        WebsiteDataStructure.AutoCancellation cancellation = (WebsiteDataStructure.AutoCancellation)JSON.deserialize(requestbody, WebsiteDataStructure.AutoCancellation.class);
        Boolean successCancellation = cancellation.Success;
		system.debug('##### successCancellation: ' + successCancellation);
        
        Case cse = new Case();
        cse = [SELECT  id,
                        Status,
                        CaseNumber,
                        Account.FirstName,
                        Org_Case_Status__c,
                        Auto_Cancellation_Status__c,
                            (Select Name,
                                Message__c,
                                Created_By_Customer__c,
                                Response_Required__c,
                                Agent_Name__c,
                                CreatedDate
                            FROM CustomerCommunications__r
                            WHERE (Status__c ='Sent' OR Status__c = 'Incoming' OR Status__c ='Pending')
                            AND Is_Autoresponse__c = FALSE
                            AND Created_By_Customer__c = TRUE) 
                FROM Case 
                WHERE CaseNumber = :caseNumberWithZeros 
                LIMIT 1];
        
        if(cse != null){
            List<Customer_Communication__c> lCustComms = new List<Customer_Communication__c>();
            lCustComms = cse.CustomerCommunications__r;
            countMessagesFromCustomer = lCustComms.size();
        } 

        if(successCancellation){
            cse.Auto_Cancellation_Status__c = 'Success';
            if(countMessagesFromCustomer < 1){ //checking to see if there is any manual message from the customer
                cse.Org_Case_Status__c = 'Closed';
                update cse;
                String successAutoMessage = 'Hi '+cse.Account.FirstName+' \n We are pleased to announce that your cancellation request has been succesfully completed. ' + '\n Thank you.' + '\n Your Travel Republic Customer Service Team';
                createCustomerCommunication(cse.Id, true, successAutoMessage, false);
        		caseNumberWithoutZeros = removeLeadingZerosFromCaseNumber(cse.CaseNumber);

            }else{
                cse.Org_Case_Status__c = 'In Progress';
               	update cse;
                //Add chatter message to agent here
                createChatterPostOnParentCaseTR(cse);
        		caseNumberWithoutZeros = removeLeadingZerosFromCaseNumber(cse.CaseNumber);
                salesforceCaseId = cse.Id;
				return new WebsiteDataStructure.CaseIdResponse(caseNumberWithoutZeros,salesforceCaseId);
            }
        }else{
            // If there is a message the status should go back to in progress. Otherwise it remains new
            System.debug('### countMessagesFromCustomer: ' + countMessagesFromCustomer);
            System.debug('### successCancellation: ' + successCancellation);
            if(countMessagesFromCustomer > 0) cse.Org_Case_Status__c = 'In Progress';  
            
            cse.Auto_Cancellation_Status__c = 'Failure';
            update cse;
            //Post chatter message to agent here.
            createChatterPostOnParentCaseTR(cse);
        } 
        caseNumberWithoutZeros = removeLeadingZerosFromCaseNumber(cse.CaseNumber);
        salesforceCaseId = cse.Id;
		return new WebsiteDataStructure.CaseIdResponse(caseNumberWithoutZeros,salesforceCaseId);
    }
    
    private static void createChatterPostOnParentCaseTR(Case caseRec){
        try{
            //New code update to tag case owner 
            Case parentCase = [Select OwnerId,Id,Closing_Comments__c,caseNumber from Case where Id=:caseRec.Id];
            if(string.valueof(parentCase.OwnerId).startsWith('005')){
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                messageBodyInput.messageSegments.add(textSegmentInput);
                textSegmentInput.text = 'Hi ';
                system.debug('Owner Id '+parentCase.OwnerId);
				mentionSegmentInput.id = parentCase.OwnerId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                textSegmentInput = new ConnectApi.TextSegmentInput();
                if(caseRec.Auto_Cancellation_Status__c == 'Failure')
                    textSegmentInput.text = '\n The auto cancellation process for this booking has failed. It will need to be cancelled manually.';
                else if(caseRec.Auto_Cancellation_Status__c == 'Success')
                    textSegmentInput.text = '\n The auto cancellation process for this booking is succesful.';
                messageBodyInput.messageSegments.add(textSegmentInput);
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = caseRec.Id;
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                system.debug('textSegmentInput'+textSegmentInput);
                
        }
            else{
                FeedItem post = new FeedItem();
                post.ParentId = parentCase.Id; 
                if(caseRec.Auto_Cancellation_Status__c == 'Failure')
                	post.Body = '\n The auto cancellation process for this booking has failed. It will need to be cancelled manually.';
                else
                    post.Body = '\n The auto cancellation process for this booking is succesful.';
                insert post;
            }
        }
        catch(Exception e){
            system.debug('Exception '+e);
        }
    }
    
    //v1.1
    private static void createRequestlogforNewDerwentBookingIds(List<String > existingBookings){
        //Map< Id, Booking__c >  existingBookings = [Select Id,Booking_ID__c,Org_Brand__c from Booking__c where Org_Brand__c = 'trp' and Booking_ID__c IN:newDerwentBookingIds];
        List<Request_Log__c> reqlist = new List<Request_Log__c>();
        for(String lbooking : existingBookings){
            Request_Log__c reqLog = new Request_Log__c();
                reqLog.Entity__c = 'Booking';
                reqLog.Entity_id__c = lbooking;
                reqLog.Status__c = 'New';
                //reqLog.Is_Synchronous__c = true;
                reqlist.add(reqLog);
            
        }

        try{
            if(reqlist.size() > 0)
                insert reqlist;
        }

        catch(Exception ex){
            system.debug('Exception e >>>> '+ex + 'at Line Number >>>>> '+ex.getLineNumber());
        }
    }

}