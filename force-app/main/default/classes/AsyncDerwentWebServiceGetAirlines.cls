/**************************************************************************************************
* Name               : AsyncDerwentWebServiceGetAirlines
* Description        : This is the queuable webservice class for Derwent webservice           
* Created Date       : 24-Apr-2019                                                                
* Created By         : Jed                                                      
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Jed        24-Apr-2019    Initial version
**************************************************************************************************/
global class AsyncDerwentWebServiceGetAirlines implements Queueable, Database.AllowsCallouts { 
    
    
    global static string endurl;
    global static string usrname;
    global static string pwd;  
    
    //The execute method for the queuable class which contains the callout
    public void execute(QueueableContext context) {
        
        getDerwentsetting('Get_Airline');
        getAirline();
        
        
    }
    
    
    /**********************Getting the Derwent integration setting*********************************/ 
    
    public static void getDerwentsetting(String servicename){
        Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
        endurl=derwent.Endpoint_URL__c;
        usrname=derwent.Username__c;      
        pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
        
    }
    
    
    /**********************Callout for getting Airline details*********************************/
    //@future(callout=true)
    webservice static void getAirline(){
        HTTPRequest req = new HTTPRequest();
        req.setMethod('GET');
        String endpointurl = endurl;
        req.setEndpoint(endpointurl);
        Blob headerValue = Blob.valueOf(usrname + ':' + pwd);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue); 
        req.setHeader('Authorization', authorizationHeader);
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        try{
            
            HTTPResponse res = http.send(req); 
            //System.debug('>>>>>Response>>>>>>'+res.getbody());
            parseGetAirlineResponse(res);
        }
        catch(Exception ex) {
            Request_Log__c objLog = new Request_Log__c();
            objLog.Error_Log__c ='Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Webservice Batch error For GetAirline';
            objLog.Status__c='Failed';
            insert objLog;            
        }    
    }
    
    /**********************Parsing the response received for Get Airline request*********************************/
    public static void parseGetAirlineResponse(HTTPResponse res){
        
        
        system.debug('PARSING RESPONSE');
        String reqstatus = '';
        String DerwentStatus = '';
        String DerwentId = '';
        map<string,string> AirlineErrorMap = new map<string,string>();
        //Getting the field mapping to be used
        List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where SF_Object__c like'Airline%'];
        List<Derwent_Field_Mapping__mdt> Airlinemappings = new List<Derwent_Field_Mapping__mdt>();
        for(Derwent_Field_Mapping__mdt DFM :mappings){ 
            if(DFM.SF_Object__c=='Airline'){
                Airlinemappings.add(DFM);
            }
        } 
        //Getting the details of all Airlines in the response
        Set<Lookup__c> AirlineList = new Set<Lookup__c>();
        List<Object> AirlineListObject = new List<Object>();
        if (res.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            AirlineListObject = (List<Object>)responseMap.get('Carriers');
        }
        if(AirlineListObject.size()>0){
            for(Object respAirline: AirlineListObject){
                Lookup__c Airline = new Lookup__c();
                Airline.Type__c = 'Airline';
                Map<String, Object> Airlinemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respAirline));
                for(Derwent_Field_Mapping__mdt DFM :Airlinemappings){
                    string fieldval=String.valueof(Airlinemap.get(DFM.JSON_Field__c));  
                    if(fieldval!=null){            
                        if(DFM.DataType__c=='DateTime'){
                            fieldval=fieldval.replace('T',' ');
                            datetime dateval= Datetime.valueOf(fieldval);
                            Airline.put(DFM.SF_Field_API_Name__c,dateval);
                        }
                        else if(DFM.DataType__c=='Checkbox'){
                            Boolean boolval=false;
                            if(fieldval=='true')
                                boolval=true;
                            Airline.put(DFM.SF_Field_API_Name__c,boolval);
                        }
                        else if(DFM.DataType__c=='Integer'){
                            Decimal fielddec= integer.valueof(fieldval);
                            Airline.put(DFM.SF_Field_API_Name__c,fielddec);
                        }
                        else
                            Airline.put(DFM.SF_Field_API_Name__c,fieldval);
                    }
                    
                }
                AirlineList.add(Airline);
            }  
            List<Lookup__c> upsertList = new List<Lookup__c>();
            Map<String,Lookup__c> AirlineLookupMap = new Map<String,Lookup__c>();
            for(Lookup__c l: [select id,name,code__c from Lookup__c where type__c = 'Airline']){  
                if(l.Code__c != null){
                    AirlineLookupMap.put(l.Code__c.toUpperCase(),l); 
                }
            }            
            List<Lookup__c> loopList = new List<Lookup__c>();
            loopList.addAll(Airlinelist);            
            for(Lookup__c n: loopList){                
                String apCode = n.code__c.toUpperCase();
                if(AirlineLookupMap.containsKey(apCode)){
                    Lookup__c temp = AirlineLookupMap.get(apCode);                        
                    temp.Code__c = n.code__c ;
                    temp.Name = n.Name; 
                    upsertList.add(temp);
                }else{
                    upsertList.add(n);
                }
                
            }
            if(upsertList.size()>0){
                Set<Lookup__c> tempSet = new Set<Lookup__c>();
                tempSet.addAll(upsertList);
                List<Lookup__c> finalUpsertList = new List<Lookup__c>(); 
                finalUpsertList.addAll(tempSet);                                
                try{                    
                    upsert finalUpsertList; 
                    Request_Log__c objLog = new Request_Log__c();
                    objLog.Type__c = 'Webservice Batch For GetAirline';  
                    objLog.Status__c='Completed';
                    insert objLog; 
                }
                catch(Exception ex) {
                    Request_Log__c objLog = new Request_Log__c();
                    objLog.Error_Log__c ='Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                    objLog.Type__c = 'Webservice Batch error For GetAirline'; 
                    objLog.Status__c='Failed';
                    insert objLog;            
                }           
            }
        }
    }    
}