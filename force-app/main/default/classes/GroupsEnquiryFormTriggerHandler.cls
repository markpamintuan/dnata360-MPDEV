/**
* @author: Mark Anthony Pamintuan
* @date: 28 February 2021
* @description: Class to house all the event handler of Groups_Enquiry_Form__c trigger
* @history:                
*/
public class GroupsEnquiryFormTriggerHandler {

	//Before Insert
    public static void onBeforeInsert(List<Groups_Enquiry_Form__c> lstNewGEF){
        
        list<Groups_Enquiry_Form__c> noEmailGEFs = new list<Groups_Enquiry_Form__c>();
        
        for(Groups_Enquiry_Form__c gef : lstNewGEF){
			system.debug('***!*!*!gef.Email__c: ' + gef.Email__c);
			system.debug('***!*!*!gef.Case__c: ' + gef.Case__c);
			if(string.IsEmpty(gef.Email__c) && string.IsNotEmpty(gef.Case__c)){
				noEmailGEFs.add(gef);
			}
        }
        system.debug('***!*!*!*noEmailGEFs: ' + noEmailGEFs);
        if(noEmailGEFs.size() > 0){
            updateEmailOnForm(noEmailGEFs);
        }   
        
    }	

	//After Insert
    public static void onAfterInsert(List<Groups_Enquiry_Form__c> lstNewGEF){
        
        set<Id> setGEFIds = new set<Id>();
        
        for(Groups_Enquiry_Form__c gef : lstNewGEF){
			setGEFIds.add(gef.Id);
        }
        
        if(!setGEFIds.IsEmpty()){
            populateCaseAccountIDs(setGEFIds);
        }   
        
    }

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 28 February 2021
	 * @description: method to create Case and Account record and stamp IDs on Groups Enquiry Form record
	 * @history:                
	 */
    @future
    static void populateCaseAccountIDs(set<Id> setGEFIds){

        set<String> setEmailBrand = new set<String>();
        map<String,String> emailBrandIdMap = new map<String,String>();
        map<String,Account> gefAccountMap = new Map<String,Account>();
        list<Groups_Enquiry_Form__c> newListGEFs = new list<Groups_Enquiry_Form__c>();
        map<Id,Case> gefIdCaseMap = new map<Id,Case>();
        map<Id,map<String,Account>> gefIdAccountMap = new map<Id,map<String,Account>>();
                
        list<Groups_Enquiry_Form__c> lstGEFs = [SELECT Id, 
        												First_Name__c, 
        												Last_Name__c, 
        												Email__c, 
        												Brand__c, 
        												Domain_Name__c, 
        												Mobile__c, 
        												Customer__c, 
        												Preferred_Destination__c,
        												Preferred_Start_Date__c,
        												Number_of_Adults__c,
        												Number_of_Children__c,
        												Number_of_Nights__c,
        												Preferred_Cabin_Class__c,
        												Case__c,
        												Domain_Id__c
        											FROM Groups_Enquiry_Form__c 
        											WHERE Id IN: setGEFIds];
        											
		map<String,Groups_Utility_Mapping__mdt> brandGroupsUtilMap = getBrandGroupsUtilMap();
		system.debug('!!!!!!!brandGroupsUtilMap: ' + brandGroupsUtilMap);
		map<String,String> domainIdNameMap = getDomainIdNameMap();
		system.debug('!!!!!!!domainIdNameMap: ' + domainIdNameMap);
        for(Groups_Enquiry_Form__c groupsEnq : lstGEFs){
            setEmailBrand.add(groupsEnq.Email__c + groupsEnq.Brand__c);
        }
        system.debug('!!!!!!!setEmailBrand: ' + setEmailBrand);
        for(Account acc : [SELECT Id, EmailBrand__c FROM Account WHERE EmailBrand__c IN: setEmailBrand]){
            emailBrandIdMap.put(acc.EmailBrand__c.toLowerCase(), acc.Id);
        }
        system.debug('!!!!!!!emailBrandIdMap: ' + emailBrandIdMap);
        for(Groups_Enquiry_Form__c groupsEnquiry : lstGEFs){
        	Case cse = new Case();
        	if(string.IsEmpty(groupsEnquiry.Case__c)){
        		system.debug('\n\n\n *************** NO CASE *************** \n\n\n');
	        	if(brandGroupsUtilMap.containsKey(groupsEnquiry.Brand__c)){
	        		String caseRT = brandGroupsUtilMap.get(groupsEnquiry.Brand__c).Groups_Case_Record_Type__c;
	        		cse.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseRT).getRecordTypeId();//'0121w000000DER2AAO';
	        		cse.OwnerId = brandGroupsUtilMap.get(groupsEnquiry.Brand__c).Groups_Queue_ID__c;
	        	}
				cse.Org_Destinations__c = groupsEnquiry.Preferred_Destination__c;
				//cse.Org_No_of_Adults_Travelling__c = groupsEnquiry.Number_of_Adults__c;
				//cse.Org_No_of_Children_Travelling__c = groupsEnquiry.Number_of_Children__c;
				//cse.Org_Number_of_Nights__c = groupsEnquiry.Number_of_Nights__c;
				
	            if(emailBrandIdMap.containsKey(groupsEnquiry.Email__c + groupsEnquiry.Brand__c)){
	            	Id accountId = emailBrandIdMap.get(groupsEnquiry.Email__c + groupsEnquiry.Brand__c);
	                groupsEnquiry.Customer__c = accountId;
	                cse.AccountId = accountId;
	            } else {
	                Person_Account_Record_Types__c par = Person_Account_Record_Types__c.getValues(groupsEnquiry.Brand__c);
	                system.debug('####!#!#!#par: ' + par);
	                Account newCustomer = new Account();
	                newCustomer.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(par.Record_Type_Name__c).getRecordTypeId();
	                newCustomer.PersonEmail = groupsEnquiry.Email__c;
	                newCustomer.Org_Brand__c = groupsEnquiry.Brand__c;
	                newCustomer.FirstName = groupsEnquiry.First_Name__c;
	                newCustomer.LastName = groupsEnquiry.Last_Name__c;
	                newCustomer.PersonMobilePhone = groupsEnquiry.Mobile__c;
	                system.debug('!!!!groupsEnquiry.Domain_Id__c: ' + groupsEnquiry.Domain_Id__c);
	                if(string.IsNotEmpty(groupsEnquiry.Domain_Id__c) && domainIdNameMap.containsKey(groupsEnquiry.Brand__c + groupsEnquiry.Domain_Id__c)){
	                	system.debug('\n\n\n *************** CUSTOMER DOMAIN WILL BE POPULATED *************** \n\n\n');
	                	newCustomer.Domain_Id__c = groupsEnquiry.Domain_Id__c;
	                	newCustomer.Customer_Domain__c = domainIdNameMap.get(groupsEnquiry.Brand__c + groupsEnquiry.Domain_Id__c);
	                }
	                system.debug('!!!!newCustomer: ' + newCustomer);
	                gefAccountMap.put(groupsEnquiry.Email__c + groupsEnquiry.Brand__c,newCustomer);
	                gefIdAccountMap.put(groupsEnquiry.Id,gefAccountMap);
	            }
	            
        	} else {
        		system.debug('\n\n\n *************** WITH CASE REASSIGN OWNER *************** \n\n\n');
        		cse.Id = groupsEnquiry.Case__c;
	        	if(brandGroupsUtilMap.containsKey(groupsEnquiry.Brand__c)){
	        		cse.OwnerId = brandGroupsUtilMap.get(groupsEnquiry.Brand__c).Groups_Queue_ID__c;
	        	}
        	}
			cse.Org_Case_Status__c = 'Requirements Complete';
        	system.debug('!!!!relatedCase: ' + cse);
        	gefIdCaseMap.put(groupsEnquiry.Id,cse);
        }       
        system.debug('!!!!!!!gefAccountMap: ' + gefAccountMap);
        
