public class PF_Homepage {
    
    //string and id parameters
    public Id currentUserId {get;set;}
    public String currentUsername {get;set;}
    public string myStr {get;set;}
    public string projId {get;set;}
    
    //list get set methods
    public PF_project__Feed[] myProjectfeeds {get;set;}
    public PF_Stories__Feed[] myStoryFeeds {get;set;}
    public PF_Project_Item__Feed[] myItemFeeds {get;set;}
    public PF_Release__Feed[] myReleasefeeds {get;set;}
    public PF_Sprints__Feed[] mySprintfeeds {get;set;}
    
    public Task[] myTasks {get;set;}
    public PF_Project__c[] myProjects {get;set;}
    public EntitySubscription[] myFollow {get;set;}
    
    
    //public List<PF_Story_Trending.NameAndCount2>  lstTrends {get;set;}
    public PF_Homepage() {
        currentUserId = UserInfo.getUserId();
        currentUsername = UserInfo.getName();
        
        retrieveMyItems();
    }
    
    public void retrieveMyItems(){
        myProjectfeeds = [SELECT Id, Type, 
                          CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
                          ParentId, Parent.Name, lastmodifiedDate,
                          Body, Title, LinkUrl, ContentData, ContentFileName,
                          (SELECT Id, FieldName, OldValue, NewValue 
                           FROM FeedTrackedChanges ORDER BY Id DESC), 
                          (SELECT Id, CommentBody, CreatedDate,
                           CreatedBy.FirstName, CreatedBy.LastName
                           FROM FeedComments ORDER BY CreatedDate LIMIT 10),
                          (SELECT CreatedBy.FirstName, CreatedBy.LastName
                           FROM FeedLikes)
                          FROM PF_Project__Feed
                          
                          ORDER BY lastmodifiedDate DESC, Id DESC
                          LIMIT 5];
        
        myReleasefeeds = [SELECT Id, Type, 
                          CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
                          ParentId, Parent.Name, lastmodifiedDate,
                          Body, Title, LinkUrl, ContentData, ContentFileName,
                          (SELECT Id, FieldName, OldValue, NewValue 
                           FROM FeedTrackedChanges ORDER BY Id DESC), 
                          (SELECT Id, CommentBody, CreatedDate,
                           CreatedBy.FirstName, CreatedBy.LastName
                           FROM FeedComments ORDER BY CreatedDate LIMIT 10),
                          (SELECT CreatedBy.FirstName, CreatedBy.LastName
                           FROM FeedLikes)
                          FROM PF_Release__Feed
                          
                          ORDER BY lastmodifiedDate DESC, Id DESC
                          LIMIT 5];
        
        mySprintfeeds = [SELECT Id, Type, 
                         CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
                         ParentId, Parent.Name, lastmodifiedDate,
                         Body, Title, LinkUrl, ContentData, ContentFileName,
                         (SELECT Id, FieldName, OldValue, NewValue 
                          FROM FeedTrackedChanges ORDER BY Id DESC), 
                         (SELECT Id, CommentBody, CreatedDate,
                          CreatedBy.FirstName, CreatedBy.LastName
                          FROM FeedComments ORDER BY CreatedDate LIMIT 10),
                         (SELECT CreatedBy.FirstName, CreatedBy.LastName
                          FROM FeedLikes)
                         FROM PF_Sprints__Feed
                         
                         ORDER BY lastmodifiedDate DESC, Id DESC
                         LIMIT 5];
        
        myStoryFeeds = [SELECT Id, Type, 
                        CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
                        ParentId, Parent.Name, lastmodifiedDate,
                        Body, Title, LinkUrl, ContentData, ContentFileName,
                        (SELECT Id, FieldName, OldValue, NewValue 
                         FROM FeedTrackedChanges ORDER BY Id DESC), 
                        (SELECT Id, CommentBody, CreatedDate,
                         CreatedBy.FirstName, CreatedBy.LastName
                         FROM FeedComments ORDER BY CreatedDate LIMIT 10),
                        (SELECT CreatedBy.FirstName, CreatedBy.LastName
                         FROM FeedLikes)
                        FROM PF_Stories__Feed
                        
                        ORDER BY lastmodifiedDate DESC, Id DESC
                        LIMIT 5];
        
        myItemFeeds = [SELECT Id, Type, 
                       CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
                       ParentId, Parent.Name, lastmodifiedDate,
                       Body, Title, LinkUrl, ContentData, ContentFileName,
                       (SELECT Id, FieldName, OldValue, NewValue 
                        FROM FeedTrackedChanges ORDER BY Id DESC), 
                       (SELECT Id, CommentBody, CreatedDate,
                        CreatedBy.FirstName, CreatedBy.LastName
                        FROM FeedComments ORDER BY CreatedDate LIMIT 10),
                       (SELECT CreatedBy.FirstName, CreatedBy.LastName
                        FROM FeedLikes)
                       FROM PF_Project_Item__Feed
                       
                       ORDER BY lastmodifiedDate DESC, Id DESC
                       LIMIT 5];
        
        myTasks = [select Id, subject, whoId,Who.name, whatId,what.name, ActivityDate 
                   from Task 
                   where isClosed = false and OwnerId =: UserInfo.getUserId()
                   order by ActivityDate ASC
                   Limit 5
                  ];
        
        myFollow = [SELECT CreatedById, CreatedDate, IsDeleted, Id, ParentId, Parent.Name, SubscriberId 
                    FROM EntitySubscription
                    where SubscriberId =: UserInfo.getUserId() and CreatedDate = LAST_N_DAYS:7
                    Order By CreatedDate DESC Limit 5
                   ];
        
        myProjects = [SELECT id,Name FROM PF_Project__c WHERE OwnerId = : UserInfo.getUserId() Order by CreatedDate ASC];
        //PF_Story_Trending trend = new PF_Story_Trending();
        //lstTrends = trend.myResults;
        
    }
    
