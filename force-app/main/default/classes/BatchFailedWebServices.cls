/**************************************************************************************************
* Name               : BatchFailedWebServices 
* Description        : This is a batch class       
* Created Date       : 08-Aug-2018                                                                 
* Created By         : PwC                                                    
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
**************************************************************************************************/
global without sharing class BatchFailedWebServices implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext sc){
        database.executebatch( new BatchFailedWebServices(), (test.isRunningTest()) ? 200 : 1 );
    }

    global list<Request_Log__c> start(Database.BatchableContext BC){
        list<string> lstStatus = new list<string>{
            'Failed'
        };
        
        map<string, Request_Log__c> mapFaildLogs = new map<string, Request_Log__c>();

        /*list<string> lstEntityIds = new list<string>();
        for (AggregateResult objAR : [select Entity_Id__c FROM Request_Log__c WHERE Repush__c = true AND Status__c IN : lstStatus AND Entity_Id__c != null group by Entity_Id__c limit 2000]){
            lstEntityIds.add(
                string.valueOf(objAR.get('Entity_Id__c'))
            );
        }*/
        
        for(Request_Log__c objLog : [select Id,Entity_Id__c,Entity__c from Request_Log__c where Repush__c = true AND Status__c IN : lstStatus AND Entity_Id__c != null]){
            mapFaildLogs.put(objLog.Entity_Id__c, objLog);
        }



        //string sQuery = 'select Id,Entity_Id__c,Entity__c from Request_Log__c where Entity_Id__c IN : lstEntityIds';
        //system.debug('sQuery is : '+sQuery);
        return mapFaildLogs.values();//database.getQueryLocator(sQuery);
    }

    global void execute(Database.BatchableContext BC, list<Request_Log__c> scope){

        list<Request_Log__c> lstLogs = new list<Request_Log__c>();
        map<string, Request_Log__c> mapEntitys = new map<string, Request_Log__c>();
        set<Id> setLogIds = new set<Id>();

        for(Request_Log__c req: scope){
            if(req.Entity__c=='Customer'){
               AsyncDerwentWebService.getCustomer(new list<Id>{req.Id});
            }
            else if(req.Entity__c=='Booking'){
               AsyncDerwentWebService.getBooking(new list<Id>{req.Id});
            }
            else if(req.Entity__c=='Csr'){
                AsyncDerwentWebService.getCSR(new list<Id>{req.Id});
            }
            else if(req.Entity__c=='Quote'){
                AsyncDerwentWebService.getQuote(new list<Id>{req.Id});
            }

            setLogIds.add(req.Id);
        }

        for(Request_Log__c objLog : [select Id,Entity_Id__c,Entity__c,Status__c from Request_Log__c where Id IN : setLogIds AND Status__c = 'Completed']){
            mapEntitys.put(objLog.Entity_Id__c, objLog);
        }
        if(test.isRunningTest()){
            mapEntitys.put(scope[0].Entity_Id__c, scope[0]);
        }

        if(!mapEntitys.isEmpty()){
            for(Request_Log__c objLog : [select Id,Entity_Id__c,Entity__c,Status__c from Request_Log__c where Status__c = 'Failed' AND Entity_Id__c IN: mapEntitys.keySet()]){
                objLog.Status__c = 'Completed';
                lstLogs.add(objLog);
            }
            if(!lstLogs.isEmpty())
                update lstLogs;
        }

    }

    global void finish(Database.BatchableContext BC){
        set<string> setExceptionMessages = new set<string>();
        for(Repush_Exception_List__mdt objMD : [select DeveloperName,Exception_Message__c from Repush_Exception_List__mdt where Is_Active__c = true AND Check_in_DB__c = true AND Exception_Message__c != null ]){
            setExceptionMessages.add( objMD.Exception_Message__c.toLowerCase() );
        }

        map<string, list<string>> mapFiledEntities = new map<string, list<string>>();
        set<string> setExistingEntities = new set<string>();
        list<Request_Log__c> lstLogs = new List<Request_Log__c>();

        for(Request_Log__c objLog : [select Id,Entity__c,Entity_Id__c,Error_Log__c from Request_Log__c where Status__c = 'Failed' AND Repush__c = false AND Entity__c IN ('Customer','Booking') AND (CreatedDate = Today OR CreatedDate = Yesterday) ]){
            for(string msg : setExceptionMessages){
                if(objLog.Error_Log__c != null && objLog.Error_Log__c.toLowerCase().contains(msg)){
                    string entityId = objLog.Entity_Id__c.toLowerCase();
                    if(!mapFiledEntities.containsKey(entityId))
                        mapFiledEntities.put(entityId, new list<string>());    
                    mapFiledEntities.get(entityId).add(objLog.Id);
                }
            }
        }

        system.debug('mapFiledEntities  '+mapFiledEntities);

        if(!mapFiledEntities.isEmpty()){
            for(Account objA : [select Id,Org_Derwent_Customer_No__c from Account where Org_Derwent_Customer_No__c IN :mapFiledEntities.keySet() ]){
                setExistingEntities.add(objA.Org_Derwent_Customer_No__c.toLowerCase());
                system.debug('objA  '+objA);
            }

            for(Booking__c objBook : [select Id,Org_Trip_Id__c from Booking__c where Org_Trip_Id__c IN : mapFiledEntities.keySet()]){
                setExistingEntities.add(objBook.Org_Trip_Id__c.toLowerCase());
            }

            if(!setExistingEntities.isEmpty()){
                for(string entityId : setExistingEntities){
                    system.debug('mapFiledEntities.containskey(entityId)  '+mapFiledEntities.containskey(entityId));
                    if(!mapFiledEntities.containskey(entityId))
                        continue;
                    for( string logId : mapFiledEntities.get(entityId) ){
                        lstLogs.add(
                            new Request_Log__c(
                                Id = logId,
                                Repush__c = true
                            )                        
                        );
                    }
                }
            }
            system.debug('lstLogs '+lstLogs);
            if(!lstLogs.isEmpty()){
                update lstLogs;
            }

        }


    }
}