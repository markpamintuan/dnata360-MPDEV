public class MC_EmailSubscribe {
   @InvocableMethod public static void doAction(){
        Contact[] contacts = [Select Id, Email, HasOptedOutOfEmail,(Select Id, Name from et4ae5__IndividualEmailResults__r WHERE 
                                                                    et4ae5__DateUnsubscribed__c != NULL  ORDER BY et4ae5__DateUnsubscribed__c DESC LIMIT 1)
                              from Contact WHERE HasOptedOutOfEmail = true];
       
            Map<Id, Contact> cMap = new Map<Id, Contact>();
        	for(Contact c : contacts){
            System.debug(c);
            if(c.et4ae5__IndividualEmailResults__r.size()>0)
                cMap.put(c.id, c);
        	}
        String output;
        for(Contact c:Contacts)
        {    
            if(c.et4ae5__IndividualEmailResults__r.isEmpty() || !cMap.containsKey(c.id)) continue;
            try{
            		if(!Test.isRunningTest())
                		output = et4ae5.jsButtonMethods.performResub(c.id, 'contact');
        		}
         	catch(Exception e)
         	{
             	output = e.getMessage();
         	}
         	System.debug(output);
        }
    }
}