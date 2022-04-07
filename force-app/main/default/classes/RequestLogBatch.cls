global class RequestLogBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
   
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();
   
    global Database.QueryLocator start(Database.BatchableContext BC){
       if(Test.isRunningTest()){
          return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where Entity__c =\'Customer\' and Unique__c = true  order by createddate ASC');
       }
       else{
             return Database.getQueryLocator('select id,Entity__c,Entity_Id__c from Request_Log__c where status__c=\'New\' and Entity__c =\'Customer\' and Unique__c = true  order by createddate ASC');
    
       }   
       
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<id> customerIds = new List<id>();
        
        
        String reqparams = '';
        Integer i=0;
        for(sobject reqLogRef : scope){
         Request_Log__c  reqLog = (Request_Log__c)reqLogRef;
         reqparams+= 'customerIds='+reqLog.Entity_Id__c;
         i++;
         if(i<scope.size())  
                reqparams+= '&';
        } 
        
        getDerwentsetting('Get_Customer');
        HTTPRequest req = new HTTPRequest();
        req.setMethod('GET');        
        
        String endpointurl = endurl+ reqparams;
        System.debug('>>>>>Request >>>>>>'+ endpointurl);        
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
                
                System.debug('>>>>>Response>>>>>>'+res.getbody());
                
                parseGetCustResponse(res.getBody());
                
            }
            catch(Exception ex) {
            
                System.debug('Callout error: '+ ex);
                /*
                Request_Log__c objLog = new Request_Log__c (id=recordids[0]);
                objLog.Error_Log__c ='Ids=='+recordids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                objLog.Type__c = 'Webservice batch error For GetCustomer';
                objLog.Entity__c='Customer';
                objLog.Status__c='Failed';
                update objLog; */             
            }    
       // }
        
        /*
        //Process retrieved SetupAuditTrail records and format field values.
        for(Request_Log__c  reqlog : (List<Request_Log__c >) scope){
            String formattedDate = currSetupAudit.CreatedDate.format('M/d/yyyy h:mm:ss a z');
            String userName = currSetupAudit.CreatedBy.Username != null ? currSetupAudit.CreatedBy.Username : '';
            String displayVal = currSetupAudit.Display != null ? String.valueOf(currSetupAudit.Display).escapeCsv() : '';
            String sectionVal = currSetupAudit.Section != null ? currSetupAudit.Section : '';
            String delegateUser = currSetupAudit.DelegateUser != null ? currSetupAudit.DelegateUser : '';
           
            String rowStr = formattedDate + ',' + userName + ',' + displayVal + ',' + sectionVal + ','+ delegateUser;
            csvRowValues.add(rowStr);
        }*/
    }
   
    global void finish(Database.BatchableContext BC){
        List<Folder> folders = [SELECT Id, Name FROM Folder WHERE Name = 'Request Logs'];
       
        if(!folders.isEmpty()){
            String documentName = 'Request_Logs-'+ Datetime.now().format('d/M/yyyy h:mm:ss a z');
            csvColumnHeader = 'TenantId, DerwentId, Email\n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
           
            // Insert the generated CSV file in Document object under "Setup Audit Trail Logs".
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folders[0].Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;
        }
    }
    
    global static string endurl;
    global static string usrname;
    global static string pwd;  
    
    
    /**********************Getting the Derwent integration setting*********************************/ 
    
    public void getDerwentsetting(String servicename){
        Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
        endurl=derwent.Endpoint_URL__c;
        usrname=derwent.Username__c;      
        pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
        system.debug('***Derwent***'+derwent);
        
        system.debug('***PWD***'+pwd);
        
    }
    
    public void parseGetCustResponse(string respbody){
        //Parsing the response of the getcustomer request        
        CustomerResponse getCustresp= CustomerResponse.parse(respbody);
        System.debug('>>>>>CustomerResponse>>>>>>'+getCustresp);
        List<CustomerResponse.Customers> Custlist =getCustresp.Customers;
        if(Custlist.size()>0){
            for(CustomerResponse.Customers cust:Custlist){
                
                String tenantid=cust.TenantId!= null ? string.valueof(cust.TenantId): '';                
                String derwentid=cust.CustomerId!= null ? cust.CustomerId: '';
                String email=cust.Email!= null ? cust.Email: '';
                /*
                String domainid=cust.LastRegisteredOnDomainId!= null ?cust.LastRegisteredOnDomainId : '';
                String title=cust.Title!= null ? cust.Title: '';
                String firstname=cust.FirstName!= null ? cust.FirstName: '';
                String lastname=cust.LastName!= null ? cust.LastName: '';
                String country=cust.CountryCode!= null ? cust.CountryCode: '';
                String po =cust.PostCode!= null ? cust.PostCode: '';
                String addr=cust.Address!= null ? cust.Address: '';
                String city=cust.City!= null ? cust.City: '';
                String county=cust.County!= null ? cust.County: '';
                String phone=cust.HomeTel!= null ? cust.HomeTel: '';
                String mobile=cust.MobileTel!= null ? cust.MobileTel: '' ;
                String loyaltyid=cust.LoyaltyId!= null ? cust.LoyaltyId: '';
                String nationality=cust.Nationality!= null ? cust.Nationality: '';
                */
                String rowStr = tenantid+ ',' + derwentid+ ',' + email;
            csvRowValues.add(rowStr);
        
          }
      }      
    }
}