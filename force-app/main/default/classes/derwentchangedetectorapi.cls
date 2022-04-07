/**************************************************************************************************
 * Name               : derwentchangedetectorapi
 * Description        : This is API class for derwent Callout
 * Created Date       : 10-Jan-2020
 * Created By         : PwC
 * -----------------------------------------------------------------------------------------------
 * VERSION     AUTHOR        DATE           COMMENTS
 * v1.0        PwC        	 10-Jan-2020    Initial version
 * v1.1        Mark        	 21-Jul-2020    Moved Request_Log__c initialization outside try catch block to fix null pointer error
 ******************************************************************************************************/
@RestResource(urlMapping='/derwent-change-detector')
global class derwentchangedetectorapi {
	global static string endurl;
	global static string usrname;
	global static string pwd;
	global List<id> recordids = new List<id>();

	@HttpPost
	global static DerwentChangeDetectorDataStructure.Response doCallout(){
		RestRequest reqmain = RestContext.request;

		Request_Log__c reqlog;

		//String id = RestContext.request.params.get('id');
		//System.debug('ID: '+ id);
		Blob body = reqmain.requestBody;
		String requestString = body.toString();

		System.debug('Please Debug this');

		RequestWrapper rw = (RequestWrapper)JSON.deserialize(requestString,RequestWrapper.class);
		if(rw != null) {
			if(rw.Entity == 'Booking') {
				getDerwentsetting('Get_Booking');
				HTTPRequest req = new HTTPRequest();
				req.setMethod('GET');
				String reqparams ='tripids='+rw.EntityId;
				String endpointurl = endurl+ reqparams;
				System.debug('>>>>>Request >>>>>>'+ endpointurl);
				req.setEndpoint(endpointurl);

				Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				req.setHeader('Authorization', authorizationHeader);
				req.setTimeout(60 * 1000);

				HTTP http = new HTTP();
				
				//* v1.1
				reqlog = new Request_Log__c();
				reqlog.Entity__c = 'Booking';
				reqlog.Entity_Id__c = rw.EntityId;
				reqlog.Status__c = 'New';
				reqlog.Is_Synchronous__c = true;

				try{
					HTTPResponse res = http.send(req);
					System.debug('>>>>>Response>>>>>>'+res.getbody());
					/* v1.1
					reqlog = new Request_Log__c();
					reqlog.Entity__c = 'Booking';
					reqlog.Entity_Id__c = rw.EntityId;
					reqlog.Status__c = 'New';
					reqlog.Is_Synchronous__c = true;
					*/
					AsyncDerwentWebService.RequestLog = reqlog;//insert reqlog;

					asyncderwentwebservice.parseGetBookingResponse(res.getBody(),new List<String> {reqlog.id});
					return new DerwentChangeDetectorDataStructure.Response(true, 'Record inserted successfully');
				}catch(Exception ex) {
					System.debug('***Booking Error: ' + ex.getMessage());
					reqlog.Error_Log__c ='Ids=='+(rw != null ? rw.EntityId : '')+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
					reqlog.Type__c = 'Webservice Booking Batch Error';
					reqlog.Status__c = 'Failed';
					upsert reqlog;//update reqlog;
					return new DerwentChangeDetectorDataStructure.Response(FALSE, reqlog.Error_Log__c);
				}
			}else if(rw.Entity == 'Customer') {
				system.debug('Entered Customer');
				getDerwentsetting('Get_Customer');
				HTTPRequest req = new HTTPRequest();
				req.setMethod('GET');
				String reqparams ='customerIds='+rw.EntityId;
				String endpointurl = endurl+ reqparams;
				System.debug('>>>>>Request >>>>>>'+ endpointurl);
				//req.setbody(reqJSON);
				req.setEndpoint(endpointurl);
				Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				req.setHeader('Authorization', authorizationHeader);
				req.setTimeout(60 * 1000);
				HTTP http = new HTTP();
				
				//* v1.1
				reqlog = new Request_Log__c();
				reqlog.Entity__c = 'Customer';
				reqlog.Entity_Id__c = rw.EntityId;
				reqlog.Status__c = 'New';
				reqlog.Is_Synchronous__c = true;

				try{
					HTTPResponse res = http.send(req);
					System.debug('>>>>>Response>>>>>>'+res.getbody());
					/* v1.1
					reqlog = new Request_Log__c();
					reqlog.Entity__c = 'Customer';
					reqlog.Entity_Id__c = rw.EntityId;
					reqlog.Status__c = 'New';
					reqlog.Is_Synchronous__c = true;
					*/
					insert reqlog;
									
					AsyncDerwentWebService.RequestLog = reqlog;//insert reqlog;
					asyncderwentwebservice.parseGetCustResponse(res.getBody(),new List<String> {reqlog.id});
					return new DerwentChangeDetectorDataStructure.Response(TRUE, 'Record insert successfully');

				}catch(Exception ex) {
					System.debug('***Customer Error: ' + ex.getMessage());					
					reqlog.Error_Log__c ='Ids=='+(rw != null ? rw.EntityId : '')+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
					reqlog.Type__c = 'Webservice Booking Batch Error';
					reqlog.Status__c ='Failed';
					upsert reqlog;
					return new DerwentChangeDetectorDataStructure.Response(FALSE, reqlog.Error_Log__c);
				}
			}else if(rw.Entity == 'Agency') {

				try{
					reqlog = new Request_Log__c();
					reqlog.Entity__c = 'Agency';
					reqlog.Entity_Id__c = rw.EntityId;
					reqlog.Status__c = 'New';
					reqlog.Is_Synchronous__c = true;
					insert reqlog;
					AsyncDerwentWebService.RequestLog = reqlog;//insert reqlog;
					return new DerwentChangeDetectorDataStructure.Response(TRUE, 'Record insert successfully');

				}catch(Exception ex) {
					System.debug('***Agency Error: ' + ex.getMessage());
					reqlog.Error_Log__c ='Ids=='+rw.EntityId+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
					reqlog.Type__c = 'Webservice Agency Batch Error';
					reqlog.Status__c ='Failed';
					update reqlog;
					return new DerwentChangeDetectorDataStructure.Response(FALSE, reqlog.Error_Log__c);
				}
			}else if(rw.Entity == 'Quote') {
				system.debug('Entered Quote');
				getDerwentsetting('Get_Quote');
				HTTPRequest req = new HTTPRequest();
				req.setMethod('GET');
				String reqparams ='quoteIds='+rw.EntityId;
				String endpointurl = endurl+ reqparams;
				System.debug('>>>>>Request >>>>>>'+ endpointurl);
				//req.setbody(reqJSON);
				req.setEndpoint(endpointurl);
				Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				req.setHeader('Authorization', authorizationHeader);
				req.setTimeout(60 * 1000);
				HTTP http = new HTTP();
				
				//* v1.1
				reqlog = new Request_Log__c();
				reqlog.Entity__c = 'Quote';
				reqlog.Entity_Id__c = rw.EntityId;
				reqlog.Status__c = 'New';
				reqlog.Is_Synchronous__c = true;				
				
				try{
					HTTPResponse res = http.send(req);
					System.debug('>>>>>Response>>>>>>'+res.getbody());
					/* v1.1
					reqlog = new Request_Log__c();
					reqlog.Entity__c = 'Quote';
					reqlog.Entity_Id__c = rw.EntityId;
					reqlog.Status__c = 'New';
					reqlog.Is_Synchronous__c = true;
					*/
					//insert reqlog;
					AsyncDerwentWebService.RequestLog = reqlog;//insert reqlog;
					asyncderwentwebservice.parseGetQuoteResponse(res.getBody(),new List<String> {reqlog.id});
					return new DerwentChangeDetectorDataStructure.Response(TRUE, 'Record insert successfully');

				}catch(Exception ex) {
					System.debug('***Quote Error: ' + ex.getMessage());
					reqlog.Error_Log__c ='Ids=='+rw.EntityId+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
					reqlog.Type__c = 'Webservice Booking Batch Error';
					reqlog.Status__c='Failed';
					upsert reqlog;
					return new DerwentChangeDetectorDataStructure.Response(FALSE, reqlog.Error_Log__c);
				}
			}else if(rw.Entity == 'CSR') {
				reqlog = new Request_Log__c();
				reqlog.Entity__c = 'CSR';
				reqlog.Entity_Id__c = rw.EntityId;
				reqlog.Status__c = 'New';
				reqlog.Is_Synchronous__c = true;
				system.debug('Entered CSR');
				String BookingId = '';
				String DomainId = '';
				getDerwentsetting('Get_CSR');
				HTTPRequest req = new HTTPRequest();
				req.setMethod('GET');
				String reqparams ='csrIds='+rw.EntityId;
				String endpointurl = endurl+ reqparams;
				System.debug('>>>>>Request >>>>>>'+ endpointurl);
				//req.setbody(reqJSON);
				req.setEndpoint(endpointurl);
				Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				req.setHeader('Authorization', authorizationHeader);
				req.setTimeout(60 * 1000);
				HTTP http = new HTTP();
				try{
					HTTPResponse res = http.send(req);
					System.debug('>>>>>Response>>>>>>'+res.getbody());
					CSR_Response getCSRresp= CSR_Response.parse(res.getbody());

					List<CSR_Response.Csrs> RespCsrlist =getCSRresp.Csrs;
					if(RespCsrlist.size()>0) {
						BookingId = string.valueof(RespCsrlist[0].BookingId);
					}
					getDerwentsetting('Get_Booking');
					//Add for v1.13 Service Request CSR
					HTTPRequest bookreq = new HTTPRequest();
					bookreq.setMethod('GET');
					//Booking request
					String bookreqparams = 'tripids='+BookingId;
					String bookendpointurl = endurl+ bookreqparams;
					System.debug('>>>>>Book Request>>>>>>'+ bookendpointurl);
					bookreq.setEndpoint(bookendpointurl);
					Blob bookheaderValue = Blob.valueOf(usrname + ':' + pwd);
					String bookauthorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(bookheaderValue);
					bookreq.setHeader('Authorization', bookauthorizationHeader);
					bookreq.setTimeout(60 * 1000);
					HTTP bookhttp = new HTTP();

					HTTPResponse bookres = bookhttp.send(bookreq);

					//System.debug('>>>>>Book Response>>>>>>'+bookres.getbody());

					BookingResponseNew getBookresp= BookingResponseNew.parse(bookres.getbody());

					List<BookingResponseNew.cls_Trips> Triplist =getBookresp.Trips;
					if(Triplist != null && Triplist.size()>0) {
						//Getting the bookings in each booking header
						for(BookingResponseNew.cls_Bookings Bkng: Triplist[0].Bookings) {
							//Getting details of Booking Detail
							if(Bkng.BookingCore != null && Bkng.BookingCore.DomainId != null) {
								DomainId = String.valueOf(Bkng.BookingCore.DomainId);
								System.debug('DomainId===>'+DomainId);
							}
						}
					}

					Map<String,String> derwentMap = getLookupvalue();
					system.debug('derwent map'+derwentMap);
					//End of v1.13 Service Request CSR

					insert reqlog;
					AsyncDerwentWebService.RequestLog = reqlog;//insert reqlog;

					//Changed for v1.13
					if(derwentMap.containsKey('DomainId__c.'+DomainId) && Label.Service_Request_Brand.contains(derwentMap.get('DomainId__c.'+DomainId))) {
						System.debug('**********TRP Callout'+derwentMap.get('DomainId__c.'+DomainId));
						asyncderwentwebservice.parseGetServiceRequestResponse(res.getBody(),new List<String> {reqlog.id},derwentMap.get('DomainId__c.'+DomainId));
						return new DerwentChangeDetectorDataStructure.Response(TRUE, 'Record insert successfully');
					} else {
						System.debug('**********EKH and other Callout'+derwentMap.get('DomainId__c.'+DomainId));
						asyncderwentwebservice.parseGetCSRResponse(res.getBody(),new List<String> {reqlog.id});
						return new DerwentChangeDetectorDataStructure.Response(TRUE, 'Record insert successfully');
					}

				}catch(Exception ex) {
					System.debug('***CSR Error: ' + ex.getMessage());
					//reqlog = new Request_Log__c();
					reqlog.Error_Log__c ='Ids=='+rw.EntityId+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
					reqlog.Type__c = 'Webservice Booking Batch Error';
					reqlog.Status__c='Failed';
					upsert reqlog;
					return new DerwentChangeDetectorDataStructure.Response(FALSE, reqlog.Error_Log__c);
				}
			}else{
				reqlog = new Request_Log__c();
				reqLog.Error_Log__c = 'Request Body:\n'+requestString;
				reqLog.Type__c = 'Invalid request body';
				reqLog.Status__c = 'Failed';
				return new DerwentChangeDetectorDataStructure.Response(FALSE, 'Request not contains any body');
			}
		}else{
			reqlog = new Request_Log__c();
			reqLog.Error_Log__c = 'Request Body:\n'+requestString;
			reqLog.Type__c = 'Invalid request body';
			reqLog.Status__c = 'Failed';
			return new DerwentChangeDetectorDataStructure.Response(FALSE, 'Request not contains any body');
		}
	}

	/**********************Getting the Derwent integration setting*********************************/

	public static void getDerwentsetting(String servicename){
		Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
		endurl=derwent.Endpoint_URL__c;
		usrname=derwent.Username__c;
		pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
		system.debug('***Derwent***'+derwent);

		system.debug('***PWD***'+pwd);

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

	//Wrapper Class
	public class requestWrapper {
		public String Entity;
		public String EntityId;

		public requestWrapper(String entity,String entityid){
			this.Entity = entity;
			this.EntityId = entityid;
		}
	}
}