        //insert related Accounts
        if(!gefAccountMap.isEmpty()) {
            insert gefAccountMap.values();
        }

        for(Groups_Enquiry_Form__c grpEnq : lstGEFs){
			if(gefIdCaseMap.containsKey(grpEnq.Id)){
				if(gefIdCaseMap.get(grpEnq.Id).AccountId == null && gefAccountMap.containsKey(grpEnq.Email__c + grpEnq.Brand__c)){
					gefIdCaseMap.get(grpEnq.Id).AccountId = gefAccountMap.get(grpEnq.Email__c + grpEnq.Brand__c).Id;
				}
			}
        }
		
		//insert related Cases
        if(!gefIdCaseMap.isEmpty()) {
            upsert gefIdCaseMap.values();
        }
        
        for(Groups_Enquiry_Form__c gEnq : lstGEFs){
        	if(String.IsEmpty(gEnq.Customer__c) || String.IsEmpty(gEnq.Case__c)){
	            if(String.IsEmpty(gEnq.Customer__c) && gefAccountMap.containsKey(gEnq.Email__c + gEnq.Brand__c)){
	                gEnq.Customer__c = gefAccountMap.get(gEnq.Email__c + gEnq.Brand__c).Id;
	            }
	           
	            if(String.IsEmpty(gEnq.Case__c) && gefIdCaseMap.containsKey(gEnq.Id)){
	                gEnq.Case__c = gefIdCaseMap.get(gEnq.Id).Id;
	            }
	            
	            system.debug('!!!!!!!gEnq.Customer__c: ' + gEnq.Customer__c);
	            newListGEFs.add(gEnq);
        	}
        }
        system.debug('!!!!!!!newListGEFs: ' + newListGEFs);
        
