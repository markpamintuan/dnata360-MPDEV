/**************************************************************************************************
* Name               : AsyncDerwentWebServiceGetAirports
* Description        : This is the queuable webservice class for Derwent webservice           
* Created Date       : 24-Apr-2019                                                                
* Created By         : Jed                                                      
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Jed        24-Apr-2019    Initial version
**************************************************************************************************/
global class AsyncDerwentWebServiceGetAirports implements Queueable, Database.AllowsCallouts { 
    
    
    global static string endurl;
    global static string usrname;
    global static string pwd;  
    
    //The execute method for the queuable class which contains the callout
    public void execute(QueueableContext context) {        
        getDerwentsetting('Get_Airport');
        getAirport();                
    }
    
    
    /**********************Getting the Derwent integration setting*********************************/ 
    
    public static void getDerwentsetting(String servicename){
        Derwent_Integration_Setting__mdt derwent= [select id,Endpoint_URL__c,Password__c,  Username__c from Derwent_Integration_Setting__mdt where DeveloperName = :servicename];
        endurl=derwent.Endpoint_URL__c;
        usrname=derwent.Username__c;      
        pwd=PasswordCryptoGraphy.DecryptPassword(derwent.Password__c);
        
    }
    
    
    /**********************Callout for getting airport details*********************************/
    //@future(callout=true)
    webservice static void getAirport(){
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
            parseGetAirportResponse(res);
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            Request_Log__c objLog = new Request_Log__c();
            objLog.Error_Log__c ='Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Webservice Batch error For GetAirport';
            objLog.Status__c='Failed';
            insert objLog;            
        }    
    }
    
    /**********************Parsing the response received for Get Airport request*********************************/
    public static void parseGetAirportResponse(HTTPResponse res){
        
        String reqstatus = '';
        String DerwentStatus = '';
        String DerwentId = '';
        map<string,string> AirportErrorMap = new map<string,string>();
        //Getting the field mapping to be used
        List<Derwent_Field_Mapping__mdt> mappings = [select id, JSON_Field__c,SF_Field_API_Name__c,SF_Object__c,Module__c,DataType__c,Order__c,Lookup_Type__c from Derwent_Field_Mapping__mdt where SF_Object__c like'Airport%'];
        List<Derwent_Field_Mapping__mdt> Airportmappings = new List<Derwent_Field_Mapping__mdt>();
        for(Derwent_Field_Mapping__mdt DFM :mappings){ 
            if(DFM.SF_Object__c=='Airport'){
                Airportmappings.add(DFM);
            }
        } 
        //Getting the details of all Airports in the response
        List<Lookup__c> airportList = new List<Lookup__c>();
        List<Object> airportListObject = new List<Object>();
        if (res.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            system.debug(responseMap);
            airportListObject = (List<Object>)responseMap.get('Stations');
        }
        if(airportListObject.size()>0){
            for(Object respAirport: airportListObject){
                Lookup__c Airport = new Lookup__c();
                Airport.Type__c = 'Airport';
                Map<String, Object> Airportmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(respAirport));
                for(Derwent_Field_Mapping__mdt DFM :Airportmappings){
                    string fieldval=String.valueof(Airportmap.get(DFM.JSON_Field__c));  
                    if(fieldval!=null){            
                        if(DFM.DataType__c=='DateTime'){
                            fieldval=fieldval.replace('T',' ');
                            datetime dateval= Datetime.valueOf(fieldval);
                            Airport.put(DFM.SF_Field_API_Name__c,dateval);
                        }
                        else if(DFM.DataType__c=='Checkbox'){
                            Boolean boolval=false;
                            if(fieldval=='true')
                                boolval=true;
                            Airport.put(DFM.SF_Field_API_Name__c,boolval);
                        }
                        else if(DFM.DataType__c=='Integer'){
                            Decimal fielddec= integer.valueof(fieldval);
                            Airport.put(DFM.SF_Field_API_Name__c,fielddec);
                        }
                        else
                            Airport.put(DFM.SF_Field_API_Name__c,fieldval);
                    }                    
                }
                airportList.add(Airport);
            }  
            List<Lookup__c> upsertList = new List<Lookup__c>();
            Map<String,Lookup__c> airportLookupMap = new Map<String,Lookup__c>();
            for(Lookup__c l: [select id,name,code__c from Lookup__c where type__c = 'Airport']){     
                if(l.Code__c != null){
                    airportLookupMap.put(l.Code__c.toUpperCase(),l);    
                }                
            }
            for(Lookup__c n: Airportlist){                
                String apCode = n.code__c.toUpperCase();
                if(airportLookupMap.containsKey(apCode)){
                    n.code__c = airportLookupMap.get(apCode).Code__c;
                    n.Id = airportLookupMap.get(apCode).Id; 
                    system.debug(n);
                    upsertList.add(n);
                }else{
                    system.debug(n);
                    upsertList.add(n);
                }
                
            }
            if(upsertList.size()>0){
                try{
                    Set<Lookup__c> tempSet = new Set<Lookup__c>();
                    tempSet.addAll(upsertList);
                    List<Lookup__c> finalUpsertList = new List<Lookup__c>(); 
                    finalUpsertList.addAll(tempSet);
                    upsert finalUpsertList; 
                    Request_Log__c objLog = new Request_Log__c();
                    objLog.Type__c = 'Webservice Batch For GetAirport'; 
                    objLog.Status__c='Completed';
                    insert objLog;
                }
                catch(Exception ex) {
                    Request_Log__c objLog = new Request_Log__c();
                    objLog.Error_Log__c ='Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
                    objLog.Type__c = 'Webservice Batch error For GetAirport'; 
                    objLog.Status__c='Failed';
                    insert objLog;            
                } 
                
            }
        }
    }    
}