public class PF_Story_Trending {
    public List<nameAndCount2> myResults{get;set;}
    //public string longStr {get;set;}
    
    public PF_Story_Trending(){
        AggregateResult[] groupStory = [SELECT ParentID,Parent.Name,  count(id) totalid 
                                        FROM PF_Stories__Feed 
                                        where Type != 'CreateRecordEvent' and CreatedDate = LAST_N_DAYS:7
                                        Group By ParentID, Parent.Name
                                        Order By count(id) DESC
                                        LIMIT 5
                                       ];
        
        system.debug('++++++++++++++++++++++'+groupStory); 
        myResults = new List<NameAndCount2>();
        for (AggregateResult SalesList: groupStory ) {
            NameAndCount2 myNC = new NameAndCount2() ;
            myNC.ParentID = String.valueOf(SalesList.get('ParentID'));
            //longStr = longSTR+myNC.ParentID;
            MyNC.ParentName = String.valueOf(SalesList.get('Name'));
            MyNC.CountVotes = String.valueof(SalesList.get('totalid'));
            myResults.add(MyNC);
            
        }
        system.debug('+++++++++++++++++++++++++++++++++'+myResults);   
    }
    public class NameAndCount2 {
        
        public string ParentName {get;set;}
        public string CountVotes {get;set;}
        public string ParentID {get;set;}
    }
}