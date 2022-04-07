global without sharing class BatchUpdateTravellerCountOnBooking implements Database.Batchable<sObject>, Schedulable{
    
    public Integer iBatchSize = 2000;
    public Date cutoffdate;
    public list<string> lstBrands = new list<string>();

    public static map<Integer, set<string>> mapTravellerCategory = new map<integer, set<string>>{
		1 => new set<string>{'Adult','Adult Swimmer','Adult NON Swimmer','Main Driver','Additional Driver','Lead Guest'}, // Adults
		2 => new set<string>{'Child','Child Swimmer','Child Non Swimmer','Infant'} // Childs // Infants
	};

    global void execute(SchedulableContext sc){
        database.executebatch( new BatchUpdateTravellerCountOnBooking(), (test.isRunningTest() ? 1 : iBatchSize) );
    }

    global database.QueryLocator start(Database.BatchableContext BC){
        cutoffdate = cutoffdate != null ? cutoffdate : system.today();
        if(test.isRunningTest())
            cutoffdate = system.today().addDays(2);
        Id BookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByDeveloperName().get('Booking').getRecordTypeId();
        //string sQuery = 'string id,Name,Org_Age_Category__c,Org_Age_on_Return__c,Org_Booking__c from Traveller__c where CreatedDate <=: cutoffdate order by Org_Booking__c';
        string sQuery = 'select id from Booking__c where Id IN ( select Org_Booking__c from Traveller__c where CreatedDate <=: cutoffdate) AND RecordTypeId=:BookingItemRecordTypeId ';
        
        if(!lstBrands.isEmpty())
            sQuery += ' AND Org_Brand__c IN : lstBrands';
		
        return database.getQueryLocator(sQuery);
    }

    global void execute(Database.BatchableContext BC, list<Booking__c> scope){
        list<Booking__c> lstBookings = new list<Booking__c>();
        map<Id, Integer[]> mapTravellerCounts = new map<Id, Integer[]>();
        list<Traveller__c> lstTravellers = new list<Traveller__c>();
        for(Traveller__c objT : [select Id,Org_Booking__c,Org_Age_Category__c,Org_Age_on_Return__c from Traveller__c where Org_Booking__c IN : scope]){
            if(!mapTravellerCounts.containsKey(objT.Org_Booking__c))
                mapTravellerCounts.put(objT.Org_Booking__c, new Integer[]{0,0});
            if(objT.Org_Age_Category__c != null){                
                if(mapTravellerCategory.get(1).contains(objT.Org_Age_Category__c)){
                    mapTravellerCounts.get(objT.Org_Booking__c)[0]++;
                }
                if(mapTravellerCategory.get(2).contains(objT.Org_Age_Category__c)){
                    mapTravellerCounts.get(objT.Org_Booking__c)[1]++;
                }
            }else{
                mapTravellerCounts.get(objT.Org_Booking__c)[0]++;
            }
            lstTravellers.add(objT);
        }

        for(Id BookingId : mapTravellerCounts.keySet()){
            Integer[] iTCounts = mapTravellerCounts.get(BookingId);
            if(iTCounts != null && (iTCounts[0] > 0 || iTCounts[1] > 0)){
                Booking__c objBooking = new Booking__c(Id=BookingId);
                if(iTCounts[0] > 0)
                    objBooking.Number_of_adults__c = iTCounts[0];
				if(iTCounts[1] > 0)
				    objBooking.Number_of_children__c = iTCounts[1];
                lstBookings.add(objBooking);
            }
        }
        if(!lstBookings.isEmpty())
            update lstBookings;
        if(!lstTravellers.isEmpty())
            delete lstTravellers;
    }

    global void finish(Database.BatchableContext BC){

    }
}