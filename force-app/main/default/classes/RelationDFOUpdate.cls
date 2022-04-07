public class RelationDFOUpdate implements Queueable  {
    public Map<Id,relation__c> relIdList;
    public RelationDFOUpdate(Map<Id,relation__c> relIdList)
    {
        this.relIdList = relIdList;
    }
    public void execute(QueueableContext context) {
         List<relation__c> rellist = new  List<relation__c>();
        for(relation__c rel : relIdList.values())
        {
             for(DFoAccount__c acc :[Select id,Account__c,child_id__c from DFoAccount__c where child_Id__c =: rel.Org_ParentAccountId__c]) 
            {
                    relation__c newRel = new relation__c(Id = rel.Id);
                    newRel.Org_AccountName__c = acc.Account__c;
                    rellist.add(newRel);
                    system.debug('@@Account Name:'+newRel.Org_AccountName__c );       
		            relIdList.put(rel.ID,rel);
		            system.debug('bookIdList'+relIdList);
		            system.debug('@@'+acc.Id);
                
            }
          
        }
        relIdList.putall(relList);
        if(relIdList.size()>0)
        	update relIdList.values();
        system.debug('After DFO update'+relIdList);
    }
    
}