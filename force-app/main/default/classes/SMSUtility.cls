/*****
 * Name         :   SMSUtility
 * Description  :   This method will be used send SMS using API and will have code to save the logs for SMS i.e. it is sucessfull or any error
 *****/
global class SMSUtility implements Queueable, Database.AllowsCallouts{
    
    /********
     * Name         :   sendSMS_Method
     * Description  :   This method will be used to send SMS to the phone number related to the case's Contact
     ****/
    
    //@future(callout = true)
    //
    /// Added by Sri Bala
    public string JSONString;
    public List<Customer_Communication__c> listCustomerComm;
    public SMSUtility (String js,List<Customer_Communication__c> listCustomerComm){
        JSONString = js;
        this.listCustomerComm = listCustomerComm;
    }
    public void execute(QueueableContext context) {
        sendSMS_Method(JSONString,listCustomerComm);
        
    }
    // end
    public static void sendSMS_Method(string stringJSON,List<Customer_Communication__C> listCustomerComm){
        system.debug('\n--stringJSON--'+stringJSON);
        
        try{
            //Initial Request to Server to send sms.
            // making instance for request
            HttpRequest req = new HttpRequest();
            
            // setting end point
            req.setEndpoint('callout:SMS_Credentials/v1.0/messagedispatcher');
            
            // setting method
            req.setMethod('POST');
            
            // settiing header
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            
            // setting body
            req.setBody(stringJSON);
            
            // making callout
            Http http = new Http();
            HTTPResponse res = http.send(req);  //Commented by SB for testing
            
            // setting debug logs
            System.debug('Status --> '+res.getStatus());
            System.debug('StatusCode --> '+res.getStatusCode());
            System.debug('Body --> '+res.getBody());
            
            
            SMSLog logs = (SMSLog) System.JSON.deserialize(res.getBody(),SMSLog.class);
            system.debug(logs.batch.batchid);
            // creating logs
            //CreateLogs(req.getBody(), res.getBody(),'',res.getStatusCode());
           //createLogs(stringJSON,stringJSON,'',200);
           system.debug('success ' + res.getBody());
            
            
            // request to server to get basic logs.
            req = new HttpRequest();
            
            system.debug('callout:SMS_Credentials/v1.1/messagebatches/'+logs.batch.batchid);
            req.setEndpoint('callout:SMS_Credentials/v1.1/messagebatches/'+logs.batch.batchid);
            
            // setting method
            req.setMethod('GET');
            
            // settiing header
            req.setHeader('Content-Type', 'application/xml');
            req.setHeader('Accept', 'application/xml');
            
        
            // making callout
            Http http2 = new Http();
            HTTPResponse res2 = http2.send(req);  
            
            // setting debug logs
            System.debug('Status --> '+res2.getStatus());
            System.debug('StatusCode --> '+res2.getStatusCode());
            System.debug('Body --> '+res2.getBody());
            
          
           system.debug('success ' + res2.getBody());
            
            
            
            
            //request to server to get messages log
             req = new HttpRequest();
            
            system.debug('callout:SMS_Credentials/v1.1/messagebatches/'+logs.batch.batchid + '/messages');
            req.setEndpoint('callout:SMS_Credentials/v1.1/messagebatches/'+logs.batch.batchid  + '/messages');
            
            // setting method
            req.setMethod('GET');
            
            // settiing header
            req.setHeader('Content-Type', 'application/xml');
            req.setHeader('Accept', 'application/xml');
            
        
            // making callout
            Http http3 = new Http();
            HTTPResponse res3 = http3.send(req);  
            
            // setting debug logs
            System.debug('Status --> '+res3.getStatus());
            System.debug('StatusCode --> '+res3.getStatusCode());
            System.debug('Body --> '+res3.getBody());
            
          
           system.debug('success ' + res3.getBody());
            
            
            
            //inserting all logs
            //
            string logid = CreateLogs(res2.getBody(),logs.batch.batchid);
            
            ContentVersion version = new ContentVersion();
            version.Title='MessageLog';
            version.PathOnClient = 'C:\\MessageLog.xml';
            version.VersionData = Blob.valueOf(res3.getBody());
            insert version;
            
            FeedItem post = new FeedITem();
            post.body = 'MessageLog';
            post.ParentID = logid;
            insert post;
        
            // Associate the file with the post
            FeedAttachment postAttachment = new FeedAttachment();
            postAttachment.FeedEntityId = post.id;
            postAttachment.Type = 'Content';
            postAttachment.RecordId = version.id;
            insert postAttachment;
            
            List<Customer_Communication__c> customerCommToUpdate = new List<Customer_Communication__c>();
            List<String> ids = new List<String>();
            for(Customer_Communication__c cc: listCustomerComm){
                ids.add(cc.id);
            }
            List<Customer_Communication__c> newListCustomerComm = [Select id,SMS_Batch_Id__c from Customer_Communication__c where id in :ids];
            
            for(Customer_Communication__c cc: newListCustomerComm){
                if(cc.SMS_Batch_Id__c == '' || cc.SMS_Batch_Id__c == null){
                    cc.SMS_Batch_Id__c = '';
                }else{
                    cc.SMS_Batch_Id__c += ',';
                }
                cc.SMS_Batch_Id__c += logs.batch.batchid;
                customerCommToUpdate.add(cc);
            }
            update customerCommToUpdate;

        }
        catch(exception ex){
            system.debug('error ' + ex.getMessage());
           // CreateLogs(res2.getBody(),logs.batch.batchid);

            //CreateLogs('','',ex.getMessage(),0);
        }
        
    }    
    
    /*** 
     * Name         :   CreateLogs
     * Description  :   This method will be used for the creating the logs for SMS status and 
     *                  If any error comes
     ****/
    public static string CreateLogs(string response, string batchid){
       SMS_Log__c smslog = new SMS_Log__c();
       smslog.SMS_Log_Info__c = response;
       smslog.Name = batchid;
        insert smslog;
        
        return smslog.id;
    }
    
    //wrapper class for batch in smslog
    global class batch{
            string batchid;
            //string messageheaders;
        }
      
    
    //Wrapper class for logs
    global class SMSLog{
        batch batch;
        string errors;       
    }
}