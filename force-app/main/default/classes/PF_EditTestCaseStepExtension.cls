/*
Extension class for EditTestCaseStep page
*/
public with sharing class PF_EditTestCaseStepExtension {  
	//---------- For test case object ------------------------------  
	PF_TestCases__c testCaseObj;
	//---------- For Test Case Assignment object ------------------------------  
	public PF_TestCaseExecution__c testCaseAssignmentObj;
 	//---------- For all test case steps ---------------------------    
	 list<testCaseWrapper> testCaseStepList = new list<testCaseWrapper>();       
	 //---------- Store selected test cass steps -----------------------     
	 list<PF_Test_Case_Step__c> selectedTestCaseSteps = new list<PF_Test_Case_Step__c>();  
	 //---------- Store test case steps to be removed---------------------    
	 list<PF_Test_Case_Step__c> removeTestCaseStepList = new list<PF_Test_Case_Step__c>();    
	 //---------- Store test case steps that to be updated-----------------------  
	 list<PF_Test_Case_Step__c> updateTestCaseStepList = new list<PF_Test_Case_Step__c> (); 
	 list<PF_Test_Case_Step__c> tempList = new list<PF_Test_Case_Step__c>();  
	 
	 //---------- flag to indicate duplicate or zero step number found-----------------    
	 boolean flag = false ;             
	 //---------- For new test case step---------------------------------------    
	 public PF_Test_Case_Step__c newTestCaseStep{ get; set; } 
	 
	 //----------Constructor -------------------------------------------    
	 public PF_EditTestCaseStepExtension (ApexPages.StandardController controller) {    
	    //check the sObjectType and initiatlise based on the object from where the request originated
	    system.debug('SObject Name - '+controller.getRecord().getsObjectType());
	    if(controller.getRecord().getsObjectType() == PF_TestCaseExecution__c.sObjectType){
	    	testCaseAssignmentObj = (PF_TestCaseExecution__c)controller.getRecord();
	    }else{
	    	testCaseObj = (PF_TestCases__c)controller.getRecord();  	
	    }
	    newTestCaseStep = new PF_Test_Case_Step__c();    
	 }
	 
	 //---------- Test Case Step Add/Remove -------------------------------------------    
	 public list<testCaseWrapper> getTestCaseSteps()    {           
	    testCaseStepList.clear();     
	    Id testCaseObjId;
	    if(testCaseAssignmentObj != null){
	    	list<PF_TestCaseExecution__c> testCaseId = [Select PF_Test_Case__c from PF_TestCaseExecution__c where id =:testCaseAssignmentObj.Id];
	    	system.debug('Test Case Assignment query return - '+testCaseId);
	    	testCaseObjId = testCaseId[0].PF_Test_Case__c;
	    }else{
	    	testCaseObjId = testCaseObj.Id;		
	    }
	       
	    for(PF_Test_Case_Step__c a : [select Id , PF_Step_Number__c ,PF_Step_Description__c ,PF_Expected_Result__c ,PF_Test_Case__c from PF_Test_Case_Step__c where PF_Test_Case__c =:testCaseObjId order by PF_Step_Number__c])        
	        testCaseStepList.add(new testCaseWrapper(a)); 
	        
	    return testCaseStepList;    
	 }
	 
	 //---------- Get Selected Test Case Steps-------------------------    
	 public PageReference getSelected()    {        
	    selectedTestCaseSteps.clear();        
	    for(testCaseWrapper testCsWrTemp : testCaseStepList )          
	        if(testCsWrTemp.selected == true)            
	            selectedTestCaseSteps.add(testCsWrTemp.testCsWr);        
	            
	    return null;    
	 }
	 
	 //---------- Class testCaseWrapper, wraps Test Case object and boolean selected------    
	 public class testCaseWrapper    {        
	    public PF_Test_Case_Step__c testCsWr{get; set;}        
	    public boolean selected {get; set;}        
	    public testCaseWrapper(PF_Test_Case_Step__c testCaseStep)        {            
	        testCsWr = testCaseStep;            
	        selected = false;        
	    }    
	 }
	 
	 //---------- Add new Test Case Step ----------------------------------------------------         
	 public PageReference addTestCaseStep() {    
	    if(newTestCaseStep.PF_Step_Number__c==0)    {      
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Step Number should not be zero.'));      
	        return null;    
	    }    
	    else if(duplicateStepNumber_AddClick()){      
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Step Number already exists.'));      
	        return null;        
	    }        
	    else {            
	        PF_Test_Case_Step__c newTCS = new PF_Test_Case_Step__c();            
	        newTCS.PF_Step_Number__c = newTestCaseStep.PF_Step_Number__c;            
	        newTCS.PF_Step_Description__c = newTestCaseStep.PF_Step_Description__c;            
	        newTCS.PF_Expected_Result__c = newTestCaseStep.PF_Expected_Result__c;            
	        newTCS.PF_Test_Case__c= testCaseObj.Id;            
	        insert newTCS;            
	        newTestCaseStep.PF_Step_Number__c = newTestCaseStep.PF_Step_Number__c!=null?newTestCaseStep.PF_Step_Number__c+1:1;            
	        newTestCaseStep.PF_Step_Description__c = null;            
	        newTestCaseStep.PF_Expected_Result__c = null;            
	        return null;        
	    }    
	 }
	 
	 //--------------------------------- Remove Selected TestCaseStep Record ---------------------------------------  
	 public pagereference removeTestCaseStep() {   
	    //system.debug('--Remove Called.--');         
	    for(testCaseWrapper testCsWrTemp : testCaseStepList){          
	        if(testCsWrTemp.selected == true)            
	            removeTestCaseStepList.add(testCsWrTemp.testCsWr);         
	    }    
	    
	    delete  removeTestCaseStepList;    
	    removeTestCaseStepList.clear();    
	    return null;    
	 }
	 
	 //--------------------------------- Update Selected Test Case Step ---------------------------------------        
	 public PageReference updateTestCaseStep() {        
	    if(zeroStepNumber()){         
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Step Value should not be zero.'));         
	        return null;       
	    }       
	    else if (duplicateStepNumber()){         
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Step Value should not be duplicate.'));         
	        return null;       
	    }       
	    else {          
	        //system.debug('testCaseStepList-->>'+testCaseStepList);        
	        for(testCaseWrapper testCsWrTemp : testCaseStepList)            
	            if(testCsWrTemp.selected == true)          
	                updateTestCaseStepList.add(testCsWrTemp.testCsWr);          
	                
	            update updateTestCaseStepList;          
	            //system.debug('updateTestCaseStepList-->>'+updateTestCaseStepList);          
	            updateTestCaseStepList.clear();          
	            return null;       
	    }  
	 }
	 
	 //--------------------------------- Supporting Methods --------------------------------        
	 public boolean zeroStepNumber(){      
	    tempList.clear();       
	    flag = false;       
	    for(testCaseWrapper testCsWrTemp : testCaseStepList){        
	        if(testCsWrTemp.testCsWr.PF_step_Number__c == 0){          
	            flag = true;          
	            break;        
	        }      
	    }      
	    
	    return flag;    
	 }
	 
	 //------Check Duplicate Step Number-----------------------  
	 public boolean duplicateStepNumber() {    
	    tempList.clear();    
	    flag = false;    
	    for(testCaseWrapper testCsWrTemp : testCaseStepList)          
	        tempList.add(testCsWrTemp.testCsWr);             
	    
	    for(Integer i = 0 ; i< tempList.size();i++){        
	        for(Integer j = i+1 ; j< tempList.size();j++){             
	            if(tempList[i].PF_step_number__c==tempList[j].PF_step_number__c)               
	                flag = true;
	                
	            break;         
	        }      
	    }        
	    
	    return flag;   
	 }
	 
	 //----------Check Duplicate Step Number-----------------------    
	 public boolean duplicateStepNumber_AddClick(){      
	    tempList.clear();    
	    flag = false;    
	    for(testCaseWrapper testCsWrTemp : testCaseStepList)        
	        tempList.add(testCsWrTemp.testCsWr);    //system.debug('eeeeeeeeeeeeeeeeeeeee>' +tempList);    
	    
	    for(Integer i = 0 ; i< tempList.size();i++)    {        
	        //system.debug('cccccccccccccccccc>' +tempList[i].step_number__c);        
	        //system.debug('ddddddddddddddddddddddd>' +newTestCaseStep.step_number__c);        
	        if(tempList[i].PF_step_number__c==newTestCaseStep.PF_step_number__c){        
	            flag = true;        
	            break;        
	        }     
	    }    
	    
	    return flag;    
	 }
}