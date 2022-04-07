public with sharing class NewBookingComponentController {
	public Case cse;
	public String caseId{get;set;}

	public void setCase(Case cse){
		this.cse = cse;  
		system.debug('##### cse: ' + this.cse); 
		system.debug('##### cse: ' + this.cse);  
	} 

	public NewBookingComponentController(){
		system.debug('##### cse: ' + this.cse);
		system.debug('##### caseId: ' + this.caseId); 
	}
}