    //Page Reference redirect to Salesforce native home page
    public PageReference redirectToPreviousPage() {
        PageReference pageRef;
        pageRef = new PageReference('/home/home.jsp');
        pageRef.setRedirect(true);
        return pageRef;  
    }
    
    public List <PF_Project_Item__c> getRisk(){
        List <PF_Project_Item__c> rsk = [Select Id, Name, PF_Risk_Ranking__c, PF_Project__c, PF_Project__r.Name, 
                                         PF_Project_Item_Description__c, PF_Type__c from PF_PRoject_Item__c 
                                         where PF_Type__c = 'Risk' and PF_Risk_Ranking__c != null and PF_Status__c != 'Closed'
                                         Order by PF_Risk_Ranking__c DESC
                                         limit 5];
        
        if(rsk.size() > 0) {
            return rsk;
        } else {
            return null;
        }
        
    }
    public List <PF_Project__c  > getProject(){
        List <PF_Project__c> projList = [select id, name from PF_PRoject__c];
        return projList;
    }
    
    public LIST <SelectOption> getProjectList(){
        // recently viewed
        List<RecentlyViewed> recent = [SELECT Id, Name FROM RecentlyViewed 
                                       WHERE Type IN ('PF_Project__c')
                                       ORDER BY LastViewedDate DESC ];
        String recentId;
        List <PF_Project__c> projList;
        List<SelectOption> projectoptions = new List<SelectOption>();
        if(recent.size()>0){
            projectoptions.add(new SelectOption(recent[0].id, recent[0].name));
            //recentId
            projList = [select id, name from PF_PRoject__c where id !=: recent[0].id];
        } else {
            projectoptions.add(new SelectOption('', '--Select Project--'));
            projList = [select id, name from PF_PRoject__c];
        }
        
        for(PF_PRoject__c p : projList){
            projectoptions.add(new SelectOption(p.id,p.name));
        }
        return projectoptions;
        //return null;
    }
    
    // method to retrieve Project and Applicable sprints
    public void retrieveProjSprint(){
        List<RecentlyViewed> recent = [SELECT Id, Name FROM RecentlyViewed 
                                       WHERE Type IN ('PF_Project__c')
                                       ORDER BY LastViewedDate DESC ];
        String recentId;
        List <PF_Project__c> projList;
        List<SelectOption> projectoptions = new List<SelectOption>();
        if(recent.size()>0){
            projectoptions.add(new SelectOption(recent[0].id, recent[0].name));
            projList = [select id, name from PF_PRoject__c where id !=: recent[0].id];
        } else {
            projectoptions.add(new SelectOption('', '--Select Project--'));
            projList = [select id, name from PF_PRoject__c];
        }
        
        for(PF_PRoject__c p : projList){
            projectoptions.add(new SelectOption(p.id,p.name));
        }
    }
}