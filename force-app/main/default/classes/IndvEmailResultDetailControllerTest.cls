@isTest
global class IndvEmailResultDetailControllerTest 
{
    
            @testSetup static void dataSetup() 
            {
            
        
                Account a = new Account(name='test acc',phone='9494146144');
                insert a;
                Contact con = new Contact(accountid=a.id,lastname='test con',email='lnarasimha823@gmail.com');
                insert con;
                
                et4ae5__Automated_Send__c autSend = new et4ae5__Automated_Send__c();
                insert autSend ;
                
                et4ae5__IndividualEmailResult__c indv = new et4ae5__IndividualEmailResult__c();
                indv.IsError__c = false ;
                indv.et4ae5__MergeId__c= 'Test';
                indv.et4ae5__Contact__c = con.Id;
                indv.et4ae5__TriggeredSendDefinition__c= autSend.Id;
                insert indv;
                
                et4ae5__IndividualLink__c indvLnk = new et4ae5__IndividualLink__c();
                indvLnk.et4ae5__Unique_Link_ID__c = 'Test';
                indvLnk.et4ae5__Individual_Email_Result__c = indv.Id;
                insert indvLnk;
                
               
                
        
            }
            
            @future(callout=true)
            public static void insertBigObject(String mergId,Id conId,Id sendDefId)
            {
                Email_Result_Archive__b indv = new Email_Result_Archive__b();
                indv.MergeId__c= mergId;
                indv.Contact__c = conId;
                indv.TriggeredSendDefinition__c= sendDefId;
                Database.SaveResult sr = database.insertimmediate(indv);
                   
                    if (sr.isSuccess()) 
                    {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                               
                
            }
    
    
    
    static testMethod void testMethod1() 
    {
        
            
       
        Test.startTest();
         
            
            Id conId = [select id from contact limit 1][0].Id;
            Id sendId = [select id from et4ae5__Automated_Send__c limit 1][0].Id;
            //insertBigObject('Test',conId,sendId);  
            
            system.debug('######## Test query '+[select id from Email_Result_Archive__b limit 2]); 
            IndvEmailResultDetailController.RequestWrap reqWrap = 
                                                      new  IndvEmailResultDetailController.RequestWrap();
                                                      
            reqWrap.MergeID = 'Test' ;
            reqWrap.RelObjID = conId;
            reqWrap.RelSendID = sendId;
            
            IndvEmailResultDetailController.fetchEmailResultArchive(JSON.serialize(reqWrap));   
                   
            
            
       Test.stopTest();
    }
}