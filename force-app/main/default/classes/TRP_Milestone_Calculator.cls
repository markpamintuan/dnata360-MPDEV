/**************************************************************************************************
* Name               : TRP_Milestone_Calculator
* Description        : This is the apex class for calculating Milestone for TRP 
* Created Date       : 27-Jul-2019
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS           
* v1.0        Sri Bala      25-Jul-2019    Initial Draft
**************************************************************************************************/
global class TRP_Milestone_Calculator implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        try{
            system.debug('milestoneTypeId'+milestoneTypeId);
            MilestoneType caseResMilestoneId = [Select Id,Name from MilestoneType  where Name = 'Resolution'];
            MilestoneType firstResMilestoneId = [Select Id,Name from MilestoneType  where Name = 'Email Response'];

            Integer duration;
            
            List<Issues__c> issuesList = [Select Org_Case__c,Issue_Type__c,Issue__c,Status__c from Issues__c where Org_Case__c=:caseId and Status__c != 'Resolved'];
            system.debug('IssuesList'+issuesList);
            
            Case c = [SELECT Priority,Org_Current_Team_Name__c,Org_Email_From_Customer__c,Customer_Communication_Pending__c,Reopened__c,Org_Brand__c,Org_Business_Unit__c,Org_Customer_Journey_Point__c,Record_Type_Name__c,First_Manual_Email_Response__c,Origin FROM Case WHERE Id=:caseId];
            
            if(c.Record_Type_Name__c == 'Travel Republic - Complaint' && c.Org_Brand__c == 'trp'){
                system.debug('Reopened>>>>'+c.Reopened__c);
                system.debug('Org_Customer_Journey_Point__c>>>>'+c.Org_Customer_Journey_Point__c);
                
                
                if(c.Reopened__c && milestoneTypeId == CaseResMilestoneId.Id){
                   
                    return 60*24*14;
                }  
                  
                if(c.Org_Customer_Journey_Point__c == 'In Resort'){
                    system.debug('#### entering In Resort');
                    if(milestoneTypeId == caseResMilestoneId.Id) return 2880;
                    if(milestoneTypeId == firstResMilestoneId.Id && c.origin != 'Email'){ 
                       return 60;
                       }
                    else{
                       return 60;//return DateTimeCalculator.calculateStandardMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addDays(2).format('yyyy-MM-dd hh:mm:ss')); //return 60*17; //18 business hours (2 business days)
                    }
                   
                     
                }
                
                System.debug('Reached not in resort check' + c.Org_Customer_Journey_Point__c);
                System.debug('Reached not in resort check' + milestoneTypeId);
                System.debug('Reached not in resort check' + c.Origin);
                System.debug('Reached not in resort check' + c.Org_Customer_Journey_Point__c);
                System.debug('Reached not in resort check');
                if(c.Org_Customer_Journey_Point__c != 'In Resort'){
                    if(milestoneTypeId == firstResMilestoneId.Id) {
                        if( c.Origin == 'Email'){
                            if(c.Org_Customer_Journey_Point__c == 'Pre Travel / Post Booking'){
                                return 60;//return 2880;
                            }else{
                                return 1080;//return DateTimeCalculator.calculateBusinessMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addHours(16).format('yyyy-MM-dd hh:mm:ss'));//60*9*19; //28 days with standard business hours //return 1080; //ER - PT
                            }
                        }else{
                            if(c.Org_Customer_Journey_Point__c == 'Pre Travel / Post Booking'){
                                System.debug('Reached Pre Travel');
                                return 60;
                            }else{
                                return 1080;//return DateTimeCalculator.calculateBusinessMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addHours(16).format('yyyy-MM-dd hh:mm:ss'));//return 2880;
                            }
                            
                        }
                    }
                    //if(milestoneTypeId == CaseResMilestoneId.Id) return 60*24; //24 business hours (3 business days)
                    
                   
                    
                    if(milestoneTypeId == caseResMilestoneId.Id){
                        Boolean hasHealthAndSafety = false;
                        if(c.Org_Customer_Journey_Point__c == 'Pre Travel / Post Booking'){
                                return 2880;
                            }else{
                            for(Issues__c issue : issuesList){
                                if(issue.Issue__c == 'Health and Safety'){
                                    hasHealthAndSafety = true;
                                }
                            }
                            if(hasHealthAndSafety){
                                
                                return DateTimeCalculator.calculateStandardMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addMonths(6).format('yyyy-MM-dd hh:mm:ss')) -1920;//return 60*9*123; //6 months 151 business days in 6 months
                            }
                            else{
                                
                                return DateTimeCalculator.calculateStandardMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addDays(28).format('yyyy-MM-dd hh:mm:ss'));//60*9*19; //28 days with standard business hours 
                            }            
                       }
                    }
                }


            }
            
            if(c.Record_Type_Name__c == 'Travel Republic - Service Request'){
                c.Next_Milestone_DateTime__c = system.now().addHours(48);
                update c;
                if(milestoneTypeId == caseResMilestoneId.Id) return 2880; //18 hours
            }
        
            //default return statement
            return DateTimeCalculator.calculateStandardMinutes( Datetime.now().format('yyyy-MM-dd hh:mm:ss'), Datetime.now().addDays(28).format('yyyy-MM-dd hh:mm:ss'));//60*9*19; //28 days with standard business hours 
            //return 240; //4 business hours 
          
            
        }catch(Exception e){
            System.debug('### Exception: ' + e);
            return 1;
        }
        
    }              
}