        if(newListGEFs.size() > 0){
            update newListGEFs;
        }   
        
    }

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 20 July 2021
	 * @description: method to make sure that Email field is always stamped or in sync with related case
	 * @history:                
	 */
    static void updateEmailOnForm(list<Groups_Enquiry_Form__c> lstGEFs){

		set<Id> caseIds = new set<Id>();
		map<Id,String> caseEmailMap = new map<Id,String>();
		for(Groups_Enquiry_Form__c geForm : lstGEFs){
			if(string.IsNotEmpty(geForm.Case__c)){
				caseIds.add(geForm.Case__c);
			}
		}

        if(!caseIds.IsEmpty()){
            for(Case cse : [SELECT Id, SuppliedEmail FROM Case WHERE Id IN: caseIds]){
				caseEmailMap.put(cse.Id,cse.SuppliedEmail);
			}
        }   
		system.debug('***!*!*caseEmailMap: ' + caseEmailMap);
		for(Groups_Enquiry_Form__c geForm : lstGEFs){
			if(caseEmailMap.containsKey(geForm.Case__c)){
				geForm.Email__c = caseEmailMap.get(geForm.Case__c);
				system.debug('***!*!*geForm.Email__c: ' + geForm.Email__c);
			}
		}		

	}

	static map<String,Groups_Utility_Mapping__mdt> getBrandGroupsUtilMap(){
		
		map<String,Groups_Utility_Mapping__mdt> mapBrandGroupsUtil = new map<String,Groups_Utility_Mapping__mdt>();
		
		for(Groups_Utility_Mapping__mdt groupUtil : [SELECT MasterLabel, Groups_Case_Record_Type__c, Groups_Queue_ID__c FROM Groups_Utility_Mapping__mdt]){
			mapBrandGroupsUtil.put(groupUtil.MasterLabel,groupUtil);
		}
		
		return mapBrandGroupsUtil;
		
	}

	static map<String,String> getDomainIdNameMap(){
		
		Map<String,String> fieldmap = new Map<String,String>();
		
		for(Derwent_Lookup__mdt lookup : [SELECT Id, Code__c, Value__c, Field__c, Tenant__c from Derwent_Lookup__mdt WHERE Field__c = 'Customer_Domain__c']) {
			fieldmap.put(lookup.Tenant__c + lookup.Code__c, lookup.Value__c);
		}
		
		return fieldmap;
	}

}