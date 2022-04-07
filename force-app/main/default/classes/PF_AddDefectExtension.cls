/*Purpose: Controller to create Defect from the Test Case Assignment detail page */
public class PF_AddDefectExtension {
	public ApexPages.StandardController controller;
	public PF_TestCaseExecution__c testCaseAssgnRecord {get;set;}
	public PF_Defects__c defect {get; set;}
	public Id testCaseAssgnId {get;set;}
	
	public PF_AddDefectExtension(ApexPages.StandardController controller){
		this.controller = controller;
		defect = new PF_Defects__c();
		if(!Test.isRunningTest()){
			controller.addFields(new List<String>{'PF_Test_Case__c'});
		}
		testCaseAssgnRecord = (PF_TestCaseExecution__c)controller.getRecord();
		system.debug('Test Case Assignment records' +testCaseAssgnRecord.PF_Test_Case__c);
		testCaseAssgnId = testCaseAssgnRecord.Id;
	}
	
	//called when Save button is clicked
	public PageReference saveDefect() {
		if(String.isNotBlank(testCaseAssgnRecord.PF_Test_Case__c)){
			defect.PF_Test_Case__c = testCaseAssgnRecord.PF_Test_Case__c;
		}
		system.debug('Defect - '+defect);
		insert defect; 
		
		PageReference result = new PageReference('/'+testCaseAssgnId);
		result.setRedirect(false);
		return result;
	}    
}