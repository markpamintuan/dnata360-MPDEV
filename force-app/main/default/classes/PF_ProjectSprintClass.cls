public class PF_ProjectSprintClass {
    public string recentId {get;set;}
    public string projId {get;set;}
    public string sprintId {get;set;}
    public string releaseId {get;set;}
    public boolean isRendered {get; set;}
    public boolean sprintBurndownAvail {get;set;}
    
    public SelectOption[] ProjectList {get;set;}
    public SelectOption[] ReleaseList {get;set;}
    public SelectOption[] Sprints {get;set;}
    
    
    public PF_ProjectSprintClass.PF_ProjectSprintClass(PF_Homepage controller){
        initialLoad();
        chartData();
    }
    
    //PUBLIC PF_ProjectSprintClass.
    public PF_ProjectSprintClass(){
        initialLoad();
        chartData();
    }
    
    
    public void initialLoad(){
        
        sprintId = retrieveRecentelyViewed(); // retreive recent sprint id
        
        if(sprintId != null){
            PF_Sprints__c sprintInfo = [select id, name, PF_Release__c, PF_Release__r.PF_Project__c 
                                        from PF_Sprints__c 
                                        where id =: sprintId limit 1]; // get me the info for the recent sprint
            projId = sprintInfo.PF_Release__r.PF_Project__c; //set the project Id
            releaseId = sprintInfo.PF_Release__c; //set the release id
            
            system.debug('what is my project id? ' +projId +' what is my releaes id ' +releaseId);
            
        }
        retrieveProject();
        retrieveRelease();
        retrieveSprints();
        
        
        
    }
    
    public string retrieveRecentelyViewed(){
        List <RecentlyViewed> recentSprints = [SELECT Id, Name, Type, LastViewedDate, LastName FROM RecentlyViewed 
                                       WHERE Type IN ('PF_Sprints__c')
                                       ORDER BY LastViewedDate DESC LIMIT 1];
        if(recentSprints.size()>0){
            return recentSprints[0].id;
        } else {
            return null ;
        }
       
    }
    
    public void retrieveProject(){
        
        List<SelectOption> projectoptions = new List<SelectOption>();
        ProjectList = new List <selectoption>();
        
        List <PF_Project__c> projList = [select id, name from PF_PRoject__c ORDER BY NAME ASC];
        
        system.debug(projList);
        projectoptions.add(new SelectOption('','Select Project'));
        for(PF_Project__c mProj : projList){
            projectoptions.add(new SelectOption(mProj.id,mProj.name)); 
        }
        ProjectList.addAll(projectoptions);
    }
    
    public void retrieveRelease(){
        
        List<SelectOption> releaseoptions = new List<SelectOption>();
        ReleaseList = new List <selectoption>();
        
        List <PF_Release__c> relList = [select id, name from PF_Release__c 
                                        where PF_Project__c =: projId
                                        Order By Name ASC
                                       ];
        
        if(relList.size()>0){
            releaseoptions.add(new SelectOption('','Select Release'));
            system.debug('RELEASE LIST? ' +relList);
            for(PF_Release__c r : relList){
                releaseoptions.add(new SelectOption(r.id,r.name)); 
            }
            if(releaseoptions.size()>0){
                //sprintId
                ReleaseList.addAll(releaseoptions);
            }
        } else {
             ReleaseList.add(new SelectOption('','No Release Available'));
        }
    }
    
        
    public void retrieveSprints(){
        Sprints = new List <selectoption>(); 
        
        List<SelectOption> sprintOptions = new List<SelectOption>();

        if(projId != null){
            List <PF_Sprints__c> projSprint = [select id, Name, PF_Start_Date__c, PF_Number_of_Business_Day__c, PF_Total_Sprint_Capacity__c, PF_Sprint_Velocity__c, PF_Release__r.PF_Project__c  
                                               from PF_Sprints__c
                                               where PF_Release__r.PF_Project__c  =: projId and PF_Release__c =: releaseid
                                               Order By Name ASC
                                              ];
            system.debug('size of my project sprint??? ' +projSprint.size() +'---' +projSprint);
            if(projSprint.size()>0){
                sprintOptions.add(new SelectOption('','Select Sprint'));
                for(PF_Sprints__c p : projSprint){
                    sprintOptions.add(new SelectOption(p.id,p.name));
                }
                
                if(sprintOptions.size()>0){
                    sprints.addAll(sprintOptions); 
                }
            } else {
            sprints.add(new SelectOption('','No Sprints Available'));
            }
        } else {
            sprints.add(new SelectOption('','No Sprints Available'));
        }
        
    }
    //Page Reference Methods
    public PageReference setOptions(){ 
        return null;
    }
    public PageReference changeProject(){
        retrieveRelease();
        retrieveSprints();
        sprintId = null;
        return null;
    }
    
    public PageReference changeRelease(){
        retrieveSprints();
        return null;
    }
    
    public PageReference retrieveChart(){
        retrieveSprints();
        chartData();
        system.debug('we are here... ' +sprintId);
        if(sprintId != null && Label.pForceCallout == 'true' ){
            //String updateEndpointURL =  Label.pForce_Salesforce_URL+'/services/data/v36.0/query/?q=';
            String updateEndpointURL = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/data/v36.0/query/?q=';
            system.debug('my endpoint?? ' +updateEndpointURL);
            String updateRecentView = 'Select Id FROM PF_Sprints__c where id = \'' +sprintId +'\' LIMIT 1 FOR VIEW';
            string url = updateEndpointURL+ EncodingUtil.urlEncode(updateRecentView, 'UTF-8') ;
            
            Http h = new Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' +UserInfo.getSessionId());
            
            req.setEndpoint(url);
            req.setMethod('GET');
            system.debug(req);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('response??? ' +res.getBody());
        }
        return null;
    }

    
    
    
    ///Burndown Chart Logic
    public list <string> stringLabel {get;set;}
    public list <integer> optimizedList {get;set;}
    public list <integer> actualList {get;set;}
    public void chartData(){
        system.debug('went to charts whats my sprint id?? ' +sprintId);
        stringLabel = new List<string>();
        optimizedList = new List<Integer>();
        actualList = new list <Integer>();
        List<PF_Sprints__c> sprintInfo = [select id, PF_Start_Date__c, PF_Number_of_Business_Day__c, PF_Total_Sprint_Capacity__c, PF_Sprint_Velocity__c
                                          from PF_Sprints__c
                                          where id IN 
                                          (SELECT PF_Sprint__c  
                                           FROM PF_Stories__c where PF_Sprint__c =: sprintid )
                                          and PF_Number_of_Business_Day__c != null
                                         ];
        // 'a0H36000002KBv3' a0H36000002KBNaEAO
        
        if(sprintInfo.size()>0){
            
            sprintBurndownAvail = true;
            List <AggregateResult> ar = [select SUM(PF_Story_Point_Number__c) story, PF_End_Date__c from PF_Stories__c where PF_Sprint__c =: sprintid 
                                         and PF_End_Date__c != null 
                                         GROUP BY PF_End_Date__c ];
            
            Map<String, String> spMap = new Map<String, String>();
            
            for (AggregateResult result : ar)  {
                System.debug('Info ===' + result.get('story') +'====' +result.get('PF_End_Date__c'));
                date dGroup = date.valueOf(result.get('PF_End_Date__c'));
                string dateId = ''+dgroup.year()+dgroup.dayOfYear();
                spMap.put(dateId, string.valueof(result.get('story')));
            }
            
            system.debug('spMap ==== ' +spMap);
            
            SYSTEM.debug('did we get this value 2016-03-09 00:00:00 from the map ' +spMap.get('2016-03-09 00:00:00'));
            SYSTEM.debug('did we get this value 2016-03-08 00:00:00 from the map ' +spMap.get('2016-03-08 00:00:00'));
            Integer eventCounter = 0; //eventCounter to be used in do while and to track number of occurence
            integer counter = 0; //counter to track the number of days and using counter++ to add counter
            integer endCounter = integer.valueof(sprintInfo[0].PF_Number_of_Business_Day__c) + 1;
            integer velocity = integer.valueof(sprintInfo[0].PF_Sprint_Velocity__c); 
            decimal decSubstract;
            integer springCap = integer.valueof(sprintInfo[0].PF_Total_Sprint_Capacity__c);
            integer dailyBurn = springCap; //start of daily burn based on capacity
            
            //do while loop here
            do { 
                datetime dateNow = sprintInfo[0].PF_Start_Date__c.addDays(counter);
                integer burnrate;
                counter++; //always add a number
                //if statement to skip Weekend
                if(dateNow.format('E')!= 'Sun' && dateNow.format('E')!= 'Sat'){
                    string strDay = string.valueof('Day '+eventCounter);
                    stringLabel.add(strDay);
                    
                    system.debug(dateNow.format('E') +'---- ' +dateNow +'---' +counter);
                    integer optInteger = integer.valueOf(springCap - (velocity * eventCounter));//logic to get the optimize burn rate
                    optimizedList.add(optInteger);
                    
                    integer actualBurn;
                    
                    
                    String dateNowId = ''+string.valueof(datenow.year())+string.valueof(datenow.dayofyear());
                    system.debug('datenowid??? ' +dateNowId);
                    if(spMap.get(dateNowId) != null){
                        actualBurn = integer.valueof(spMap.get(dateNowId));   
                    } else {
                        actualBurn = 0;
                    }
                    
                    system.debug('>>> actual burn??? ' +actualBurn);
                    burnrate = dailyBurn - actualBurn;
                    dailyBurn = burnrate;
                    actualList.add(burnrate);
                    
                    eventCounter++;
                }
            } while (
                eventCounter < endCounter// sprintInfo[0].PF_Number_of_Business_Day__c //when eventCounter hits number of occurence then we finished
            );
        }
        else{
            sprintBurndownAvail = false;
        }
    }
}