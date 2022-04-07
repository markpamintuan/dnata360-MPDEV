/**************************************************************************************************
* Name               : AsyncDerwentWebService
* Description        : This is the queuable webservice class for Derwent webservice
* Created Date       : 09-May-2018
* Created By         : Kaavya Raghuram
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR        DATE           COMMENTS
* v1.0        Kaavya        08-Aug-2018    Initial version
* v1.1        Kaavya        19-Sep-2018    T-00195: Updated itinerary type for flights
* v1.2        Kaavya        25-Sep-2018    T-00233: Fix for Opt In date
* v1.3        Kaavya        17-Oct-2018    T-00185: Adding customer domain
* v1.4        Kaavya        29-Oct-2018    Added Booking System
* v1.5        Kaavya        27-Nov-2018    T-00303: Link Booking to case based on Supplier Ref
* v1.6        Kaavya        12-Dec-2018    Fix for billing city
* v1.7        Kaavya        27-Dec-2018    Fix for timezone for Booked Date
* v1.8        Sri Bala      26-Feb-2019    Supplier Info
* v1.9        Sri Bala      27-Mar-2019    T-00355 -Manage Booking Notes
* v1.10       Sri Bala      27-Mar-2019    T-00522 - Booking Language
* v1.11       Sri Bala      01-Apr-2019    T-00390 - Updating Domain names for bookings
* v1.12       Evendo        17-Apr-2019    Creation of customer|booking if absent in Insertion of Quote/Booking|Csr
* v1.13       Maruf         29-Apr-2019    Create Service Request Questions and Notes for TRP CSR
* v1.14       Sri Bala      28-May-2019    TR Case CSR Model Change
* v1.15       Sri Bala      21-Jul-2019    Disabling the marketing cloud Sync for TRP accounts
* v1.16       Sri Bala      25-Jul-2019    Upsert Booking only if the version number is greater than its previous value
* v1.17       Sri Bala      29-Jul-2019    Assign the newly created CSR (Service Request ) based on the owner id from derwent for TRP
* v1.18       Kaavya        29-Jul-2019    Fix for Customer Domain
* v1.19       Sri Bala      29-Jul-2019    Map Case Status in Derwent and assign the case status
* v1.20       Sri Bala      01-Aug-2019    Map Category Id to Case Category Id and Next follow up date
* v1.21       Sri Bala      01-Aug-2019    Upsert cases,questions and notes without updating CreatedDate
* v1.22       Keith         07-Aug-2019    Preventing the creation of CSR's with the booking response
* v1.23       Keith         07-Aug-2019    Adding Category Group and default values if derwent categoryid is not found
* v1.24       Sri Bala      18-Aug-2019    Service Request Answer created by customer must be true.
* v1.25       Sri Bala      19-Aug-2019    Check if the queue derwent user id matches with CSR Owner Id and assign the TRP Case to Queue
* v1.27       Keith         20-Aug-2019    Bug fix for null pointer of destination on attraction bookings
* v1.29       Sri Bala      09=Sep-2019    Commented insertion of request for v1.12
* v1.30       Evendo        14-Oct-2019    Added Code to insert derwent id for existingemail on derwent
* v1.31       Sri Bala      16-Oct-2019    Commenting v1.15 as the field  triggering marketing cloud is not marketing consent (Marketing consent field is in sync only with derwent )
* v1.32       Kaavya        05-Dec-2019    Fix for booking type and booking header on case
* v1.33       Kaavya        12-Dec-2019    Addition of Domain Id on Account
* v1.34       Kaavya        23-Dec-2019    Filter case query only for dnata and version query only if label is true
* v1.35       Ravi          26-Jan-2020    Added conditions/logic to reduce the SOQL Count
* v1.35       Ravi          27-Jan-2020    Added Logic for synchronous call

* v1.38       Ravi          29-Jan-2020    Added the logic to get Customer if the email exists in DerWent in customer creation and update the details in SF accordingly
* v1.39       Ravi          10-Feb-2020    Added conditions for null check
* v1.40       Ravi          27-Feb-2020    Added Logic for GDPR
* v1.41       Ravi          03-Mar-2020    Added logic/condition to fix
                                            1. get Customer in Quore creation
                                            2. Cehck for Customer in get Customer if the email exists witht the same brand
                                            3. CSR - Null Pointer & Duplicate Issues
                                            4. Booking Price Breakdown logic to get SupRef

* v1.43       Ravin         17-Mar-2020    Added the logic to populate the Traveller count on booking
* v1.44       PwC			23-Mar-2020    Added logic/fix TRP CSRs
										    1. Uncommented CreatedDate for CSR/Notes/Questions/Answers
											2. Added logic for TRP if CSR and Booking does not exist in SF
											3. Mix/Match logic match
											4. Fix for Category Text on Case (Service Request)
* v1.45		  Mark			13-Aug-2020	   Added lineItem field mappings and calculations on booking item and booking header
**************************************************************************************************/
global class AsyncDerwentWebService implements Queueable, Database.AllowsCallouts {

	public List<id> recordids = new List<id>();
	public string servicetype;
	public string customerid;

	public AsyncDerwentWebService.InPorgressItems PendingItems;

	public static Request_Log__c RequestLog = new Request_Log__c();
	public static Boolean isFromCustomerCreate = false;
	public static list<string> lstEntityIds = new list<string>();

	public static map<string, string> mapAllLookupNames = new map<string, string>();
	public static map<string, string> mapAllLookupCodes = new map<string, string>();

	public static Boolean isFromDerwentCall = false;

	public static string Str_Receipted = 'Receipted';
	public static string Str_ekh = 'ekh';
	public static string Str_trp = 'trp'; //v1.44
	public static map<Integer, set<string> > mapTravellerCategory = new map<integer, set<string> > {
		1 => new set<string> {'Adult','Adult Swimmer','Adult NON Swimmer','Main Driver','Additional Driver','Lead Guest'}, // Adults
		2 => new set<string> {'Child','Child Swimmer','Child Non Swimmer', 'Infant'} // Childs // Infants
	};

	//Defining the constructor
	public AsyncDerwentWebservice (List<Id> rids, string svctype, string custid){
		recordids=rids;
		servicetype=svctype;
		customerid=custid;
	}

	public AsyncDerwentWebservice(){

	}

	//The execute method for the queuable class which contains the callout
	public void execute(QueueableContext context) {
		if(servicetype=='Customer_Create')
			sendCustCreate(recordids,'New');
		if(servicetype=='Customer_Update')
			sendCustCreate(recordids,customerid);
		if(servicetype=='Customer_Upsert')
			getCustomer(recordids);
		if(servicetype=='Booking_Upsert')
			getBooking(recordids);
		if(servicetype=='CSR_Upsert')
			getCSR(recordids);
		if(servicetype=='Quote_Upsert')
			getQuote(recordids);
		

		if(PendingItems != null) {
			resumeItems(PendingItems);
		}
	}
	global static string endurl;
	global static string usrname;
	global static string pwd;


	/**********************Getting the Derwent integration setting*********************************/

	public static void getDerwentsetting(String servicename){
		Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
		endurl=derwent.Endpoint_URL__c;
		usrname=derwent.Username__c;
		pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
		////system.debug('***Derwent***'+derwent);

		//system.debug('***PWD***'+pwd);

	}

	/**********************Preparing the request body for the customer create request*********************************/
	public static string prepareCustCreate(List<id> rids){

		//Querying the customer records
		string CustQuery = getCreatableFieldsSOQL('Account');
		CustQuery+=' where Id in :rids';
		List<Account> Custlist= database.query(CustQuery);

		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where SF_Object__c='Account' order by Order__c asc];

		//Getting all the lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();

		//Getting all the other lookup codes and values
		Map<String,String> alllookupmap= getAllLookupCode();

		//Added as part of v1.3
		//Getting all the lookup codes and values
		Map<String,String> lkpcodemap= getDerwentLookupCode();

		String jsonbody = '';
		//Building the json string
		JSONGenerator gen = JSON.createGenerator(true);
		//gen.writeStartArray();
		for(Account cust:Custlist) {
			string customerBrand = cust.Org_Brand__c.toLowerCase();
			string domainid='';
			domainid=lkpcodemap.get('Customer_Domain__c.'+customerBrand+'.'+cust.Customer_Domain__c); //Added as part of v1.3
			if(domainid=='' || domainid==null)
				domainid=lkpmap.get('Org_Domain__c.'+customerBrand);
			gen.writeStartObject();
			if(domainid!='' && domainid!=null)
				gen.writeStringField('DomainId',domainid);
			for(Derwent_Field_Mapping__mdt DFM:mappings ) {
				String fieldval=String.ValueOf(cust.get(DFM.SF_Field_API_Name__c));

				if(DFM.DataType__c=='OtherLookup') {
					fieldval=alllookupmap.get(DFM.Lookup_Type__c+'.'+cust.get(DFM.SF_Field_API_Name__c));
				}
				/********************** Hard coded to set the value of EmailSignUp in Derwent for trp ******************************
				 *********************CREATED A NEW FIELD TRP_Send_exclusive_discounts_offers__c  NOT TO SYNC WITH MARKETING CLOUD *********************************************/
				//v1.15 start
				/* if(DFM.DataType__c =='Checkbox' && customerBrand == 'trp' && DFM.SF_Field_API_Name__c == 'EKUK_Send_exclusive_discounts_offers__c' ){
				      fieldval = String.valueof(cust.TRP_Send_exclusive_discounts_offers__c);
				   }*/
				//end v1.15 commented as a part of v1.31
				if(fieldval==null)
					fieldval='';
				gen.writeStringField(DFM.JSON_Field__c, fieldval);
			}

			gen.writeEndObject();
		}
		//gen.writeEndArray();

		jsonbody=gen.getAsString();
		//system.debug('jsonMaterials'+jsonbody);


		return jsonbody;

	}
    
  
	/**********************Callout for the customer creation*********************************/

	webservice static void sendCustCreate(List<id> recordids,string custid){

		getDerwentsetting('Register_Customer');
		HTTPRequest req = new HTTPRequest();

		String reqJSON = prepareCustCreate(recordids);
		system.debug('>>>>>Request Body>>>>>>'+ reqJSON);
		system.debug('>>>>>Request URL>>>>>>'+ endurl);
		req.setbody(reqJSON);
		if(custid!='New') {//For customer updates
			endurl = endurl.replace('register',custid);
			req.setMethod('PUT');
		}
		else // For New
			req.setMethod('POST');
		//system.debug('>>>>>Request URL>>>>>>'+ endurl);
		req.setEndpoint(endurl);
		req.setHeader('Content-Type','application/json');
		Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(60 * 1000);
		HTTP http = new HTTP();
		// if(!Test.isrunningTest()){
		try{
			HTTPResponse res = http.send(req);

			system.debug('>>>>>Response>>>>>>'+res.getbody());
			Integer statuscode= res.getStatusCode();
			parseCustCreateResponse(res.getBody(),recordids,statuscode);

		}
		catch(Exception ex) {
			//system.debug('Callout error: '+ ex);
			Request_Log__c objLog = new Request_Log__c();
			objLog.status__c = 'Failed';
			objLog.Error_Log__c ='Ids=='+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice Callout For Customer Creation';
			insert objLog;
		}
		// }
	}

	/**********************Parsing the response received for cust create request*********************************/
	public static void parseCustCreateResponse(string respbody,List<id> recordids,Integer statuscode){

		Id custid = recordids[0];
		String reqstatus='';
		String DerwentStatus,ErrorMsg,DerwentId='';
		// Parse JSON response to get the values.
		JSONParser parser = JSON.createParser(respbody);
		//system.debug('>>>>>JSON Parse>>>>>>'+parser);
		//system.debug('>>>>>Status Code>>>>'+statuscode);
		Boolean emailAlreadyExists = false; //v1.30 - Setting this to true at status 400 and it will only update accounts with brand trp
		while (parser.nextToken() != null) {

			if(statuscode== 200) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CustomerId')) {
					// Get the value.
					parser.nextToken();
					DerwentId= parser.getText();
				}
			}
			if(statuscode== 400) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Errors')) {
					// Get the value.
					parser.nextToken();
					ErrorMsg= parser.getText();
				}
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CustomerId')) { //v1.30
					// Get the value.
					parser.nextToken();
					DerwentId= parser.getText();
					emailAlreadyExists = true;
				}
			}
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Status')) {
				// Get the value.
				parser.nextToken();
				DerwentStatus= parser.getText();
			}
		}

		//update new Account(id=custid,Org_Derwent_Status__c=DerwentStatus,Org_Derwent_Customer_No__c=DerwentId,Org_Derwent_Error_Message__c=ErrorMsg);
		//system.debug('>>>>>Derwent ID>>>>>>'+DerwentId);

		//v1.37 - if emailAlreadyExists is true, do a call to get the Customer Info
		if(emailAlreadyExists) {
			getExistingCustomerEmail(custid, DerwentId);
			return;
		}//end of v1.37

		//Account acc= new Account(id=custid);
		Account acc = [Select id,org_brand__c,Re_Push__c from Account where id = :custid];
		Account objAccUpdate = new Account(Id=acc.Id);
		//system.debug('account brand : ' + acc.org_Brand__c);
		if(DerwentId!=null && DerwentId!='' && statusCode == 200) {
			objAccUpdate.Org_Derwent_Customer_No__c=DerwentId;
		}
		objAccUpdate.Org_Derwent_Error_Message__c=ErrorMsg;
		objAccUpdate.Org_Derwent_Status__c=DerwentStatus;

		if(statusCode == 400 && emailAlreadyExists == true && acc.Org_Brand__c == 'trp') {
			objAccUpdate.Org_Derwent_Status__c='Success';
			objAccUpdate.Org_Derwent_Customer_No__c=DerwentId;
		}
		if(objAccUpdate.Org_Derwent_Status__c == 'Success') {
			objAccUpdate.Re_Push__c = false;
		}
		objAccUpdate.Updated_from_Derwent__c=system.now(); //Added on Nov 28 to prevent too many queueable jobs error
		update objAccUpdate;
		//database.update(acc);

	}

	//v1.37
	public static void getExistingCustomerEmail(string AccountId, string derWentId){
		isFromCustomerCreate = true;
		lstEntityIds.add(AccountId);
		doCustomerCall(new list<string> {derWentId});
	}

	/**********************Preparing the request parameters for the get customer request*********************************/
	public static string prepareGetCustomer(List<id> rids){

		//Querying the customer records
		string ReqQuery = getCreatableFieldsSOQL('Request_Log__c');
		string entity='Customer';
		ReqQuery+=' where Entity__c = \'' + entity+ '\'  AND Id in :rids';
		List<Request_Log__c> Custlist= database.query(ReqQuery);
		Map<String,Request_Log__c> custmap = new Map<String,Request_Log__c>();
		List<Request_Log__c> GetCustlist= new List<Request_Log__c>();
		for(Request_Log__c RL :Custlist) {
			if(!custmap.containskey(RL.Entity_Id__c)) {
				custmap.put(RL.Entity_Id__c,RL);
				GetCustlist.add(RL);
			}
		}

		String reqparams = '';

		for(integer i=1; i<=GetCustlist.size(); i++) {
			reqparams+= 'customerIds='+Getcustlist[i-1].Entity_Id__c;
			if(i!=GetCustlist.size())
				reqparams+= '&';
		}
		//system.debug('>>>>>Request Parameters>>>>>>'+reqparams);
		return reqparams;

	}
	/**********************Callout for getting customer details*********************************/

	webservice static void getCustomer(List<id> recordids){

		getDerwentsetting('Get_Customer');
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');

		String reqparams = prepareGetCustomer(recordids);
		String endpointurl = endurl+ reqparams;
		//system.debug('>>>>>Request >>>>>>'+ endpointurl);
		//req.setbody(reqJSON);
		req.setEndpoint(endpointurl);
		Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(60 * 1000);
		HTTP http = new HTTP();
		//if(!Test.isrunningTest()){
		try{
			HTTPResponse res = http.send(req);

			//system.debug('>>>>>Response>>>>>>'+res.getbody());

			parseGetCustResponse(res.getBody(),recordids);

		}
		catch(Exception ex) {
			//system.debug('Callout error: '+ ex);
			Request_Log__c objLog = new Request_Log__c (id=recordids[0]);
			objLog.Error_Log__c ='Ids=='+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice batch error For GetCustomer';
			objLog.Entity__c='Customer';
			objLog.Status__c='Failed';
			objLog.Is_Synchronous__c = !( system.isBatch() || system.isFuture() || system.isQueueable() || system.isScheduled() );
			update objLog;
		}
		// }
	}

	/**********************Parsing the response received for Get Customer request*********************************/
	public static void parseGetCustResponse(string respbody,List<id> recordids){

		String reqstatus='';
		String DerwentStatus,DerwentId='';
		List<Account> acclist = new List<Account>();
		//Getting all the lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();

		//Getting all the other lookup codes and values
		Map<String,String> alllookupmap= getAllLookupvalue();
		List<Derwent_Field_Mapping__mdt> Accountmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> prefrencemappings = new List<Derwent_Field_Mapping__mdt>();
		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where SF_Object__c='Account' order by Order__c];

		//Parsing the response of the getcustomer request
		CustomerResponse getCustresp= CustomerResponse.parse(respbody);
		//system.debug('>>>>>CustomerResponse>>>>>>'+getCustresp);

		//v1.37
		list<string> lstDerwentIds = new list<string>();
		set<string> lstAccountFields = new set<string>();
		map<string, string> mapCustomerEmails = new map<string, string>();
		List<Account> lstAccountsToUpdate = new List<Account>();

		for(Derwent_Field_Mapping__mdt DFM :mappings) {
			if(DFM.Module__c=='AccountEmaPreference') {
				prefrencemappings.add(DFM);
			}
			else{
				Accountmappings.add(DFM);
			}
			if(DFM.SF_Field_API_Name__c != null)
				lstAccountFields.add(DFM.SF_Field_API_Name__c.toLowerCase());
		}


		List<CustomerResponse.Customers> Custlist =getCustresp.Customers;
		if(Custlist != null && Custlist.size()>0) {
			for(CustomerResponse.Customers cust:Custlist) {
				Account acc = new Account();
				//system.debug('<<<TenantID>>>'+cust.TenantId);
				//Getting the brand of the customer
				String brand= lkpmap.get('Org_Brand__c'+'.'+cust.TenantId);
				acc.Org_Brand__c=brand;
				//system.debug('<<<BRand>>>'+brand);

				//Added as part of v1.3
				//system.debug('<<<DomainID>>>'+cust.LastRegisteredOnDomainId);
				acc.Domain_Id__c=cust.LastRegisteredOnDomainId; //Added as part of v1.33
				String domain = lkpmap.get('Customer_Domain__c'+'.'+cust.LastRegisteredOnDomainId);
				acc.Customer_Domain__c=domain;
				//system.debug('<<<Domain>>>'+domain);

				//Getting the record types of the account for the brand
				Person_Account_Record_Types__c par = Person_Account_Record_Types__c.getValues(brand);
				acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(par.Record_Type_Name__c).getRecordTypeId();

				if(cust.EmailSignup==true) { //If condition Added as part of v1.2
					if(cust.CommunicationPreferenceDetails != null) {

						for(CustomerResponse.CommunicationPreferenceDetails cu:cust.CommunicationPreferenceDetails ) {

							if(cu.CommunicationChannel == 'Email') {

								Map<String, Object> custPrefmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize( cu ));

								for(Derwent_Field_Mapping__mdt DFM :prefrencemappings) {
									string fieldval=string.valueof(custPrefmap.get(DFM.JSON_Field__c));

									if(fieldval!=null) {
										if(DFM.DataType__c=='DateTime') {
											acc.put(DFM.SF_Field_API_Name__c, formatDatetimeGMT(fieldval));
										}
										else{
											acc.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}

								}
							}
						}
					}
				}

				Map<String, Object> custmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize( cust ));
				for(Derwent_Field_Mapping__mdt DFM :Accountmappings) {
					string fieldval=string.valueof(custmap.get(DFM.JSON_Field__c));

					if(fieldval!=null) {
						if(DFM.DataType__c=='DateTime') {
							acc.put(DFM.SF_Field_API_Name__c, formatDatetimeGMT(fieldval));
						}
						else if(DFM.DataType__c=='Lookup') {
							acc.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
						}
						else if(DFM.DataType__c=='Checkbox') {
							Boolean boolval=false;
							if(fieldval=='true')
								boolval=true;
							//Added as a part of v1.15
							/*if(brand == 'trp' && DFM.SF_Field_API_Name__c == 'EKUK_Send_exclusive_discounts_offers__c')
							    acc.TRP_Send_exclusive_discounts_offers__c = Boolean.valueof(fieldval);
							   else     //ended as a part of v1.15 commented as a part of v1.31*/
							acc.put(DFM.SF_Field_API_Name__c,boolval);
						}
						else if(DFM.DataType__c=='OtherLookup') {
							acc.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
						}
						else
							acc.put(DFM.SF_Field_API_Name__c,fieldval);
					}
				}
				if(acc.LastName==null || acc.LastName=='' || string.isBlank(acc.lastName))
					acc.LastName='-';
				if(!string.isBlank(acc.FirstName) && acc.LastName == '-' ) {
					acc.LastName = acc.FirstName;
					acc.FirstName = '';
				}

				//Start of v1.6
				acc.BillingStreet=cust.Address;
				if(cust.City!=null) {
					if(cust.City.length()<=40)
						acc.BillingCity=cust.City;
					else{
						acc.BillingCity=cust.City.subString(0, 39);
						if(cust.Address!=null) {
							if((cust.City.length()+ cust.Address.length())<255)
								acc.BillingStreet = cust.Address+','+ cust.City;
							else{
								acc.BillingStreet=cust.Address+','+ cust.City;
								if(acc.BillingStreet.length() > 255)
									acc.BillingStreet = acc.BillingStreet.subString(0, 255);
							}
						}
						else{
							acc.BillingStreet = cust.City;
						}
					}
				}
				//end of v1.6

				acc.Updated_from_Derwent__c=system.now();
				acclist.add(acc);
				lstDerwentIds.add(acc.Org_Derwent_Customer_No__c);
				if(acc.PersonEmail != null)
					mapCustomerEmails.put(acc.PersonEmail.toLowerCase(), acc.Org_Brand__c);
			}

			if(!mapCustomerEmails.isEmpty()) {
				list<string> lst = new list<string>();
				list<string> lstEmails = new list<string>();
				lstAccountFields.add('org_brand__c');
				lstAccountFields.add('id');
				lst.addAll(lstAccountFields);
				lstEmails.addAll(mapCustomerEmails.keySet());

				string sQuery = 'select '+string.join(lst, ',') +' from Account where PersonEmail IN :lstEmails AND PersonEmail != null AND Org_Derwent_Customer_No__c = null';

				for(Account objAccount : database.query(sQuery)) {
					string email = objAccount.PersonEmail.toLowerCase();
					if(mapCustomerEmails.containsKey(email) && mapCustomerEmails.get(email) == objAccount.Org_Brand__c) {
						Integer i=0;
						for(Account objNewAccount : acclist) {
							//lstAccountsToUpdate
							if(objNewAccount.PersonEmail == objAccount.PersonEmail && objNewAccount.Org_Brand__c == objAccount.Org_Brand__c) {
								objNewAccount.Id = objAccount.Id;

								for(string field : lstAccountFields) {
									if(objNewAccount.get(field) != objAccount.get(field) && objNewAccount.get(field) == null) {
										objNewAccount.put(field, objAccount.get(field));
									}
								}

								lstAccountsToUpdate.add(objNewAccount);
								break;
							}
							i++;
						}
						system.debug('lstAccountsToUpdate is :  '+lstAccountsToUpdate);
						if(acclist.size() > i) {
							acclist.remove(i);
						}
					}
				}
			}

			if(isFromCustomerCreate == true) {
				// compare acclist with Salesforce field values and keep SF values, if SF values is null update with DerWent Data
				if(!lstDerwentIds.isEmpty()) {
					list<string> lst = new list<string>();
					lstAccountFields.add('id');
					lst.addAll(lstAccountFields);
					string sQuery = 'select '+string.join(lst, ',')+' from Account where Id IN : lstEntityIds AND PersonEmail != null';
					map<string, Account> mapExistingAccounts = new map<string, Account>();
					//system.debug('sQuery is : '+sQuery);
					for(Account objAcc : database.query(sQuery)) {
						mapExistingAccounts.put(objAcc.PersonEmail.toLowerCase(),objAcc);
					}

					if(!mapExistingAccounts.isEmpty()) {
						list<Account> lstA = new list<Account>();
						lstA.addAll(acclist);
						lstA.addAll(lstAccountsToUpdate);

						for(Account objNew : lstA) {
							string email = objNew.PersonEmail.toLowerCase();
							if(mapExistingAccounts.containsKey(email)) {
								Account objEx = mapExistingAccounts.get(email);
								for(string field : lstAccountFields) {
									if(objNew.get(field) != objEx.get(field) && objEx.get(field) == null) {
										objEx.put(field, objNew.get(field));
									}
								}
							}
						}
						update mapExistingAccounts.values();
					}
				}
			}else{
				if(acclist.size()>0) {
					upsert acclist Account.Fields.Org_Derwent_Customer_No__c;
				}
				if(!lstAccountsToUpdate.isEmpty())
					update lstAccountsToUpdate;
			}
		}

		List<String> ErrorCustlist =getCustresp.NotFoundCustomers;
		set<String> ErrorCustset = new set<String>();
		if(ErrorCustlist != null && ErrorCustlist.size() > 0) {
			ErrorCustset.addAll(ErrorCustlist);
		}
		if(recordids != null &&!recordids.isEmpty()) {
			List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in :recordids ];
			for(Request_Log__c req :ReqList) {
				if(!ErrorCustset.isEmpty()) {
					if(ErrorCustset.contains(req.Entity_Id__c)) {
						req.Error_Log__c='Not found Customer';
						req.Status__c='Failed';
					}
				}else{
					req.Status__c='Completed';
				}
			}
			update ReqList;
		}


	}

	/**********************Preparing the request parameters for the get Quote request*********************************/

	public static string prepareGetQuote(List<id> rids){

		//Querying the customer records
		string ReqQuery = getCreatableFieldsSOQL('Request_Log__c');
		string entity='Quote';
		ReqQuery+=' where Entity__c = \'' + entity+ '\'  AND Id in :rids';
		List<Request_Log__c> QuoteList= database.query(ReqQuery);

		String reqparams = '';

		for(integer i=1; i<=QuoteList.size(); i++) {
			reqparams+= 'quoteIds='+QuoteList[i-1].Entity_Id__c;
			if(i!=QuoteList.size())
				reqparams+= '&';
		}
		//system.debug('>>>>>Request Parameters>>>>>>'+reqparams);
		return reqparams;

	}

	/**********************End ofPreparing the request parameters for the get Quote request*********************************/

	/************************** Start Callout Quote ****************************/
	webservice static void getQuote(List<id> recordids){
		getDerwentsetting('Get_Quote');
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');

		String reqparams = prepareGetQuote(recordids);
		String endpointurl = endurl+ reqparams;
		//system.debug('>>>>>Request >>>>>>'+ endpointurl);
		//req.setbody(reqJSON);
		req.setEndpoint(endpointurl);
		Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(60 * 1000);
		HTTP http = new HTTP();
		// if(!Test.isrunningTest()){
		try{
			HTTPResponse res = http.send(req);

			system.debug('>>>>>Response>>>>>>'+res.getbody());

			parseGetQuoteResponse(res.getBody(),recordids);

		}
		catch(Exception ex) {

			//system.debug('Callout error: '+ ex);
			Request_Log__c objLog = new Request_Log__c (id=recordids[0]);
			objLog.Error_Log__c ='Ids=='+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice Callout For Quote';
			objLog.status__c = 'Failed';

			update objLog;

		}
		//  }


	}

	/************************** End Callout Quote ****************************/

	/**********************Parsing the response received for Get Quote request*********************************/
	public static void parseGetQuoteResponse(string respbody,List<id> recordids){

		List<Request_Log__c>  reqQuoteList = new List<Request_Log__c>();
		List<Quote_Line_Item__c> quotProdList = new List<Quote_Line_Item__c>();
		List<Quote_Header__c> quotHeadList = new List<Quote_Header__c>();
		List<Quote_Product_Segment__c> quotProdSegList = new List<Quote_Product_Segment__c>();
		List<Quote_Product__c> quotProductList = new List<Quote_Product__c>();
		List<Quote_Option__c> quoteOptionList = new List<Quote_Option__c>();
		List<Quote_Note__c> quoteNoteList = new List<Quote_Note__c>();
		set<Quote_Note__c> quoteNoteSet = new set<Quote_Note__c>();
		List<booking__c> updateBookingList = new List<booking__c>();
		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c from Derwent_Field_Mapping__mdt where Module__c='Quotation' order by Order__c];
		set<string> errorQuoteId = new set<string>();
		List<Derwent_Field_Mapping__mdt> quoteMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> quoteProductMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> quoteProductSegmentMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> quoteProductOptionMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> AdhocProductMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> AdhocProductSegmentMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> QuoteNotesMappings = new List<Derwent_Field_Mapping__mdt>();

		//Following is part of Quotation object only but for json differentiation mapping is used differently
		List<Derwent_Field_Mapping__mdt> QuotationAgentMapping = new List<Derwent_Field_Mapping__mdt>();

		for(Derwent_Field_Mapping__mdt DFM :mappings) {
			if(DFM.SF_Object__c=='Quotation')
				quoteMappings.add(DFM);
			else if(DFM.SF_Object__c=='QuoteProduct')
				quoteProductMappings.add(DFM);
			else if(DFM.SF_Object__c=='QuoteProductSegment')
				quoteProductSegmentMappings.add(DFM);
			else if(DFM.SF_Object__c=='QuoteProductOption')
				quoteProductOptionMappings.add(DFM);
			else if(DFM.SF_Object__c=='Adhoc')
				AdhocProductMappings.add(DFM);
			else if(DFM.SF_Object__c=='AdhocSegment')
				AdhocProductSegmentMappings.add(DFM);
			else if(DFM.SF_Object__c=='QuoteNotes')
				QuoteNotesMappings.add(DFM);

			else if(DFM.SF_Object__c=='QuotationAgent') {
				QuotationAgentMapping.add(DFM);
			}

		}

		//system.debug('!!!!!!!!!!!!!!!'+respbody);
		//Getting all the lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();
		string respbody1 = respbody.replace('"Currency"','"Currencyval"');
		//Parsing the json response
		QuoteResponse getQuoteresp  =   QuoteResponse.parse(respbody1);
		//system.debug('>>>>>QuoteResponse>>>>>>'+getQuoteresp);

		//Getting the Quote List
		List<QuoteResponse.Quotes> QuoteList = getQuoteresp.Quotes;
		List<String> custidlist = new List<String>();
		List<Integer> domainidlist = new List<Integer>();
		if(QuoteList != null && QuoteList.size() > 0) {
			for(QuoteResponse.Quotes quo:QuoteList) {
				Quote_Header__c quoHeader = new Quote_Header__c();
				QuoteResponse.ImpersonatedCustomer quocustomer= quo.ImpersonatedCustomer;
				if(quocustomer != null) {
					if(quocustomer.Id != null && quocustomer.Id != '') {
						quoHeader.Customer__r = new Account(Org_Derwent_Customer_No__c = quocustomer.Id);
						custidlist.add(quocustomer.Id);
					}

				}

				else{
					if((quo.TrackingTag != '' && quo.TrackingTag != null)) {

						string str = quo.TrackingTag;
						str = str.removeEnd('\"').removeStart('\"');
						List<case> caseList =[select AccountId from case where id=: str];
						//system.debug(caseList);
						if(caseList.size() > 0) {
							quoHeader.Customer__r = new Account(id =caseList[0].AccountId);

						}
					}
				}

				if(Schema.SObjectType.Quote_Header__c.getRecordTypeInfosByName().get('Derwent Quote').getRecordTypeId() != null) {
					quoHeader.recordtypeid = Schema.SObjectType.Quote_Header__c.getRecordTypeInfosByName().get('Derwent Quote').getRecordTypeId();
				}


				if(quo.DomainId != null && quo.DomainId != 0) {
					quoHeader.Brand__c=lkpmap.get('DomainId__c.'+quo.DomainId);
					domainidlist.add(quo.DomainId);
				}

				// Following conditions for creating Quote Notes
				if(quo.Notes != null && quo.Notes.size() > 0) {
					List<QuoteResponse.Notes> quoNote= quo.Notes;
					set<string> noteIds = new set<string>();
					for(QuoteResponse.Notes notRef:quoNote) {

						Quote_Note__c quoNoteRef = new Quote_Note__c();
						Map<String, Object> quoNoteMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(notRef));
						quoNoteRef.Quote__r = new Quote_Header__c(Quote_Id__c = quo.Id);
						for(Derwent_Field_Mapping__mdt DFM :QuoteNotesMappings) {

							string fieldval=String.valueof(quoNoteMap.get(DFM.JSON_Field__c));
							if(fieldval != null) {
								if(DFM.DataType__c=='DateTime') {
									quoNoteRef.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
								}
								else if(DFM.DataType__c=='Lookup') {
									quoNoteRef.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
								}
								else if(DFM.DataType__c=='Checkbox') {
									Boolean boolval=false;
									if(fieldval=='true')
										boolval=true;
									quoNoteRef.put(DFM.SF_Field_API_Name__c,boolval);
								}
								else
									quoNoteRef.put(DFM.SF_Field_API_Name__c,fieldval);
							}
						}
						quoteNoteSet.add(quoNoteRef);
						//system.debug('@@@@@@@@@@@@@@@@@@@quoteNoteSet'+quoteNoteSet);
					}
				}

				list<integer> booking = new list<integer>();

				if(quo.BookingIds != null && quo.BookingIds.size()>0 ) {
					booking = quo.BookingIds;
					quoHeader.put('BookingIds__c',string.valueof(booking));
					quoHeader.put('Status__c','Accepted');
				}

				if(quo.TrackingTag != '' && quo.TrackingTag != null) {
					string str = quo.TrackingTag;
					str = str.removeEnd('\"').removeStart('\"');
					List<Case> caselist = [select id from case where id=: str];
					if(caselist.size() > 0) {
						quoHeader.Case__c = str;
					}
					if(booking.size() > 0) {

						string query ='select id,Org_Booking_Ref__c,Org_SF_Case_Reference__c from Booking__c where org_trip_ID__c in '+getValuesInQuotes(booking);

						List<Booking__c> bookingList=(List<Booking__c>)Database.query(query);
						if(bookinglist.size() > 0) {
							for(Booking__c bkref:bookingList) {
								bkref.Org_SF_Case_Reference__c = quo.TrackingTag;
								updateBookingList.add(bkref);
							}
						}
					}
				}

				if(quo.CreatedByAgent != null) {
					Map<String, Object> quoteAgentMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(quo.CreatedByAgent));
					for(Derwent_Field_Mapping__mdt DFM :QuotationAgentMapping) {

						string fieldval=String.valueof(quoteAgentMap.get(DFM.JSON_Field__c));
						if(fieldval != null) {
							if(DFM.DataType__c=='DateTime') {
								quoHeader.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
							}
							else if(DFM.DataType__c=='Lookup') {
								quoHeader.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							}
							else if(DFM.DataType__c=='Checkbox') {
								Boolean boolval=false;
								if(fieldval=='true')
									boolval=true;
								quoHeader.put(DFM.SF_Field_API_Name__c,boolval);
							}
							else
								quoHeader.put(DFM.SF_Field_API_Name__c,fieldval);
						}

					}
				}
				Map<String, Object> quoteHeaderMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(quo));
				for(Derwent_Field_Mapping__mdt DFM :quoteMappings) {

					string fieldval=String.valueof(quoteHeaderMap.get(DFM.JSON_Field__c));
					if(fieldval != null) {
						if(DFM.DataType__c=='DateTime') {
							quoHeader.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
						}
						else if(DFM.DataType__c=='Lookup') {
							quoHeader.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
						}
						else if(DFM.DataType__c=='Checkbox') {
							Boolean boolval=false;
							if(fieldval=='true')
								boolval=true;
							quoHeader.put(DFM.SF_Field_API_Name__c,boolval);
						}
						else if(DFM.DataType__c=='Integer') {

							quoHeader.put(DFM.SF_Field_API_Name__c,integer.valueof(fieldval));
						}
						else
							quoHeader.put(DFM.SF_Field_API_Name__c,fieldval);
					}
				}

				quotHeadList.add(quoHeader);
				List<QuoteResponse.cls_Products> quop = quo.Products;

				//Creating Quote Option for maintain the structure
				Quote_Option__c QOption = new Quote_Option__c();
				QOption.Quote_Header__r = new Quote_Header__c(Quote_Id__c = quo.Id);

				QOption.Quote_External__c = quo.Id;
				quoteOptionList.add(QOption);
				if(quop != null && quop.size() > 0) {
					for(QuoteResponse.cls_Products qu:quop) {
						Quote_Line_Item__c quoProd = new Quote_Line_Item__c();
						quoProd.CurrencyIsoCode = quoHeader.CurrencyIsoCode;
						if(qu.ChildAges != null && qu.ChildAges.size()>0 ) {
							list<integer> child = qu.ChildAges;
							//system.debug('child@@@'+child);
							for(integer i=1; i <= child.size(); i++) {
								quoProd.ChildAges__c = quoProd.ChildAges__c+string.valueof(child[i-1]);
								if(i < child.size()) {
									quoProd.ChildAges__c = quoProd.ChildAges__c +',';
								}
							}
						}
						//system.debug('qu############################'+qu);
						Map<String, Object> quoProdMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(qu));
						//system.debug('quoProdMap############################'+quoProdMap);
						quoProd.Quote_Custom__r = new Quote_Header__c(Quote_Id__c = quo.Id);
						quoProd.Quote_Option__r = new Quote_Option__c(Quote_External__c = quo.Id);
						for(Derwent_Field_Mapping__mdt DFM :quoteProductMappings) {

							string fieldval=String.valueof(quoProdMap.get(DFM.JSON_Field__c));
							if(fieldval != null) {
								if(DFM.DataType__c=='DateTime') {
									quoProd.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
								}
								else if(DFM.DataType__c=='Lookup') {
									quoProd.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
								}
								else if(DFM.DataType__c=='Checkbox') {
									Boolean boolval=false;
									if(fieldval=='true')
										boolval=true;
									quoProd.put(DFM.SF_Field_API_Name__c,boolval);
								}
								else if(DFM.DataType__c=='Integer') {
									Decimal fielddec= Decimal.valueof(fieldval);
									quoProd.put(DFM.SF_Field_API_Name__c,fielddec);
								}
								else
									quoProd.put(DFM.SF_Field_API_Name__c,fieldval);
							}
						}

						//For Hotel Product
						if(qu.TypeId == Integer.valueOf('0')) {

							if(qu.Destination != null) {
								quoProd.put('Hotel_Location__c',String.valueof(qu.Destination.Location));
								quoProd.put('Hotel_country__c',String.valueof(qu.Destination.Country));
								quoProd.put('Hotel_Province__c',String.valueof(qu.Destination.Province));
							}

						}
						// For Flight Product
						if(qu.TypeId == Integer.valueOf('1')) {

							List<QuoteResponse.cls_Legs> quoLegs = qu.Legs;

							for(QuoteResponse.cls_Legs quoLeg:quoLegs) {

								List<QuoteResponse.cls_Segments> quoSegments= quoLeg.Segments;

								for(QuoteResponse.cls_Segments quosegment:quoSegments) {

									Quote_Product_Segment__c quo_Prod_segment = new Quote_Product_Segment__c();

									quo_Prod_segment.Quote_Line_Item__r = new Quote_Line_Item__c(Product_Id__c=qu.Id);

									Map<String, Object> quoSecMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(quosegment));
									//system.debug('quoSecMap&&&&&&&&&&&&&&&&&&&&&&&'+quoSecMap);
									for(Derwent_Field_Mapping__mdt DFM :quoteProductSegmentMappings) {
										string fieldval=String.valueof(quoSecMap.get(DFM.JSON_Field__c));
										if(fieldval != null) {
											if(DFM.DataType__c=='DateTime') {
												quo_Prod_segment.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
											}
											else if(DFM.DataType__c=='Lookup') {
												quo_Prod_segment.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
											}
											else if(DFM.DataType__c=='Checkbox') {
												Boolean boolval=false;
												if(fieldval=='true')
													boolval=true;
												quo_Prod_segment.put(DFM.SF_Field_API_Name__c,boolval);
											}

											else if(DFM.DataType__c=='Integer') {
												Decimal fielddec= integer.valueof(fieldval);
												quo_Prod_segment.put(DFM.SF_Field_API_Name__c,fielddec);
											}
											else
												quo_Prod_segment.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}
									quotProdSegList.add(quo_Prod_segment);
								}
							}
						}

						//For Adhoc Products
						if(qu.TypeId == Integer.valueOf('9')) {
							if(qu.Product != null) {
								//for(QuoteResponse.cls_product adhoc: qu.Product){
								Map<String, Object> AdhocProductMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(qu.Product));

								for(Derwent_Field_Mapping__mdt DFM :AdhocProductMappings) {

									string fieldval=String.valueof(AdhocProductMap.get(DFM.JSON_Field__c));
									if(fieldval != null) {
										if(DFM.DataType__c=='DateTime') {
											quoProd.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
										}
										else if(DFM.DataType__c=='Lookup') {
											quoProd.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
										}
										else if(DFM.DataType__c=='Checkbox') {
											Boolean boolval=false;
											if(fieldval=='true')
												boolval=true;
											quoProd.put(DFM.SF_Field_API_Name__c,boolval);
										}
										else if(DFM.DataType__c=='Integer') {
											Decimal fielddec= Decimal.valueof(fieldval);
											quoProd.put(DFM.SF_Field_API_Name__c,fielddec);
										}
										else
											quoProd.put(DFM.SF_Field_API_Name__c,fieldval);
									}
								}

								if(qu.Product.Itinerary != null) {
									for(QuoteResponse.cls_Itinerary Itn:qu.Product.Itinerary) {
										Quote_Product_Segment__c quo_Prod_segment_adHoc = new Quote_Product_Segment__c();

										quo_Prod_segment_adHoc.Quote_Line_Item__r = new Quote_Line_Item__c(Product_Id__c=qu.Id);
										Map<String, Object> AdhocProductSegmentMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Itn));
										for(Derwent_Field_Mapping__mdt DFM :AdhocProductSegmentMappings) {

											string fieldval=String.valueof(AdhocProductSegmentMap.get(DFM.JSON_Field__c));
											if(fieldval != null) {
												if(DFM.DataType__c=='DateTime') {
													quo_Prod_segment_adHoc.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
												}
												else if(DFM.DataType__c=='Lookup') {
													quo_Prod_segment_adHoc.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
												}
												else if(DFM.DataType__c=='Checkbox') {
													Boolean boolval=false;
													if(fieldval=='true')
														boolval=true;
													quo_Prod_segment_adHoc.put(DFM.SF_Field_API_Name__c,boolval);
												}
												else if(DFM.DataType__c=='Integer') {
													Decimal fielddec= Decimal.valueof(fieldval);
													quo_Prod_segment_adHoc.put(DFM.SF_Field_API_Name__c,fielddec);
												}
												else
													quo_Prod_segment_adHoc.put(DFM.SF_Field_API_Name__c,fieldval);
											}
										}

										quotProdSegList.add(quo_Prod_segment_adHoc);
									}
								}
							}
						}
						// For all prodcuts product Option will get create

						List<QuoteResponse.cls_Options> quoOptions = qu.Options;
						//system.debug('#######################quoOptions'+quoOptions);
						for(QuoteResponse.cls_Options quoOption:quoOptions) {

							Quote_Product__c quo_Prod_Option = new Quote_Product__c();

							quo_Prod_Option.Quote_Line_Item__r = new Quote_Line_Item__c(Product_Id__c=qu.Id);

							Map<String, Object> quoOppMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(quoOption));

							for(Derwent_Field_Mapping__mdt DFM :quoteProductOptionMappings) {
								string fieldval=String.valueof(quoOppMap.get(DFM.JSON_Field__c));
								if(fieldval != null) {

									if(DFM.DataType__c=='DateTime') {
										quo_Prod_Option.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
									}
									else if(DFM.DataType__c=='Lookup') {
										quo_Prod_Option.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
									}
									else if(DFM.DataType__c=='Checkbox') {
										Boolean boolval=false;
										if(fieldval=='true')
											boolval=true;
										quo_Prod_Option.put(DFM.SF_Field_API_Name__c,boolval);
									}
									else if(DFM.DataType__c=='Integer') {
										Decimal fielddec= Decimal.valueof(fieldval);
										quo_Prod_Option.put(DFM.SF_Field_API_Name__c,fielddec);
									}
									else{
										quo_Prod_Option.put(DFM.SF_Field_API_Name__c,fieldval);
									}

									if(String.valueof(quoOppMap.get('Id')) != null) {
										quo_Prod_Option.put('Option_Id__c',qu.Id+'-'+quoOppMap.get('Id'));
									}
								}
							}
							quotProductList.add(quo_Prod_Option);
						}
						quotProdList.add(quoProd);
					}
				}
			}
		}

		//v1.41.1
		if(!custidlist.isEmpty()) {
			doCustomerCall(custidlist);
		}

		if(quotHeadList.size() > 0) {
			upsert quotHeadList Quote_Header__c.Fields.Quote_Id__c;
			quotHeadList.clear();
		}

		if(quoteOptionList.size() > 0) {
			upsert quoteOptionList Quote_Option__c.Fields.Quote_External__c;
			quoteOptionList.clear();
		}

		if(quotProdList.size() > 0) {
			upsert quotProdList Quote_Line_Item__c.Fields.Product_Id__c;
			quotProdList.clear();
		}

		if(quotProductList.size() > 0) {
			upsert quotProductList Quote_Product__c.Fields.Option_Id__c;
			quotProductList.clear();
		}

		if(updateBookingList.size() > 0) {
			update updateBookingList;
		}
		if(quotProdSegList.size() > 0) {
			insert quotProdSegList;
			quotProdSegList.clear();
		}

		if(!quoteNoteSet.isEmpty()) {
			quoteNoteList.addAll(quoteNoteSet);
			upsert quoteNoteList Quote_Note__c.Fields.Notes_Id__c;
			quoteNoteList.clear();
		}

		List<string> ErrorBooklist = new List<string>();
		set<string> ErrorBooklist1 = new set<string>();
		ErrorBooklist = getQuoteresp.NotFoundQuotes;
		ErrorBooklist1.addAll(ErrorBooklist);

		if(ErrorBooklist1!=null && ErrorBooklist1.isEmpty() == false) {
			if(ErrorBooklist1.contains(AsyncDerwentWebService.RequestLog.Entity_Id__c)) {
				AsyncDerwentWebService.RequestLog.Error_Log__c = (AsyncDerwentWebService.RequestLog.Error_Log__c != null ? AsyncDerwentWebService.RequestLog.Error_Log__c : '') + 'Not found Quotes';
				AsyncDerwentWebService.RequestLog.Status__c = 'Failed';
			}else{
				AsyncDerwentWebService.RequestLog.Status__c = 'Completed';
			}
		} else{
			AsyncDerwentWebService.RequestLog.Status__c = 'Completed';
			for(Id LogId : recordids) {
				AsyncDerwentWebService.RequestLog.Id = logId;
				AsyncDerwentWebService.RequestLog.Status__c = 'Completed';
			}
		}
		upsert AsyncDerwentWebService.RequestLog;

		/*List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in :recordids ];
		   for(Request_Log__c req :ReqList) {
		    if(!ErrorBooklist1.isEmpty()) {
		        if(ErrorBooklist1.contains(req.Entity_Id__c)) {
		            req.Error_Log__c='Not found Quotes';
		            req.Status__c='Failed';
		        }
		    }else
		        req.Status__c='Completed';
		   }
		   update ReqList;*/
	}

	/****************************Parsing get Quote response******************************************/


	/**********************Preparing the request parameters for the get booking request*********************************/
	public static string prepareGetBooking(List<id> rids){

		//Querying the customer records
		string ReqQuery = getCreatableFieldsSOQL('Request_Log__c');
		string entity='Booking';
		ReqQuery+=' where Entity__c = \'' + entity+ '\'  AND Id in :rids';
		List<Request_Log__c> Bookinglist= database.query(ReqQuery);

		String reqparams = '';

		for(integer i=1; i<=Bookinglist.size(); i++) {
			reqparams+= 'tripIds='+Bookinglist[i-1].Entity_Id__c;
			if(i!=Bookinglist.size())
				reqparams+= '&';
		}
		//system.debug('>>>>>Request Parameters>>>>>>'+reqparams);
		return reqparams;

	}
	/**********************Callout for getting booking details*********************************/

	webservice static void getBooking(List<id> recordids){

		getDerwentsetting('Get_Booking');
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');

		String reqparams = prepareGetBooking(recordids);
		String endpointurl = endurl+ reqparams;
		//system.debug('>>>>>Request >>>>>>'+ endpointurl);
		//req.setbody(reqJSON);
		req.setEndpoint(endpointurl);
		Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(60 * 1000);
		HTTP http = new HTTP();
		// if(!Test.isrunningTest()){
		try{
			HTTPResponse res = http.send(req);

			//system.debug('>>>>>Response>>>>>>'+res.getbody());

			parseGetBookingResponse(res.getBody(),recordids);

		}
		catch(Exception ex) {
			//system.debug('Callout error: '+ ex);
			Request_Log__c objLog = new Request_Log__c (id=recordids[0]);
			objLog.Error_Log__c ='Ids=='+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice Booking Batch Error';
			objLog.Status__c='Failed';

			update objLog;
		}
		// }
	}

	/**********************Parsing the response received for Get Booking request*********************************/
	public static void parseGetBookingResponse(string respbody,List<id> recordids){
		String reqstatus='';
		String DerwentStatus,DerwentId='';
		List<Booking__c> BkgHeaderlist = new List<Booking__c>();
		map<string, Booking__c> mapBookingHeaders = new map<string, Booking__c>(); //Ravi
		map<string, Booking__c> mapBookingItems = new map<string, Booking__c>(); //Ravi
		List<Booking__c> lstBookingRecords = new List<Booking__c>();
		List<Itinerary__c> Itnrylist = new List<Itinerary__c>();
		List<Itinerary__c> ItnryExtlist = new List<Itinerary__c>();
		List<Itinerary_Detail__c> ItnryDetlist = new List<Itinerary_Detail__c>();
		List<Traveller__c> TRAlist = new List<Traveller__c>();
		List<Booking_Price_Breakdown__c> Pricelist = new List<Booking_Price_Breakdown__c>();
		//List<Booking_Note__c> notelist = new List<Booking_Note__c>();
		List<CSR__c> csrlist = new List<CSR__c>();
		List<CSR_Questions__c> quelist = new List<CSR_Questions__c>();
		List<CSR_Notes__c> csrnotelist = new List<CSR_Notes__c>();
		integer countOfBooking = 0;
		String bookingType = '';

		map<string, string> mapOwnerEmailIds = new map<string, string>();
		map<string, string> mapItnaryBHeaders = new map<string, string>();
		map<string, string> mapBookingItnaryDetails = new map<string, string>();
		map<string, string> mapBookingPriceBreakDown = new map<string, string>();
		map<string, string> mapDestinations = new map<string, string>();
		map<string, Datetime[]> mapItnaryDates = new map<string, Datetime[]>();
		map<string, string[]> mapHotelStays = new map<string, string[]>();
		map<string, list<string> > mapBookingSegments = new map<string, list<string> >();
		map<string, set<string> > mapBookingSupliers = new map<string, set<string> >();
		map<string, string> mapDerwentUsernames = new map<string, string>();
		map<string,string> mapTRPDerwentCSRID = new map<String,String>(); //v1.44

		map<string, list<BookingResponseNew.cls_LineItems>> bookingLineItemMap = new map<string, list<BookingResponseNew.cls_LineItems>>();  //v1.45

		//map<string, string> mapItnaryDetails = new map<string, string>();

		AsyncDerwentWebService.InPorgressItems lstInPorgressItems = new AsyncDerwentWebService.InPorgressItems();

		//   map<string,database.Error> ErrorCustMapBooking = new map<string,database.Error>();

		//Parsing the json response
		system.debug('>>>>>BookingResponse>>>>>>'+respbody);
		BookingResponseNew getBookresp= BookingResponseNew.parse(respbody);
		//system.debug('>>>>>BookingResponse>>>>>>'+getBookresp);

		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where Module__c='Booking' order by Order__c];

		List<Derwent_Field_Mapping__mdt> BKmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> ITImappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> staymappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> roommappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> segmentmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> TRAmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> Pricemappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> Notemappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRQuemappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRNotemappings = new List<Derwent_Field_Mapping__mdt>();
		List<String> derwentTRPCSRList = new List<String>();//v1.44
        
		for(Derwent_Field_Mapping__mdt DFM :mappings) {
			if(DFM.SF_Object__c=='Booking')
				BKmappings.add(DFM);
			else if(DFM.SF_Object__c=='Itinerary')
				ITImappings.add(DFM);
			else if(DFM.SF_Object__c=='Stay')
				staymappings.add(DFM);
			else if(DFM.SF_Object__c=='Room')
				roommappings.add(DFM);
			else if(DFM.SF_Object__c=='Segment')
				segmentmappings.add(DFM);
			else if(DFM.SF_Object__c=='Traveller')
				TRAmappings.add(DFM);
			else if(DFM.SF_Object__c=='LineItem')
				Pricemappings.add(DFM);
			else if(DFM.SF_Object__c=='Note')
				Notemappings.add(DFM);
			else if(DFM.SF_Object__c=='CSR')
				CSRmappings.add(DFM);
			else if(DFM.SF_Object__c=='CSRQuestion')
				CSRQuemappings.add(DFM);
			else if(DFM.SF_Object__c=='CSRNote')
				CSRNotemappings.add(DFM);
		}

		//Getting all the derwent lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();

		//Getting all the other lookup codes and values
		Map<String,String> alllookupmap= getAllLookupvalue();



		//Getting the booking headers
		List<BookingResponseNew.cls_Trips> Triplist =getBookresp.Trips;
		List<String> tripidlist= new List<String>();
		List<String> custidlist = new List<String>();
		List<String> versionBkglist = new List<String>();//v1.16
		Map<Decimal,Booking__c> BkglistMap = new Map<Decimal,Booking__c>();//v1.37
		List<Integer> domainidlist = new List<Integer>(); //PoC - v1.12 - Added By Evendo
		String BkngBrand=''; //v1.34

		list<LineItem_Field_Mapping__mdt> lineItemFieldMappings = [SELECT DataType__c, JSON_Field__c, SF_Field_API_Name__c FROM LineItem_Field_Mapping__mdt]; //v1.45

		if(Triplist != null && Triplist.size()>0) {
			for(BookingResponseNew.cls_Trips Trip:Triplist) {

				tripidlist.add(String.valueof(Trip.TripId));
				//Getting the bookings in each booking header
				List<BookingResponseNew.cls_Bookings> Bookingslist =Trip.Bookings;

				for(BookingResponseNew.cls_Bookings Bkng: Bookingslist) {
					//Getting details of Booking Detail
					BookingResponseNew.cls_BookingDetail BKdetail=Bkng.BookingDetail;
					BookingResponseNew.cls_BookingCore BKCore = Bkng.BookingCore; // v1.12
					domainidlist.add(BKCore.DomainId); // v1.12
					versionBkglist.add(BKCore.BookingRef);//v1.16
					BkngBrand=lkpmap.get('DomainId__c.'+BKcore.DomainId); //v1.34

					if(String.valueOf(BKdetail.UserId)!= null && String.valueOf(BKdetail.UserId)!= '') {
						custidlist.add(String.valueof(BKdetail.UserId));
					}/*RB else{
					    //system.debug('BKdetail -' + BKdetail );
					    //system.debug('BKCore -' + BKCore );
					    }*/
                    // Added as part of v1.44
					if(BkngBrand == 'trp'){	
						List<BookingResponseNew.cls_Csrs> trpcsrlist =Bkng.Csrs; // v1.44
						if(trpcsrlist != null && trpcsrlist.size() > 0){
							for(BookingResponseNew.cls_Csrs bkngcsr : trpcsrlist){
								mapTRPDerwentCSRID.put(String.valueof(bkngcsr.CsrId),string.valueof(bkngcsr.CsrId));
							}
						}
					}
					//end of v1.44
				}
			}
		}
		//system.debug('<<Cust ID List>>'+custidlist);

		if(!custidlist.isEmpty()) {
			doCustomerCall(custidlist);
		}

		//AccountTriggerHelper.BlockAccountTrigger = true;

		//Getting the existing quotes of the customers in the trip list
		List<Quote_Header__c> QHList = [select id,BookingIds__c,Case__c,Customer__c from Quote_Header__c where BookingIds__c!=null AND Customer__r.Org_Derwent_Customer_No__c in :custidlist];

		Map<String,String> qtcasemap= new Map<String,String>();
		if(QHList.size()>0) {
			for(Quote_Header__c QH:QHList) {
				//system.debug('<<QT Bookings>>'+QH.BookingIds__c);
				string qtbkngs= QH.BookingIds__c.remove('(').remove(')'); // Added by SB remove(')')
				List<string> qtbknglist=qtbkngs.split(',');
				for(integer i=0; i<qtbknglist.size(); i++) {
					if(tripidlist.contains(qtbknglist[i])) {
						qtcasemap.put(tripidlist[tripidlist.indexof(qtbknglist[i])],QH.Case__c);
					}
				}
			}
		}
		//system.debug('<<QT Case Map>>'+qtcasemap);

		//Added as part of v1.5
		//Get the existing enquiry case of the customers in the triplist
		List<Case> EnqCaseList = new List<Case>();
		if(BkngBrand =='dnata') { //Added if condition as part of v1.34
			EnqCaseList=[select id,Org_Type__c,AccountId,Org_Booking__c,dTME_Supplier_Ref__c from Case where Org_Type__c='Booking Enquiry' AND dTME_Supplier_Ref__c!=null AND Account.Org_Derwent_Customer_No__c in :custidlist];
		}
		Map<String,String> enqcasemap= new Map<String,String>();
		if(EnqCaseList.size()>0) {
			for(Case enqcase: EnqCaseList) {
				enqcasemap.put(enqcase.dTME_Supplier_Ref__c,enqcase.id);
			}
		}
		//
		// Added as a part of v1.44
		Map<String,Case> trpcsrlist = new Map<String,Case>();
		List<String> DerwentCSRsTobeCreated = new List<String>();
		if(BkngBrand == 'trp' && mapTRPDerwentCSRID != null && mapTRPDerwentCSRID.size() > 0){
			for(Case cs : [Select Id,Derwent_CSR_Id__c from Case where Derwent_CSR_Id__c IN : mapTRPDerwentCSRID.keySet()])
			{
				trpcsrlist.put(cs.Derwent_CSR_Id__c,cs);
			}
		}
		for(String str : mapTRPDerwentCSRID.keySet()){
			if(!trpcsrlist.containsKey(str)){
				DerwentCSRsTobeCreated.add(str);
			}
		}
		createRequestlogforNewDerwentBookingIds(DerwentCSRsTobeCreated,'CSR');
			   
		//end of v1.44
		//Getting the existing itineraries of the trips //v1.35
		List<Itinerary__c> ExistItinList= tripidlist.isEmpty() ? new list<Itinerary__c>() : [select id from Itinerary__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in : tripidlist];

		//Getting the existing travellers of the trips //v1.35
		List<Traveller__c> ExistTravList= (system.label.Run_Traveller_Count == 'true') ? new list<Traveller__c>() : [select id from Traveller__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in : tripidlist];

		//Getting the existing price line items of the trips //v1.35
		//List<Booking_Price_Breakdown__c> ExistPriceList= tripidlist.isEmpty() ? new list<Booking_Price_Breakdown__c>() : [select id from Booking_Price_Breakdown__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in :tripidlist];
		string accountid='';
		Decimal Derwent_Version;//v1.16
		Map<Id,Decimal> derwentVersionBkngMap = new Map<Id,Decimal>(); //v1.16
		//added as a part of v1.16

		List<Booking__c> VersionBooking = new List<Booking__c>();
		if(Label.UpsertDerwentBookings == 'TRUE' && !versionBkglist.isEmpty()) { //if condition added as part of v1.34 // also added part of v1.35
			VersionBooking =[Select Id,Name, Derwent_Version_Number__c,Booking_Header__c from Booking__c where Name IN :versionBkglist];
		}
		if(VersionBooking.size()>0) { //if condition added as part of v1.34
			for(Booking__c book:VersionBooking) {
				if(book.Derwent_Version_Number__c != null) {
					//system.debug('Derwent Id'+book.Derwent_Version_Number__c );
					//system.debug('booking Id'+book.Id);
					//system.debug('Name '+book.Name);
					derwentVersionBkngMap.put(book.Id,Integer.valueof(book.Derwent_Version_Number__c));
				}
			}
		}

		//end v1.16
		Map<String,Booking__c> casebkngmap= new Map<String,Booking__c>();
		if(Triplist != null && Triplist.size()>0) {
			for(BookingResponseNew.cls_Trips Trip:Triplist) {
				String caseid=''; //Added as part of v1.5
				Booking__c BkgHeader= new Booking__c();
				BkgHeader.name=String.valueof(Trip.TripId);
				BkgHeader.Org_Trip_Id__c=String.valueof(Trip.TripId);

				BkgHeader.recordtypeid=Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();

				//Getting the bookings in each booking header
				List<BookingResponseNew.cls_Bookings> Bookingslist =Trip.Bookings;

				countOfBooking = Bookingslist != null ? Bookingslist.size() : countOfBooking;

				for(BookingResponseNew.cls_Bookings Bkng: Bookingslist) {

					//Getting the tracking tag
					caseid= Bkng.TrackingTag; //removed initialization as part of v1.5
					Derwent_Version = Decimal.valueof(Bkng.Version);//added as part of v1.16
					//system.debug('<<<<<<Version Number>>>>>'+Derwent_Version); //v.1.16
					//system.debug('<<TrackingTag>>'+caseid);

					if(caseid==null && qtcasemap!=null)
						caseid=qtcasemap.get(BkgHeader.Org_Trip_Id__c);

					if(caseid!=null)
						casebkngmap.put(caseid,BkgHeader);

					//Getting details of Booking Core
					BookingResponseNew.cls_BookingCore BKcore=Bkng.BookingCore;
					Map<String, Object> bkcoremap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(BKcore));
					//system.debug('<<bkcoremap>>'+bkcoremap);

					//Creating each booking record
					Booking__c BK= new Booking__c();
					BK.Booking_System__c = 'Derwent'; //Added as part of v1.4
					if(BKcore.Type !=1024) {
						BK.Booking_Header__r= new Booking__c(Org_Trip_Id__c=BkgHeader.Org_Trip_Id__c);
						BK.recordtypeid=Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
					}else{
						BK.recordtypeid=Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
						BkgHeader.Booking_ID__c = String.valueof(BKcore.id);
						BkgHeader.Org_Trip_Id__c = String.valueof(BKcore.id); //v1.43
					}
					if(BKcore.DomainId != null && BKcore.DomainId != 0) {
						BkgHeader.Org_Brand__c=lkpmap.get('DomainId__c.'+BKcore.DomainId);
						BK.Org_Brand__c=lkpmap.get('DomainId__c.'+BKcore.DomainId);

						//v.11 - added by sribala
						BkgHeader.Org_Domain_Name__c = lkpmap.get('Customer_Domain__c.'+BKcore.DomainId);
						BkgHeader.Org_Domain_Id__c = String.valueof(BKCore.DomainId);
						BK.Org_Domain_Name__c = lkpmap.get('Customer_Domain__c.'+BKcore.DomainId);
						//
					}

					//added as a part of v1.16

					if(Bkng.Version != null) {
						Bk.Derwent_Version_Number__c = Decimal.Valueof(Bkng.Version);
					}

					//end v1.16
					if(BKcore.Status == 2) {
						BkgHeader.Booking_Status__c=lkpmap.get('Booking_Status__c.'+BKcore.Status);
					}

					BkgHeader.Booking_Language__c = BKCore.BookingLanguage;//added as a part of v1.10

					//Getting details of Booking Detail
					BookingResponseNew.cls_BookingDetail BKdetail=Bkng.BookingDetail;

					if(BKdetail.UserId!=null) {
						accountid = BKdetail.UserId;
					}

					if(BKcore.Type ==1024) {
						BkgHeader.Org_Title__c= BKdetail.Title;
						BkgHeader.Org_Booking_Type__c='Bundle'; //v1.32
					}else{
						BkgHeader.Org_Booking_Type__c='Package/Single Product';
					}

					if(BKdetail.UserId==null) {
						BK.Org_Account_Name__c=null;
					}else{
						BK.Org_Account_Name__r= new Account(Org_Derwent_Customer_No__c= BKdetail.UserId);
					}
					BK.Org_Title__c=BKdetail.Title;
					Map<String, Object> bkdetailmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(BKdetail));
					//system.debug('<<bkdetailmap>>'+bkdetailmap);

					//added by sribala
					if(BKdetail.OfficeName!=null && BKdetail.OfficeNo!=null) {
						BkgHeader.Office_Name__c = BKdetail.OfficeName;
						BkgHeader.Office_Number__c = String.valueof(BKdetail.OfficeNo);
					}

					//Getting details of Lead Contact
					BookingResponseNew.cls_LeadContact leadcon=Bkng.LeadContact;
					Map<String, Object> LeadContactmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(leadcon));
					//system.debug('<<LeadContactmap>>'+LeadContactmap);
					BK.Salutation__c=leadcon.Title;



					//Getting details of Cancellation  details
					BookingResponseNew.cls_CancellationDetails canceldetail=Bkng.CancellationDetails;
					Map<String, Object> canceldetailmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(canceldetail));
					//system.debug('<<canceldetailmap>>'+canceldetailmap);

					//Getting details of Balance
					BookingResponseNew.cls_Balance balance=Bkng.Balance;
					Map<String, Object> balancemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(balance));
					//system.debug('<<balancemap>>'+balancemap);

					//Getting details of Ticketing Info
					BookingResponseNew.cls_TicketInfo ticket=Bkng.TicketInfo;
					Map<String, Object> ticketmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ticket));
					//system.debug('<<ticketmap>>'+ticketmap);

					//Added as a part of v1.8
					//Getting details of Supplier Info
					BookingResponseNew.cls_SupplierInfo supplierInfo = Bkng.SupplierInfo;
					Map<String, Object> SupplierInfomap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(supplierInfo));
					//system.debug('<<SupplierInfomap>>'+SupplierInfomap);

					//BK.Org_SF_Case_Reference__c=caseid;
					//BkgHeader.Org_SF_Case_Reference__c=caseid; //v1.5 commented and moved down

					//Putting all the items related to single booking record in one map
					Map<String, Object> bookingmap = new Map<String, Object>();
					if(bkcoremap != null)
						bookingmap.putall(bkcoremap);

					if(bkdetailmap != null)
						bookingmap.putall(bkdetailmap);

					if(LeadContactmap != null)
						bookingmap.putall(LeadContactmap);

					//added as  a part of v1.8
					if(SupplierInfomap != null)
						bookingmap.putall(SupplierInfomap);

					if(canceldetailmap != null)
						bookingmap.putall(canceldetailmap);

					if(balancemap != null)
						bookingmap.putall(balancemap);

					if(ticketmap != null)
						bookingmap.putall(ticketmap);

					//system.debug('<<fullMMM>>'+bookingmap);

					//Getting the configured field mapping for booking
					for(Derwent_Field_Mapping__mdt DFM :BKmappings) {
						string fieldval=String.valueof(bookingmap.get(DFM.JSON_Field__c));
						if(fieldval!=null) {
							if(Label.BookingNumberFix == 'TRUE') {
								if(DFM.JSON_Field__c == 'BookingRef') {
									if(!fieldval.contains('/')) {
										fieldval = fieldval + '/'+String.valueof(bookingmap.get('Id'));
									}
								}
							}
							if(DFM.DataType__c=='DateTime') {
								BK.put(DFM.SF_Field_API_Name__c, formatDatetimeGMT(fieldval));
							}
							else if(DFM.DataType__c=='Lookup') {
								BK.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							}
							else if(DFM.DataType__c=='Checkbox') {
								Boolean boolval=false;
								if(fieldval=='true')
									boolval=true;
								BK.put(DFM.SF_Field_API_Name__c,boolval);
							}
							else if(DFM.DataType__c=='Integer') {
								Decimal fielddec= decimal.valueof(fieldval);
								BK.put(DFM.SF_Field_API_Name__c,fielddec);
							}
							else if(DFM.DataType__c=='OtherLookup') {
								BK.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
							}
							else
								BK.put(DFM.SF_Field_API_Name__c,fieldval);
						}
					}

					//Getting the itinerary related to each booking from json
					BookingResponseNew.cls_Itinerary iti =Bkng.Itinerary;
					if(iti != null) {
						if(iti.BookingType == 1) {// Flight Itinerary
							List<BookingResponseNew.cls_Flights> flightlist =iti.Flights;
							if(flightlist!=null && flightlist.size()>0) {
								for(BookingResponseNew.cls_Flights flight: flightlist) {
									Map<String, Object> flightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(flight));
									//system.debug('<<FlightMap>>'+flightmap);
									Itinerary__c Itnry = new Itinerary__c();
									Itnry.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
									//Itnry.Type__c=lkpmap.get('Org_Booking_Type__c.'+iti.BookingType); //Commented as part of v1.1
									//Added as part of v1.1
									if(flight.ItineraryType == 1)
										Itnry.Type__c ='Flight Outbound';
									else if(flight.ItineraryType == 2)
										Itnry.Type__c ='Flight Inbound';
									//
									Itnry.Itinerary_ID__c=string.valueof(flight.ItineraryId);
									//Getting the configured field mapping for stays
									for(Derwent_Field_Mapping__mdt DFM :ITImappings) {
										string fieldval=String.valueof(flightmap.get(DFM.JSON_Field__c));
										//system.debug('Fieldname'+DFM.JSON_Field__c);
										//system.debug('Fieldval'+fieldval);
										if(fieldval!=null) {
											if(DFM.DataType__c=='DateTime') {
												Itnry.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
											}
											else if(DFM.DataType__c=='Lookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
											}
											else if(DFM.DataType__c=='Checkbox') {
												Boolean boolval=false;
												if(fieldval=='true')
													boolval=true;
												Itnry.put(DFM.SF_Field_API_Name__c,boolval);
											}
											else if(DFM.DataType__c=='Integer') {
												Decimal fielddec= decimal.valueof(fieldval);
												Itnry.put(DFM.SF_Field_API_Name__c,fielddec);
											}
											else if(DFM.DataType__c=='OtherLookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
											}
											else
												Itnry.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}
									Itnrylist.add(Itnry);
									mapItnaryBHeaders.put(Itnry.Itinerary_ID__c, BkgHeader.Org_Trip_Id__c);

									List<BookingResponseNew.cls_Segments> segmentlist =flight.Segments;
									if(segmentlist!=null && segmentlist.size()>0) {
										for(BookingResponseNew.cls_Segments segment :segmentlist) {
											Map<String, Object> segmentmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(segment));
											//system.debug('<<Segmentmap>>'+segmentmap);
											Itinerary_Detail__c ItnryDet = new Itinerary_Detail__c();
											ItnryDet.Itinerary__r= new  Itinerary__c(Itinerary_ID__c= string.valueof(flight.ItineraryId));
											ItnryDet.Itinerary_Detail_Type__c='Segment';
											ItnryDet.Org_Itinerary_Detail_Id__c=string.valueof(flight.ItineraryId)+segment.DepartureDate;
											//Getting the configured field mapping for segments
											Datetime dDate, aDate;
											for(Derwent_Field_Mapping__mdt DFM :segmentmappings) {
												string fieldval=String.valueof(segmentmap.get(DFM.JSON_Field__c));
												if(fieldval!=null) {
													if(DFM.DataType__c=='DateTime') {
														datetime dateval= formatDatetime(fieldval);

														if(dateval < Datetime.valueOf('1700-01-01 18:00:00Z')) {
															dateval = Datetime.valueOf('1700-01-01 18:00:00Z');
														}

														dDate = (DFM.SF_Field_API_Name__c == 'Org_Departure_Date__c') ? dateval : dDate;
														aDate = (DFM.SF_Field_API_Name__c == 'Org_Arrival_Date__c' ) ? dateval : aDate;

														ItnryDet.put(DFM.SF_Field_API_Name__c,dateval);

														mapItnaryDates = getItnaryDates(mapItnaryDates, DFM.SF_Field_API_Name__c, dateval, BK.Booking_ID__c);
													}
													else if(DFM.DataType__c=='Lookup') {
														ItnryDet.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
													}
													else if(DFM.DataType__c=='Checkbox') {
														Boolean boolval=false;
														if(fieldval=='true')
															boolval=true;
														ItnryDet.put(DFM.SF_Field_API_Name__c,boolval);
													}
													else if(DFM.DataType__c=='Integer') {
														Decimal fielddec= integer.valueof(fieldval);
														ItnryDet.put(DFM.SF_Field_API_Name__c,fielddec);
													}
													else if(DFM.DataType__c=='OtherLookup') {
														ItnryDet.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
													}
													else
														ItnryDet.put(DFM.SF_Field_API_Name__c,fieldval);
												}
											}

											if(!mapBookingSupliers.containsKey(BK.Booking_ID__c))
												mapBookingSupliers.put(BK.Booking_ID__c, new set<string>());
											if(ItnryDet.Org_Operating_Carrier__c != null) {
												mapBookingSupliers.get(BK.Booking_ID__c).add(ItnryDet.Org_Operating_Carrier__c);
											}

											mapBookingSegments = getSegments(mapItnaryDates, mapBookingSegments,BK.Booking_ID__c, ItnryDet.Departure_Airport__c, ItnryDet.Arrival_Airport__c, dDate, aDate );

											ItnryDetlist.add(ItnryDet);
											//mapItnaryDetails.put(ItnryDet.Org_Itinerary_Detail_Id__c, BK.Booking_ID__c);
											mapBookingItnaryDetails.put(ItnryDet.Org_Itinerary_Detail_Id__c, BK.Booking_ID__c);
											if(Itnry.Type__c == 'Flight Outbound') {
												mapDestinations.put(BK.Booking_ID__c, ItnryDet.Arrival_Airport__c);

											}
										}
									}
								}
							}
						}
						else if(iti.BookingType == 8) {// Accommodation Itinerary
							List<BookingResponseNew.cls_Stays> staylist =iti.Stays;
							if(staylist!=null && staylist.size()>0) {
								for(BookingResponseNew.cls_Stays stay: staylist) {
									Map<String, Object> staymap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(stay));
									//system.debug('<<MMM22>>'+staymap);
									Itinerary__c Itnry = new Itinerary__c();
									Itnry.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
									Itnry.Type__c=lkpmap.get('Org_Booking_Type__c.'+iti.BookingType);
									Itnry.External_System_ID__c=BK.Booking_ID__c+'-'+string.valueof(stay.EstabId)+'-'+stay.CheckIn+'-'+stay.CheckOut;
									//added as a part of v1.2
									//getting destination of the hotel
									BookingResponseNew.cls_Destination hoteldes = stay.Destination;
									Map<String, Object> hoteldestinationmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(hoteldes));
									//system.debug('<<hotelDestMap>>'+hoteldestinationmap);
									if(hoteldestinationmap!=null) {
										for(String HDkey:hoteldestinationmap.keyset()) {
											staymap.put('Destination.'+HDkey,hoteldestinationmap.get(HDkey));
										}
									}
									//end of v1.2
									//Getting the configured field mapping for stays
									Datetime checkIn, checkOut;
									for(Derwent_Field_Mapping__mdt DFM :Staymappings) {
										string fieldval=String.valueof(staymap.get(DFM.JSON_Field__c));
										if(fieldval!=null) {
											if(DFM.DataType__c=='DateTime') {
												datetime dateval = formatDatetime(fieldval);
												if(DFM.SF_Field_API_Name__c == 'Org_Check_In__c')
													checkIn = dateval;
												if(DFM.SF_Field_API_Name__c == 'Org_Check_Out__c' )
													checkOut = dateval;
												Itnry.put(DFM.SF_Field_API_Name__c,dateval);
												mapItnaryDates = getItnaryDates(mapItnaryDates, DFM.SF_Field_API_Name__c, dateval, BK.Booking_ID__c);
											}
											else if(DFM.DataType__c=='Lookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
											}
											else if(DFM.DataType__c=='Checkbox') {
												Boolean boolval=false;
												if(fieldval=='true')
													boolval=true;
												Itnry.put(DFM.SF_Field_API_Name__c,boolval);
											}
											else if(DFM.DataType__c=='Integer') {
												Decimal fielddec= integer.valueof(fieldval);
												Itnry.put(DFM.SF_Field_API_Name__c,fielddec);
											}
											else if(DFM.DataType__c=='OtherLookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
											}
											else
												Itnry.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}
									mapHotelStays = getHotelNames(mapHotelStays, Itnry.Org_Hotel_Name__c, BkgHeader.Org_Trip_Id__c, checkIn, checkOut);
									mapItnaryBHeaders.put(Itnry.External_System_ID__c, BkgHeader.Org_Trip_Id__c);
									ItnryExtlist.add(Itnry);
									mapDestinations.put(BK.Booking_ID__c, Itnry.Org_Destination_Name__c);

									List<BookingResponseNew.cls_Rooms> roomlist =stay.Rooms;
									if(roomlist!=null && roomlist.size()>0) {
										for(BookingResponseNew.cls_Rooms room :roomlist) {
											Map<String, Object> roommap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(room));
											//system.debug('<<Roommap>>'+roommap);
											Itinerary_Detail__c ItnryDet = new Itinerary_Detail__c();
											ItnryDet.Itinerary__r= new  Itinerary__c(External_System_ID__c= BK.Booking_ID__c+'-'+string.valueof(stay.EstabId)+'-'+stay.CheckIn+'-'+stay.CheckOut);
											ItnryDet.Itinerary_Detail_Type__c='Room';
											ItnryDet.Org_Itinerary_Detail_Id__c=string.valueof(room.ItineraryId);
											//Getting the configured field mapping for rooms
											for(Derwent_Field_Mapping__mdt DFM :Roommappings) {
												string fieldval=String.valueof(roommap.get(DFM.JSON_Field__c));
												if(fieldval!=null) {
													if(DFM.DataType__c=='DateTime') {
														ItnryDet.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
													}
													else if(DFM.DataType__c=='Lookup') {
														ItnryDet.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
													}
													else if(DFM.DataType__c=='Checkbox') {
														Boolean boolval=false;
														if(fieldval=='true')
															boolval=true;
														ItnryDet.put(DFM.SF_Field_API_Name__c,boolval);
													}
													else if(DFM.DataType__c=='Integer') {
														Decimal fielddec= integer.valueof(fieldval);
														ItnryDet.put(DFM.SF_Field_API_Name__c,fielddec);
													}
													else if(DFM.DataType__c=='OtherLookup') {
														ItnryDet.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
													}
													else
														ItnryDet.put(DFM.SF_Field_API_Name__c,fieldval);
												}
											}
											ItnryDetlist.add(ItnryDet);
											mapBookingItnaryDetails.put(ItnryDet.Org_Itinerary_Detail_Id__c, BK.Booking_ID__c);
											//mapItnaryDetails.put(ItnryDet.Org_Itinerary_Detail_Id__c, BK.Booking_ID__c);
										}
									}
								}
							}
						}
						else if(iti.BookingType==2) { //Attractions Itinerary
							List<BookingResponseNew.cls_Tickets> attrticketlist =iti.Tickets;
							if(attrticketlist != null && attrticketlist.size() > 0) {
								for(BookingResponseNew.cls_Tickets attrticket: attrticketlist) {
									Map<String, Object> attrticketmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(attrticket));
									//system.debug('<<TicketMap>>'+attrticketmap);
									Itinerary__c Itnry = new Itinerary__c();
									Itnry.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
									Itnry.Type__c=lkpmap.get('Org_Booking_Type__c.'+iti.BookingType);
									Itnry.Itinerary_ID__c=string.valueof(attrticket.ItineraryId);

									Map<String, Object> attrdestinationmap = new Map<String, Object>(); //v1.27
									if(attrticket.Destination != null) { //v1.27 adding if statement to check if it is null
										BookingResponseNew.Destination attrdest=attrticket.Destination; //v1.27
										attrdestinationmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(attrdest)); //v1.27 removing Map<String, Object>
									}

									//Getting details of attraction destination
									//BookingResponseNew.Destination attrdest=attrticket.Destination; //comment for v1.27
									// Map<String, Object> attrdestinationmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(attrdest));
									//system.debug('<<AttrDestMap>>'+attrdestinationmap);
									if(attrdestinationmap.size()>0)
										attrticketmap.putall(attrdestinationmap);

									//Getting the configured field mapping for itinerary
									for(Derwent_Field_Mapping__mdt DFM :ITImappings) {
										string fieldval=String.valueof(attrticketmap.get(DFM.JSON_Field__c));
										if(fieldval!=null) {
											if(DFM.DataType__c=='DateTime') {
												Itnry.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
											}
											else if(DFM.DataType__c=='Lookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
											}
											else if(DFM.DataType__c=='Checkbox') {
												Boolean boolval=false;
												if(fieldval=='true')
													boolval=true;
												Itnry.put(DFM.SF_Field_API_Name__c,boolval);
											}
											else if(DFM.DataType__c=='Integer') {
												Decimal fielddec= integer.valueof(fieldval);
												Itnry.put(DFM.SF_Field_API_Name__c,fielddec);
											}
											else if(DFM.DataType__c=='OtherLookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
											}
											else
												Itnry.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}
									Itnrylist.add(Itnry);
									mapItnaryBHeaders.put(Itnry.Itinerary_ID__c, BkgHeader.Org_Trip_Id__c);
								}
							}
						}
						else if(iti.BookingType==32) { //Transfer Itinerary
							List<BookingResponseNew.cls_Transfers> transferlist =iti.Transfers;
							if(transferlist!=null && transferlist.size()>0) {
								for(BookingResponseNew.cls_Transfers transfer: transferlist) {
									Map<String, Object> transfermap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(transfer));
									//system.debug('<<TransferMap>>'+transfermap);
									Itinerary__c Itnry = new Itinerary__c();
									Itnry.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
									Itnry.Type__c=lkpmap.get('Org_Booking_Type__c.'+iti.BookingType);
									Itnry.Itinerary_ID__c=string.valueof(transfer.ItineraryId);

									//Getting details of transfer pickup point
									BookingResponseNew.PickUpPoint PUpoint=transfer.PickUpPoint;
									Map<String, Object> PUpointmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(PUpoint));
									//system.debug('<<PUPointMap>>'+PUpointmap);
									if(PUpointmap!=null) {
										for(String PUkey:PUpointmap.keyset()) {
											transfermap.put('PickUpPoint.'+PUkey,PUpointmap.get(PUkey));
										}
									}

									//Getting details of transfer dropoff point
									BookingResponseNew.DropOffPoint DOpoint=transfer.DropOffPoint;
									Map<String, Object> DOpointmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(DOpoint));
									//system.debug('<<DOPointMap>>'+DOpointmap);
									if(DOpointmap!=null) {
										for(String DOkey:DOpointmap.keyset()) {
											transfermap.put('DropOffPoint.'+DOkey,DOpointmap.get(DOkey));
										}
									}

									//Getting details of transfer outbound flight
									BookingResponseNew.Flight OBflight=transfer.OutboundFlight;
									Map<String, Object> OBflightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(OBflight));
									//system.debug('<<OBflightmap>>'+OBflightmap);
									if(OBflightmap!=null) {
										for(String OBkey:OBflightmap.keyset()) {
											transfermap.put('OutboundFlight.'+OBkey,OBflightmap.get(OBkey));
										}
									}

									//Getting details of transfer inbound flight
									BookingResponseNew.Flight IBflight=transfer.InboundFlight;
									Map<String, Object> IBflightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(IBflight));
									//system.debug('<<IBflightmap>>'+IBflightmap);
									if(IBflightmap!=null) {
										for(String IBkey:IBflightmap.keyset()) {
											transfermap.put('InboundFlight.'+IBkey,IBflightmap.get(IBkey));
										}
									}
									//Getting the configured field mapping for itinerary
									for(Derwent_Field_Mapping__mdt DFM :ITImappings) {
										string fieldval=String.valueof(transfermap.get(DFM.JSON_Field__c));
										if(fieldval!=null) {
											if(DFM.DataType__c=='DateTime') {
												Itnry.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
											}
											else if(DFM.DataType__c=='Lookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
											}
											else if(DFM.DataType__c=='Checkbox') {
												Boolean boolval=false;
												if(fieldval=='true')
													boolval=true;
												Itnry.put(DFM.SF_Field_API_Name__c,boolval);
											}
											else if(DFM.DataType__c=='Integer') {
												Decimal fielddec= integer.valueof(fieldval);
												Itnry.put(DFM.SF_Field_API_Name__c,fielddec);
											}
											else if(DFM.DataType__c=='OtherLookup') {
												Itnry.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
											}
											else
												Itnry.put(DFM.SF_Field_API_Name__c,fieldval);
										}
									}
									Itnrylist.add(Itnry);
									mapItnaryBHeaders.put(Itnry.Itinerary_ID__c, BkgHeader.Org_Trip_Id__c);
								}
							}
						}
						else {
							Itinerary__c Itnry = new Itinerary__c();
							Itnry.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
							Itnry.Type__c=lkpmap.get('Org_Booking_Type__c.'+iti.BookingType);
							String itid= string.valueof(iti.ItineraryId);

							if(itid==null || itid=='')
								itid=BK.Booking_ID__c+'_'+iti.BookingType; //For itinerary types 128, 512, 1024, 2048
							Itnry.Itinerary_ID__c=itid;

							//Getting the details of the itinerary
							Map<String, Object> itimap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(iti));
							//system.debug('<<ITImap>>'+itimap);
							if(itimap != null && itimap.size()>0) {
								if(itimap.containsKey('ItineraryDate')) {
									//system.debug('<<ItineraryDate>>'+itimap.get('ItineraryDate'));
									itimap.put('Date',itimap.get('ItineraryDate'));
								}
							}
							if(iti.BookingType==16) {//airport parking itinerary
								//Getting details of outbound flight
								BookingResponseNew.Flight OBflight=iti.OutboundFlight;
								Map<String, Object> OBflightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(OBflight));
								//system.debug('<<OBflightmap>>'+OBflightmap);
								if(OBflightmap!=null) {
									for(String OBkey:OBflightmap.keyset()) {
										itimap.put('OutboundFlight.'+OBkey,OBflightmap.get(OBkey));
									}
								}
								//Getting details of  inbound flight
								BookingResponseNew.Flight IBflight=iti.InboundFlight;
								Map<String, Object> IBflightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(IBflight));
								//system.debug('<<IBflightmap>>'+IBflightmap);
								if(IBflightmap!=null) {
									for(String IBkey:IBflightmap.keyset()) {
										itimap.put('InboundFlight.'+IBkey,IBflightmap.get(IBkey));
									}
								}
							}
							else if(iti.BookingType==4) { //car hire itinerary
								//Getting details of connecting flight
								BookingResponseNew.Flight Connflight=iti.ConnectingFlight;
								Map<String, Object> Connflightmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Connflight));
								//system.debug('<<Connflightmap>>'+Connflightmap);
								if(Connflightmap!=null) {
									for(String Connkey:Connflightmap.keyset()) {
										itimap.put('ConnectingFlight.'+Connkey,Connflightmap.get(Connkey));
									}
								}
							}
							//Getting the configured field mapping for itineraries
							for(Derwent_Field_Mapping__mdt DFM :ITImappings) {
								string fieldval=String.valueof(itimap.get(DFM.JSON_Field__c));
								if(fieldval!=null) {
									if(DFM.DataType__c=='DateTime') {
										Itnry.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
									}
									else if(DFM.DataType__c=='Lookup') {
										Itnry.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
									}
									else if(DFM.DataType__c=='Checkbox') {
										Boolean boolval=false;
										if(fieldval=='true')
											boolval=true;
										Itnry.put(DFM.SF_Field_API_Name__c,boolval);
									}
									else if(DFM.DataType__c=='Integer') {
										Decimal fielddec= integer.valueof(fieldval);
										Itnry.put(DFM.SF_Field_API_Name__c,fielddec);
									}
									else if(DFM.DataType__c=='OtherLookup') {
										Itnry.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
									}
									else
										Itnry.put(DFM.SF_Field_API_Name__c,fieldval);
								}
							}
							Itnrylist.add(Itnry);
							mapItnaryBHeaders.put(Itnry.Itinerary_ID__c, BkgHeader.Org_Trip_Id__c);
						}
					}
					//Getting the travellers related to each booking from json
					List<BookingResponseNew.cls_Passengers> Passlist =Bkng.Passengers;
					if(Passlist!=null && Passlist.size()>0) {
						Integer[] iAgeCats = new Integer[] {0,0}; //mapTravellerCategory // v1.43

						for(BookingResponseNew.cls_Passengers Pass: Passlist) {
							Traveller__c TR = new Traveller__c();
							TR.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);
							TR.name= Pass.firstname +' '+ Pass.surname;
							Map<String, Object> passmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Pass));
							//system.debug('<<MMM22>>'+passmap);
							//Getting the configured field mapping for travellers
							for(Derwent_Field_Mapping__mdt DFM :TRAmappings) {
								string fieldval=String.valueof(passmap.get(DFM.JSON_Field__c));
								if(fieldval!=null) {
									if(DFM.DataType__c=='DateTime') {
										TR.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
									}
									else if(DFM.DataType__c=='Date') {
										fieldval=fieldval.replace('T',' ');
										//string rem=fieldval.right(5);
										//fieldval=fieldval.remove(rem);
										date dateval= Date.valueOf(fieldval);
										TR.put(DFM.SF_Field_API_Name__c,dateval);
									}
									else if(DFM.DataType__c=='Lookup') {
										TR.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
									}
									else if(DFM.DataType__c=='Checkbox') {
										Boolean boolval=false;
										if(fieldval=='true')
											boolval=true;
										TR.put(DFM.SF_Field_API_Name__c,boolval);
									}
									else if(DFM.DataType__c=='Integer') {
										Decimal fielddec= integer.valueof(fieldval);
										TR.put(DFM.SF_Field_API_Name__c,fielddec);
									}
									else
										TR.put(DFM.SF_Field_API_Name__c,fieldval);
								}
							}
							//v1.43
							if(mapTravellerCategory.get(1).contains(TR.Org_Age_Category__c)) {
								iAgeCats[0]++;
							}
							if(mapTravellerCategory.get(2).contains(TR.Org_Age_Category__c)) {
								iAgeCats[1]++;
							}
							//v1.43
							if(system.label.Run_Traveller_Count == 'false')
								TRAlist.add(TR);
						}

						//v1.43
						if(iAgeCats[0] > 0)
							BK.Number_of_adults__c = iAgeCats[0];
						if(iAgeCats[1] > 0)
							BK.Number_of_children__c = iAgeCats[1];
						//End of v1.43
					}

					System.debug('BK.Number_of_adults__c is : '+BK.Number_of_adults__c);
					System.debug('BK.Number_of_children__c is : '+BK.Number_of_children__c);

					//Getting the price line items of each booking record
					List<BookingResponseNew.cls_LineItems> Lineitemlist =Bkng.LineItems;
					if(Lineitemlist!=null && Lineitemlist.size()>0) {
						//mapBookingPriceBreakDown.put(BK.Booking_ID__c, JSON.serialize(Lineitemlist));
						bookingLineItemMap.put(BK.Booking_ID__c,Lineitemlist); //v1.45
						system.debug('#!#!#!#!#!#!#bookingLineItemMap: ' + bookingLineItemMap);
						for(BookingResponseNew.cls_LineItems Lineitem: Lineitemlist) {
							//Booking_Price_Breakdown__c Price = new Booking_Price_Breakdown__c();
							//Price.Org_Booking__r= new Booking__c(Booking_ID__c= BK.Booking_ID__c);

							//Map<String, Object> pricemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Lineitem));

							//Added as part of v1.5
							if(caseid==null) {
								if(Lineitem.SupplierRef != null) {
									if(enqcasemap.size()>0)
										if(enqcasemap.get(Lineitem.SupplierRef)!=null)
											caseid= enqcasemap.get(Lineitem.SupplierRef);
								}
							}

							if(Lineitem.SupplierRef != null) {

								string suplierRef = mapBookingPriceBreakDown.containsKey(BK.Booking_ID__c) ? mapBookingPriceBreakDown.get(BK.Booking_ID__c) : '';
								if(!suplierRef.contains(Lineitem.SupplierRef)) {
									suplierRef += suplierRef != '' ? (','+Lineitem.SupplierRef) : Lineitem.SupplierRef;
								}
								mapBookingPriceBreakDown.put(BK.Booking_ID__c, suplierRef);
							}

							//system.debug('<<MMM22>>'+pricemap);
							//Getting the configured field mapping for lineitems
							/*for(Derwent_Field_Mapping__mdt DFM :Pricemappings){
							    string fieldval=String.valueof(pricemap.get(DFM.JSON_Field__c));
							    if(fieldval!=null){
							        if(DFM.DataType__c=='DateTime'){
							            fieldval=fieldval.replace('T',' ');
							            //string rem=fieldval.right(5);
							            //fieldval=fieldval.remove(rem);
							            datetime dateval= Datetime.valueOf(fieldval);

							            Price.put(DFM.SF_Field_API_Name__c,dateval);
							        }
							        else if(DFM.DataType__c=='Lookup'){
							            Price.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							        }
							        else if(DFM.DataType__c=='Checkbox'){
							            Boolean boolval=false;
							            if(fieldval=='true')
							                boolval=true;
							            Price.put(DFM.SF_Field_API_Name__c,boolval);
							        }
							        else if(DFM.DataType__c=='Integer'){
							            Decimal fielddec= decimal.valueof(fieldval);
							            Price.put(DFM.SF_Field_API_Name__c,fielddec);
							        }
							        else
							            Price.put(DFM.SF_Field_API_Name__c,fieldval);
							    }
							   }
							   Pricelist.add(Price);*/
						}
					}

					bookingType = BK.Org_Booking_Type__c;
					if(BK.Booked_By_Email__c != null)
						mapOwnerEmailIds.put(BK.Booked_By_Email__c.toLowerCase(), null);
					if(BK.Booked_by_Username__c != null)
						mapDerwentUsernames.put(BK.Booked_by_Username__c, null);
					lstBookingRecords.add(BK);
					mapBookingItems.put(BK.Booking_ID__c, BK);
					BkglistMap.put(BK.Derwent_Version_Number__c,BK);//v1.37
				}

				if(countOfBooking > 1) {
					BkgHeader.Product_Type__c = 'Package';
				}

				if(countOfBooking == 1) {
					BkgHeader.Product_Type__c = bookingType;
				}

				if(accountid != '' ) {
					BkgHeader.Org_Account_Name__r= new Account(Org_Derwent_Customer_No__c= accountid);
				}
				else{
					BkgHeader.Org_Account_Name__c=null;
				}

				//Added as part of v1.5
				if(caseid!=null)
					BkgHeader.Org_SF_Case_Reference__c=caseid;

				mapBookingHeaders.put(BkgHeader.Org_Trip_Id__c, BkgHeader);//BkgHeaderlist.add(BkgHeader);
			}

			//Getting the cases from tracking tag
			List<id> ExistBkngHdrIds = new List<id>();
			Map<id,id> existbkngcasemap = new Map<id,id>();
			if(casebkngmap.size()>0) {
				//Get the existing booking id on the case
				for(Case c:[select id,Org_Booking__c from Case where id in:casebkngmap.keyset()]) {
					existbkngcasemap.put(c.Org_Booking__c,c.id);
				}

				//Query the booking tagged on the case and update the trip id
				//List<Booking__c>ExistBkngHdrList = [select id,Org_Trip_Id__c from Booking__c where id in:existbkngcasemap.keyset()];
				list<Booking__c> ExistBkngHdrList = new list<Booking__c>();
				for(Booking__c ExistHdr : [select id,Org_Trip_Id__c, Booking_System__c from Booking__c where id in:existbkngcasemap.keyset()]) {
					if(ExistHdr.Org_Trip_Id__c==null) { //if condition added as part of v1.32
						ExistHdr.Org_Trip_Id__c = casebkngmap.get(existbkngcasemap.get(ExistHdr.id)).Org_Trip_Id__c;
						//Ravi ExistBkngHdrList.add(ExistHdr);
						if(mapBookingHeaders.containsKey(ExistHdr.Org_Trip_Id__c)) {
							mapBookingHeaders.get(ExistHdr.Org_Trip_Id__c).Id = ExistHdr.Id;
							mapBookingHeaders.get(ExistHdr.Org_Trip_Id__c).Booking_System__c = ExistHdr.Booking_System__c;
							ExistBkngHdrList.add(ExistHdr);
						}
					}
				}
				// Updating Booking Headers for which Booking is already created in Salesforce by Agent mostly for dnata
				if(!ExistBkngHdrList.isEmpty()) {
					BookingTriggerHandler.BlockBookingTrigger = true;
					update ExistBkngHdrList;
					BookingTriggerHandler.BlockBookingTrigger = false;
				}

			}

			// v1.35 - not using query result anywhere
			// List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in :recordids ];
			List<Integer> ErrorBooklist = new List<Integer>();
			ErrorBooklist =getBookresp.NotFoundBookings;
			map<String,Database.Error> ErrorBookingMap = new map<String,Database.Error>();
			//Upserting Booking Header records

			//map<string, list<Datetime>> mapTravelDates = new map<string, list<Datetime>>();
			map<string, list<Date> > mapTravelDatesBooks = new map<string, list<Date> >();



			//v1.35
			if(!lstBookingRecords.isEmpty()) {

				if(!mapOwnerEmailIds.isEmpty() || !mapDerwentUsernames.isEmpty()) {
					for(User objUser : [select Id,Email,Derwent_Username__c from User where (Email IN : mapOwnerEmailIds.keySet() OR Derwent_Username__c IN :mapDerwentUsernames.keySet() ) AND isActive = true]) {
						if(mapOwnerEmailIds.containsKey(objUser.Email.toLowerCase())) {
							mapOwnerEmailIds.put(objUser.Email.toLowerCase(), objUser.Id);
						}
						if(mapDerwentUsernames.containsKey(objUser.Derwent_Username__c) )
							mapDerwentUsernames.put(objUser.Derwent_Username__c, objUser.Id);
					}
				}

				/*List<Itinerary__c> lstAllItnaties = new List<Itinerary__c>();
				   if(!ItnryExtlist.isEmpty())
				    lstAllItnaties.addAll(ItnryExtlist);
				   if(!Itnrylist.isEmpty())
				    lstAllItnaties.addAll(Itnrylist);
				 */
				//if(!lstAllItnaties.isEmpty()){ // to populate the Hotel Name
				//  map<string, integer> mapIc = new map<string, Integer>();
				//map<string, string> mapHotels = new map<string, string>();
				/*for(Itinerary__c objItnary : lstAllItnaties){
				    if(objItnary.Type__c == 'Accommodation' && objItnary.Org_Check_Out__c != null && objItnary.Org_Check_In__c != null){
				        Integer days = Date.valueOf(objItnary.Org_Check_In__c).daysBetween(Date.valueOf(objItnary.Org_Check_Out__c));
				        string tripId = objItnary.Itinerary_ID__c != null ? mapItnaryBHeaders.get(objItnary.Itinerary_ID__c) : mapItnaryBHeaders.get(objItnary.External_System_ID__c) ;
				        if(mapIc.containsKey(tripId) ){
				            if(mapIc.get(tripId) < days){
				                mapIc.put(tripId, days);
				                mapHotels.put(tripId, objItnary.Org_Hotel_Name__c);
				            }
				        }else{
				            mapIc.put(tripId, days);
				            mapHotels.put(tripId, objItnary.Org_Hotel_Name__c);
				        }
				       /* string bookId = objItnary.Org_Booking__r.Booking_ID__c;
				        list<Datetime> lst = mapTravelDates.containsKey(bookId) ? mapTravelDates.get(bookId) : new list<Datetime>{null, null};
				        if(lst[0] != null){
				            if(lst[0] < objItnary.Org_Check_In__c)
				                lst[0] = lst[0];
				        }else {
				            lst[0] = objItnary.Org_Check_In__c;
				        }

				        if(lst[1] != null){
				            if(lst[1] < objItnary.Org_Check_Out__c)
				                lst[1] = objItnary.Org_Check_Out__c;
				        }else {
				            lst[1] = objItnary.Org_Check_Out__c;
				        }
				        mapTravelDates.put(bookId, lst);* /
				    }
				   }*/

				//for(Booking__c BookingHeader : mapBookingHeaders.values()){
				//  if(mapHotels.get(BookingHeader.Org_Trip_Id__c) != null){
				// BookingHeader.Hotel_Name__c = mapHotels.get(BookingHeader.Org_Trip_Id__c);
				//}
				//}
				//}
				//set<string> setIts = new set<string>();

				//for(string iKey : mapItnaryDates.keySet()){

				//Itinerary_Detail__c objID = mapItnaryDetails.get(iKey);
				//string bookId = mapItnaryDetails.get(iKey);

				//if(mapBookingItnaryDetails.containsKey(objID.Org_Itinerary_Detail_Id__c)){
				//string bookId = mapBookingItnaryDetails.get(objID.Org_Itinerary_Detail_Id__c);
				//if(mapItnaryDates.containsKey(bookId)){
				//system.debug('Segment Dates '+mapItnaryDates.get(iKey));
				//mapTravelDates.put(bookId, mapItnaryDates.get(iKey));
				//}
				/*if(objId.Itinerary_Detail_Type__c == 'Segment'){
				    list<Datetime> lst = mapTravelDates.containsKey(bookId) ? mapTravelDates.get(bookId) : new list<Datetime>{null, null};
				    list<string> lstSegs = mapBookingSegments.containsKey(bookId) ? mapBookingSegments.get(bookId) : new list<string>{null, null};

				    if(!mapBookingSupliers.containsKey(bookId))
				        mapBookingSupliers.put(bookId, new set<string>());
				    string tripId = objID.Itinerary__r.Itinerary_ID__c != null ? objID.Itinerary__r.Itinerary_ID__c : objID.Itinerary__r.External_System_ID__c ;
				    if(objID.Org_Operating_Carrier__c != null && setIts.contains( tripId )){
				        mapBookingSupliers.get(bookId).add(objID.Org_Operating_Carrier__c);
				        setIts.add( tripId );
				    }
				    if(mapItnaryDates.containsKey(bookId)){
				        system.debug('Segment Dates '+mapItnaryDates.get(bookId));
				        mapTravelDates.put(bookId, mapItnaryDates.get(bookId));
				    }
				    /*if(lst[0] != null){
				        if(depatureDate < lst[0] )
				            lst[0] = depatureDate;
				    }else {
				        lst[0] = depatureDate;
				        lstSegs[0] = objID.Arrival_Airport__c;
				    }

				    if(lst[1] != null){
				        if(lst[1] < arrivalDate)
				            lst[1] = arrivalDate;
				            lstSegs[1] = objID.Departure_Airport__c;
				    }else {
				        lst[1] = arrivalDate;
				        lstSegs[1] = objID.Departure_Airport__c;
				    }* /
				    //mapTravelDates.put(bookId, lst);
				    mapBookingSegments.put(bookId, lstSegs);
				   }*/
				//}
				//}

				for(Booking__c objBooking : lstBookingRecords) {

					if(objBooking.Org_Booking_Type__c == 'Accommodation' || objBooking.Org_Booking_Type__c == 'Flight' ) {
						objBooking.Destination__c = mapDestinations.get(objBooking.Booking_ID__c);
					}

					//system.debug('travelDates is : '+mapTravelDates.get(objBooking.Booking_ID__c));

					if(mapItnaryDates.containsKey(objBooking.Booking_ID__c)) {
						objBooking.Org_Travel_Start_Date__c = mapItnaryDates.get(objBooking.Booking_ID__c)[0] != null ? Date.valueOf(mapItnaryDates.get(objBooking.Booking_ID__c)[0]) : null;
						objBooking.Org_Travel_End_Date__c = mapItnaryDates.get(objBooking.Booking_ID__c)[1] != null ? Date.valueOf(mapItnaryDates.get(objBooking.Booking_ID__c)[1]) : null;

						string bookId = objBooking.Booking_Header__r.Org_Trip_Id__c;
						list<Date> lst = mapTravelDatesBooks.containsKey(bookId) ? mapTravelDatesBooks.get(bookId) : new list<Date> {null, null};
						if(lst[0] != null) {
							if(lst[0] < objBooking.Org_Travel_Start_Date__c)
								lst[0] = lst[0];
						}else {
							lst[0] = objBooking.Org_Travel_Start_Date__c;
						}

						if(lst[1] != null) {
							if(lst[1] < objBooking.Org_Travel_End_Date__c)
								lst[1] = objBooking.Org_Travel_End_Date__c;
						}else {
							lst[1] = objBooking.Org_Travel_End_Date__c;
						}
						mapTravelDatesBooks.put(bookId, lst);
					}

					/*if(mapBookingSegments.containsKey(objBooking.Booking_ID__c) || mapBookingSupliers.containsKey(objBooking.Booking_ID__c)) {
					    list<string> lst = mapBookingSegments.containsKey(objBooking.Booking_ID__c) ? mapBookingSegments.get(objBooking.Booking_ID__c) : new list<string> {null, null};
					    if(lst[0] != lst[1] || mapBookingSupliers.get(objBooking.Booking_ID__c).size() > 1) {
					        objBooking.Mix_Match__c = true;
					        system.debug( ' objBooking.Mix_Match__c is :  true');
					    }else{
					        system.debug( ' objBooking.Mix_Match__c is :  false');
					    }
					   }*/

					if(mapBookingPriceBreakDown.containsKey(objBooking.Booking_ID__c)) {
						//objBooking.Booking_Price_Breakdown__c = mapBookingPriceBreakDown.get(objBooking.Booking_ID__c);
						objBooking.Booking_Price_Breakdown__c = mapBookingPriceBreakDown.get(objBooking.Booking_ID__c);
						objBooking.Supplier_Names__c = mapBookingPriceBreakDown.get(objBooking.Booking_ID__c);
						if(objBooking.Supplier_Names__c != null && objBooking.Supplier_Names__c.length() > 255)
							objBooking.Supplier_Names__c = objBooking.Supplier_Names__c.substring(0, 254);
						if(mapBookingPriceBreakDown.get(objBooking.Booking_ID__c) != null) {
							if(mapBookingPriceBreakDown.get(objBooking.Booking_ID__c).split(',').size() > 2) //v1.44.3
								objBooking.Mix_Match__c = true;
						}
					}

					if(mapBookingHeaders.containsKey(objBooking.Booking_Header__r.Org_Trip_Id__c)) {
						Booking__c BookingHeader = mapBookingHeaders.get(objBooking.Booking_Header__r.Org_Trip_Id__c);
						if(objBooking.Booking_Status__c == Str_Receipted && objBooking.Org_Brand__c != Str_ekh) {
							BookingHeader.Booking_Status__c = Str_Receipted;
						}else if(BookingHeader.Booking_Status__c == null) {
							BookingHeader.Booking_Status__c = objBooking.Booking_Status__c;
						}
						BookingHeader.Booking_System__c = BookingHeader.Booking_System__c != null ? BookingHeader.Booking_System__c : objBooking.Booking_System__c;
						if(objBooking.Booking_System__c != BookingHeader.Booking_System__c) {
							BookingHeader.Booking_System__c = 'Multiple Systems';
						}

						BookingHeader.Booked_By_Email__c = objBooking.Booked_By_Email__c != null ? objBooking.Booked_By_Email__c : BookingHeader.Booked_By_Email__c;
						BookingHeader.Org_BookedById__c = objBooking.Org_BookedById__c != null ? objBooking.Org_BookedById__c : BookingHeader.Org_BookedById__c;
						BookingHeader.Org_BookedByName__c = objBooking.Org_BookedByName__c != null ? objBooking.Org_BookedByName__c : BookingHeader.Org_BookedByName__c;
						BookingHeader.Org_Booked_Date__c = objBooking.Org_Booked_Date__c != null ? objBooking.Org_Booked_Date__c : BookingHeader.Org_Booked_Date__c;

						/* Adding counts  */
						BookingHeader.Org_Total_Cost__c = ((BookingHeader.Org_Total_Cost__c == null ? 0 : BookingHeader.Org_Total_Cost__c)
						                                   +(objBooking.Org_Total_Cost__c != null ? objBooking.Org_Total_Cost__c : 0));

						objBooking.Org_Total_Cost_Client_Currency_Number__c = doTotalCostCC( objBooking.Org_Total_Cost__c, objBooking.Org_Accounting_Exchange_Rate__c, objBooking.Org_ClientCurrencyExchangeRate__c);

						BookingHeader.Org_Total_Cost_Client_Currency_Number__c = ((BookingHeader.Org_Total_Cost_Client_Currency_Number__c == null ? 0 : BookingHeader.Org_Total_Cost_Client_Currency_Number__c)
						                                                          +(objBooking.Org_Total_Cost_Client_Currency_Number__c != null ? objBooking.Org_Total_Cost_Client_Currency_Number__c : 0));
						/*
						   BookingHeader.Org_Total_Cost_Client_Currency_Number__c = ((BookingHeader.Org_Total_Cost_Client_Currency_Number__c == null ? 0 : BookingHeader.Org_Total_Cost_Client_Currency_Number__c)
						 +(objBooking.Org_Total_Cost_Client_Currency_Number__c != null ? objBooking.Org_Total_Cost_Client_Currency_Number__c : 0));
						 */
						BookingHeader.Total_Cost_AED__c = ((BookingHeader.Total_Cost_AED__c == null ? 0 : BookingHeader.Total_Cost_AED__c)
						                                   +(objBooking.Total_Cost_AED__c != null ? objBooking.Total_Cost_AED__c : 0));

						BookingHeader.Product_Type__c = lstBookingRecords.size() > 1 ? 'Package' : objBooking.Org_Booking_Type__c;

						BookingHeader.Org_Booked_Date__c =  (BookingHeader.Org_Booked_Date__c < objBooking.Org_Booked_Date__c ? BookingHeader.Org_Booked_Date__c : objBooking.Org_Booked_Date__c);

						/* End of counts */

						if(objBooking.Org_Booking_Type__c == 'Flight')
							BookingHeader.Flight_Destination__c = objBooking.Destination__c;
						if(objBooking.Org_Booking_Type__c == 'Accommodation')
							BookingHeader.Hotel_Destination__c = objBooking.Destination__c;
						BookingHeader.Org_ClientCurrencyCode__c = BookingHeader.Org_ClientCurrencyCode__c != null ? objBooking.Org_ClientCurrencyCode__c : BookingHeader.Org_ClientCurrencyCode__c;
						if(objBooking.Booked_by_Username__c != null && mapDerwentUsernames.get(objBooking.Booked_by_Username__c) != null ) {
							objBooking.OwnerId = mapDerwentUsernames.get(objBooking.Booked_by_Username__c);
							BookingHeader.OwnerId = objBooking.OwnerId;
						}else if(objBooking.Booked_By_Email__c != null && mapOwnerEmailIds.get(objBooking.Booked_By_Email__c.toLowerCase()) != null) {
							objBooking.OwnerId = mapOwnerEmailIds.get(objBooking.Booked_By_Email__c.toLowerCase());
							BookingHeader.OwnerId = objBooking.OwnerId;
						}
						mapBookingHeaders.put(objBooking.Booking_Header__r.Org_Trip_Id__c, BookingHeader);
					}
					
					//v1.45
					if(bookingLineItemMap.containsKey(objBooking.Booking_ID__c)){
						for(BookingResponseNew.cls_LineItems Lineitem : bookingLineItemMap.get(objBooking.Booking_ID__c)){
							map<String, Object> lineItemMap = (map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Lineitem));
							for(LineItem_Field_Mapping__mdt lineItemField : lineItemFieldMappings){
								string fieldValue = string.valueOf(lineItemMap.get(lineItemField.JSON_Field__c));
								if(fieldValue != null){
									if(lineItemField.DataType__c == 'Integer'){
										Decimal decimalValue = decimal.valueOf(fieldValue);
										if(objBooking.get(lineItemField.SF_Field_API_Name__c) == null){
											if(lineItemField.JSON_Field__c == 'RebateAmount' || lineItemField.JSON_Field__c == 'UpsellAmount'){
												objBooking.put(lineItemField.SF_Field_API_Name__c, decimalValue * decimal.valueOf(Lineitem.AccountingExchangeRate));
											} else {
												objBooking.put(lineItemField.SF_Field_API_Name__c, decimalValue);
											}
										} else {
											if(lineItemField.JSON_Field__c == 'RebateAmount' || lineItemField.JSON_Field__c == 'UpsellAmount'){
												objBooking.put(lineItemField.SF_Field_API_Name__c, (decimal)objBooking.get(lineItemField.SF_Field_API_Name__c) + (decimalValue * decimal.valueOf(Lineitem.AccountingExchangeRate)));
											} else {
												objBooking.put(lineItemField.SF_Field_API_Name__c, (decimal)objBooking.get(lineItemField.SF_Field_API_Name__c) + decimalValue);
											}
										}
										
									} else {
										objBooking.put(lineItemField.SF_Field_API_Name__c, objBooking.get(lineItemField.SF_Field_API_Name__c) + fieldValue);
									}	
								}
							}							

						}
						//calculate total gross
						objBooking.Total_Gross__c = ((objBooking.Total_Gross__c == null ? 0 : objBooking.Total_Gross__c) + ((objBooking.Org_ClientTotalCost__c != null ? objBooking.Org_ClientTotalCost__c : 0) + (objBooking.UpsellAmount__c != null ? objBooking.UpsellAmount__c : 0) - (objBooking.RebateAmount__c != null ? objBooking.RebateAmount__c : 0)));
						//rollup total gross to booking header
						if(mapBookingHeaders.containsKey(objBooking.Booking_Header__r.Org_Trip_Id__c)){
							mapBookingHeaders.get(objBooking.Booking_Header__r.Org_Trip_Id__c).Client_Total_Gross__c = (mapBookingHeaders.get(objBooking.Booking_Header__r.Org_Trip_Id__c).Client_Total_Gross__c  == null ? 0 : mapBookingHeaders.get(objBooking.Booking_Header__r.Org_Trip_Id__c).Client_Total_Gross__c) + (objBooking.Total_Gross__c == null ? 0 : objBooking.Total_Gross__c);
						}

					}
					//End v1.45					
					
				}

				for(string header : mapBookingHeaders.keySet()) {
					Booking__c BookingHeader = mapBookingHeaders.get(header);
					if(BookingHeader != null) {
						if( mapTravelDatesBooks.containsKey(BookingHeader.Org_Trip_Id__c)) {
							BookingHeader.Org_Travel_Start_Date__c = mapTravelDatesBooks.get(BookingHeader.Org_Trip_Id__c)[0];
							BookingHeader.Org_Travel_End_Date__c = mapTravelDatesBooks.get(BookingHeader.Org_Trip_Id__c)[1];
						}
						if(mapHotelStays.containsKey(BookingHeader.Org_Trip_Id__c) && mapHotelStays.get(BookingHeader.Org_Trip_Id__c)[0] != null) {
							BookingHeader.Hotel_Name__c = mapHotelStays.get(BookingHeader.Org_Trip_Id__c)[0];
						}
						mapBookingHeaders.put(header, BookingHeader);
					}
				}
			}

			isFromDerwentCall = true;
			if( checkCPUTime(4) ) {
				lstInPorgressItems = prepareInProgressItems(mapBookingHeaders, lstBookingRecords, Itnrylist, ItnryExtlist, ItnryDetlist, TRAlist, Pricelist, csrlist, RequestLog, tripidlist );
				AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
				objAWS.PendingItems = lstInPorgressItems;
				system.enqueueJob( objAWS );
				return;
			}

			if(!mapBookingHeaders.isEmpty()) { //BkgHeaderlist
				BkgHeaderlist.addAll(mapBookingHeaders.values());
				//system.debug('BkgHeaderlist is : '+BkgHeaderlist);
				upsert BkgHeaderlist Booking__c.Fields.Org_Trip_Id__c;
			}

			if( checkCPUTime(2) ) {
				lstInPorgressItems = prepareInProgressItems(null, lstBookingRecords, Itnrylist, ItnryExtlist, ItnryDetlist, TRAlist, Pricelist, csrlist, RequestLog, tripidlist );
				AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
				objAWS.PendingItems = lstInPorgressItems;
				system.enqueueJob( objAWS );
				return;
			}

			//Upserting Booking records
			if(!lstBookingRecords.isEmpty()) {
				/* Added as a part of v1.16 upsert bookings only if version number is greater*******/

				if(Label.UpsertDerwentBookings == 'TRUE') {
					if(derwentVersionBkngMap.values().size() >0) {
						for(Decimal str:derwentVersionBkngMap.values()) {
							if(Derwent_Version > str) {//Added as a part of v1.16
								upsert lstBookingRecords Booking__c.Fields.Booking_ID__c;
							}//else
							 //system.debug('Upsert not required *******************');
						}
					}
					else
						upsert lstBookingRecords Booking__c.Fields.Booking_ID__c;
				}
				//End of v1.16
				else{ //v.16
					//system.debug('Upserting the bookings');
					upsert lstBookingRecords Booking__c.Fields.Booking_ID__c;
				} // v1.16
			}

			if( checkCPUTime(1.5) ) {
				lstInPorgressItems = prepareInProgressItems(null, null, Itnrylist, ItnryExtlist, ItnryDetlist, TRAlist, Pricelist, csrlist, RequestLog, tripidlist );
				AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
				objAWS.PendingItems = lstInPorgressItems;
				system.enqueueJob( objAWS );
				return;
			}

			//Deleting the existing itineraries of the trips
			if(ExistItinList.size()>0) {
				delete ExistItinList;
			}


			//Inserting itineraries and itinerary details of the trips
			if(Itnrylist.size()>0) {
				upsert Itnrylist Itinerary__c.Fields.Itinerary_ID__c;
			}

			if(ItnryExtlist.size()>0) {
				upsert ItnryExtlist Itinerary__c.Fields.External_System_ID__c;
			}

			if( checkCPUTime(1.5) ) {
				lstInPorgressItems = prepareInProgressItems(null, null, null, null, ItnryDetlist, TRAlist, Pricelist, csrlist, RequestLog, tripidlist );
				AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
				objAWS.PendingItems = lstInPorgressItems;
				system.enqueueJob( objAWS );
				return;
			}

			if(ItnryDetlist.size()>0) {
				upsert ItnryDetlist Itinerary_Detail__c.Fields.Org_Itinerary_Detail_Id__c;
			}

			if( checkCPUTime(1.5) ) {
				lstInPorgressItems = prepareInProgressItems(null, null, null, null, null, TRAlist, Pricelist, csrlist, RequestLog, tripidlist );
				AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
				objAWS.PendingItems = lstInPorgressItems;
				system.enqueueJob( objAWS );
				return;
			}

			//Deleting the existing travellers of the trips
			if(ExistTravList.size()>0) {
				delete ExistTravList;
			}

			//Inserting travellers of the trips
			if(TRAlist.size()>0) {
				upsert TRAlist Traveller__c.Fields.Org_Traveller_ID__c;
			}

			/*if( checkCPUTime(1.5) ){
			    lstInPorgressItems = prepareInProgressItems(null, null, null, null, null, null, Pricelist, notelist, csrlist, RequestLog, tripidlist );
			    AsyncDerwentWebService objAWS = new AsyncDerwentWebService();
			    objAWS.PendingItems = lstInPorgressItems;
			    system.enqueueJob( objAWS );
			    return;
			   }*/

			//Deleting the existing price line items of the trips
			/*if(ExistPriceList.size()>0){
			    delete ExistPriceList;
			   } */
			//Inserting the price line items of the trips
			/*if(Pricelist.size()>0){
			    upsert Pricelist Booking_Price_Breakdown__c.Fields.Org_Line_Item_Id__c;
			   }
			   if(notelist.size()>0){
			    upsert notelist Booking_Note__c.Fields.Org_Note_Id__c;
			   }
			   if(csrlist.size()>0){
			    upsert csrlist CSR__c.Fields.TaskID__c;
			   }*/
			BKmappings.clear();
			ITImappings.clear();
			staymappings.clear();
			roommappings.clear();
			segmentmappings.clear();
			TRAmappings.clear();
			Pricemappings.clear();
			Notemappings.clear();
			CSRmappings.clear();
			CSRQuemappings.clear();
			CSRNotemappings.clear();
			TRAlist.clear();
			Itnrylist.clear();
		}


		List<Integer> ErrorBooklist = new List<Integer>();
		ErrorBooklist =getBookresp.NotFoundBookings;

		if(ErrorBooklist!=null && ErrorBooklist.isEmpty() == false) {
			if(ErrorBooklist.contains(integer.valueof(AsyncDerwentWebService.RequestLog.Entity_Id__c))) {
				AsyncDerwentWebService.RequestLog.Error_Log__c = (AsyncDerwentWebService.RequestLog.Error_Log__c != null ? AsyncDerwentWebService.RequestLog.Error_Log__c : '') + 'Not found bookings';
				AsyncDerwentWebService.RequestLog.Status__c = 'Failed';
			}
		} else{
			for(Id LogId : recordids) {
				AsyncDerwentWebService.RequestLog.Id = logId;
				AsyncDerwentWebService.RequestLog.Status__c = 'Completed';
			}

		}
		upsert AsyncDerwentWebService.RequestLog;

		/*List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in :recordids ];
		   for(Request_Log__c req :ReqList){
		    if(ErrorBooklist!=null){
		        if(ErrorBooklist.contains(integer.valueof(req.Entity_Id__c))){
		            req.Error_Log__c='Not found bookings';
		            req.Status__c='Failed';
		        }
		    }
		    else
		        req.Status__c='Completed';
		   }
		   update ReqList;
		 */


	}
	
	/**********************Preparing the request parameters for the get CSR request*********************************/
	public static string prepareGetCSR(List<id> rids){

		//Querying the customer records
		string ReqQuery = getCreatableFieldsSOQL('Request_Log__c');
		string entity='CSR';
		ReqQuery+=' where Entity__c = \'' + entity+ '\'  AND Id in :rids';
		List<Request_Log__c> CSRlist= database.query(ReqQuery);

		String reqparams = '';

		for(integer i=1; i<=CSRlist.size(); i++) {
			reqparams+= 'csrIds='+CSRlist[i-1].Entity_Id__c;
			if(i!=CSRlist.size())
				reqparams+= '&';
		}
		//system.debug('>>>>>Request Parameters>>>>>>'+reqparams);
		return reqparams;





	}
	/**********************Callout for getting booking details*********************************/

	webservice static void getCSR(List<id> recordids){
		String BookingId = '';
		String DomainId = '';
		getDerwentsetting('Get_CSR');
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');

		String reqparams = prepareGetCSR(recordids);
		String endpointurl = endurl+ reqparams;
		//system.debug('>>>>>Request >>>>>>'+ endpointurl);
		//req.setbody(reqJSON);
		req.setEndpoint(endpointurl);
		Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(60 * 1000);
		HTTP http = new HTTP();
		// if(!Test.isrunningTest()){
		try{
			HTTPResponse res = http.send(req);
			//system.debug('>>>>>CSR Response>>>>>>'+res.getbody());
			CSR_Response getCSRresp= CSR_Response.parse(res.getbody());

			//Getting the details of all csrs in the response
			List<CSR_Response.Csrs> RespCsrlist =getCSRresp.Csrs;
			if(RespCsrlist != null && RespCsrlist.size()>0) {
				BookingId = string.valueof(RespCsrlist[0].BookingId);
			}
			getDerwentsetting('Get_Booking');
			//Add for v1.13 Service Request CSR
			HTTPRequest bookreq = new HTTPRequest();
			bookreq.setMethod('GET');
			//Booking request
			String bookreqparams = 'tripids='+BookingId;
			String bookendpointurl = endurl+ bookreqparams;
			//system.debug('>>>>>Book Request>>>>>>'+ bookendpointurl);
			bookreq.setEndpoint(bookendpointurl);
			Blob bookheaderValue = Blob.valueOf(usrname + ':' + pwd);
			String bookauthorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(bookheaderValue);
			bookreq.setHeader('Authorization', bookauthorizationHeader);
			bookreq.setTimeout(60 * 1000);
			HTTP bookhttp = new HTTP();

			HTTPResponse bookres = bookhttp.send(bookreq);

			////system.debug('>>>>>Book Response>>>>>>'+bookres.getbody());

			BookingResponseNew getBookresp= BookingResponseNew.parse(bookres.getbody());

			List<BookingResponseNew.cls_Trips> Triplist =getBookresp.Trips;
			if(Triplist != null && Triplist.size()>0) {
				//Getting the bookings in each booking header
				for(BookingResponseNew.cls_Bookings Bkng: Triplist[0].Bookings) {
					//Getting details of Booking Detail
					if(Bkng.BookingCore != null && Bkng.BookingCore.DomainId != null) {
						DomainId = String.valueOf(Bkng.BookingCore.DomainId);
						//system.debug('DomainId===>'+DomainId);
					}
				}
			}

			Map<String,String> derwentMap = getLookupvalue();
			//system.debug('derwent map'+derwentMap);
			//End of v1.13 Service Request CSR

			//Changed for v1.13
			if(derwentMap.containsKey('DomainId__c.'+DomainId) && Label.Service_Request_Brand.contains(derwentMap.get('DomainId__c.'+DomainId))) {
				//system.debug('**********TRP Callout'+derwentMap.get('DomainId__c.'+DomainId));
				parseGetServiceRequestResponse(res.getBody(),recordids,derwentMap.get('DomainId__c.'+DomainId));
			} else {
				//system.debug('**********EKH Callout'+derwentMap.get('DomainId__c.'+DomainId));
				parseGetCSRResponse(res.getBody(),recordids);
			}


		}
		catch(Exception ex) {
			//system.debug('Callout error: '+ ex);
			Request_Log__c objLog = new Request_Log__c (id=recordids[0]);
			objLog.Error_Log__c ='Ids == '+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice Batch error For GetCSR';
			objLog.Status__c='Failed';
			update objLog;
		}
		//  }
	}



	/**********************Parsing the response received for Get CSR request*********************************/
	public static void parseGetCSRResponse(string respbody,List<id> recordids){

		String reqstatus='';
		String DerwentStatus,DerwentId='';
		List<Request_Log__c>  reqCSRList = new List<Request_Log__c>();
		List<CSR__c> csrlist = new List<CSR__c>();
		List<CSR_Questions__c> quelist = new List<CSR_Questions__c>();
		List<CSR_Notes__c> csrnotelist = new List<CSR_Notes__c>();
		map<string,string> csrErrorMap = new map<string,string>();
		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where SF_Object__c like 'CSR%'];

		List<Derwent_Field_Mapping__mdt> CSRmappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRQuemappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRNotemappings = new List<Derwent_Field_Mapping__mdt>();

		for(Derwent_Field_Mapping__mdt DFM :mappings) {
			if(DFM.SF_Object__c=='CSR')
				CSRmappings.add(DFM);
			else if(DFM.SF_Object__c=='CSRQuestion')
				CSRQuemappings.add(DFM);
			else if(DFM.SF_Object__c=='CSRNote')
				CSRNotemappings.add(DFM);
		}

		//Getting all the lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();

		//Getting all the other lookup codes and values
		Map<String,String> alllookupmap= getAllLookupvalue();

		//Parsing the response of the get CSR request
		CSR_Response getCSRresp= CSR_Response.parse(respbody);
		//system.debug('>>>>>CSRResponse>>>>>>'+getCSRresp);

		//Getting the details of all csrs in the response
		List<CSR_Response.Csrs> RespCsrlist =getCSRresp.Csrs;

		if(RespCsrlist != null && RespCsrlist.size()>0) {
			for(CSR_Response.Csrs respcsr:RespCsrlist) {
				CSR__c csr = new CSR__c();
				csr.Booking_ID__r= new Booking__c(Booking_ID__c= string.valueof(respcsr.BookingId));
				if(respcsr.TrackingTag == null || respcsr.TrackingTag == '') {
					csr.Derwent_CSR__c = true;
				}
				Map<String, Object> csrmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsr));
				//system.debug('<<csrmap>>'+csrmap);
				//Getting the configured field mapping for csrs
				for(Derwent_Field_Mapping__mdt DFM :CSRmappings) {
					string fieldval=String.valueof(csrmap.get(DFM.JSON_Field__c));
					//system.debug('<<csr field>>'+DFM.JSON_Field__c+'<<<<csr values>>>'+fieldval);
					if(fieldval!=null) {
						if(DFM.DataType__c=='DateTime') {
							csr.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
						}
						else if(DFM.DataType__c=='Lookup') {
							csr.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
						}
						else if(DFM.DataType__c=='Checkbox') {
							Boolean boolval=false;
							if(fieldval=='true')
								boolval=true;
							csr.put(DFM.SF_Field_API_Name__c,boolval);
						}
						else if(DFM.DataType__c=='Integer') {
							Decimal fielddec= integer.valueof(fieldval);
							csr.put(DFM.SF_Field_API_Name__c,fielddec);
						}
						else if(DFM.DataType__c=='OtherLookup') {
							csr.put(DFM.SF_Field_API_Name__c,alllookupmap.get(DFM.Lookup_Type__c+'.'+fieldval));
						}
						else
							csr.put(DFM.SF_Field_API_Name__c,fieldval);
					}
				}

				//Getting the questions of each csr record
				List<CSR_Response.cls_Questions> csrqnlist =respcsr.Questions;
				for(CSR_Response.cls_Questions csrqn: csrqnlist) {
					CSR_Questions__c que = new CSR_Questions__c();
					que.Org_CSR__r= new CSR__c(TaskID__c= string.valueof(respcsr.CsrId));

					Map<String, Object> quemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(csrqn));
					//system.debug('<<quemap>>'+quemap);
					//Getting the configured field mapping for csr questions
					for(Derwent_Field_Mapping__mdt DFM :CSRQuemappings) {
						string fieldval=String.valueof(quemap.get(DFM.JSON_Field__c));
						if(fieldval!=null) {
							if(DFM.DataType__c=='DateTime') {
								que.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
							}
							else if(DFM.DataType__c=='Lookup') {
								que.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							}
							else if(DFM.DataType__c=='Checkbox') {
								Boolean boolval=false;
								if(fieldval=='true')
									boolval=true;
								que.put(DFM.SF_Field_API_Name__c,boolval);
							}
							else if(DFM.DataType__c=='Integer') {
								Decimal fielddec= integer.valueof(fieldval);
								que.put(DFM.SF_Field_API_Name__c,fielddec);
							}
							else
								que.put(DFM.SF_Field_API_Name__c,fieldval);
						}
					}
					quelist.add(que);
				}

				//Getting the notes of each csr record
				List<CSR_Response.cls_Notes> respcsrnotelist =respcsr.Logs;
				for(CSR_Response.cls_Notes respcsrnote: respcsrnotelist) {
					CSR_Notes__c CSRnote = new CSR_Notes__c();
					CSRnote.Org_CSR__r= new CSR__c(TaskID__c= string.valueof(respcsr.CsrId));

					Map<String, Object> csrnotemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsrnote));
					//system.debug('<<csrnotemap>>'+csrnotemap);
					//Getting the configured field mapping for csr questions
					for(Derwent_Field_Mapping__mdt DFM :CSRNotemappings) {
						string fieldval=String.valueof(csrnotemap.get(DFM.JSON_Field__c));
						if(fieldval!=null) {
							if(DFM.DataType__c=='DateTime') {
								CSRnote.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
							}
							else if(DFM.DataType__c=='Lookup') {
								CSRnote.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							}
							else if(DFM.DataType__c=='Checkbox') {
								Boolean boolval=false;
								if(fieldval=='true')
									boolval=true;
								CSRnote.put(DFM.SF_Field_API_Name__c,boolval);
							}
							else if(DFM.DataType__c=='Integer') {
								Decimal fielddec= integer.valueof(fieldval);
								CSRnote.put(DFM.SF_Field_API_Name__c,fielddec);
							}
							else
								CSRnote.put(DFM.SF_Field_API_Name__c,fieldval);
						}
					}
					CSRnotelist.add(CSRnote);
				}
				csrlist.add(csr);
			}

			if(csrlist.size()>0) {
				upsert csrlist CSR__c.Fields.TaskID__c;

			}

			if(quelist.size()>0) {
				upsert quelist CSR_Questions__c.Fields.Org_Question_Id__c;

			}
			if(CSRnotelist.size()>0) {
				upsert CSRnotelist CSR_Notes__c.Fields.Org_Task_Log_ID__c;

			}
			//  database.upsert(CSRnotelist,CSR_Notes__c.Fields.Org_Task_Log_ID__c,false);
		}

		if(reqCSRList.size() > 0) {
			insert reqCSRList;
		}

		List<Integer> ErrorCSRlist =getCSRresp.NotFoundCsrs;
		List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in :recordids ];
		for(Request_Log__c req :ReqList) {
			if(ErrorCSRlist.contains(integer.valueof(req.Entity_Id__c))) {
				req.Error_Log__c='Not found CSRs';
				req.Status__c='Failed';
			}

			else{
				req.Status__c='Completed';
			}
		}
		update ReqList;
	}
	//v1.44
	private static void createRequestlogforNewDerwentBookingIds(List<String > existingBookings,String EntityName){
        List<Request_Log__c> reqlist = new List<Request_Log__c>();
        for(String lbooking : existingBookings){
            Request_Log__c reqLog = new Request_Log__c();
                reqLog.Entity__c = EntityName;
                reqLog.Entity_id__c = lbooking;
                reqLog.Status__c = 'New';
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
    //end of v1.44
	//Added for v1.13 changes
	public static void parseGetServiceRequestResponse(string respbody,List<id> recordids,String brandName){

		String reqstatus='';
		String DerwentStatus,DerwentId='';
		Map<String,case> csrCaseMap = new Map<String,case>();
		List<case> csrCaseList = new List<case>();
		List<Case> existingCase = new List<Case>();
		List<Request_Log__c>  reqCSRList = new List<Request_Log__c>();
		List<case> caselist = new List<case>();
		List<Customer_Communication__c> quelist = new List<Customer_Communication__c>();
		List<Customer_Communication__c> anslist = new List<Customer_Communication__c>();
		List<Customer_Communication__c> csrnotelist = new List<Customer_Communication__c>();
		List<Internal_Notes__c> csrInternalNoteList = new List<Internal_Notes__c>();
        List<String> lderwentBookingIds = new List<String>();//v1.44
		List<String> BookingsTobeCreated = new List<String>();//v1.44
		Map<String, Booking__c> lderwentBookingMap = new Map<String, Booking__c>();//v1.44
		map<string,string> csrErrorMap = new map<string,string>();
		//Getting the field mapping to be used
		List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt];

		List<Derwent_Field_Mapping__mdt> caseMappings = new List<Derwent_Field_Mapping__mdt>();
		//added as a part of v1.14
		List<Derwent_Field_Mapping__mdt> csrNoteMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> csrInternalNoteMappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CSRQuemappings = new List<Derwent_Field_Mapping__mdt>();
		List<Derwent_Field_Mapping__mdt> CustomerComMappings = new List<Derwent_Field_Mapping__mdt>();

		for(Derwent_Field_Mapping__mdt DFM: mappings) {
			if(DFM.SF_Object__c=='ServiceRequestCase')
				caseMappings.add(DFM);
			else if(DFM.SF_Object__c=='CustomerCommunication')
				csrNoteMappings.add(DFM);
			else if (DFM.SF_Object__c=='InternalNotes')
				csrInternalNoteMappings.add(DFM);

		}
		//system.debug('CustomerComMappings'+CustomerComMappings);
		//Getting all the lookup codes and values
		Map<String,String> lkpmap= getLookupvalue();
		List<User> userId = new List<User>();
		//Getting all the other lookup codes and values
		Map<String,String> alllookupmap= getAllLookupvalue();
		Id derwentOwnerId;
		String caseStatus = '';
		//Parsing the response of the get CSR request
		CSR_Response getCSRresp= CSR_Response.parse(respbody);
		//system.debug('>>>>>CSRResponse>>>>>>'+getCSRresp);
		//system.debug('brand name'+brandName);
		//Getting the details of all csrs in the response
		List<CSR_Response.Csrs> RespCsrlist =getCSRresp.Csrs;
		//system.debug('respcsr'+RespCsrlist);
		if(RespCsrlist != null && RespCsrlist.size()>0) {
            //v1.44
            for(CSR_Response.Csrs respcsr:RespCsrlist){
                lderwentBookingIds.add(String.valueof(respcsr.BookingId));
            }
            
            for(Booking__c lbookobj :[Select Id,Booking_ID__c,Org_Account_Name__c from Booking__c where Booking_ID__c IN : lderwentBookingIds])
            {
                lderwentBookingMap.put(lbookobj.Booking_ID__c,lbookobj);
            }
            for(String str : lDerwentBookingIds){
                if(!lderwentBookingMap.containsKey(str)){
                    BookingsTobeCreated.add(str);
                }
            }
            if(BookingsTobeCreated.size() > 0)
                createRequestlogforNewDerwentBookingIds(BookingsTobeCreated,'Booking');
            // end of v1.44
			for(CSR_Response.Csrs respcsr:RespCsrlist) {
				Case caseRec = csrCaseMap.containsKey(string.valueof(respcsr.CsrId)) ?  csrCaseMap.get(string.valueof(respcsr.CsrId)) : new Case();
				//added as a part of v1.17
				String derwentUsrId = '%;'+respcsr.OwnedById+';%'; //v1.25
				userId = [Select Id,Derwent_User_Id__c from User where Derwent_User_Id__c=:respcsr.OwnedById];
				List<Group> que = new List<Group>();
				if(userId.size()>0)
					derwentOwnerId = userId[0].id;
				else{
					List<Business_Unit__c> bunit = [Select Name,Derwent_User_Id__c,Org_Queue_Name__c from Business_Unit__c where Derwent_User_Id__c LIKE :derwentUsrId];//v1.26
					if(bunit.size()>0)
						que = [SELECT Id,Name,Type from Group where Name =: bunit[0].Org_Queue_Name__c and Type = 'Queue'];
					if(que.size()>0)
						derwentOwnerId = que[0].Id;
					else{
						Group defaultQueue = [SELECT Id,Name,Type from Group where Name = 'CSR - trp' and Type = 'Queue' LIMIT 1];
						derwentOwnerId = defaultQueue.Id;
					}

				}
				//end
				//added as a part of v1.19
				if(respcsr.Status == 1)
					caseStatus = 'New';
				else if(respcsr.Status == 2)
					caseStatus = 'In Progress';
				else if(respcsr.Status == 3)
					caseStatus = 'Closed';
				else if(respcsr.Status == 4)
					caseStatus = 'Pending Response';
				else if(respcsr.Status == 5)
					caseStatus = 'Pending Response';
				//end of v1.19


				//added as a part of v1.20
				String derwentCatId = '%;'+respcsr.CategoryId+';%';
				Travel_Republic_Category__mdt trCategoryId = new Travel_Republic_Category__mdt();
				//KR 1.23 add try catch and default values if they were not found
				try{
					trCategoryId = [Select Category_Text__c,Category_Id__c, Category_Group__c, Derwent_Category_Ids__c
					                from Travel_Republic_Category__mdt
					                where Derwent_Category_Ids__c LIKE :derwentCatId];
				}catch(exception e) {
					trCategoryId.Category_Id__c = 1.0;
					trCategoryId.Category_Group__c = 'Amendment';
                    trCategoryId.Category_Text__c = 'Amendment'; //v1.44.4
				}

				//system.debug('<<<Category Id>>>>>>>'+trCategoryId.Category_Id__c);
				Decimal CategoryIdTRP = trCategoryId.Category_Id__c;
				String catGroupText = trCategoryId.Category_Group__c; //v1.23
                String categoryText = trCategoryId.Category_Text__c;//v1.44.4
				//end of v1.20

				/***
				    KR suggested update
				    remive: Case caseRec = csrCaseMap.containsKey(string.valueof(respcsr.CsrId)) ?  csrCaseMap.get(string.valueof(respcsr.CsrId)) : new Case();
				    add: Case caseRec  = new Case();
				 **/


				//This will only be one record at a time now. If Derwent API's gets updated, then this will break and needs to be bulkified.

				caseRec = createTRPCase(respcsr,caseStatus,CategoryIdTRP,catGroupText,brandName,derwentOwnerId,categoryText); //added categoryText as a part of v1.44.4
				//system.debug('<<<<Returned Case>>>>'+caseRec);

				//end of v1.14
				Map<String, Object> csrmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsr));

				//Getting the questions of each csr record
				List<CSR_Response.cls_Questions> respcsrqueslist =respcsr.Questions;
				User custComCreatedBy = new User();
				User usr = [Select Name From User where Name =: 'Integration User' LIMIT 1];
				List<User> UserIdDerwent = new List<User>();
				for(CSR_Response.cls_Questions respcsrques: respcsrqueslist) {
					Customer_Communication__c servReqQues = new Customer_Communication__c();
					Customer_Communication__c servReqAns = new Customer_Communication__c();
					UserIdDerwent = [Select Id,Derwent_User_Id__c from User where Derwent_User_Id__c=:respcsrques.CreatedById];
					if(UserIdDerwent.size()>0)
						custComCreatedBy = UserIdDerwent[0];
					else
						custComCreatedBy = usr;
					if(respcsrques.Answer !='' && respcsrques.Answer != null) {
						servReqAns.Service_Request__r = new case (Derwent_CSR_Id__c = string.valueof(respcsr.CsrId));
														servReqAns.Derwent_Unique_ID__c  = 'A_'+ respcsrques.Id;
														servReqAns.DERWENT_GROUP_ID__c = string.valueof(respcsrques.Id);
														servReqAns.DERWENT_TYPE__c = 'Answer';
					}
					if(respcsrques.QuestionText!='' && respcsrques.QuestionText!= null) {
						servReqQues.Service_Request__r = new case (Derwent_CSR_Id__c = string.valueof(respcsr.CsrId));
														 servReqQues.Derwent_Unique_ID__c  = 'Q_'+ respcsrques.Id;
														 servReqQues.Response_Required__c = TRUE;
														 servReqQues.DERWENT_GROUP_ID__c = string.valueof(respcsrques.Id);
														 servReqQues.DERWENT_TYPE__c = 'Question';

					}
					//v1.21
					List<Customer_Communication__c> existingCustComQuesList = new List<Customer_Communication__c>();
					List<Customer_Communication__c> existingCustComAnsList = new List<Customer_Communication__c>();
					List<String> UniqueIdQuestionList = new List<String>();
					List<String> UniqueIdAnsList = new List<String>();
					UniqueIdQuestionList.add('Q_'+ respcsrques.Id);
					UniqueIdAnsList.add('A_'+ respcsrques.Id);
					existingCustComQuesList = [Select Id,Derwent_Unique_ID__c,DERWENT_GROUP_ID__c from Customer_Communication__c where Derwent_Unique_ID__c IN: UniqueIdQuestionList];
					existingCustComAnsList = [Select Id,Derwent_Unique_ID__c,DERWENT_GROUP_ID__c from Customer_Communication__c where Derwent_Unique_ID__c IN: UniqueIdAnsList];
					//end of v1.21
					Map<String, Object> csrQuesmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsrques));
					//system.debug('<<csrQuesmap>>'+csrQuesmap);
					//Getting the configured field mapping for csr questions
					for(Derwent_Field_Mapping__mdt DFM :csrNoteMappings) {
						string fieldval=String.valueof(csrQuesmap.get(DFM.JSON_Field__c));
						if(fieldval!=null) {
							if(DFM.DataType__c=='DateTime') {
								if(existingCustComQuesList.size() == 0 ) {
									servReqQues.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));

								}
								if(existingCustComAnsList.size() == 0 ) {
									servReqAns.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
								}
							}
							else if(DFM.DataType__c=='Lookup') {
								servReqQues.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
								servReqAns.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
							}
							else if(DFM.DataType__c=='Checkbox') {
								Boolean boolval=false;
								if(fieldval=='true')
									boolval=true;
								servReqQues.put(DFM.SF_Field_API_Name__c,boolval);
								servReqAns.put(DFM.SF_Field_API_Name__c,boolval);
							}
							else if(DFM.DataType__c=='Integer') {
								Decimal fielddec= integer.valueof(fieldval);
								servReqQues.put(DFM.SF_Field_API_Name__c,fielddec);
								servReqAns.put(DFM.SF_Field_API_Name__c,fielddec);
							}
							else{
								servReqQues.put(DFM.SF_Field_API_Name__c,fieldval);
								servReqAns.put(DFM.SF_Field_API_Name__c,fieldval);
							}

						}
					}

					// //system.debug('Question Log Id '+servReqQues.Question_Log_ID__c);
					if(existingCustComQuesList.size() == 0) {
						servReqQues.CreatedById = custComCreatedBy.Id;
						String FormattedQuestionDate = respcsrques.QuestionDate.replace('T',' ');
						//v1.28
						Datetime temp = Datetime.valueOfGMT(FormattedQuestionDate);
						//v1.44 String GMTDateTime = temp.format('yyyy-MM-dd HH:mm:ss', 'Europe/London'); // v1.28
						servReqQues.CreatedDate = temp ;//v1.44
						//v1.28

					}
					if(existingCustComAnsList.size() == 0) {
						servReqAns.CreatedById = custComCreatedBy.Id;
						String FormattedAnswerDate = '';
						if(respcsrques.AnswerDate != null) {
							FormattedAnswerDate = respcsrques.AnswerDate.replace('T',' ');
							//v1.28
							Datetime temp = Datetime.valueOfGMT(FormattedAnswerDate);
							//v1.44 String GMTDateTime = temp.format('yyyy-MM-dd HH:mm:ss', 'Europe/London'); // v1.28
							servReqAns.CreatedDate = temp; //v1.44
							//v1.28
							//servReqAns.CreatedDate = servReqQues.CreatedDate.addMinutes(2);Commented as  a part of v1.24

						}
					}

					servReqAns.Message__c = null;
					servReqAns.Message__c = respcsrques.Answer;
					servReqAns.Created_By_Customer__c = true;//v1.24

					if(servReqQues.Derwent_Unique_ID__c != null)
						quelist.add(servReqQues);
					if(servReqAns.Derwent_Unique_ID__c != null)
						anslist.add(servReqAns);
				}

				//Getting the notes of each csr record
				List<CSR_Response.cls_Notes> respcsrnotelist =respcsr.Logs;
				User publicNotesCreatedBy = new User();
				List<User> getUserId = new List<User>();

				map<decimal, User> mapUsers = new map<decimal, User>();
				map<string, list<Customer_Communication__c> > mapCustComms = new map<string, list<Customer_Communication__c> >();

				for(CSR_Response.cls_Notes respcsrnote: respcsrnotelist) {
					if(respcsrnote.CreatedById != null)
						mapUsers.put(decimal.valueOf(respcsrnote.CreatedById), null);
					if(respcsrnote.LogId != null)
						mapCustComms.put('N_'+ respcsrnote.LogId, null);
				}

				if(!mapUsers.isEmpty()) {
					for(User objUser : [select Id,Derwent_User_Id__c from User where Derwent_User_Id__c IN :mapUsers.keySet() ]) {
						mapUsers.put(objUser.Derwent_User_Id__c, objUser);
					}
				}
				if(!mapCustComms.isEmpty()) {
					for( Customer_Communication__c objCC : [Select Id,Derwent_Unique_ID__c,DERWENT_GROUP_ID__c from Customer_Communication__c where Derwent_Unique_ID__c IN : mapCustComms.keySet()]) {
						if(mapCustComms.containsKey(objCC.Derwent_Unique_ID__c) == false || mapCustComms.get(objCC.Derwent_Unique_ID__c) == null)
							mapCustComms.put(objCC.Derwent_Unique_ID__c, new list<Customer_Communication__c>());
						mapCustComms.get(objCC.Derwent_Unique_ID__c).add(objCC);
					}
				}

				for(CSR_Response.cls_Notes respcsrnote: respcsrnotelist) {
					//system.debug('Notes'+respcsrnote.isPublic);
					/*getUserId = [Select Id,Derwent_User_Id__c from User where Derwent_User_Id__c=:respcsrnote.CreatedById];
					   if(getUserId.size()>0)
					    publicNotesCreatedBy = getUserId[0];
					   else
					    publicNotesCreatedBy = usr;
					 */
					if(mapUsers.get(respcsrnote.CreatedById) != null) {
						publicNotesCreatedBy = mapUsers.get(respcsrnote.CreatedById);
					}else{
						publicNotesCreatedBy = usr;
					}

					if(respcsrnote.isPublic && !respcsrnote.SystemGenerated) {
						Customer_Communication__c servReqNote = new Customer_Communication__c();
						servReqNote.Service_Request__r = new case (Derwent_CSR_Id__c = string.valueof(respcsr.CsrId));
														 servReqNote.DERWENT_UNIQUE_ID__c = 'N_'+ respcsrnote.LogId;
														 servReqNote.DERWENT_TYPE__c = 'Note';
														 List<Customer_Communication__c> existingPublicNotesList = new List<Customer_Communication__c>();
														 String uniqueId = 'N_'+ respcsrnote.LogId;

														 //RB existingPublicNotesList = [Select Id,Derwent_Unique_ID__c,DERWENT_GROUP_ID__c from Customer_Communication__c where Derwent_Unique_ID__c =: uniqueId];
														 if(mapCustComms.get(uniqueId) != null) {
															 existingPublicNotesList = mapCustComms.get(uniqueId);
														 }
														 Map<String, Object> csrnotemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsrnote));
														 //system.debug('<<csrnotemap>>'+csrnotemap);
														 //Getting the configured field mapping for csr questions
														 for(Derwent_Field_Mapping__mdt DFM: CSRNotemappings) {
															 string fieldval=String.valueof(csrnotemap.get(DFM.JSON_Field__c));
															 if(fieldval!=null) {
																 if(DFM.DataType__c=='DateTime') {
																	 if(existingPublicNotesList.size() == 0) {
																		 servReqNote.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
																	 }
																 }
																 else if(DFM.DataType__c=='Lookup') {
																	 servReqNote.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
																 }
																 else if(DFM.DataType__c=='Checkbox') {
																	 Boolean boolval=false;
																	 if(fieldval=='true')
																		 boolval=true;
																	 servReqNote.put(DFM.SF_Field_API_Name__c,boolval);
																 }
																 else if(DFM.DataType__c=='Integer') {
																	 Decimal fielddec= integer.valueof(fieldval);
																	 servReqNote.put(DFM.SF_Field_API_Name__c,fielddec);
																 }
																 else
																	 servReqNote.put(DFM.SF_Field_API_Name__c,fieldval);
															 }
														 }
														 ////system.debug('Note Log Id '+servReqNote.Task_Log_ID__c);
														 if(existingPublicNotesList.size() == 0) {
															 String FormattedDate = respcsrnote.CreatedDate.replace('T',' ');
															 //v1.28
															 datetime temp = Datetime.valueOfGMT(FormattedDate); 
															 //v1.44 String GMTDateTime = temp.format('yyyy-MM-dd HH:mm:ss', 'Europe/London'); // v1.28
															 servReqNote.CreatedDate = temp ; //v1.44
															 //v1.28 end
															 servReqNote.CreatedById = publicNotesCreatedBy.Id;

														 }
														 //system.debug('Notes'+servReqNote);
														 CSRnotelist.add(servReqNote);
					}
					if (!respcsrnote.isPublic || respcsrnote.SystemGenerated != true) {
						Internal_Notes__c servReqNote = new Internal_Notes__c();
						servReqNote.Name = 'N_'+ respcsrnote.LogId;
						servReqNote.Service_Request__r = new case (Derwent_CSR_Id__c = string.valueof(respcsr.CsrId));
														 servReqNote.DERWENT_UNIQUE_ID__c = 'N_'+ respcsrnote.LogId;
														 List<Internal_Notes__c> existingInternalNotesList = new List<Internal_Notes__c>();
														 String uniqueId = 'N_'+ respcsrnote.LogId;
														 existingInternalNotesList = [Select Id,Derwent_Unique_ID__c,DERWENT_GROUP_ID__c from Internal_Notes__c where Derwent_Unique_ID__c =: uniqueId];

														 Map<String, Object> csrnotemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respcsrnote));
														 //system.debug('<<csrnotemap>>'+csrnotemap);
														 //Getting the configured field mapping for csr questions
														 for(Derwent_Field_Mapping__mdt DFM :CSRInternalNotemappings) {
															 string fieldval=String.valueof(csrnotemap.get(DFM.JSON_Field__c));
															 if(fieldval!=null) {
																 if(DFM.DataType__c=='DateTime') {
																	 if(existingInternalNotesList.size() == 0) {
																		 servReqNote.put(DFM.SF_Field_API_Name__c, formatDatetime(fieldval));
																	 }
																 }
																 else if(DFM.DataType__c=='Lookup') {
																	 servReqNote.put(DFM.SF_Field_API_Name__c,lkpmap.get(DFM.SF_Field_API_Name__c+'.'+fieldval));
																 }
																 else if(DFM.DataType__c=='Checkbox') {
																	 Boolean boolval=false;
																	 if(fieldval=='true')
																		 boolval=true;
																	 servReqNote.put(DFM.SF_Field_API_Name__c,boolval);
																 }
																 else if(DFM.DataType__c=='Integer') {
																	 Decimal fielddec= integer.valueof(fieldval);
																	 servReqNote.put(DFM.SF_Field_API_Name__c,fielddec);
																 }
																 else
																	 servReqNote.put(DFM.SF_Field_API_Name__c,fieldval);
															 }
														 }
														 ////system.debug('Note Log Id '+servReqNote.Task_Log_ID__c);
														 if(existingInternalNotesList.size() == 0) {
															 String FormattedDate = respcsrnote.CreatedDate.replace('T',' ');
															 //v1.28
															 datetime temp = Datetime.valueOfGMT(FormattedDate);
															 //v1.44 String GMTDateTime = temp.format('yyyy-MM-dd HH:mm:ss', 'Europe/London'); // v1.28
															  servReqNote.CreatedDate = temp;
															 //v1.28 end
															 servReqNote.CreatedById = publicNotesCreatedBy.Id;

														 }
														 CSRInternalnotelist.add(servReqNote);
					}
				}

				caselist.add(caseRec);
				//system.debug('caselist'+caselist);
				//system.debug('caseRec'+caseRec);


			}

			if(caselist.size()>0) {
				upsert caselist case.Fields.Derwent_CSR_Id__c;
				//system.debug('####Case Inserted=====>'+caselist);
			}

			if(quelist.size()>0) {
				upsert quelist Customer_Communication__c.Fields.Derwent_Unique_ID__c;
				//system.debug('####Case quelist=====>'+quelist);
			}
			if(anslist.size()>0) {
				upsert anslist Customer_Communication__c.Fields.Derwent_Unique_ID__c;
				//system.debug('####Case anslist=====>'+anslist);
			}
			if(CSRnotelist.size()>0) {
				upsert CSRnotelist Customer_Communication__c.Fields.Derwent_Unique_ID__c;
				//system.debug('####Case CSRnotelist=====>'+CSRnotelist);


			}

			if(CSRInternalnotelist.size() > 0) {
				upsert CSRInternalnotelist Internal_Notes__c.Fields.Derwent_Unique_ID__c;
				//system.debug('####Case CSRnotelist=====>'+CSRnotelist);
			}
			//  database.upsert(CSRnotelist,CSR_Notes__c.Fields.Org_Task_Log_ID__c,false);
		}

		if(reqCSRList.size() > 0) {
			insert reqCSRList;
		}

		List<Integer> ErrorCSRlist =getCSRresp.NotFoundCsrs;
		List<Request_Log__c> ReqList= [select id,Entity_Id__c,Entity__c,Error_Log__c,Response_Log__c,Status__c from Request_Log__c where id in: recordids ];
		for(Request_Log__c req :ReqList) {
			if(ErrorCSRlist.contains(integer.valueof(req.Entity_Id__c))) {
				req.Error_Log__c='Not found CSRs';
				req.Status__c='Failed';
			}

			else{
				req.Status__c='Completed';
			}
		}
		update ReqList;
	}



	//ex: abc;pqr;lmn = ('abc','pqr','lmn')
	public static String getValuesInQuotes(List<Integer> lst){
		string condition ='(';
		for(Integer strid : lst) {
			condition += '\''+string.ValueOf(strid)+'\',';
		}
		condition = condition.substring(0,condition.length()-1);
		condition += ')';
		return condition;
	}
	/*******************************************************************************************************************************/
	//Generic method for fields for SOQL query
	public static string getCreatableFieldsSOQL(string objectName){
		String selects = '';
		// Get a map of field name and field token
		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
		list<string> selectFields = new list<string>();
		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				// if (fd.isCreateable()){ // field is creatable
				selectFields.add(fd.getName());
				//  }
			}
		}
		// contruction of SOQL
		if (!selectFields.isEmpty()) {
			for (string s:selectFields) {
				selects += s + ',';
			}
			if (selects.endsWith(',')) {selects = selects.substring(0,selects.lastIndexOf(','));}

		}
		// return constrcucted query
		return 'SELECT ' + selects + ' FROM ' + objectName;

	}

	//Generic method for getting field look up value from Derwent Lookup
	public static Map<String,String> getLookupvalue(){
		Map<String,String> fieldmap= new Map<String,String>();
		Map<String,String> lkpmap= new Map<String,String>();
		for(Derwent_Lookup__mdt lookup :[select id,code__c,value__c, field__c from Derwent_Lookup__mdt ]) {
			fieldmap.put(lookup.field__c+'.'+lookup.code__c,lookup.value__c);
		}
		return fieldmap;
	}



	//Generic method for getting field look up value from other Lookup
	public static Map<String,String> getAllLookupvalue(){
		//Map<String,String> fieldmap= new Map<String,String>();
		//Map<String,String> lkpmap= new Map<String,String>();
		if(mapAllLookupCodes.isEmpty()) {
			for(Lookup__c lookup :[select id,name,code__c,type__c from Lookup__c ]) {
				mapAllLookupCodes.put(lookup.type__c+'.'+lookup.code__c,lookup.name);
			}
		}
		return mapAllLookupCodes;
	}

	//Generic method for getting field look up codefrom other Lookup
	public static Map<String,String> getAllLookupCode(){
		//Map<String,String> fieldmap= new Map<String,String>();
		//Map<String,String> lkpmap= new Map<String,String>();
		if(mapAllLookupNames.isEmpty()) {
			for(Lookup__c lookup :[select id,name,code__c,type__c from Lookup__c ]) {
				mapAllLookupNames.put(lookup.type__c+'.'+lookup.name,lookup.code__c);
			}
		}
		return mapAllLookupNames;
	}

	//Added as part of v1.3
	//Generic method for getting field look up code from Derwent Lookup
	public static Map<String,String> getDerwentLookupCode(){
		Map<String,String> fieldmap= new Map<String,String>();
		Map<String,String> lkpmap= new Map<String,String>();
		for(Derwent_Lookup__mdt lookup :[select id,code__c,value__c, field__c,Tenant__c from Derwent_Lookup__mdt ]) {
			fieldmap.put(lookup.field__c+'.'+lookup.Tenant__c+'.'+lookup.value__c,lookup.code__c);
		}
		return fieldmap;
	}

	//Added as a part of v1.21
	public static Case createTRPCase(CSR_Response.Csrs respcsr,String caseStatus,Decimal CategoryIdTRP, String catGroupText,String brandName,Id derwentOwnerId,String categoryText){
		Case caseRec = new Case();
		Booking__c book = new Booking__c(); //[Select Id,Booking_ID__c,Org_Account_Name__c from Booking__c where Booking_ID__c =: string.valueof(respcsr.BookingId)];
		for(Booking__c obj : [Select Id,Booking_ID__c,Org_Account_Name__c from Booking__c where Booking_ID__c =: string.valueof(respcsr.BookingId)]) {
			book = obj;
		}
		String FormattedDate =    respcsr.CreatedDate.replace('T',' ');
		Datetime temp = Datetime.valueOfGMT(FormattedDate);
		//v1.44 String GMTDateTime = temp.format('yyyy-MM-dd HH:mm:ss', 'Europe/London'); // v1.28
		//system.debug('Time FORMAT @@@'+GMTDateTime);
		List<Case> existingcase = [Select Id,Derwent_CSR_Id__c from Case where Derwent_CSR_Id__c=:string.valueof(respcsr.CsrId)];

		//v1.40
		caseRec.Org_Booking__r = new Booking__c(Booking_ID__c= string.valueof(respcsr.BookingId));
		caseRec.Org_Brand__c = brandName;
		caseRec.AccountId = book.Org_Account_Name__c;
		//caseRec.Org_Type__c = 'Other'; KR suggest to remove.
		//caseRec.Org_Case_Status__c = respcsr.Status; // KR to do mapping
		caseRec.CategoryId__c = CategoryIdTRP;//v1.20
		caseRec.Derwent_Category_Id__c = respcsr.CategoryId;//v1.20
		caseRec.Derwent_Created_By_Id__c = respcsr.CreatedById;
		caseRec.Category_Group__c = catGroupText; //v1.23
		caseRec.Derwent_Category_Text__c = respcsr.CategoryText;
		caseRec.Category__c = categoryText; //v1.44.4
		caseRec.Derwent_Owner_Id__c = respcsr.OwnedById;
		caseRec.Description = respcsr.Text; //KR Added this
		caseRec.Subject = respcsr.Subject; //KR Added this
		caseRec.Receive_Text_Messages__c = respcsr.TextAlerts; //KR Added this
		caseRec.Derwent_CSR_Id__c = string.valueof(respcsr.CsrId);
		caseRec.OwnerId = derwentOwnerId; //added as a part of v1.17
		caseRec.Org_Case_Status__c = caseStatus; //added as a part of v1.19
		caseRec.Next_Follow_Up_Date__c = respcsr.NextActionDate; //Added as a part of v1.20
		//RB caseRec.CreatedDate = Datetime.valueOf(GMTDateTime);
		if(existingcase.size() == 0) {
            caseRec.CreatedDate = temp; //v1.44
			if(respcsr.isPublic) { //v1.14
				caseRec.Is_Public__c = TRUE; //KR Added this
				caseRec.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();
			}
			//Added as a part of v1.14
			else{
				caseRec.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
									   caseRec.Is_Public__c = FALSE; //KR Added this
			}

			//system.debug(caseRec + '<<<CaseRec>>>');
			return caseRec;
		}
		else{
			if(respcsr.isPublic) { //v1.14

				/* caseRec.Org_Booking__r = new Booking__c(Booking_ID__c= string.valueof(respcsr.BookingId));
				   caseRec.Org_Brand__c = brandName;
				   caseRec.AccountId = book.Org_Account_Name__c;
				   //caseRec.Org_Type__c = 'Other'; KR suggest to remove.
				   //caseRec.Org_Case_Status__c = respcsr.Status; // KR to do mapping
				   caseRec.CategoryId__c = CategoryIdTRP;//v1.20
				   caseRec.CreatedDate = DateTime.valueOf(GMTDateTime); //v1.28
				   caseRec.Derwent_Category_Id__c = respcsr.CategoryId;//v1.20
				   caseRec.Derwent_Created_By_Id__c = respcsr.CreatedById;
				   caseRec.Derwent_Category_Text__c = respcsr.CategoryText;
				   //caseRec.Category__c = trCategoryId.Category_Text__c;
				   caseRec.Derwent_Owner_Id__c = respcsr.OwnedById;
				   caseRec.Description = respcsr.Text; //KR Added this
				   caseRec.Subject = respcsr.Subject;  //KR Added this
				   caseRec.Receive_Text_Messages__c = respcsr.TextAlerts; //KR Added this
				   caseRec.Derwent_CSR_Id__c = string.valueof(respcsr.CsrId);
				   caseRec.OwnerId = derwentOwnerId; //added as a part of v1.17
				   caseRec.Org_Case_Status__c = caseStatus; //added as a part of v1.19
				   caseRec.Next_Follow_Up_Date__c = respcsr.NextActionDate; //Added as a part of v1.20*///v1.40
				caseRec.Is_Public__c = TRUE; //KR Added this
				caseRec.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Travel Republic - Service Request').getRecordTypeId();

			}
			//Added as a part of v1.14
			else{
				/*caseRec.Org_Booking__r = new Booking__c(Booking_ID__c= string.valueof(respcsr.BookingId));
				   caseRec.Org_Brand__c = brandName;
				   //caseRec.Org_Type__c = 'Other'; KR Removed this.
				   caseRec.AccountId = book.Org_Account_Name__c;
				   caseRec.Derwent_CSR_Id__c = string.valueof(respcsr.CsrId);
				   caseRec.CategoryId__c = CategoryIdTRP;//v1.20
				   caseRec.Derwent_Created_By_Id__c = respcsr.CreatedById;
				   caseRec.Derwent_Category_Text__c = respcsr.CategoryText;
				   caseRec.CreatedDate =  Datetime.valueOf(GMTDateTime);//v1.28
				   //caseRec.Category__c = trCategoryId.Category_Text__c;
				   caseRec.Derwent_Category_Id__c = respcsr.CategoryId;//v1.20
				   caseRec.Derwent_Owner_Id__c = respcsr.OwnedById;
				   //caseRec.OwnerId = respcsr.Owner; KR added this. We need a mapping of ownerids from derwent.
				   caseRec.Description = respcsr.Text; //KR Added this
				   caseRec.Subject = respcsr.Subject;  //KR Added this
				   caseRec.Org_Case_Status__c = caseStatus; //added as a part of v1.19
				   caseRec.Receive_Text_Messages__c = respcsr.TextAlerts; //KR Added this
				   caseRec.OwnerId = derwentOwnerId; //added as a part of v1.17
				   caseRec.Next_Follow_Up_Date__c = respcsr.NextActionDate; //Added as a part of v1.20
				 */
				caseRec.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Travel Republic - Internal Request').getRecordTypeId();
									   caseRec.Is_Public__c = FALSE; //KR Added this


			}
			//system.debug(caseRec + '<<<CaseRec>>>');
			return caseRec;
		}
	}

	/*
	    check the account details if account is not exsit in the system do a callout and insert the customer
	 */
	public static void doCustomerCall(list<string> lstDerwentCustomerIds){
		try{
			set<string> setDerwentCustomerIds = new Set<String>();
			setDerwentCustomerIds.addAll(lstDerwentCustomerIds);
			if(setDerwentCustomerIds.isEmpty())
				return;
			lstDerwentCustomerIds = new list<string>();
			lstDerwentCustomerIds.addAll(setDerwentCustomerIds);
			getDerwentsetting('Get_Customer');
			String reqparams = '';//prepareGetCustomer(recordids);
			if(isFromCustomerCreate == false) {// this variable set to true if the call is to get Custoomer in Customer creation error
				for(Account objAcc: [select Id, Org_Derwent_Customer_No__c from Account where Org_Derwent_Customer_No__c IN : setDerwentCustomerIds]) {
					if(setDerwentCustomerIds.contains(objAcc.Org_Derwent_Customer_No__c))
						setDerwentCustomerIds.remove(objAcc.Org_Derwent_Customer_No__c);
				}
			}
			if(!setDerwentCustomerIds.isEmpty()) {
				for(string cusId : setDerwentCustomerIds) {
					reqparams+= (reqparams != '' ? '&' : '') + 'customerIds='+cusId;
				}
				String endpointurl = endurl+ reqparams;
				HTTPRequest req = new HTTPRequest();
				req.setMethod('GET');
				req.setEndpoint(endpointurl);
				Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				req.setHeader('Authorization', authorizationHeader);
				req.setTimeout(60 * 1000);
				HTTP http = new HTTP();
				HTTPResponse res = http.send(req);
				//system.debug('>>>>>Response>>>>>>'+res.getbody());
				parseGetCustResponse(res.getBody(),null);
			}
		}catch(Exception ex) {
			insert prepareLog(ex, null, lstDerwentCustomerIds,'Customer',string.join(lstDerwentCustomerIds,','));
		}
	}

	public static Request_Log__c prepareLog(Exception ex, string logId, list<string> recordIds, string entityname, string entityIds){
		Request_Log__c objLog = logId != null ? new Request_Log__c(Id=logId) : new Request_Log__c();
		objLog.Error_Log__c = 'Ids=='+(recordids != null ? string.join(recordids,',') : '')+'Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage()+'--Stack Trace==>'+ex.getStackTraceString();
		objLog.Type__c = 'Webservice Error';
		objLog.Status__c='Failed';
		objLog.Entity__c = entityname;
		objLog.Entity_Id__c = entityIds;
		objLog.Is_Synchronous__c = !( system.isBatch() || system.isFuture() || system.isQueueable() || system.isScheduled() );
		return objLog;
	}

	public static boolean checkCPUTime(decimal dPoint){
		long lTime = Limits.getLimitCpuTime();
		long lUsed = Limits.getCpuTime();
		dPoint = dPoint != null ? dPoint : 2;
		if(lUsed > (lTime/dPoint)) {
			return true;
		}else
			return false;
	}

	public static decimal doTotalCostCC(decimal dTC, string accountER, string clinetER){
		return ( (dTC != null ? dTC : 0) *
		         (accountER != null ? decimal.valueOf(accountER) : 0) *
		         (clinetER != null ? decimal.valueOf(clinetER) : 0)
		         );
	}

	public static map<string, Datetime[]> getItnaryDates(map<string, Datetime[]> mapItnaryDates, string FieldName, Datetime dateval, string key){
		list<Datetime> lst = mapItnaryDates.containskey(key) ? mapItnaryDates.get(key) : new list<Datetime> {null, null};

		if(FieldName == 'Org_Departure_Date__c' || FieldName == 'Org_Check_In__c') {
			system.debug(' dateval is : before '+dateval);
			dateval = dateval.addHours(4);
			system.debug(' dateval is : after '+dateval);
			if(lst[0] != null) {
				if(dateval < lst[0] )
					lst[0] = dateval;
			}else {
				lst[0] = dateval;
			}
		}else if(FieldName == 'Org_Arrival_Date__c' || FieldName == 'Org_Check_Out__c') {
			system.debug(' dateval is : before '+dateval);
			dateval = dateval.addHours(4);
			system.debug(' dateval is : after '+dateval);
			if(lst[1] != null) {
				if(lst[1] < dateval)
					lst[1] = dateval;
			}else {
				lst[1] = dateval;
			}
		}
		mapItnaryDates.put(key, lst);
		return mapItnaryDates;
	}

	public static map<string, string[]> getHotelNames(map<string, string[]> mapHotelStays, string HotelName,  string tripId, datetime checkIn, datetime checkout){
		if(checkIn != null && checkout != null) {
			checkIn = checkIn.addHours(4);
			checkout = checkout.addHours(4);
			Integer days = Date.valueOf(checkIn).daysBetween(Date.valueOf(checkout));
			if(mapHotelStays.containsKey(tripId) ) {
				Integer iC = Integer.valueOf(mapHotelStays.get(tripId)[1]);
				if(iC < days) {
					mapHotelStays.put(tripId, new list<string> {HotelName, days+''});
				}
			}else{
				mapHotelStays.put(tripId, new list<string> {HotelName, days+''});
			}
		}
		return mapHotelStays;
	}

	public static map<string, list<string> > getSegments(map<string, Datetime[]> mapItnaryDates, map<string, list<string> > mapBookingSegments,string bookId, string DepartureAirport,
	                                                     string ArrivalAirport, datetime dDate, datetime aDate){
		list<string> lstSegs = mapBookingSegments.containsKey(bookId) ? mapBookingSegments.get(bookId) : new list<string> {null, null};

		list<Datetime> lst = mapItnaryDates.containsKey(bookId) ? mapItnaryDates.get(bookId) : new list<Datetime>();
		dDate = dDate.addHours(4);

		if(lst[0] != null) {
			if(dDate < lst[0] )
				lstSegs[0] = DepartureAirport;
		}else {
			lstSegs[0] = DepartureAirport;
		}

		aDate = aDate.addHours(4);
		if(lst[1] != null) {
			if(lst[1] < aDate)
				lstSegs[1] = ArrivalAirport;
		}else {
			lstSegs[1] = ArrivalAirport;
		}

		mapBookingSegments.put(bookId, lstSegs);
		return mapBookingSegments;
	}

	public static Datetime formatDatetime(string fieldval){
		fieldval = fieldval.replace('T',' ');
		datetime dateval= Datetime.valueOf(fieldval);
		if(dateval < Datetime.valueOf('1700-01-01 18:00:00Z')) {
			dateval = Datetime.valueOf('1700-01-01 18:00:00Z');
		}
		return dateval;
	}

	public static Datetime formatDatetimeGMT(string fieldval){
		fieldval = fieldval.replace('T',' ');
		datetime dateval= Datetime.valueOfGMT(fieldval);
		if(dateval < Datetime.valueOf('1700-01-01 18:00:00Z')) {
			dateval = Datetime.valueOf('1700-01-01 18:00:00Z');
		}
		return dateval;
	}


	public static InPorgressItems prepareInProgressItems(
		map<string, Booking__c> BookingHeaders,
		list<Booking__c> BookingItems,
		list<Itinerary__c> Itineries,
		list<Itinerary__c> ExtraItineries,
		list<Itinerary_Detail__c> ItineryDetails,
		list<Traveller__c> Travellers,
		list<Booking_Price_Breakdown__c> PriceBreakDowns,
		list<CSR__c> CSRs,
		Request_Log__c Log,
		list<string> tripIds

		){
		InPorgressItems objInPorgressItems = new InPorgressItems();
		objInPorgressItems.mapBookingHeaders = BookingHeaders;
		objInPorgressItems.lstBookingItems = BookingItems;
		objInPorgressItems.lstItineries = Itineries;
		objInPorgressItems.lstItnryExtra = ExtraItineries;
		objInPorgressItems.lstItineryDetails = ItineryDetails;
		objInPorgressItems.lstTravellers = Travellers;
		objInPorgressItems.lstPriceBreakDowns = PriceBreakDowns;
		//objInPorgressItems.lstBookingNotes = BookingNotes;
		objInPorgressItems.lstCSRs = CSRs;
		objInPorgressItems.RequestLog = Log;
		objInPorgressItems.lstTripIds = tripIds;
		return objInPorgressItems;
	}

	public static void resumeItems(InPorgressItems inputItems){
		try{
			if(inputItems != null) {
				isFromDerwentCall = true;
				if(inputItems.mapBookingHeaders != null) {
					if(!inputItems.mapBookingHeaders.isEmpty()) {
						upsert inputItems.mapBookingHeaders.values() Booking__c.Fields.Org_Trip_Id__c;
					}
				}

				if(inputItems.lstBookingItems != null) {
					upsert inputItems.lstBookingItems Booking__c.Fields.Booking_ID__c;
				}

				if(inputItems.lstTripIds != null && (inputItems.lstItineries != null || inputItems.lstItnryExtra != null)) {
					delete [select id from Itinerary__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in : inputItems.lstTripIds];
				}

				if(inputItems.lstItineries != null) {
					upsert inputItems.lstItineries Itinerary__c.Fields.Itinerary_ID__c;
				}

				if(inputItems.lstItnryExtra != null) {
					upsert inputItems.lstItnryExtra Itinerary__c.Fields.External_System_ID__c;
				}

				if(inputItems.lstItineryDetails != null) {
					upsert inputItems.lstItineryDetails Itinerary_Detail__c.Fields.Org_Itinerary_Detail_Id__c;
				}
				if(inputItems.lstTravellers != null) {
					delete [select id from Traveller__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in : inputItems.lstTripIds];
					upsert inputItems.lstTravellers Traveller__c.Fields.Org_Traveller_ID__c;
				}
				/*if(inputItems.lstPriceBreakDowns != null){
				    delete [select id from Booking_Price_Breakdown__c where Org_Booking__r.Booking_Header__r.Org_Trip_Id__c in :inputItems.lstTripIds];
				    upsert inputItems.lstPriceBreakDowns Booking_Price_Breakdown__c.Fields.Org_Line_Item_Id__c;
				   }
				   if(inputItems.lstBookingNotes != null){
				    upsert inputItems.lstBookingNotes Booking_Note__c.Fields.Org_Note_Id__c;
				   }
				   if(inputItems.lstCSRs != null){
				    upsert inputItems.lstCSRs CSR__c.Fields.TaskID__c;
				   }*/
				if(inputItems.RequestLog != null) {
					inputItems.RequestLog.Status__c = 'Completed';
					upsert inputItems.RequestLog;
				}
			}
		}catch(Exception ex) {
			Request_Log__c objLog = inputItems.RequestLog != null ? inputItems.RequestLog : new Request_Log__c();
			objLog.Status__c = 'Failed';
			objLog.Error_Log__c = 'Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Webservice Callout For Booking Creation';
			upsert objLog;
		}
	}

	public class InPorgressItems {
		public map<string, Booking__c> mapBookingHeaders {get; set;}
		public list<Booking__c> lstBookingItems {get; set;}
		public list<Itinerary__c> lstItineries {get; set;}
		public list<Itinerary__c> lstItnryExtra {get; set;}
		public list<Itinerary_Detail__c> lstItineryDetails {get; set;}
		public list<Traveller__c> lstTravellers {get; set;}
		public list<Booking_Price_Breakdown__c> lstPriceBreakDowns {get; set;}
		//public list<Booking_Note__c> lstBookingNotes {get; set;}
		public list<CSR__c> lstCSRs {get; set;}
		public Request_Log__c RequestLog {get; set;}
		public list<String> lstTripIds {get; set;}
	}
}