/**************************************************************************************************
* Name               : CaseTriggerHandler
* Description        : This is the handler class for Case trigger
* Created Date       : 08-Oct-2018
* Created By         : Keith Rogers
* -----------------------------------------------------------------------------------------------
* VERSION     AUTHOR        DATE           COMMENTS
* v1.0        Keith        08-Aug-2018    Initial version
* v1.1        Kaavya       08-Oct-2018    T-00046: Update Previous Team Name and Reassigned Date on the Case
* v1.2        Kaavya       15-Oct-2018    T-00259: Added functionality of Case Field History
* v1.3        Kaavya       04-Nov-2018    Rehlaty- Generic condition for complaints and enquiry and disable autoclose
* v1.4        Keith        04-Nov-2018    Change Reopened status to checkbox
* v1.5        Kaavya       25-Nov-2018    Conditions added for Non-selective query
* v1.6        Keith        25-Nov-2018    Prevent Milestone Creation and Updated Type field Logic
* v1.7        Maruf        05-Mar-2019    Update Current and Previous team Name logic
* v1.8        Mark         11-Mar-2019    Added before insert logic to set marhaba case to 'Spam/NA' for certain subjects
* v1.9        Maruf        10-Mar-2019    Code added to reduce SOQL query
* v1.10       Maruf        12-Mar-2019    Add error to case if no follow up task present before case status changed to Quotation Sent
* v1.11       Maruf        01-Apr-2019    Update Retail Store fields
* v1.12       Mark         19-Mar-2019    Added before insert logic to set AA Case Origin to B2C Website
* v1.13       Mark         25-Mar-2019    Added checking to exclude Cases using business Accounts(marhaba & AA) on person account creation/association
* v1.14       Kaavya       15-May-2019    Fix for hotel name SOQL
* V1.15       Keith        17-June-2019   If TR has a complaint, then the agent should be able to change the account lookup as it may be different to the supplied email
* v1.16       Sri Bala     18-June-2019   Complete Milestone for Service Request(TR)
* v1.17       Sri Bala     24-June-2019   Update the supplier id unique field on case for internal request (TR).
* v1.18       Sri Bala     24-June-2019   Update the task status to completed for PuP cases(TR)
* v1.19       Sri Bala     25-Jun-2019    Updated populateCaseStatus() to check if the TRP Service Request case is created through web integration.
* v1.20       Sri Bala     25-June-2019   Update the subject on case for TR service request where customer journey point is In Resort
* v1.21       Sri Bala     27-June-2019   Update the subject on case for TR Service Request mapping with Category.
* v1.22       Sri Bala     02-JUly-2019   To Create a chatter post on parent case when a child case is closed(TR)
* v1.23       Mark         02-Jul-2019    Added logic to populate Cluster on case based on retail store
* v1.24       Merul        28-Jul-2019    Onwer reassignment should only work for 'EKH UK Customer Service Admin' Team.
* v1.26       Sri Bala     29-Jul-2019    Populate Business Hour for In-Resort and Post Travel (TRP)
* v1.28       Keith        01-Aug-2019    For Travel Republic: if a complaint is created and in resort, then set the EmailFromCustomer flag to true for first response milestone.
* v1.30       Kaavya       01-Aug-2019    Fix for follow up task
* v1.33       Sri Bala     20-Aug-2019    Case Assignment rules for TRP
* v1.34       Mark         20-Aug-2019    Fix lock row error on marhaba cases
* v1.35       Sri bala     20-Aug-2019    Complete Email Response Milestone (TRP)
* v1.36       Sri bala     20-Aug-2019    Commenting code of v1.17,v1.18,v1.20,v1.21
* v1.37       Evendo       21-Aug-2019    Prevent Reopened flag for blanking out if reopened either via mail or manually for TRP
* v1.38       Mark         28-Aug-2019    T-00571: Added method to populate Region name based on business unit
* v1.39       Sri bala     23-Sep-2019    populate domain on account if a new account is created through email-to-case
* v1.40       Sri Bala     19-Oct-2019    entitlement process update and commented old code
* v1.41       Mark         04-Nov-2019    made marhaba and aa separate loops so that for update soql will be executed for marhaba cases only
* v1.43       Keith        27-Oct-2019    EKH Cases should only enter customer engine if the account exists or if the mailbox email is on the case
* v1.44       Keith        11-Nov-2019    If Check for EKH entitlements
* v1.45       Sri Bala     17-Nov-2019    Fix for the original team.
* v1.46       Evendo       28-Nov-2019    Added method to set booking contact on case / clearing scheduled customer message
* v1.48       Sri Bala     18-Dec-2019    Modified code for the CPU Time limit fix
* v1.49       Evendo       23-Dec-2019    Commmented the method for 1.46
* v1.50       Sri Bala     24-Dec-2019    Modified Code to reduce SOQL queries.
* v1.51       Sri Bala     26-Dec-2019    Fix for original team name
* v1.52       Sri Bala     29-Dec-2019    completing dtme After Sales Milestones
* v1.53       Sri Bala     30-Dec-2019    Reopen parent case if the related child case is reopened.
* v1.54       Sri Bala     11-Feb-2020    Business Unit Update on Case (EKH ROW Case Update PB)
* v1.55       Ravi         20-Jan-2020    Added the condition for generic queries.
* v1.56       Sri Bala     27-Jan-2020    Added condition to reduce too many soql for v1.53
* v1.57       Keith        9-Feb-2020     Adding map firstname and last name to supplied name. This is for live chat.
* v1.58       Sri Bala     10-Feb-2020    Adding the "dnata eCommerce" entitlement process.
* v1.59       Sri Bala     11-Feb-2020    Updates Total Value, Booking Ref and Sales Status when the case is closed by the B2C Sales Team
* v1.60       Keith        15-Feb-2020    Added check for the domain passed in from live chat
* v1.61       Keith        18-Feb-2020    Removed customer creation from Trigger.

* v1.63       Ravi         20-Feb-2020    Added the logic to update Orgin to Email for Email-to-Case

* v1.65       Ravi         09-Mar-2020    Implemented logic to populate Team & Queue Names
* v1.66       Keith        09-Mar-2020    Implement logic to notify Derwent if a TR complaint is raised

* v1.68       Kaavya	   17-Mar-2020	  fix for blank domain check and activating v1.54 and v1.59
* v1.69       Mark         26-Mar-2020	  fix for B2B Account cases
* v1.70       Mark         16-Jun-2020	  Added logic to exclude SF Support recordtypes
* v1.71       Mark         16-Jun-2020	  Added SF Support logic
* v1.72       Mark         09-Jul-2020	  Exclude SF Generic on Status change validation
* v1.73       Mark         16-Jul-2020    Added calling of populateContactId method for excluded record types
* v1.74       Mark         31-Aug-2020    change the logic to populate Total Value field on Case
* v1.75       Mark         15-Feb-2021    Business unit and team on manually created cases will be based on BU and Team assigned to logged in user
* v1.76       Mark         21-Mar-2021	  Added logic to stamp Queue ID when the case owner changes to a Queue
* v1.77       Mark         26-Apr-2021	  Added method on new logic to populate Retail Store on Case
* v1.78       Jed          23-May-2021	  added filter to add person accounts on AMI Chat cases for EK
* v1.79       Mark         14-Jul-2021    Added logic on populating case status for EKH Groups Enquiry cases
**************************************************************************************************/
public class CaseTriggerHandler {

	static map<String, Schema.RecordTypeInfo> mCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName();
	static Entitlement entitlement; //v1.9
	static Map<Id, List<CaseMilestone> > mapCaseToCaseMilestones = new Map<Id, List<CaseMilestone> >();
	static Set<Id> sAccountIds = new Set<Id>();
	static List<Id> caseIdsListforAssignmentRule = new List<Id>();//v1.33
	static String dateformat = 'yyyy-MM-dd HH:mm:ss:sssZ';
	static Id marhabaEmailRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Email').getRecordTypeId(); //v1.8 MPamintuan
	static Id aaB2CRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - B2C').getRecordTypeId(); //v1.8 MPamintuan
	static Id marhabaSocialRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('marhaba - Social').getRecordTypeId(); //v1.12 MPamintuan
	static Id aaStellaRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - Stella').getRecordTypeId(); //v1.13 MPamintuan
	static Id aaEKHUKRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AA - EKHUK').getRecordTypeId(); //v1.13 MPamintuan
	static Id travelRepublicComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Travel Republic - Complaint').getRecordTypeId(); //v1.15 KRogers
	static Map<String,Booking__c> RowCaseBookingMap = new Map<String,Booking__c>(); //v1.54
	static List<Case> trpCaselist = new List<Case>(); // added by sb  v1.48 for calculateCaseAssignmentRulesforTRP()
	//public static List<entitlement> entitlementList = new List<entitlement>(); // added as a part of v1.48
	public static Map<String,String> entitlementBrandMap = new Map<String,String>();
	static list<string> b2cWebsiteFromEmails = Label.AA_B2C_Website_Emails.split(','); //v1.13 MPamintuan
	static set<string> setB2CWebsiteFromEmails = new set<string>(b2cWebsiteFromEmails); //v1.13 MPamintuan
	static list<Customer_Communication__c> CConServiceRequest = new List<Customer_Communication__c>();  //list of cc to be created for service requests from myb
	static list<Customer_Communication__c> CCtoCancel = new List<Customer_Communication__c>();
	static Map<String,Booking__c> bookingList = new Map<String,Booking__c>();
	static Map<Id,String> parentCaseMap = new Map<Id,String>(); //v1.53
	static List<Booking__c> bklistToUpdate = new List<Booking__c>(); //v1.59
	public static list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
	public static map<string, Case_Email_Configuration__c> mapCaseEmailConfigs = new map<string, Case_Email_Configuration__c>();
	static List<String> rowCasebklist = new List<String>();//v1.54
	static map<String,Recordtype_Utility_Mapping__mdt> recordtypeUtilMap = new map<String,Recordtype_Utility_Mapping__mdt>(); //v1.70

	public static void onBeforeInsert(List<Case> lCases){
		BusinessUnitMappingUtility.populateBusinessQueueMap();
		emailToCaseChanges(lCases); //1.63
		populateTeamQueueNames(lCases, null);

		recordtypeUtilMap = CRK_UtilityClass.getRTUtilityMap('Case'); //v1.70

		//v1.46  v1.49
		/*List<String> BookingIdsList = new List<String>();
		   for(Case cse: lCases){
		    BookingIdsList.add(cse.Org_Booking__c);
		   }

		   for(Booking__c book : [select org_account_name__c,org_account_name__r.name from booking__c where id In :BookingIdsList]){
		    bookingList.put(book.id,book);
		   }*/

		list<Case> ekhCases = new list<Case>(); //v1.38

		//v1.13 MPamintuan
		list<Case> nonBusinessAccountCases = new list<Case>();
		list<Case> marhabaAACases = new list<Case>();
		list<Case> businessAccountCases = new list<Case>();//v1.69
		list<Case> lstCaseToAssign = new list<Case>(); //v1.75
		list<Case> casesToPopulateStore = new list<Case>(); //v1.77

		for(Case c : lCases) {
			if(!recordtypeUtilMap.containsKey(c.RecordtypeId)){ //v1.70
				//v1.69
				if(mapCaseEmailConfigs.containsKey(c.Org_Mailbox_Email__c)){
					Case_Email_Configuration__c cec = mapCaseEmailConfigs.get(c.Org_Mailbox_Email__c);
					if(cec.Account_Type__c == 'B2B'){
						businessAccountCases.add(c);					
					} else {	
						nonBusinessAccountCases.add(c);
					}
				} else {
	            //if(c.RecordtypeId != aaStellaRecTypeID && c.RecordtypeId != aaEKHUKRecTypeID) { //v1.69 remove checking for aa record types for they will fall under b2b
	                if(c.Org_Brand__c == 'ekh' && c.Case_Domain__c != null) { //v1.43
	                    nonBusinessAccountCases.add(c); //v1.43 (This existed, just wrapped an if statement)
	                } //v1.43
                   	
	                if(c.Org_Brand__c != 'ekh') { //v1.43
	                    nonBusinessAccountCases.add(c); //v1.43
	                } //v1.43
	            //}			
				} 
	
				//v1.34
				if(c.RecordtypeId == marhabaEmailRecTypeID || c.RecordtypeId == aaB2CRecTypeID) {
					marhabaAACases.add(c);
				}
	
				//v1.38
				if(c.Org_Brand__c == 'ekh') {
					ekhCases.add(c);
				}
				
                //v1.77
                if(string.valueof(c.OwnerId).startsWith('005')){
                    casesToPopulateStore.add(c);
                }
                
			}

		}//End - v1.13 MPamintuan

		getBookingsforCases(rowCasebklist);//v1.54		

		//v1.13 MPamintuan
		system.debug(nonBusinessAccountCases);
		if(nonBusinessAccountCases.size() > 0) {
			getExistingAccounts(nonBusinessAccountCases);
		}//End - v1.13 MPamintuan

        //v1.69 MPamintuan
        if(businessAccountCases.size() > 0) {
            getExistingAccounts(businessAccountCases);
        }

        //v1.77
        //updateRetailUserField(lCases,null,True); //v1.11
        if(casesToPopulateStore.size() > 0){
            stampRetailStore(casesToPopulateStore);
        }
        //End v1.77
        		
		populateEntitlementMap(); //v1.48
		for(Case cse: lCases) {
			if(!recordtypeUtilMap.containsKey(cse.RecordtypeId)){ //v1.70
				if(cse.RecordTypeId == travelRepublicComplaintRecordType && cse.Origin == 'Email') {
					cse.Org_Customer_Journey_Point__c = 'Post Travel / Holiday';
				}
	
				if(cse.OwnerId != null && string.valueof(cse.OwnerId).startsWith('00G') && cse.Sys_Case_Queue__c!=null)
					cse.Queue_Name__c = cse.Sys_Case_Queue__c;
	
				/*if(cse.Org_Brand__c == 'trp'){
				    populateSupplierId(cse,null); // v1.17
				    //handleTRServiceRequest(cse,null); //v1.21
				   }*///Commented as a part of v1.36
				//setBookingContactOnCase(cse);//v1.46
				//populateCustomerJourneyPoint(cse, null); //v1.27
				populateEmailFlagForTravelRepublic(cse, null); //v1.28
				populateContactId(cse,null);
				//populateCurrentTeamName(cse,null); //commented out as part v1.75
				populatedBusinessHours(cse,null);
				populateEntitlementId(cse,null);
				populateCaseStatus(cse, null);
	
				//closeCaseFromSpamEmail(cse); //v1.8 - MPamintuan //v1.34
				setAACaseOrigin(cse); //v1.12 - MPamintuan
				
				//v1.75
                //rowCaseUpdate(null,cse);//v1.54
                if(string.valueof(cse.OwnerId).startsWith('005') && cse.Case_Owner_FirstName__c != Label.IntegrationUserName){
                    lstCaseToAssign.add(cse);
                }
                //End v1.75
                
				updateSalesClosureFieldsOnCase(cse,null); //v1.59
			} else {
				populateContactId(cse,null); //v1.73
			}
		}
		//populateCaseSubjectforTR(lCases);//v1.20 - Sri Bala

		//v1.34
		if(marhabaAACases.size() > 0) {
			closeCaseFromSpamEmail(marhabaAACases);
		}

		//Start - v1.38
		if(ekhCases.size() > 0) {
			setRegionName(ekhCases);
		}
		//End

        //v1.75
        if(lstCaseToAssign.size() > 0){
            rowCaseUpdate(lstCaseToAssign);
        }

	}

	public static void onAfterInsert(List<Case> lCases){
		List<String> caseids  = new List<String>();
		List<Customer_Communication__c> listcc = new List<Customer_Communication__c>();
		Boolean invokemethod = false; //v1.50
		
		recordtypeUtilMap = CRK_UtilityClass.getRTUtilityMap('Case'); //v1.70
		set<Id> sfSupportCaseIds = new set<Id>(); //v1.71
		
		for(Case c : lCases) {
			if(c.Org_Brand__c == 'trp') { // Added by Evendo as a part of v1.48
				caseids.add(c.id);
			}
		}
		if(caseids.size() > 0) { // Added by Evendo as a part of v1.48
			listcc = [Select id,Status__c from Customer_Communication__c where Service_request__c in :caseids];
		}

		for(Case cse: lCases) {
			if(!recordtypeUtilMap.containsKey(cse.RecordtypeId)){ //v1.70
				populateAccountSetId(cse, null);
				populateCaseListforAssignmentRules(cse);//added as a part of v1.33
				if(cse.Derwent_CSR_Id__c != null && cse.Record_Type_Name__c == 'Travel Republic - Service Request') {//v1.61 v1.67
					CreateCustomerCommunicationForServiceRequest(cse); //v1.61 v1.67
				}
				if(cse.Org_Brand__c == 'trp' && cse.Status == 'Closed'  && cse.Record_Type_Name__c == 'Travel Republic - Service Request') {
					if(listcc.size() > 0) {
						cancelScheduledCCs(cse,listcc);//v1.46
					}
				}
	
				//added as a part of v1.50
				if(cse.Org_Type__c == 'Complaint')
					invokemethod = true;
				//end
			} else {
				//v1.71
				Recordtype_Utility_Mapping__mdt rtUtil = recordtypeUtilMap.get(cse.RecordtypeId);
				if(rtUtil.Recordtype_Name__c == 'SF Change Request' || rtUtil.Recordtype_Name__c == 'SF Generic' || rtUtil.Recordtype_Name__c == 'SF Incidents'){
					sfSupportCaseIds.add(cse.Id);
				}
			}
		}
		//Added as a part of v1.48
		if(CConServiceRequest.size() > 0) {
			insert CConServiceRequest;
		}

		if(CCtoCancel.size() > 0) {
			update CCtoCancel;
		}
		//end of v1.48
		if(invokemethod) //v1.50
			updateComplaintsOnAccount();

		/* Case SLA */
		CaseSLAHelper.CreateSLAOnInsert(lCases); //Added as part of V1.2
		calculateCaseAssignmentRulesforTRP(); //SB v1.33

		//v1.71
        if(!sfSupportCaseIds.isEmpty()){
            populateMilestoneTargetDate(sfSupportCaseIds);
        }   
		
	}

	public static void onBeforeUpdate(  List<Case> oldCasesList,
	                                    List<Case> newList,
	                                    Map<Id,Case> oldCaseMap,
	                                    Map<Id,Case> newMap){

		List<Case> newCaseList = new List<Case>();
		Map<Id,Case> newCaseMap = new Map<Id,Case>();

		for(Case c : newList){
			Case oldCase = oldCaseMap.get(c.Id);  
			if(c.OwnerId == Label.Integration_User_Id){                                                
				c.OwnerId = oldCase.OwnerId; 
			}
			newCaseList.add(c);
			newCaseMap.put(c.Id,c);
		}
											
		CaseTriggerHandler.populateHotelName(newCaseList);
		
		/**********     Added By Paramasivan ******************/
		system.debug('### Entering OnBefore Update with oldCasesList: ' + oldCasesList);
		system.debug('### Entering OnBefore Update with newCaseList: ' + newCaseList);

		//v1.46  v1.49
		/*List<String> BookingIdsList = new List<String>();
		   for(Case cse: newCaseList){
		    BookingIdsList.add(cse.Org_Booking__c);
		   }

		   for(Booking__c book : [select org_account_name__c,org_account_name__r.name from booking__c where id In :BookingIdsList]){
		    bookingList.put(book.id,book);
		   }*/

		/*** v1.53  **/
		List<String> parentCaseIds = new List<String>();
		list<Case> casesToPopulateStore = new list<Case>(); //v1.77
		
		recordtypeUtilMap = CRK_UtilityClass.getRTUtilityMap('Case'); //v1.70		
		
		for(Case cse : newCaseList) {

			if(cse.SuppliedName == null && cse.First_Name__c!= null && cse.Last_Name__c!=null) { //v1.57
				cse.SuppliedName = cse.First_Name__c + ' ' + cse.Last_Name__c;//v1.57
			} //v1.57

			if(cse.ParentId!= null && cse.Org_Brand__c == 'EKH' && !cse.Current_User_Profile_Name__c.contains('System Administrator')){ // Added "&& !cse.Current_User_Profile_Name__c.contains('System Administrator')" as a part of v1.56
				parentCaseIds.add(cse.ParentId);
			}
			
            //v1.77
            if(cse.OwnerId != oldCaseMap.get(cse.Id).OwnerId && string.valueof(cse.OwnerId).startsWith('005')){
                casesToPopulateStore.add(cse);
            }
            
		}
		
		if(parentCaseIds.size() > 0) {
			for(Case parentCase : [Select Id,Org_case_status__c from Case where Id IN: parentCaseIds]) {
				parentCaseMap.put(parentCase.Id,parentCase.Org_Case_Status__c);
			}
		}
		//end

		map<id,id> bookMap = new map<id,id>();
		set<string> receiptString = new set<string>();
		List<booking__c> bookList = new List<booking__c>();
		/**********        Added By Paramasivan ******************/
		List<CaseMilestone> lCaseMilestonesToClose = new List<CaseMilestone>();
		List<EmailMessage> lEmailsMessagesToUpdate = new List<EmailMessage>();

		//v1.12 MPamintuan
		list<Case> nonBusinessAccountCases = new list<Case>();

		list<Case> ekhCases = new list<Case>();//v1.38
		list<Case> businessAccountCases = new list<Case>();//v1.69
		getCaseConfigs();//v1.69


		for(Case cse: newCaseList) {
			system.debug('### adding Case cse: ' + cse);
			if(cse.Org_Booking__c != null) //v1.54
				rowCasebklist.add(cse.Org_Booking__c); //v1.54

			//v1.53
			if(cse.Org_Case_Status__c == 'Closed' && oldCaseMap.get(cse.Id).Reopened__c != newCaseMap.get(cse.Id).Reopened__c && cse.Org_Brand__c == 'EKH') {
				cse.Reopened__c = false;
			}
			//v1.53
			// Added By Paramasivan for updating the case id on  booking
			if(newCaseMap.get(cse.id).Org_Booking__c != null && oldCaseMap.get(cse.id).Org_Booking__c != newCaseMap.get(cse.id).Org_Booking__c && newCaseMap.get(cse.id).Org_Type__c =='Booking Enquiry') {
				bookMap.put(newCaseMap.get(cse.id).Org_Booking__c,cse.id);
			}
			mapOwnerAndRecordType(cse, oldCaseMap.get(cse.Id));


			//v1.15 Krogers added if statment to check if the agent is trying to change the accountId or lookup
			if((newCaseMap.get(cse.id).ContactId != oldCaseMap.get(cse.id).ContactId ||newCaseMap.get(cse.id).AccountId != oldCaseMap.get(cse.id).AccountId) &&
			   cse.RecordtypeId == travelRepublicComplaintRecordType) {
				//Dont add to the list to put through the customer engine
			}else{
				//v1.69
				if(mapCaseEmailConfigs.containsKey(cse.Org_Mailbox_Email__c)){
					Case_Email_Configuration__c cec = mapCaseEmailConfigs.get(cse.Org_Mailbox_Email__c);
					if(cec.Account_Type__c == 'B2B'){
						businessAccountCases.add(cse);					
					} else {	
						nonBusinessAccountCases.add(cse);
					}
				} else {
					if(!recordtypeUtilMap.containsKey(cse.RecordtypeId)){
		            	//if(c.RecordtypeId != aaStellaRecTypeID && c.RecordtypeId != aaEKHUKRecTypeID) { //v1.69 remove checking for aa record types for they will fall under b2b
		                if(cse.Org_Brand__c == 'ekh' && cse.Case_Domain__c != null) { //v1.43
		                    nonBusinessAccountCases.add(cse); //v1.43
		                } //v1.43
						
						if(cse.Org_Brand__c == 'ekh' && cse.Origin == 'AMI Chat') { //added 23-05-2021 jed
	                    	nonBusinessAccountCases.add(cse); 
	                	}
                    
						
		                if(cse.Org_Brand__c != 'ekh') { //v1.43
		                    nonBusinessAccountCases.add(cse); //v1.43
		                } //v1.43
		            	//}	
					}		
				}
			}
			system.debug('### nonBusinessAccountCases: ' + nonBusinessAccountCases);

			//Start - v1.38
			Case oldCase = oldCaseMap.get(cse.Id);

			if(cse.Org_Brand__c == 'ekh' && (string.IsEmpty(cse.Region_dropdown__c) || oldCase.Org_Business_Unit_dropdown__c != cse.Org_Business_Unit_dropdown__c)) {
				ekhCases.add(cse);
			}
			//End

		}
		system.debug('### outside the for Loop with newCaseList: ' + newCaseList);
		system.debug('### outside the for Loop with nonBusinessAccountCases: ' + nonBusinessAccountCases);


		if(bookMap.size() > 0) {
			// v1.50 bookList = [select id,Booking_Status__c from booking__c where id in:bookMap.keyset() and Booking_Status__c = 'Receipted'];
		}
		/* if(bookList.size() > 0){
		   for(booking__c bk:bookList){

		   receiptString.add(bk.id);

		   }
		   }* v1.50 */

		populateEntitlementMap(); //v1.50
		getBookingsforCases(rowCasebklist);//v1.54
		BusinessUnitMappingUtility.populateBusinessQueueMap();
		createMapCaseToCaseMilestones(newCaseList, oldCasesList, lCaseMilestonesToClose);
		reopenParentCase(newCaseList,oldCaseMap); //v1.53

		List<Case> newCaseListforTask = new List<Case>();  //v1.50

		system.debug('### Before nonBusinessAccountCases check: ' + nonBusinessAccountCases);
		//v1.13 MPamintuan
		if(nonBusinessAccountCases.size() > 0) {
			system.debug('### Entering nonBusinessAccountCases: ' + nonBusinessAccountCases);

			getExistingAccounts(nonBusinessAccountCases);
		}//End - v1.13 MPamintuan

        //v1.69 MPamintuan
        if(businessAccountCases.size() > 0) {
            getExistingAccounts(businessAccountCases);
        }

		populateTeamQueueNames(newCaseList, oldCaseMap);
		for(Case cse: newCaseList) {
			//Added as part of V1.2
			if(cse.OwnerId!=oldCaseMap.get(cse.Id).OwnerId && string.valueof(cse.OwnerId).startsWith('00G') && cse.Sys_Case_Queue__c!=null)
				cse.Queue_Name__c = cse.Sys_Case_Queue__c;

			//added as a part of v1.50
			string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId();
			string oldStatus = oldCaseMap.get(cse.Id).Status;
			if(cse.Current_User_Profile_Name__c.contains('Retail') && cse.RecordTypeId == caseRecordTypeId && oldStatus != 'Quotation Sent' &&  cse.Status == 'Quotation Sent') {
				newCaseListforTask.add(cse);
			}
			//end of v1.50

			// Added By Paramasivan for updating the case id on  booking
			if(oldCaseMap.get(cse.id).Org_Booking__c != newCaseMap.get(cse.id).Org_Booking__c && newCaseMap.get(cse.id).Org_Booking__c != null &&
			   newCaseMap.get(cse.id).Org_Type__c =='Booking Enquiry') { //added as part of v1.3
				//commented as part of v1.3
				/*
				   (newCaseMap.get(cse.id).recordtypeid == Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId()
				 || newCaseMap.get(cse.id).recordtypeid == Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKUK - New Enquiry').getRecordTypeId())){
				 */
				/* if(cse.Auto_close__c) { //condition added as part of v1.3
				      if(receiptString.contains(cse.Org_Booking__c)){
				      cse.Org_Case_Status__c = 'Closed';
				      cse.Reason = 'Closed Confirmed';
				      }
				   }  *///* v1.50 Created a workflow rule instead
			}
			//setBookingContactOnCase(cse);//v1.46
			if(cse.Org_Brand__c == 'EKH' && cse.ParentId != null && !cse.Current_User_Profile_Name__c.contains('System Administrator')) // v1.53
				preventChangingStatusOnChildCaseEKH(cse, oldcaseMap.get(cse.id)); //v1.53
			
			if(!recordtypeUtilMap.containsKey(cse.RecordtypeId)){ //v1.70
				populatedBusinessHours(cse,null); //1.26
				populateEmailFlagForTravelRepublic(cse, oldCaseMap.get(cse.Id)); //v1.28
				preventChangingStandardStatus(cse, oldCaseMap.get(cse.Id));
				populateCaseStatus(cse, oldCaseMap.get(cse.Id));
				//populateCurrentTeamName(cse,oldCaseMap.get(cse.Id)); //commented out as part v1.75
				createListOfEmailsMessages(cse, oldCaseMap.get(cse.Id), lEmailsMessagesToUpdate);
				//createListMilestonesToComplete(cse, oldCaseMap.get(cse.Id), lCaseMilestonesToClose); mp 7/27/2021
				//preventOwnershipChange(cse,oldCaseMap.get(cse.Id));
				updateCustomerDetails(cse, oldCaseMap.get(cse.Id));
				preventCaseReopenedBlankFromClosed(cse,oldCaseMap.get(cse.id)); //v1.37
				//rowCaseUpdate(oldCaseMap.get(cse.id),cse);//v1.54 //commented as part of v1.75

				updateSalesClosureFieldsOnCase(cse,null);     //v1.59
				updateBookings();//v1.59
			}
		}
		closeCaseMilestones(lCaseMilestonesToClose);
		updateEmailMessages(lEmailsMessagesToUpdate);


		if(bookMap.size() > 0 && system.isBatch() == false && system.isFuture() == false && system.isQueueable() == false) {
			// bookingUpdate.updateBooking(bookMap);
		}

		if(newCaseListforTask.size() > 0) //added as a part of v1.50
			addErrorOnCase(newCaseList,oldCaseMap); //Added as part of V1.2 //modified as a part of v1.50

        //v1.77
        //updateRetailUserField(newCaseList,oldCaseMap,False); //v1.11
        if(casesToPopulateStore.size() > 0){
            stampRetailStore(casesToPopulateStore);
        }
        //End v1.77  

		//Start - v1.38
		if(ekhCases.size() > 0) {
			setRegionName(ekhCases);
		}
		//End

	}

	/**v1.66
	public static void populateParentCaseType(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
		List<Id> parentIds = new List<Id>();

		for(Case cse: newCaseList) {
			if(cse.ParentId != null) {
				parentIds.add(cse.ParentId);
			}
		}

		Map<Id, Case> mParentCaseIdToValues = new Map<ID, Case>([SELECT Id,
		                                                         RecordType.Name
		                                                         FROM Case
		                                                         WHERE Id IN: parentIds]);
		for(Case cse: newCaseList) {
			if(mParentCaseIdToValues.get(cse.ParentId)!=null) {
				cse.Parent_Case_Type__c = mParentCaseIdToValues.get(cse.ParentId).RecordType.Name;
			}
		}
	}

	//v1.66
	public static void notifyComplaintRaisedDerwent( List<Case> newCaseList, Map<Id,Case> oldCaseMap){
		List<Id> lCaseIds = new List<Id>();

		for(Case cse: newCaseList) {
			if(cse.ParentId != null
			   && cse.Org_Booking__c != null
			   && cse.Parent_Case_Type__c == 'Travel Republic - Complaint') lCaseIds.add(cse.Id);
		}

		if(lCaseIds.size()>0) {
			system.enqueueJob(new AsyncDerwentWebservice (lCaseIds,'Notify_Complaint',null));
		}
	}**/

	//v1.66
	public static void allowPaymentOnBooking( List<Case> newCaseList, Map<Id,Case> oldCaseMap){
		List<Id> lCaseIds = new List<Id>();

		//could be true or false
		for(Case cse: newCaseList) {
			if(cse.ParentId != null
			   && cse.Org_Booking__c != null
			   && cse.Parent_Case_Type__c == 'Travel Republic - Complaint'
			   && cse.Allow_Payment_On_Booking__c != oldCaseMap.get(cse.Id).Allow_Payment_On_Booking__c)
				lCaseIds.add(cse.Id);
		}

		if(lCaseIds.size()>0) {
			system.enqueueJob(new AsyncDerwentWebservice (lCaseIds,'Allow_Payment',null));
		}
	}

	//v1.46  v1.49
	//Added By Evendo.
	//This is for setting the booking lead contact value on Case which is picked up from the booking upon linking the booking to the Case.
	/*public static void setBookingContactOnCase(Case newCase){

	    if(newCase.Org_Brand__c == 'trp' && newCase.Org_Booking__c != null){
	       try{
	            Booking__c bk = BookingList.get(newCase.Org_Booking__c);
	            newCase.Booking_Lead_Contact__c = bk.Org_Account_Name__r.name;
	            newCase.Booking_Lead_Contact_Id__c = bk.Org_Account_Name__c;
	            newCase.Is_Booking_Contact_same_as_Case_Contact__c = (newCase.AccountId == bk.Org_Account_Name__c);
	        }catch(Exception e){
	            System.debug(e);
	        }
	    }
	   }*/



	//Method added for changes in v1.10 ticket number T-00501
	public static void addErrorOnCase( List<Case> newCaseList, Map<Id,Case> oldCaseMap){
		List<Task> tasksList = new List<Task>();
		Map<Id,List<Task> > taskCaseMap = new Map<Id,List<Task> >();
		tasksList = [SELECT Id,WhatId,Org_Due_Date_Time__c,Status FROM Task WHERE WhatId IN :oldCaseMap.keyset() AND Org_Due_Date_Time__c > :System.now() AND Status = 'Open'];  //v1.30 Changed Due_DateTime__c to Org_Due_Date_Time__c
		for(Task taskRec:tasksList) {
			if(taskCaseMap.containsKey(taskRec.WhatId)) {
				taskCaseMap.get(taskRec.WhatId).add(taskRec);
			} else {
				List<Task> tempTaskList = new List<Task>();
				tempTaskList.add(taskRec);
				taskCaseMap.put(taskRec.WhatId,tempTaskList);
			}
		}
		for(Case caseRec:newCaseList) {
			string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId();
			string oldStatus = oldCaseMap.get(caseRec.Id).Status;
			if(caseRec.Current_User_Profile_Name__c.contains('Retail') && caseRec.RecordTypeId == caseRecordTypeId && (oldStatus != 'Quotation Sent' &&  caseRec.Status == 'Quotation Sent') ) {
				if(!taskCaseMap.containsKey(caseRec.Id) || taskCaseMap.get(caseRec.Id).size() == 0) {
					caseRec.addError('Please create a follow up task before changing the status to "Quotation Sent".');
				}
			}
		}
	}

	public static void mapOwnerAndRecordType(Case newCase, Case oldCase){
		//v1.6 Update to Org_Type__c field for tagging
		//Merul: Onwer reassignment should only work for 'EKH UK Customer Service Admin' Team
		if(newCase.Org_Type__c != oldCase.Org_Type__c &&
		   newCase.Org_Brand__c == 'EKH' &&
		   Label.EKH_Use_RecordType_Mapping == 'TRUE' &&
		   (
			   newCase.Org_Current_Team_Name__c == 'EKH UK Customer Service Admin' ||
			   newCase.Org_Mailbox__c == 'EKH UK - Customer Service Admin'
		   )

		   )
		{
			if(EKH_Type_Reassignment__c.getValues(newCase.Org_Type__c) != null) {
				try
				{
					newCase.RecordTypeId = EKH_Type_Reassignment__c.getValues(newCase.Org_Type__c).Case_RecordTypeId__c;
					newCase.OwnerId = EKH_Type_Reassignment__c.getValues(newCase.Org_Type__c).Case_Owner_Id__c;
				}
				catch (Exception e)
				{
					System.debug('### Exception mapOwnerAndRecordType:' + e);
				}
			}
		}
	}

	public static void onAfterUpdate(   List<Case> oldCasesList,
	                                    List<Case> newCaseList,
	                                    Map<Id,Case> oldCaseMap,
	                                    Map<Id,Case> newCaseMap){

		Boolean invokemethod = false;
		allowPaymentOnBooking(newCaseList, oldCaseMap); //1.66
		getCaseConfigs(); //v1.69
		list<Case> businessAccountCases = new list<Case>(); //v1.69\
		
		recordtypeUtilMap = CRK_UtilityClass.getRTUtilityMap('Case'); //v1.70
		set<Id> sfSupportCaseIds = new set<Id>(); //v1.71
		
		for(Case cse: newCaseList) {
			//v1.69
			Case oldCase = oldCaseMap.get(cse.Id);
			if(!recordtypeUtilMap.containsKey(cse.RecordtypeId)){ //v1.70
				populateAccountSetId(cse, oldCaseMap.get(cse.Id));
				if(cse.Org_Type__c == 'Complaint') //v1.50
					invokemethod = true; //v1.50

				//v1.69
				if(oldCase.AccountId == null && cse.AccountId != null){
					if(mapCaseEmailConfigs.containsKey(cse.Org_Mailbox_Email__c)){
						Case_Email_Configuration__c cec = mapCaseEmailConfigs.get(cse.Org_Mailbox_Email__c);
						if(cec.Account_Type__c == 'B2B'){
							businessAccountCases.add(cse);					
						}
					}
				}
			} else {
				//v1.71
				Recordtype_Utility_Mapping__mdt rtUtil = recordtypeUtilMap.get(cse.RecordtypeId);
				if((rtUtil.Recordtype_Name__c == 'SF Change Request' && oldCase.Status != cse.Status && cse.Status == 'In Progress') || ((rtUtil.Recordtype_Name__c == 'SF Incidents' || rtUtil.Recordtype_Name__c == 'SF Generic') && oldCase.Status != cse.Status)){
					sfSupportCaseIds.add(cse.Id);
				}
			}
				
		}
		//Added as a part of v1.18
		//Tasks to update.
		// updateTaskStatusforTR(newCaseList,oldCaseMap);
		createChatterPostOnParentCaseTR(newCaseList,oldCaseMap); //Added as a part of v1.22
		if(invokemethod)  //v1.50
			updateComplaintsOnAccount();

		/* Case SLA */
		CaseSLAHelper.CreateSLAOnUpdate(newCaseList,oldCaseMap); //Added as part of V1.2

        //v1.69
        if(businessAccountCases.size() > 0){
        	linkContactToAccount(businessAccountCases);
        }

		//v1.71
        if(!sfSupportCaseIds.isEmpty()){
            populateMilestoneTargetDate(sfSupportCaseIds);
        }  
		
	}

	public static void onAfterDelete(   List<Case> oldCasesList,
	                                    Map<Id,Case> oldCaseMap){
		for(Case cse: oldCasesList) {
			populateAccountSetId(cse, null);
		}
		updateComplaintsOnAccount();
	}

	// Code written by Mahadev
	// The below method will populate BU name on the case record
	// Email-to-case, based on the email addresses, we need to extract the mailbox name which is stored on BU object
	// fetch the BU's mailbox based on configured Email address

	public static Map<String, String> getEmailBusinessUnit(){
		Map<String, String> mapBUDetails = new Map<String, String>();

		String recTypeId = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
		for(Business_Unit__c bu : [Select Id, Name, Org_Email__c, Org_Business_Unit_Email__c,Org_Brand__c From Business_Unit__c Where RecordTypeId = :recTypeId]) {
			system.debug(bu.Id);
			mapBUDetails.put(bu.Org_Email__c, bu.Org_Brand__c);
		}

		return mapBUDetails;
	}

	private static void populateContactID(Case newCase, Case oldCase){
		//v1.13 Added checking - if business account, Person_Account_Contact_Id__c is blank
		if(string.IsNotEmpty(newCase.Person_Account_Contact_Id__c)) {
			newCase.ContactId = newCase.Person_Account_Contact_Id__c;
		}
	}
	//Added as a part of v1.20
	/* private static void populateCaseSubjectforTR(List<Case> newCase){
	     for(Case caseRec : newCase){
	         system.debug('new Case Account'+caseRec.Account.name);
	         caseRec.Org_Customer_Journey_Point__c = caseRec.Customer_Journey_Point_Formula__c;
	         if(caseRec.Org_Brand__c == 'trp' && caseRec.Record_Type_Name__c == 'Travel Republic - Complaint' && caseRec.Customer_Journey_Point_Formula__c == 'In Resort'){
	            caseRec.Subject = 'IR Complaint for' + ' ' + caseRec.Account_Name__c;
	         }
	     }
	   }*/

	//Added as a part of v1.21
	/* private static void handleTRServiceRequest(Case newCase, Case oldCase){
	      try{
	         List<Service_Request_Category_Mapping__mdt> srcmList = [select Customer_Facing_Category_Text__c,Category_Text__c from Service_Request_Category_Mapping__mdt where Category_Text__c = :newCase.Category__c and Booking_Type_Name__c = :newCase.Booking_Product_Type__c];
	          if(srcmList.size()>0){
	              for(Service_Request_Category_Mapping__mdt Src : srcmList){
	                  newCase.Subject = Src.Customer_Facing_Category_Text__c;
	              }
	          }
	     }catch(Exception e){
	         System.debug(e);
	     }
	   }*/

	// //KR It is necessary to always keep the Messaging_User__c record in sync with SourceId v1.64
	public static void populateMessagingUserLookup(List<Case> newCase, Map<Id,Case> newCaseMap){
		system.debug('EEEEntering populateMessagingUserLookup with newCase:' + newCase);
		system.debug('EEEEntering populateMessagingUserLookup with newCaseMap:' + newCaseMap);
		List<Id> lMessageSessions = new List<Id>();
		List<Case> lCases = new List<Case>();


		for(Case caseRec : newCase) {
			system.debug('EEEEntering caseRec.SourceId :' + caseRec.SourceId);
			system.debug('EEEEntering caseRec.SourceId :' + caseRec.SourceId);

			Id messageSessionId = null;
			if(caseRec.SourceId==null) continue;
			messageSessionId = caseRec.SourceId;

			if(messageSessionId !=null &&
			   messageSessionId.getSObjectType().getDescribe().getName() == 'MessagingSession' &&
			   caseRec.Messaging_User__c == NULL) {
				system.debug('inside if statement:');
				lMessageSessions.add(caseRec.SourceId);
				lCases.add(caseRec);
				system.debug('lCases:');
			}
		}

		system.debug('lMessageSessions:' + lMessageSessions);


		if(lMessageSessions.size()>0) {
			Map<ID, MessagingSession> mMessageSessionIdToMessageSession = new Map<ID, MessagingSession>([SELECT Id,
			                                                                                             MessagingEndUserId
			                                                                                             FROM MessagingSession
			                                                                                             WHERE ID IN: lMessageSessions]);
			for(Case caseRec : lCases) {
				if(mMessageSessionIdToMessageSession.get(caseRec.SourceId) == null) continue;
				caseRec.Messaging_User__c = mMessageSessionIdToMessageSession.get(caseRec.SourceId).MessagingEndUserId;
			}
		}
	}

	// Added as a part of v1.22
	@TestVisible
	private static void createChatterPostOnParentCaseTR(List<Case> newCase, Map<Id,Case> oldCaseMap){
		try{
			for(Case caseRec : newCase) {
				if(caseRec.Org_Brand__c == 'trp' && caseRec.IsParentCase__c == false
				   && caseRec.Org_Case_Status__c == 'Closed' && caseRec.Record_Type_Name__c == 'Travel Republic - Internal Request') {

					//New code update to tag case owner
					ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
					ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
					ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
					ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

					messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
					textSegmentInput.text = 'Hi ';
					messageBodyInput.messageSegments.add(textSegmentInput);
					Case parentCase = [Select OwnerId,Id from Case where Id=:caseRec.ParentId];
					system.debug('Owner Id '+parentCase.OwnerId);
					mentionSegmentInput.id = parentCase.OwnerId;
					messageBodyInput.messageSegments.add(mentionSegmentInput);
					textSegmentInput = new ConnectApi.TextSegmentInput();
					textSegmentInput.text = '\n I have closed a related request '+caseRec.caseNumber+'.\n Here are the closing comments :'+'\n \n'+caseRec.Closing_Comments__c;

					messageBodyInput.messageSegments.add(textSegmentInput);



					feedItemInput.body = messageBodyInput;
					feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
					feedItemInput.subjectId = caseRec.ParentId;

					ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
				}
			}
		}
		catch(Exception e) {
			system.debug('Exception '+e);
		}
	}
	//Added as a part of v1.18
	/*private static void updateTaskStatusforTR(List<Case> newCase, Map<Id,Case> oldCaseMap){
	    List<Task> taskList = new List<Task>();
	    for(Case caseRec : newCase){
	        // Getting the old case status;
	        string oldStatus = oldCaseMap.get(caseRec.Id).Status;
	        string taskSubject = 'Automated Reminder For Customer';
	        //checking the brand and status of case
	        if(caseRec.Org_Brand__c == 'trp' && caseRec.Record_Type_Name__c == 'Travel Republic - Service Request' && oldStatus == 'Pending Response' && caseRec.Org_Case_Status__c == 'In Progress' && caseRec.Category__c == 'Price Up (PUP)' ){
	            system.debug('Entered');
	            //query all the task with the subject as 'Automated Reminder For Customer'
	            List<Task> taskObj = [Select Id,Subject,Status from Task where whatId =: caseRec.Id and Subject =: taskSubject];
	            for(Task t : taskObj){
	                t.Status = 'Completed';
	                taskList.add(t);
	            }
	        }
	    }
	    // update the task status
	    if(taskList.size()>0)
	        update taskList;
	   }*/

	//end of v1.18
	//added as a part of v1.33

	//v1.61 v1.67 uncommented
	public static void CreateCustomerCommunicationForServiceRequest(Case cse){
		Customer_Communication__c cc = new Customer_Communication__c();
		cc.Created_By_Customer__c = true;
		cc.Message__c = cse.Description;
		cc.Service_Request__c = cse.id;
		cc.Status__c = 'Incoming';
		cc.CreatedDate = datetime.now().addSeconds(-30);

		CConServiceRequest.add(cc);

	}


	//v1.46
	public static void cancelScheduledCCs(Case cse,List<Customer_Communication__c> cclist){
		List<Customer_Communication__c> cctoupdate = new List<Customer_Communication__c>();
		for(Customer_Communication__c cc: cclist) {
			if(cc.Service_Request__c == cse.id && cc.Status__c == 'Scheduled') {
				cc.Status__c = 'Cancelled';
				cctoupdate.add(cc);
				CCtoCancel.add(cc);
			}
		}


	}
	//v1.53
	public static void reopenParentCase(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
		try{
			List<Case> parentCasetoUpdate = new List<case>();
			for(Case newCase: newCaseList) {
				if(oldCaseMap.get(newCase.Id).Reopened__c != newCase.Reopened__c && newCase.Reopened__c == true
				   && newCase.ParentId != null && newCase.Org_Brand__c == 'EKH') {
					Case parentCase = new Case();
					parentCase.Id = newCase.parentId;
					parentCase.Org_Case_Status__c = 'Reopened';
					parentCase.Reopened__c = true;
					parentCase.OwnerId = newCase.OwnerId;
					parentCasetoUpdate.add(parentCase);
				}
			}
			system.debug('parentCasetoUpdate >>>>>>. '+parentCasetoUpdate);

			if(parentCasetoUpdate.size() > 0)
				update parentCasetoUpdate;
		}
		catch(Exception ex) {
			system.debug('Exception <<<< '+ex + ' Line Number >>>>>> '+ex.getLineNumber());
		}
	}


	public static void preventChangingStatusOnChildCaseEKH(Case newCase, Case oldCase){
		if(newCase.Org_case_status__c != oldCase.Org_case_status__c && parentCaseMap.get(newCase.ParentId) == 'Closed') {
			newCase.addError('Please change the parent case status before changing the status of the child case.');
		}
	}

	// end

	private static void populateCaseListforAssignmentRules(Case cse){

		if(cse.Invoke_Assignment_Rules__c && cse.Org_Brand__c == 'trp') {
			caseIdsListforAssignmentRule.add(cse.Id);

		}


	}
	private static void calculateCaseAssignmentRulesforTRP(){
		system.debug('List of Case Ids');
		List<Case> cases = new List<Case> {};
		List<Id> caseIds = new List<Id> {};
		List<Case> caselist = new List<Case>();
		//v1.48 --> populating trpCaselist values in populateCaseListforAssignmentRules() instead of querying again.Hence commenting the below soql.
		caselist = [Select Id,Org_Brand__c,Invoke_Assignment_Rules__c from Case where Id in : caseIdsListforAssignmentRule]; //commented by sb as a part of v1.48
		AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];  // Added as a part of v1.48
		for(Case c : caselist) { // modified by sb as a part of v1.48 was -- > caselist changed to -->  trpCaselist
			//AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]; //moved query outside loop as a part of v1.48
			system.debug('Rule'+rules);
			if (rules.size() > 0) {
				Database.DMLOptions dmlOpts = new Database.DMLOptions();
				dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
				system.debug('Case '+c);
				if(c.Invoke_Assignment_Rules__c && c.Org_Brand__c == 'trp') {
					c.setOptions(dmlOpts);
					c.Invoke_Assignment_Rules__c = false;
				}
				cases.add(c);
			}


		}
		if(cases.size() > 0) // Added by SB as a part of v1.48
			Database.upsert(cases);
	}
	//end of v1.33
	// Sahil K R
	// Updates Contact Id with Person Account's Contact and chages Web Email to Contact's email
	private static void updateCustomerDetails(Case newCase, Case oldCase){
		//v1.13 Added checking - if business account, Pers`on_Account_Contact_Id__c is blank
		if(string.IsNotEmpty(newCase.Person_Account_Contact_Id__c)) {
			newCase.ContactId = newCase.Person_Account_Contact_Id__c;
		}

		if(newCase.SuppliedEmail == null) { //v1.43
			newCase.SuppliedEmail = newCase.Org_Contact_On_Email__c;
		}
		if(oldCase.AccountId != newCase.AccountId && newCase.Org_Brand__c == 'ekh') {
			newCase.SuppliedEmail = newCase.Org_Contact_On_Email__c;
			// newCase.Contact.Email = newCase.Org_Contact_On_Email__c;
		}


	}

	public static void populateAccountSetId(Case newCase, Case oldCase){
		Boolean bComplaintRecordType = false;
		system.debug('### populateAccountSetId newCase.Org_Case_Status__c: ' + newCase.Org_Case_Status__c);

		//commented as part of v1.3
		/*if(newCase.RecordTypeId == mCaseRecordType.get('dTME - Complaints').getRecordTypeId() ||
		    newCase.RecordTypeId == mCaseRecordType.get('EKUK - Complaints').getRecordTypeId()){ */
		if(newCase.Org_Type__c == 'Complaint') { //Added as part of v1.3
			bComplaintRecordType = true;
		}

		if(oldCase == null && bComplaintRecordType) sAccountIds.add(newCase.AccountId);

		if( oldCase != null && bComplaintRecordType &&
		    // newCase.Org_Case_Status__c == 'Closed' && oldCase.Org_Case_Status__c != 'Closed'
		    oldCase.Org_Case_Status__c != newCase.Org_Case_Status__c
		    ) {

			sAccountIds.add(newCase.AccountId);
		}
		system.debug('### populateAccountSetId sAccountIds: ' + sAccountIds);
	}

	public static void createListOfEmailsMessages(Case newCase, Case oldCase, List<EmailMessage> lEmailMessages){
		system.debug('### createListOfEmailsMessages newCase.Org_Case_Status__c: '+ newCase.Org_Case_Status__c);
		system.debug('### createListOfEmailsMessages oldCase.Org_Case_Status__c: '+ oldCase.Org_Case_Status__c);


		if(newCase.Org_Case_Status__c == 'Closed' &&
		   oldCase.Org_Case_Status__c != 'Closed' &&
		   newCase.Org_Email_From_Customer__c) {

			EmailMessage msg = new EmailMessage();
			msg.Id = newCase.Org_Open_Email_Message_Id__c;
			msg.SLA_Completion_Date__c = System.now();
			lEmailMessages.add(msg);
		}
	}

	public static void updateEmailMessages(List<EmailMessage> lEmailMessages){
		try{
			if(lEmailMessages.size()>0) update lEmailMessages;
		}catch(Exception e) {
			System.debug('#### updateEmailMessages exception : ' + e);
		}
	}

	public static void updateComplaintsOnAccount(){
		System.debug('### Entering countOpenComplaints with sAccountIds: ' + sAccountIds);
		List<Account> lAccountsToUpdate = new List<Account>();
		sAccountIds.remove(null); //Added as part of v1.5
		AggregateResult[] groupedResults
		    = [SELECT Count(Id), AccountId
		       FROM Case
		       WHERE AccountId IN: sAccountIds
		       AND Org_Case_Status__c != 'Closed'
		       //commented as part of v1.3
		       /*AND (RecordTypeId =: mCaseRecordType.get('dTME - Complaints').getRecordTypeId()
		          OR RecordTypeId =: mCaseRecordType.get('EKUK - Complaints').getRecordTypeId()) */
		       AND Org_Type__c = 'Complaint' //added as part of v1.3
		                         GROUP BY AccountId];

		System.debug('### updateComplaintsOnAccount 1 sAccountIds: ' + sAccountIds);

		for (AggregateResult ar : groupedResults) {
			Account acc = new Account();
			acc.Id = String.valueOf(ar.get('AccountId'));
			acc.Org_No_of_Open_Complaints__c = (Decimal)ar.get('expr0');
			lAccountsToUpdate.add(acc);
			sAccountIds.remove(acc.Id);
			System.debug('### updateComplaintsOnAccount 2 sAccountIds: ' + sAccountIds);
		}

		System.debug('### updateComplaintsOnAccount 3 sAccountIds: ' + sAccountIds);
		for(Id accId: sAccountIds) {
			Account acc = new Account();
			acc.Id = accId;
			acc.Org_No_of_Open_Complaints__c = 0.00;
			lAccountsToUpdate.add(acc);
		}
		System.debug('### updateComplaintsOnAccount 3 lAccountsToUpdate: ' + lAccountsToUpdate);



		//handle update exception here
		try{
			if(lAccountsToUpdate.size()>0) update lAccountsToUpdate;

		}catch(Exception e) {
			System.debug('#### exception e: ' + e);
		}

	}


	//Add as part of 1.28
	private static void populateEmailFlagForTravelRepublic(Case newCase, Case oldCase){
		if(oldCase == null && newCase.RecordTypeId == travelRepublicComplaintRecordType) newCase.Org_Email_From_Customer__c = true;


	}

	public static void populateCaseStatus(Case newCase, Case oldCase){
		//updated as a part of v1.19
		if(oldCase != null && string.valueOf(newCase.OwnerId).startsWith('005') &&
		   string.valueOf(oldCase.OwnerId).startsWith('00G') && newCase.Case_Owner_FirstName__c != Label.IntegrationUserName &&
		   (oldCase.Org_Case_Status__c == 'New' || oldCase.Org_Case_Status__c == 'New Enquiry') ) { //v1.79
			system.debug('case status @@@'+newCase.status);
			system.debug('Case Owner '+newCase.OwnerId);
			//v1.79 added checking if EKH Groups Enquiry
			if(newCase.Record_Type_Name__c == 'EKH Groups Enquiry'){
				newCase.Org_Case_Status__c = 'Requirements Gathering';
			} else {
				newCase.Org_Case_Status__c = 'In Progress';
			}

			if(oldCase.Org_Original_Case_Owner__c == null || oldCase.Org_Original_Case_Owner__c == '') {
				newCase.Org_Original_Case_Owner__c = newCase.Org_Owner_Name__c;
			}
		}

		if(oldCase == null) {
			newCase.Status = newCase.Org_Case_Status__c;
		}
		//updated as a part of v1.19
		if(oldCase == null && string.valueOf(newCase.OwnerId).startsWith('005') &&
		   newCase.Org_Case_Status__c != 'Closed' && newCase.Case_Owner_FirstName__c != Label.IntegrationUserName ) {
			system.debug('Case Owner '+newCase.OwnerId);
			system.debug('### Created by user ');
			//v1.79 added checking if EKH Groups Enquiry
			if(newCase.Record_Type_Name__c == 'EKH Groups Enquiry'){
				newCase.Org_Case_Status__c = 'Requirements Gathering';
			} else {
				newCase.Org_Case_Status__c = 'In Progress';
			}
			newCase.Status = newCase.Org_Case_Status__c;
			newCase.Org_Original_Case_Owner__c = newCase.Org_Owner_Name__c;

			system.debug('### newCase.Org_Case_Status__c: ' + newCase.Org_Case_Status__c);
			system.debug('### newCase.Status: ' + newCase.Status);
		}

		if(oldCase != null && newCase.Org_Case_Status__c != oldCase.Org_Case_Status__c)
			newCase.Status = newCase.Org_Case_Status__c;

		if(oldCase != null &&
		   newCase.Org_Case_Status__c != oldCase.Org_Case_Status__c &&
		   newCase.Reopened__c) { //changed as per v1.4  //newCase.Org_Case_Status__c == 'Reopened'
			newCase.Org_Reopened_Date__c = Datetime.valueOf(system.now().format(dateformat,''+userinfo.getTimeZone()));
		}




	}

	public static void preventChangingStandardStatus(Case newCase, Case oldCase){
		Id sfGenericRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Generic').getRecordTypeId(); //v1.72
		if(newCase.Status != oldCase.Status && newCase.Status != newCase.Org_Case_Status__c && newCase.RecordtypeId != sfGenericRTId) {
			newCase.addError('Cannot change standard Status field');
		}
	}

	// Code written by Mahadev
	// The below method is the most imp method as this is where we are respecting the Customer Engine logic
	// If a case came from the channels: Email/Web/AMI Chat
	// We are going to follow customer engine logic
	//
	// First check the details on the Case (Supplied Email and Brand)
	// Based on the metioned field, check if the account is already exists with these details
	// Ex: jon@doe.com dnata
	// if an Account exists with above details get the account and link it to the case
	// if not create a new account and link it to the case

	public static void getExistingAccounts(List<Case> lstCases){
		system.debug('### Entering getExistingAccounts with lstCases: ' + lstCases);
		Map<String,Case> mapContactDetails = new Map<String,Case>();
		Map<String,Case> caseWithExistingAccount = new Map<String,Case>();
		Set<String> emailIds = new Set<String>();
		Set<String> mobilenumbers = new Set<String>();
		Set<String> brandNames = new Set<String>();
		Map<String, Case> emailWithCase = new Map<String, Case>();
		Map<String, Case> CasewithoutAccount = new Map<String, Case>();

		Map<String, Account> emailWithAccount = new Map<String, Account>();
		Map<String, Account> mobileWithAccount = new Map<String, Account>();
		map<string,case> emailMobileCase = new map<string,case>();
		Map<String, Case> casesToUpdate = new Map<String, Case>();
		boolean allowNull = false;
		
        //v1.69
		list<Case> b2cCases = new list<Case>();		
		//B2B variables
		list<Case> b2bCases = new list<Case>();
		Set<String> b2bEmails = new Set<String>();
		set<String> b2bContactRecordTypeIDs = new set<String>();
		Map<String, Case> caseNoContactMap = new Map<String, Case>();		
		
		for(Case cs: lstCases) {
			if(mapCaseEmailConfigs.containsKey(cs.Org_Mailbox_Email__c)){
				Case_Email_Configuration__c cec = mapCaseEmailConfigs.get(cs.Org_Mailbox_Email__c);
				system.debug('*********Account Type: ' + cec.Account_Type__c);
				if(cec.Account_Type__c == 'B2B'){
					b2bCases.add(cs);
					if(cec.B2B_Contact_Recordtype_ID__c != '' && cs.ContactId == null){
						b2bContactRecordTypeIDs.add(cec.B2B_Contact_Recordtype_ID__c);
						caseNoContactMap.put(cs.SuppliedEmail + cec.B2B_Contact_Recordtype_ID__c, cs);					
					}					
				} else {	
					b2cCases.add(cs);
				}

			} else {
				b2cCases.add(cs);
			}	
		}
		//v1.69
		
		try {
			//Start - LOGIC FOR B2C CASES
			if(b2cCases.size() > 0){
				// Iterate over all the cases and extract SuppliedEmail, & Brand
	
				system.debug('\n\n\n ********* Entered B2C Logic ********* \n\n\n');
				for(Case cs: b2cCases) {
					system.debug('#### cs.Org_Case_Status__c: ' + cs.Org_Case_Status__c);
	
					system.debug('@@@@@@@@@@@@@@'+ cs.SuppliedName);
					if(Label.Takenull == 'True' && cs.Origin == null) {
						allowNull  = true;
					}
	
					else{
						allowNull  = false;
					}
					if(((cs.Org_Case_Status__c == 'New' || cs.Org_Case_Status__c == 'In Progress') &&
					    (cs.Origin == 'Email' || cs.Origin == 'Web' || cs.Origin == 'AMI Chat' || cs.Origin == 'Live Chat' || allowNull == true))
					   || ((cs.RecordtypeId == marhabaEmailRecTypeID || cs.RecordtypeId == marhabaSocialRecTypeID) && cs.marhaba_Customer__c && string.IsEmpty(cs.AccountId))
					   || (!setB2CWebsiteFromEmails.contains(cs.SuppliedEmail) && (cs.Origin == 'Direct email' || cs.Origin == 'B2C Website') && (cs.RecordtypeId == aaB2CRecTypeID || cs.RecordtypeId == aaStellaRecTypeID || cs.RecordtypeId == aaEKHUKRecTypeID))) { //v1.13 Added AA Case origin in condition
	
						brandNames.add(cs.Org_Brand__c);
	
						if(cs.SuppliedEmail != null) {
							emailIds.add(cs.SuppliedEmail+cs.Org_Brand__c);
							emailWithCase.put(cs.SuppliedEmail+cs.Org_Brand__c, cs);
							CasewithoutAccount.put(cs.SuppliedEmail+cs.Org_Brand__c, cs);
						}
						if(cs.SuppliedPhone != null && cs.SuppliedEmail == null) {
							mobilenumbers.add(cs.SuppliedPhone+cs.Org_Brand__c);
							emailWithCase.put(cs.SuppliedPhone+cs.Org_Brand__c, cs);
							CasewithoutAccount.put(cs.SuppliedPhone+cs.Org_Brand__c, cs);
						}
					}
				}
	
				system.debug('emailIds@@@@@@@@@@@@@@@@@'+emailIds);
				system.debug('mobilenumbers@@@@@@@@@@@@'+mobilenumbers);
	
	
				// I could have checked other maps, but i used mapContactDetails here
	
	
	
				//Query on existing accounts to find out if any matching account exists with same Email and Brand or mobile and Brand
				//if yes, link the account
				//else create a new account
				List<Account> lstAccounts = new List<Account>([Select Id, PersonContactId, Org_Brand__c,PersonMobilePhone,MobileBrand__c, PersonEmail,EmailBrand__c From Account Where (MobileBrand__c IN: mobilenumbers) or (EmailBrand__c IN: emailIds) ]);
				system.debug(' --- ***** ' + lstAccounts);
				List<Case> caseToUpdate = new List<Case>();
				set<Case> setToUpdate = new set<Case>();
				set<string> accountString = new set<string>();
				set<account> setAccount = new set<account>();
				//Creating Map for related account wth cases
	
				//Finding the case wihich is having account and assign the related account and contact id
				for(account acc: lstAccounts) {
	
					if(acc.PersonEmail != null) {
						if(emailWithCase.containsKey(acc.PersonEmail+ acc.Org_Brand__c)) {
							emailWithCase.get(acc.PersonEmail+ acc.Org_Brand__c).accountId = acc.Id;
							emailWithCase.get(acc.PersonEmail+ acc.Org_Brand__c).contactid = acc.PersonContactId;
							// Removing the case with account then It will have only the case which is not having account
							CasewithoutAccount.remove(acc.PersonEmail+ acc.Org_Brand__c);
						}
					}
	
					if(acc.PersonMobilePhone != null && acc.PersonEmail == null) {
						if(emailWithCase.containsKey(acc.PersonMobilePhone+ acc.Org_Brand__c)) {
							emailWithCase.get(acc.PersonMobilePhone+ acc.Org_Brand__c).accountId = acc.Id;
							emailWithCase.get(acc.PersonMobilePhone+ acc.Org_Brand__c).contactid = acc.PersonContactId;
							// Removing the case with account then It will have only the case which is not having account
							CasewithoutAccount.remove(acc.PersonMobilePhone+ acc.Org_Brand__c);
						}
					}
				}
	
	
				system.debug('#### CasewithoutAccount: ' + CasewithoutAccount);
				if(!CasewithoutAccount.isempty()) {
					//create new person account here
	
					Map<String, Account> newCaseAccount = new Map<String, Account>();
					list<string> emailnew = new list<string>();
					list<string> brandnew = new list<string>();
					list<string> phonenew = new list<string>();
					for(Case cs : CasewithoutAccount.values()) {
						system.debug('#### cs.SuppliedEmail: ' + cs.SuppliedEmail);
	
						//if(cs.AccountId == null){
						Account a = new Account();
						a.PersonEmail = cs.SuppliedEmail;
						if(cs.SuppliedEmail != null) {
							emailnew.add(cs.SuppliedEmail+cs.Org_Brand__c);
						}
	
						a.Org_Brand__c = cs.Org_Brand__c;
						//Added as a part of v1.39
						String Domain; //=''; commented as part of v1.68
	
						if(cs.Case_Domain__c != null &&
						   cs.First_Name__c!= null &&
						   cs.Last_Name__c!=null &&
						   cs.SuppliedName!=null) {         //v1.60 Live Chat
							Domain = cs.Case_Domain__c; //v1.60
						}
	
						if(cs.Case_Domain__c != null && cs.Org_Brand__c == 'EKH') { //v1.43
							Domain = cs.Case_Domain__c; //v1.43
						}//v1.43
						else{ //v1.43 added else statment. The content of the else statement remains the same. This is change due to logic of customer engine
							if(cs.Org_Mailbox_Email__c != null)
								Domain = BusinessUnitMappingUtility.mEmailToEmailRecord.get(cs.Org_Mailbox_Email__c).Domain__c;
						}//v1.43
	
						if(Domain != null && Domain != '') // v1.68 fix for blank domain
							a.Customer_Domain__c = Domain;
						// end v1.39 Added by SB
						if(cs.SuppliedName == null || cs.SuppliedName == '') {
							a.LastName = '-';
						}
						if(cs.SuppliedName != null && cs.SuppliedName != '') {
							String fname = '';
							String lname = '';
							if(cs.SuppliedName.length() <= 40) {                                
								if(cs.SuppliedName.split(' ').size() > 1) {
									String[] name = cs.SuppliedName.split(' ');
									for(integer i = 0; i < name.size() - 1; i++) {
										fname += name[i] + ' ';
									}
									fname = fname.removeEnd(' ');
									lname = name[name.size() - 1];
								} else {
									fname = '-';
									lname = cs.SuppliedName;
								}
							} else {
								if(cs.SuppliedName.length() > 40) {
									String[] name = cs.SuppliedName.split(' ');
									String[] fnameList = new List<String>();
									String[] lnameList = new List<String>();
	
									for(integer i = 0; i < name.size(); i++) {
										if(fname.length() < 40) {
											fnameList.add(name[i]);
											fname = String.join(fnameList,' ');
										} else {
											if(fnameList.size() > 1) {
												fnameList.remove(fnameList.size() - 1);
												fname = String.join(fnameList,' ');
											}
											break;
										}
									}
	
									for(integer i = fname.split(' ').size() - 1; i < name.size(); i++) {
										if(lname.length() < 80) {
											lnameList.add(name[i]);
											lname = String.join(lnameList,' ');
										} else {
											if(lnameList.size() > 1) {
												lnameList.remove(lnameList.size() - 1);
												lname = String.join(lnameList,' ');
											}
											break;
										}
									}
	
									if(lname == '' || lname == null) {
										String[] fnametempList = new List<String>();
										fnametempList = fname.split(' ');
										for(integer i = 0; i < fnameList.size(); i++) {
											if(i < fnameList.size() - 1) {
												fnametempList.add(fnameList[i]);
												fname = String.join(fnametempList,' ');
											} else {
												lname = fnameList[i];
											}
										}
									}
								} else {
									fname = '-';
									lname = cs.SuppliedName;
								}
							}
							system.debug('fname==>'+fname);
							system.debug('lname==>'+lname);
							a.FirstName = fname.left(40);
							a.LastName = lname.left(80);
						}
						if(cs.SuppliedPhone != null && (cs.SuppliedEmail == null || cs.SuppliedName == '')) {
							a.PersonMobilePhone = cs.SuppliedPhone;
							phonenew.add(cs.SuppliedPhone+''+cs.Org_Brand__c);
						}
						system.debug('!!!!!!!!!!!!!!!'+cs.Org_Brand__c);
						string brand = cs.Org_Brand__c.toLowerCase();
						Person_Account_Record_Types__c par = Person_Account_Record_Types__c.getValues(brand);
						system.debug('par'+par.Record_Type_Name__c);
						a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(par.Record_Type_Name__c).getRecordTypeId();
						system.debug('ID@@@@'+a.RecordTypeId);
						//newAccounts.add(a);
						if(cs.SuppliedEmail != null) {
							newCaseAccount.put(cs.SuppliedEmail, a);
						}
	
						else{
							if(cs.SuppliedPhone != null) {
								newCaseAccount.put(cs.SuppliedPhone, a);
							}
						}
						system.debug('newCaseAccount@@@@@@@'+newCaseAccount);
						//}
					}
					system.debug('!!SB!! = '+newCaseAccount);
					// creating New Account
					if(!newCaseAccount.isEmpty()) {
						insert newCaseAccount.values();
					}
					map<string,account> contactId = new map<string,account>();
					List<account> accList=[select id,PersonContactId,PersonMobilePhone,PersonEmail from Account Where (MobileBrand__c in:phonenew ) or (EmailBrand__c IN :emailnew)];
					system.debug(accList+'!!!!!!!!!!!!!!!!!!accList');
					if(accList.size() > 0) {
						for(account accRef:accList) {
	
							if(accRef.PersonEmail != null) {
								contactId.put(accRef.PersonEmail,accRef);
							}
							else{
	
								if(accRef.PersonMobilePhone != null) {
									contactId.put(accRef.PersonMobilePhone,accRef);
								}
							}
						}
					}
	
					system.debug('newCaseAccount!!!!!!!!!!!!!'+newCaseAccount);
	
					//Looping the cases without account and linking them with Account and Contact
					for(Case cs : CasewithoutAccount.values()) {
	
	
						if(cs.SuppliedEmail != null) {
							system.debug('cs.SuppliedEmail!!!!!!!!!!!!!'+cs.SuppliedEmail);
							cs.AccountId = newCaseAccount.get(cs.SuppliedEmail).Id;
							cs.ContactId = contactId.get(cs.SuppliedEmail).PersonContactId;
						}
	
						else{
							system.debug('cs.SuppliedPhone!!!!!!!!!!!!!'+cs.SuppliedPhone);
							if(cs.SuppliedPhone != null && cs.SuppliedEmail == null) {
								cs.AccountId = newCaseAccount.get(cs.SuppliedPhone).Id;
								cs.ContactId = contactId.get(cs.SuppliedPhone).PersonContactId;
							}
						}
					}
	
	
	
	
	
				}
			}
			//End - LOGIC FOR B2C CASES	
			
			//v1.69
			//Start - LOGIC FOR B2B CASES
			if(b2bCases.size() > 0){
				system.debug('\n\n\n ********* Entered B2B Logic ********* \n\n\n');
				for(Case b2bCse : b2bCases){
					if((b2bCse.Org_Case_Status__c == 'New' || b2bCse.Org_Case_Status__c == 'In Progress' || b2bCse.Org_Case_Status__c == 'Open') &&
					   (b2bCse.Origin == 'Email' || b2bCse.Origin == 'Web' || b2bCse.Origin == 'AMI Chat' || b2bCse.Origin == 'Live Chat')){
						b2bEmails.add(b2bCse.SuppliedEmail);
					}	
				}
				system.debug('*******b2bEmails: ' + b2bEmails);
				system.debug('*******b2bContactRecordTypeIDs: ' + b2bContactRecordTypeIDs);
				map<String, Contact> emailContactMap = new map<String, Contact>();
				for(Contact con : [SELECT Id, Email, RecordtypeId, AccountId
									FROM Contact
									WHERE Email IN: b2bEmails
									AND RecordtypeId IN: b2bContactRecordTypeIDs]){
					emailContactMap.put(con.Email + con.RecordtypeId, con);
				}
				system.debug('*******emailContactMap: ' + emailContactMap);
				for(Case caseRecord : b2bCases){
					if(mapCaseEmailConfigs.containsKey(caseRecord.Org_Mailbox_Email__c)){
						String contactRecordtypeId = mapCaseEmailConfigs.get(caseRecord.Org_Mailbox_Email__c).B2B_Contact_Recordtype_ID__c;
						system.debug('*******contactRecordtypeId: ' + contactRecordtypeId);
						if(emailContactMap.containsKey(caseRecord.SuppliedEmail + contactRecordtypeId)){
							Contact existingContact = emailContactMap.get(caseRecord.SuppliedEmail + contactRecordtypeId);
							caseRecord.ContactId = existingContact.Id;
							if(existingContact.AccountId != null){
								caseRecord.AccountId = existingContact.AccountId;
							}
							system.debug('*******caseRecord ContactID: ' + caseRecord.ContactId);
							system.debug('*******caseRecord AccountID: ' + caseRecord.AccountId);
							caseNoContactMap.remove(caseRecord.SuppliedEmail + contactRecordtypeId);
						}	
					}	
				}
				
				if(!caseNoContactMap.isempty()){
					system.debug('\n\n\n ******* will create a B2B Contact ******* \n\n\n');
					map<String, Contact> mapNewContacts = new Map<String, Contact>();
					for(Case caseObj : caseNoContactMap.values()){
						Contact newContact = new Contact();
						if(mapCaseEmailConfigs.containsKey(caseObj.Org_Mailbox_Email__c)){
							newContact.RecordtypeId = mapCaseEmailConfigs.get(caseObj.Org_Mailbox_Email__c).B2B_Contact_Recordtype_ID__c;
						}
						newContact.Email = caseObj.SuppliedEmail;
						newContact.Phone = caseObj.SuppliedPhone;
						if(caseObj.SuppliedName.split(' ').size() > 1){
							list<String> name = caseObj.SuppliedName.split(' ');
							String firstName = '';
							for(integer i = 0; i < name.size() - 1; i++ ){
								firstName += name[i] + ' ';
							}
							newContact.FirstName = firstName;
							newContact.LastName = name[name.size() - 1];
						} else if(caseObj.SuppliedName.split(' ').size() == 1){
							newContact.LastName = caseObj.SuppliedName;
						} else {
							newContact.LastName = caseObj.SuppliedEmail;
						}
						
						if(caseObj.RecordtypeId == aaStellaRecTypeID){
							newContact.AccountId = Label.AA_Stella_Account_ID;
						}
						if(caseObj.RecordtypeId == aaEKHUKRecTypeID){
							newContact.AccountId = Label.AA_EKHUK_Account_ID;
						}													
						mapNewContacts.put(newContact.Email, newContact);						
					}
					
					if(!mapNewContacts.isEmpty()) {
						system.debug('*******mapNewContacts: ' + mapNewContacts);
						Database.DMLOptions dml = new Database.DMLOptions();
						dml.DuplicateRuleHeader.allowSave = true;
						dml.DuplicateRuleHeader.runAsCurrentUser = true;
						list<Database.SaveResult> sr = Database.insert(mapNewContacts.values(), dml);								
					}

					for(Case caseObj : caseNoContactMap.values()){
						system.debug('\n\n\n ******* contact will be linked to Case ******* \n\n\n');
						if(caseObj.SuppliedEmail != null && mapNewContacts.containsKey(caseObj.SuppliedEmail)) {
							caseObj.ContactId = mapNewContacts.get(caseObj.SuppliedEmail).Id;
						}						
					}	
				}
			
			}
			//End - LOGIC FOR B2B CASES						
		}

		catch(exception ex) {

			Request_Log__c objLog = new Request_Log__c();
			objLog.Entity__c = 'CaseTriggerHandler';
			objLog.Error_Log__c ='-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
			objLog.Type__c = 'Linking case with Account and contact';
			insert objLog;
		}
	}
	/* commented the whole method since action(line 980) inside was commented out to have higher code coverage
	   private static void preventOwnershipChange(Case newCase, Case oldCase){
	    system.debug('### mapCaseToCaseMilestones: ' + mapCaseToCaseMilestones);
	    system.debug('### preventOwnershipChange newCase.OwnerID: ' + newCase.OwnerId);
	    system.debug('### preventOwnershipChange oldCase.OwnerID: ' + oldCase.OwnerId);



	    //we can change owner from Queue to Owner
	    if( newCase.Org_Email_From_Customer__c &&
	        oldCase.OwnerId != newCase.OwnerId &&
	            (
	                (string.valueOf(oldCase.OwnerId).startsWith('005') && //User to User
	                string.valueOf(newCase.OwnerId).startsWith('005'))
	 ||
	                (string.valueOf(oldCase.OwnerId).startsWith('00G') && //Queue to Queue
	                string.valueOf(newCase.OwnerId).startsWith('00G'))
	 ||
	                (string.valueOf(oldCase.OwnerId).startsWith('005') && //User to Queue
	                string.valueOf(newCase.OwnerId).startsWith('00G'))
	            )
	        ){
	        //newCase.addError('Cannot change owner if there is an open CaseMilestone');
	    }

	   }
	 */

	//v1.37
	public static void preventCaseReopenedBlankFromClosed(Case newCase, Case oldCase){
		if(newCase.Org_Case_Status__c != oldCase.Org_Case_Status__c && oldCase.Org_Case_Status__c == 'Closed' && newCase.Org_Brand__c =='trp') {
			newCase.Reopened__c = true;
		}

		if(oldCase.Reopened__c == true && newCase.Reopened__c == false  && newCase.Org_Brand__c =='trp') {
			newCase.Reopened__c = true;
		}
	}

	/*
	private static void createListMilestonesToComplete(Case newCase, Case oldCase, List<CaseMilestone> lCaseMilestone){
		system.debug('### createListMilestonesToComplete with newCase.Status ' + newCase.Status );
		system.debug('### createListMilestonesToComplete with oldCase.Status ' + oldCase.Status );
		system.debug('### createListMilestonesToComplete with new.Org_Current_Team_Name__c ' + newCase.Org_Current_Team_Name__c);
		system.debug('### createListMilestonesToComplete with lCaseMilestone ' + lCaseMilestone );

		if(newCase.Org_Case_Status__c == 'Closed' && oldCase.Org_Case_Status__c != 'Closed') {
			newCase.Org_Email_From_Customer__c = false;
			newCase.Org_Open_Email_Message_Id__c = '';
			if(mapCaseToCaseMilestones.size() > 0 && mapCaseToCaseMilestones.containsKey(newCase.Id)) //v1.50
				lCaseMilestone.addAll(mapCaseToCaseMilestones.get(newCase.Id));
		}

		Set<String> sMilestoneNamesToClose = new Set<String>();

		if(newCase.Org_Current_Team_Name__c == 'dTME - Service Queue' &&
		   oldCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue') {
			sMilestoneNamesToClose.add('Product Support Team SLA');
		}

		if(newCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue' &&
		   oldCase.Org_Case_Status__c == 'Pending - Customer' &&
		   newCase.Org_Case_Status__c != 'Pending - Customer') {
			system.debug('#### should get populated');
			sMilestoneNamesToClose.add('Pending Customer SLA');
		}

		if(newCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue' &&
		   oldCase.Org_Case_Status__c == 'Pending - Supplier' &&
		   newCase.Org_Case_Status__c != 'Pending - Supplier') {
			sMilestoneNamesToClose.add('Pending Supplier SLA');
		}

		if(oldCase.Org_Current_Team_Name__c == 'Customer Relations Queue' &&
		   newCase.Org_Current_Team_Name__c == 'Pending - Supplier') {
			sMilestoneNamesToClose.add('Customer Relation SLA');
		}

		// Added as a part of v1.16
		if(newCase.Customer_Communication_Pending__c == False && oldCase.Customer_Communication_Pending__c == true) {
			sMilestoneNamesToClose.add('Email Response'); //changed from first response to email response by Evendo
			sMilestoneNamesToClose.add('First Response'); //v1.35
			system.debug('### Test '+sMilestoneNamesToClose);
		}
		//end of v1.16
		//v1.52
		if(newCase.Org_Case_Status__c != 'In Progress' && oldCase.Org_Case_Status__c == 'In Progress'
		   && newCase.Record_Type_Name__c == 'dTME - After Sales' && newCase.Org_Case_Status__c != 'Closed') {
			sMilestoneNamesToClose.add('Touchpoint');
		}
		//end of v1.52
		system.debug('#### sMilestoneNamesToClose: ' + sMilestoneNamesToClose);
		if(mapCaseToCaseMilestones.size() > 0 &&  mapCaseToCaseMilestones.containsKey(newCase.Id)) { //v1.50
			for(CaseMilestone cm: mapCaseToCaseMilestones.get(newCase.Id)) {
				system.debug('#### mapCaseToCaseMilestones.get(newCase.Id): ' + mapCaseToCaseMilestones.get(newCase.Id));
				system.debug('#### cm.Milestonetype.Name: ' + cm.Milestonetype.Name);

				if(sMilestoneNamesToClose.contains(cm.Milestonetype.Name)) lCaseMilestone.add(cm);
			}
		}
		system.debug('#### lCaseMilestone: ' + lCaseMilestone);
	}
	*/


	private static void closeCaseMilestones(List<CaseMilestone> lCaseMilestone){
		for(CaseMilestone cm: lCaseMilestone) {
			cm.CompletionDate = Datetime.valueOf(system.now().format(dateformat,''+userinfo.getTimeZone()));
			//cm.CompletionDate = Datetime.now(); //system.now
		}
		update lCaseMilestone;
	}

	private static void createMapCaseToCaseMilestones(List<Case> lCases, list<Case> oldCases, List<CaseMilestone> lCaseMilestonesToClose){
		//v1.55
		list<Id> lstCaseIds = new list<Id>();
		Set<String> sMilestoneNamesToClose = new Set<String>();
		Boolean isCaseClosed = false;
		Integer i = 0;
		for(Case objNewCase : lCases) {
			Case objOldCase = oldCases[i];

			Boolean flag = false;
			if(objNewCase.Org_Case_Status__c == 'Closed' && objOldCase.Org_Case_Status__c != 'Closed') {
				isCaseClosed = true;
				flag = true;
			}

			if(objNewCase.Org_Current_Team_Name__c == 'dTME - Service Queue' &&
			   objOldCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue') {
				sMilestoneNamesToClose.add('Product Support Team SLA');
				flag = true;
			}

			if(objNewCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue' &&
			   objOldCase.Org_Case_Status__c == 'Pending - Customer' &&
			   objNewCase.Org_Case_Status__c != 'Pending - Customer') {
				sMilestoneNamesToClose.add('Pending Customer SLA');
				flag = true;
			}

			if(objNewCase.Org_Current_Team_Name__c == 'dTME - Product Support Queue' &&
			   objOldCase.Org_Case_Status__c == 'Pending - Supplier' &&
			   objNewCase.Org_Case_Status__c != 'Pending - Supplier') {
				sMilestoneNamesToClose.add('Pending Supplier SLA');
				flag = true;
			}

			if(objOldCase.Org_Current_Team_Name__c == 'Customer Relations Queue' &&
			   objNewCase.Org_Current_Team_Name__c == 'Pending - Supplier') {
				sMilestoneNamesToClose.add('Customer Relation SLA');
				flag = true;
			}

			if(objNewCase.Customer_Communication_Pending__c == False && objOldCase.Customer_Communication_Pending__c == true) {
				sMilestoneNamesToClose.add('Email Response');
				sMilestoneNamesToClose.add('First Response'); 				
				flag = true;
			}

			//v1.52
			if(objNewCase.Org_Case_Status__c != 'In Progress' && objOldCase.Org_Case_Status__c == 'In Progress'
			   && objNewCase.Record_Type_Name__c == 'dTME - After Sales' && objNewCase.Org_Case_Status__c != 'Closed') {
				sMilestoneNamesToClose.add('Touchpoint');
				flag = true;
			}

			if(objNewCase.Org_Case_Status__c != 'Proposal In Progress' && objOldCase.Org_Case_Status__c == 'Proposal In Progress'
			   && objNewCase.Record_Type_Name__c == 'EKH Groups Enquiry' && objNewCase.Org_Case_Status__c != 'Closed') {
				sMilestoneNamesToClose.add('Proposal In Progress');
				flag = true;
			}

			if(objNewCase.Org_Case_Status__c != 'Proposal Sent' && objOldCase.Org_Case_Status__c == 'Proposal Sent'
			   && objNewCase.Record_Type_Name__c == 'EKH Groups Enquiry' && objNewCase.Org_Case_Status__c != 'Closed') {
				sMilestoneNamesToClose.add('Proposal Sent');
				flag = true;
			}

			if(flag) {
				lstCaseIds.add(objNewCase.Id);
			}
			i++;
		}

		if(!lstCaseIds.isEmpty()) {//added if condition - RB v1.55

			for(Case cm : [SELECT Id, Org_Case_Status__c,
			               (SELECT Id, Milestonetype.Name, CompletionDate FROM CaseMilestones WHERE CompletionDate = NULL)
			               FROM Case
			               WHERE Id IN: lstCaseIds]) {
				system.debug('cm.CaseMilestones size :: '+cm.CaseMilestones.size());
				if(cm.CaseMilestones != null && cm.CaseMilestones.size() > 0) { //v1.50 Modified as a part of v1.50
					//mapCaseToCaseMilestones.put(cm.Id, cm.CaseMilestones);
					for(CaseMilestone cmt : cm.CaseMilestones){
						if(sMilestoneNamesToClose.contains(cmt.Milestonetype.Name) || isCaseClosed){
							lCaseMilestonesToClose.add(cmt);
						}	
					}
				}
			}
		}
	}

	// Code written by Mahadev
	// This method populates the Hotel name on the case record
	// If the case is linked to a Booking, the below code will extract the itineraries
	// captures the hotel name
	// and punch it on the Case record
	public static void populateHotelName(List<Case> newCases){
		system.debug('case trigger');
		Set<Id> bookingIds = new Set<Id>();
		Map<String, List<String> > mapHotelNameWithBookingId = new Map<String, List<String> >();
		for(Case c : newCases) {
			if(c.Org_Type__c!='Booking Enquiry' && c.Org_Booking__c != null) { //v1.14 - Added the type condition
				bookingIds.add(c.Org_Booking__c);
			}
		}
		system.debug(bookingIds);
		if(bookingIds.size()>0) { //v1.14 - Added booking check
			for(Itinerary__c itin : [Select Id, Org_Hotel_Name__c,Org_Booking__c From Itinerary__c Where Org_Booking__c IN :bookingIds]) {
				if(!String.isEmpty(itin.Org_Hotel_Name__c)) {
					if(mapHotelNameWithBookingId.containsKey(itin.Org_Booking__c)) {
						List<String> hotelNames = mapHotelNameWithBookingId.get(itin.Org_Booking__c);
						hotelNames.add(itin.Org_Hotel_Name__c);
						mapHotelNameWithBookingId.put(itin.Org_Booking__c, hotelNames);
					} else {
						mapHotelNameWithBookingId.put(itin.Org_Booking__c, new List<String> {itin.Org_Hotel_Name__c});
					}
				}
			}
		}

		for(Case c : newCases) {
			if(c.Org_Type__c!='Booking Enquiry' && c.Org_Booking__c != null) { //v1.14 - Added the type condition
				system.debug(c.Org_Booking__c);
				system.debug(mapHotelNameWithBookingId.get(c.Org_Booking__c));

				//KR adding null pointer exception prevention
				if(mapHotelNameWithBookingId.get(c.Org_Booking__c) != null) {
					c.Org_Hotel_Name__c = String.join(mapHotelNameWithBookingId.get(c.Org_Booking__c), ';');
				}

			}
		}
	}


	/******************* Helper Methods *******************************/
	//KR.
	private static void populatedBusinessHours(Case newCase, Case oldCase){

		//added as a part of v1.26
		Map<String,BusinessHours> bhoursMap = new Map<String,BusinessHours>();
		if(lstBusinessHours.isEmpty()) {
			lstBusinessHours = [Select Id,Name from BusinessHours where Name IN  ('Travel Republic Standard','Travel Republic 24/7')];
		}
		List<BusinessHours> trpbhours = lstBusinessHours;//[Select Id,Name from BusinessHours where Name IN  ('Travel Republic Standard','Travel Republic 24/7')];
		if(trpbhours.size()>0) {
			for(BusinessHours bhour : trpbhours) {
				bhoursMap.put(bhour.Name,bhour);
			}
		}

		if(newCase.Org_Brand__c == 'trp' && newCase.Record_Type_Name__c == 'Travel Republic - Complaint' && newCase.Org_Customer_Journey_Point__c == 'Post Travel / Holiday')
			newCase.BusinessHoursId = bhoursMap.get('Travel Republic Standard').Id;
		else if(newCase.Org_Brand__c == 'trp' && newCase.Record_Type_Name__c == 'Travel Republic - Complaint' && newCase.Org_Customer_Journey_Point__c != 'Post Travel / Holiday')
			newCase.BusinessHoursId = bhoursMap.get('Travel Republic 24/7').Id;
		else if(newCase.Org_Brand__c == 'trp' && newCase.Record_Type_Name__c == 'Travel Republic - Service Request')
			newCase.BusinessHoursId = bhoursMap.get('Travel Republic Standard').Id;
		//end
		else if(BusinessUnitMappingUtility.queueIdToSLARecord.get(newCase.Current_Queue_ID__c) != null) { //v1.76
			newCase.BusinessHoursId = BusinessUnitMappingUtility.queueIdToSLARecord.get(newCase.Current_Queue_ID__c).Org_Business_Hour_Id__c; //v1.76
		}
	}

	//KR
	//Added as a part of v1.48
	private static void populateEntitlementMap(){
        for(entitlement ent: [select id,Org_Brand__c from entitlement]){

            entitlementBrandMap.put(ent.Org_Brand__c.toLowercase(),ent.Id);
        }
        //if(entitlementList.isEmpty())
        //entitlementList = [SELECT Id,Name FROM entitlement WHERE Name IN ('TR Entitlement','dnata Entitlement','EKH Entitlement','New dnata Entitlement','dnata After Sales Entitlement','dnata eCommerce Entitlement')]; // modified as a part of v1.52 //modified as a part of v1.58
    }
	
	// end of v1.48
	private static void populateEntitlementId(Case newCase, Case oldCase){
        //Added as a part of v1.40
        if(newCase.EntitlementId == null && !newCase.Org_Skip_All_Milestone_Creation__c && entitlementBrandMap.containsKey(newCase.Org_Brand__c.toLowercase())) { //v1.76               
            newCase.EntitlementId = entitlementBrandMap.get(newCase.Org_Brand__c.toLowercase());             
        } 
        
        
    }
	
	/* commented out as part of v1.75
	//KR
	//v1.7 Update Current and Previous team name logic
	private static void populateCurrentTeamName(Case newCase, Case oldCase){
		String sOwnerId15Char = String.valueOf(newCase.OwnerId).left(15);

		if(oldCase == null) {
			//Owner is User

			if(string.valueOf(newCase.OwnerId).startsWith('005')) {
				newCase.Org_Current_Team_Name__c = newCase.Owner_Team_Name__c;
				if(!newCase.Is_Integration_User__c) //v1.51
					newCase.Org_Original_Team_Name__c = newCase.Owner_Team_Name__c;
			}


			//Owner is Queue
			//update by SB Added {} for the if statement v1.45
			if(string.valueOf(newCase.OwnerId).startsWith('00G') &&
			   BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char) != null) {
				newCase.Org_Current_Team_Name__c = BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char).Org_Team_Name__c;
				newCase.Org_Original_Team_Name__c = newCase.Org_Current_Team_Name__c;
			}
		}else{
			system.debug('#### populateCurrentTeamName else newCase: ' + newCase);
			system.debug('#### populateCurrentTeamName else oldCase: ' + oldCase);

			//Owner is User
			if(string.valueOf(newCase.OwnerId).startsWith('005') && newCase.OwnerId != oldCase.OwnerId) {
				// V1.7
				newCase.Org_Current_Team_Name__c = newCase.Owner_Team_Name__c;
				//Added as part of V1.1
				if(oldCase.Owner_Team_Name__c != newCase.Owner_Team_Name__c) {
					newCase.Previous_Team_Name__c=oldCase.Org_Current_Team_Name__c; //Changed as a part of v1.7
					newCase.Reassigned_Date__c=system.now();
				}

				//v1.51
				if(newCase.Org_Original_Team_Name__c == null || newCase.Org_Original_Team_Name__c == '')
					newCase.Org_Original_Team_Name__c = newCase.Owner_Team_Name__c;
			}
			//Owner is Queue
			if(string.valueOf(newCase.OwnerId).startsWith('00G') &&
			   BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char) != null &&
			   newCase.OwnerId != oldCase.OwnerId) {
				newCase.Org_Current_Team_Name__c = BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char).Org_Team_Name__c;
				newCase.Previous_Team_Name__c=oldCase.Org_Current_Team_Name__c;    //Changed as a part of v1.7 //Added as part of V1.1
				newCase.Reassigned_Date__c=system.now();    //Added as part of V1.1

				//v1.51
				if(newCase.Org_Original_Team_Name__c == null || newCase.Org_Original_Team_Name__c == '')
					newCase.Org_Original_Team_Name__c = BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char).Org_Team_Name__c;
			}
		}
		

	}
	*/
	
	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 11 March 2019
	 * @description: method to set marhaba case status to 'Spam/NA' for certain subjects
	 * @history:
	 */
	private static void closeCaseFromSpamEmail(list<Case> lstNewCase){

		//Start - v1.41
		//Account marhabaSpamAccount = [SELECT Id FROM Account WHERE Name = 'marhaba SPAM EMAILS Account' LIMIT 1 FOR UPDATE]; //v1.34
		Id marhabaSpamAccountId = [SELECT Id FROM Account WHERE Name = 'marhaba SPAM EMAILS Account' LIMIT 1].Id;
		list<Case> marhabaCasesToClose = new list<Case>();
		list<Case> aaCasesToClose = new list<Case>();

		for(Case newCase : lstNewCase) {

			if(newCase.RecordtypeId == marhabaEmailRecTypeID && string.IsNotEmpty(newCase.Subject) && (newCase.Subject == '[Postmaster] Email Delivery Failure' || newCase.Subject == '[Postmaster] Email Delivery Warning' ||
			                                                                                           newCase.Subject == 'Undelivered Mail Returned to Sender' || newCase.Subject.startsWith('Undeliverable:') ||
			                                                                                           newCase.Subject == 'Your message couldn\'t be delivered' || newCase.Subject == 'Your message hasn\'t been delivered yet')) {

				marhabaCasesToClose.add(newCase);

			}

			if(newCase.RecordtypeId == aaB2CRecTypeID &&
			   string.IsNotEmpty(newCase.Subject) &&
			   newCase.Subject.startsWith('Your Arabian Adventures Booking') &&
			   newCase.SuppliedEmail == 'no-reply@arabian-adventures.com') {

				aaCasesToClose.add(newCase);

			}

		}

		//marhaba
		if(marhabaCasesToClose.size() > 0) {
			for(Case marhabaCase : marhabaCasesToClose) {
				marhabaCase.AccountId =  marhabaSpamAccountId; //v1.34
				marhabaCase.Org_Case_Status__c = 'Spam/NA';
				marhabaCase.Status = 'Spam/NA';
			}
		}

		//Arabian Adventures
		if(aaCasesToClose.size() > 0) {
			for(Case aaCase : aaCasesToClose) {
				aaCase.AccountId = Label.AA_Spam_Emails_Account_ID;
				aaCase.Org_Case_Status__c = 'Closed';
				aaCase.Status = 'Closed';
				aaCase.Reason = 'Spam';
			}
		}
		//End - v1.41

		//commented out for v1.41
		/*
		   for(Case newCase : lstNewCase){
		    if(newCase.RecordtypeId == marhabaEmailRecTypeID && string.IsNotEmpty(newCase.Subject)
		    && (newCase.Subject == '[Postmaster] Email Delivery Failure' || newCase.Subject == '[Postmaster] Email Delivery Warning'
		 || newCase.Subject == 'Undelivered Mail Returned to Sender' || newCase.Subject.startsWith('Undeliverable:') || newCase.Subject == 'Your message couldn\'t be delivered' || newCase.Subject == 'Your message hasn\'t been delivered yet')){

		        newCase.AccountId =  marhabaSpamAccount.Id; //v1.34
		        newCase.Org_Case_Status__c = 'Spam/NA';
		        newCase.Status = 'Spam/NA';

		    } else if(newCase.RecordtypeId == aaB2CRecTypeID
		      && string.IsNotEmpty(newCase.Subject)
		      && newCase.Subject.startsWith('Your Arabian Adventures Booking')
		      && newCase.SuppliedEmail == 'no-reply@arabian-adventures.com'){
		        newCase.AccountId = Label.AA_Spam_Emails_Account_ID;
		        newCase.Org_Case_Status__c = 'Closed';
		        newCase.Status = 'Closed';
		        newCase.Reason = 'Spam';
		    }
		   }
		 */
	}

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 31 July 2019
	 * @description: @future method that populate Marhaba Spam Email AccountId on Case asynchronously to avoid lock row errors
	 * @history:
	 *//*   //v1.34
	   @future
	   static void populateSpamAccountId(String strListCases){

	    list<Case> casesToUpdate = new list<Case>();
	    list<Case> lstCases = (list<Case>)JSON.deserialize(strListCases,list<Case>.class);
	    for(Case cse : lstCases){
	        cse.AccountId = Label.Marhaba_SPAM_Account_ID;
	        casesToUpdate.add(cse);
	    }

	    if(casesToUpdate.size() > 0){
	        update casesToUpdate;
	    }

	   }*/

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 19 March 2019
	 * @description: method to set Arabian Adventures Case Origin to B2C Website
	 * @history:
	 */
	private static void setAACaseOrigin(Case newCase){

		if(newCase.RecordtypeId == aaB2CRecTypeID && setB2CWebsiteFromEmails.contains(newCase.SuppliedEmail)) {
			newCase.Origin = 'B2C Website';
		}

	}

	/**
	 * @author: Maruf Bagwan
	 * @date: 01 April 2019
	 * @description: Populate Retail Store field on case record
	 * @history:
	 *//* commented out as part of v1.77
	public static void updateRetailUserField(List<case> newCaseList,Map<Id,Case> oldCaseMap, Boolean isInsert){
		Map<Id,List<case> > queueCaseMap = new Map<Id,List<case> >();
		Map<Id,List<case> > userCaseMap = new Map<Id,List<case> >();
		Map<string,string> queueStoreMap = createQueueStoreMap();
		if(isInsert) {
			for(case cse: newCaseList) {
				if(cse.OwnerId != null && string.valueof(cse.OwnerId).startsWith('00G') && cse.Sys_Case_Queue__c!=null) {
					if(!queueCaseMap.containsKey(cse.OwnerId)) {
						list<case> caselist = new List<case>();
						caselist.add(cse);
						queueCaseMap.put(cse.OwnerId,caselist);
					} else {
						queueCaseMap.get(cse.OwnerId).add(cse);
					}
				} else if(cse.OwnerId != null) {
					if(!userCaseMap.containsKey(cse.OwnerId)) {
						list<case> caselist = new List<case>();
						caselist.add(cse);
						userCaseMap.put(cse.OwnerId,caselist);
					} else {
						userCaseMap.get(cse.OwnerId).add(cse);
					}
				}
			}
		}  else{
			for(case cse: newCaseList) {
				if(cse.OwnerId != null && cse.OwnerId != oldCaseMap.get(cse.Id).OwnerId) {
					if(string.valueof(cse.OwnerId).startsWith('00G') && cse.Sys_Case_Queue__c!=null) {
						if(!queueCaseMap.containsKey(cse.OwnerId)) {
							list<case> caselist = new List<case>();
							caselist.add(cse);
							queueCaseMap.put(cse.OwnerId,caselist);
						} else {
							queueCaseMap.get(cse.OwnerId).add(cse);
						}
					} else if(cse.OwnerId != null) {
						if(!userCaseMap.containsKey(cse.OwnerId)) {
							list<case> caselist = new List<case>();
							caselist.add(cse);
							userCaseMap.put(cse.OwnerId,caselist);
						} else {
							userCaseMap.get(cse.OwnerId).add(cse);
						}
					}
				}
			}
		}

		if(queueCaseMap.keySet() != null && queueCaseMap.keySet().size() > 0) {
			for(Group grp: [Select Id, DeveloperName, Name from Group where type='Queue' AND Id IN:queueCaseMap.keySet()]) {
				for(Case cse:queueCaseMap.get(grp.Id)) {
					String grpRetailStore = queueStoreMap.containsKey(grp.DeveloperName) ? queueStoreMap.get(grp.DeveloperName) : '';
					cse.Retail_Store__c = grpRetailStore;
					cse.Cluster__c = queueStoreMap.containsKey(grpRetailStore) ? queueStoreMap.get(grpRetailStore) : ''; //v1.23
				}
			}
		}

		if(userCaseMap.keySet() != null && userCaseMap.keySet().size() > 0) {
			for(User usr: [Select Id,UserRole.Name from User where Id IN : userCaseMap.keySet()]) {
				for(Case cse:userCaseMap.get(usr.Id)) {
					String roleRetailStore = queueStoreMap.containsKey(usr.UserRole.Name) ? queueStoreMap.get(usr.UserRole.Name) : '';
					cse.Retail_Store__c = roleRetailStore;
					cse.Cluster__c = queueStoreMap.containsKey(roleRetailStore) ? queueStoreMap.get(roleRetailStore) : ''; //v1.23
				}
			}
		}
	}
	*/
	
	//Added as a part of v1.17
	/*public static void populateSupplierId(Case newCase, Case oldCase){
	    system.debug('newCase@@@'+newCase);
	    if(newCase.Org_Booking__c != null && newCase.Record_Type_Name__c == 'Travel Republic - Complaint'){
	        newCase.Supplier_ID__c = String.valueof(newCase.ParentId) +'-'+ String.valueof(newCase.Org_Booking__c);
	    }
	    else{
	        newCase.Supplier_ID__c = null;
	    }

	   }   *///commented as a part of v1.36
	//end
	/* commented out as part of v1.77
	public static Map<string,string> createQueueStoreMap(){
		Map<String,String> userRoleMap = new Map<String,String>();
		List<User_Role_And_Store_Map__mdt> userRoleStoreList = new List<User_Role_And_Store_Map__mdt>([SELECT Id,Agent_Role_Name__c,Lead_Role_Name__c,Queue_Name__c,Store_Name__c, Cluster__c FROM User_Role_And_Store_Map__mdt]);
		for(User_Role_And_Store_Map__mdt userStore:userRoleStoreList) {
			userRoleMap.put(userStore.Agent_Role_Name__c,userStore.Store_Name__c);
			userRoleMap.put(userStore.Lead_Role_Name__c,userStore.Store_Name__c);
			userRoleMap.put(userStore.Queue_Name__c,userStore.Store_Name__c);
			userRoleMap.put(userStore.Store_Name__c,userStore.Cluster__c); //v1.23
		}
		return userRoleMap;
	}
	*/
	
	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 8 July 2019
	 * @description: method to set region on case //v1.38
	 * @history:
	 */
	private static void setRegionName(list<Case> lstNewCases){

		map<String,String> businessUnitRegionMap = new map<String,String>();
		for(Business_Unit_Region_Setting__mdt buRegion : [SELECT EKH_Business_Unit__c, Region__c FROM Business_Unit_Region_Setting__mdt]) {
			businessUnitRegionMap.put(buRegion.EKH_Business_Unit__c, buRegion.Region__c);
		}

		for(Case cse : lstNewCases) {
			if(businessUnitRegionMap.containsKey(cse.Org_Business_Unit_dropdown__c)) {
				cse.Region_dropdown__c = businessUnitRegionMap.get(cse.Org_Business_Unit_dropdown__c);
			} else {
				cse.Region_dropdown__c = 'ROW';
			}
		}

	}

	/***********************************************************************************************************************
	 * @Version     : v1.54
	 * @Name        : rowCaseUpdate
	 * @Params      : Case (old) , Case (new)
	 * @Return      : null
	 * @Description : Business Unit Update on Case
	 * ********************************************************************************************************************/
	private static void getBookingsforCases(List<String> rowCasebklist){
		List<Booking__c> bkng = [SELECT Id, Name, Org_Total_Transaction_Value__c, Org_Domain_Name__c, Org_Domain_Id__c, Client_Total_Gross__c, Total_Gross__c  FROM Booking__c WHERE Id IN: rowCasebklist]; //v1.74 - added CLient_Total_Gross__c, Total_Gross__c on query
		if(bkng.size() > 0) {
			for(Booking__c bk : bkng) {
				RowCaseBookingMap.put(bk.Id,bk);
			}
		}
	}
	
	public static void rowCaseUpdate(list<Case> lstCases){

        //v1.75
        User usr = [SELECT Business_Unit_single__c, Team_Name__c FROM User WHERE Id =: UserInfo.getUserId()];

        for(Case cse : lstCases){
            cse.Org_Business_Unit_dropdown__c = usr.Business_Unit_single__c;
            cse.Org_Business_Unit_Text__c = cse.Org_Business_Unit_dropdown__c;
        }
        
        //commented as part of v1.75
        /*	
		system.debug('newcase booking' + cse.Org_Booking__c);

		//if old case is null
		if(oldcase == null && cse.Org_Booking__c != null && RowCaseBookingMap.containskey(cse.Org_booking__c) ) {
			if(cse.Org_Booking__c != null && RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c != null) {
				if(cse.org_booking__c != null && cse.org_brand__c == 'ekh') {
					IF(RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c == 'Ireland' || RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '37' || RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '56' ||
					   RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '107'){
						cse.Org_Business_Unit_dropdown__c = 'EKUK';
					}else{
						cse.Org_Business_Unit_dropdown__c  = 'EKH'+' '+RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c;
					}
				}
			}
		}
		//if old case not null
		else if(oldcase != null && oldcase.Org_Booking__c != cse.Org_Booking__c && cse.Org_Booking__c != null && RowCaseBookingMap.containskey(cse.Org_booking__c)) {
			if(cse.Org_Booking__c != null && RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c != null) {
				if(cse.org_booking__c != null && cse.org_brand__c == 'ekh') {
					IF(RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c == 'Ireland' || RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '37' || RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '56' ||
					   RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Id__c == '107'){
						cse.Org_Business_Unit_dropdown__c = 'EKUK';
					}else{
						cse.Org_Business_Unit_dropdown__c  = 'EKH'+' '+RowCaseBookingMap.get(cse.Org_booking__c).Org_Domain_Name__c;
					}
				}
			}
		}
		cse.Org_Business_Unit_Text__c = cse.Org_Business_Unit_dropdown__c;//Added by Kaavya
		if((cse.Org_Business_Unit_dropdown__c == null || cse.Org_Business_Unit_Text__c == null) && cse.AccountId != null && cse.Org_Business_Unit__c != null) {
			IF(cse.Org_Business_Unit_dropdown__c == null){
				cse.Org_Business_Unit_Text__c = cse.Org_Business_Unit__c;//cse.Account.Org_Business_Unit__c; //Modified by Kaavya
				cse.Org_Business_Unit_dropdown__c = cse.Org_Business_Unit__c;//cse.Account.Org_Business_Unit__c;//Modified by Kaavya
			}else{
				cse.Org_Business_Unit_Text__c = cse.Org_Business_Unit_dropdown__c;
			}
		}
		*/
		//End v1.75
	}

	/***********************************************************************************************************************
	 * @Version     : v1.59
	 * @Name        : updateSalesClosureFieldsOnCase
	 * @Params      : List<Case>,List<Case>
	 * @Return      :
	 * @Description : Updates Total Value, Booking Ref and Sales Status when the case is closed by the B2C Sales Team
	 * ********************************************************************************************************************/
	public static void updateSalesClosureFieldsOnCase(Case newCase,Case oldCase){
		//Closed WON with Booking?

		if(newCase.Org_Case_Status__c == 'Closed' && newCase.Org_Type__c == 'Booking Enquiry' && newCase.Reason == 'Closed Confirmed'
		   && newCase.Org_Booking__c != null) {

			newCase.Booking_Ref__c = RowCaseBookingMap.get(newCase.Org_booking__c).name;//newCase.Org_Booking__r.Name; //modified by Kaavya

			/*else{
			    if(newCase.Booking_Ref__c != null)
			        newCase.Booking_Ref__c = newCase.Booking_Ref__c;
			    else
			        newCase.Booking_Ref__c = '';
			   } */// commented by Kaavya
			//Update Booking
			Booking__c bk = new Booking__c(id=newCase.Org_Booking__c);// Modified by Kaavya
			bk.Org_Case_Origin__c = newCase.Origin;
			bk.Org_Case_TeamName__c = newCase.Org_Current_Team_Name__c;
			bklistToUpdate.add(bk);
		}

		//Closed LOST ?

		if(newCase.Org_Case_Status__c == 'Closed' && newCase.Org_Type__c == 'Booking Enquiry'
		   && newCase.Reason == 'Closed Lost') {
			newCase.Sales_Status__c = 'Lost Sales';
		}

		//Closed Won with or without Booking
		if(newCase.Org_Case_Status__c == 'Closed' && newCase.Org_Type__c == 'Booking Enquiry'
		   && newCase.Reason == 'Closed Confirmed' ) { // && newCase.Org_Booking__c == null) { //commented by Kaavya
			newCase.Sales_Status__c = 'Converted';
		}

		//Total Cost changed
		if(newCase.Record_Type_Name__c == 'dTME - New Enquiry' && newCase.Org_Is_Booked__c
		   && newCase.Org_Booking__c != null) {
            if(newCase.Org_Booked_Value__c != null){ //if(newCase.dT_Booking_Value__c != null)//Modified by Kaavya
                //newcase.Total_Value__c = RowCaseBookingMap.get(newCase.Org_booking__c).Org_Total_Transaction_Value__c; //newCase.Org_Booking__r.Org_Total_Cost_Client_Currency_Number__c; //v1.74
                //v1.74
                if(RowCaseBookingMap.containsKey(newCase.Org_booking__c)){
                    if(RowCaseBookingMap.get(newCase.Org_booking__c).Client_Total_Gross__c != null){
                        newcase.Total_Value__c = RowCaseBookingMap.get(newCase.Org_booking__c).Client_Total_Gross__c;
                    } else if(RowCaseBookingMap.get(newCase.Org_booking__c).Total_Gross__c != null){
                        newcase.Total_Value__c = RowCaseBookingMap.get(newCase.Org_booking__c).Total_Gross__c;
                    }
                }
                //End v1.74
            }
		}


	}

	private static void updateBookings(){
		try{
			if(bklistToUpdate.size() > 0)
				update bklistToUpdate;
		}
		catch(Exception ex) {

		}
	}
	// end of v1.59

	//v1.63
	public static void emailToCaseChanges(list<Case> lstCases){
		if(UserInfo.getUserName().contains(Label.Integration_User_Name) || test.isRunningTest()) {
			getCaseConfigs();

			for(Case objCase : lstCases ) {
				if(objCase.SuppliedEmail != null && objCase.Origin != null && mapCaseEmailConfigs.containsKey(objCase.Origin.toLowerCase())) {
					objCase.Org_Mailbox_Email__c = objCase.Origin.toLowerCase();
					objCase.Org_Mailbox__c = mapCaseEmailConfigs.get(objCase.Origin.toLowerCase()).Name;
					objCase.Case_Domain__c = mapCaseEmailConfigs.get(objCase.Origin.toLowerCase()).Domain__c;
					objCase.Org_Business_Unit_dropdown__c = mapCaseEmailConfigs.get(objCase.Origin.toLowerCase()).Business_Unit__c;
					objCase.Origin = 'Email';
				}
			}
		}
	}

	public static void getCaseConfigs(){
		if(mapCaseEmailConfigs.isEmpty()) {
			for(Case_Email_Configuration__c obj : [select Id,Name,Domain__c,Email_to_Case_Address__c,Queue_Developer_Name__c,Business_Unit__c,Email_Routing_Address__c,Account_Type__c,B2B_Contact_Recordtype_ID__c from Case_Email_Configuration__c where Is_Active__c = true AND Email_to_Case_Address__c != null])
				mapCaseEmailConfigs.put(obj.Email_to_Case_Address__c.toLowerCase(), obj);
		}
	}


	//v1.65
	public static void populateTeamQueueNames(list<Case> lstCases, map<Id, Case> mapOldCases){
		/* For deployment */
		for(Case objCase : lstCases) {
			Case objOldCase = mapOldCases != null && mapOldCases.containsKey(objCase.Id) ? mapOldCases.get(objCase.Id) : new Case();
			if(string.valueOf(objCase.OwnerId).startsWith('005') && objCase.OwnerId != objOldCase.OwnerId ) {
				objCase.Org_Current_Team_Name__c = objCase.Owner_Team_Name__c;

				if(objOldCase.Id == null && !objCase.Is_Integration_User__c ) {
					objCase.Org_Original_Team_Name__c = objCase.Owner_Team_Name__c;
				}else if(objCase.Org_Original_Team_Name__c == null && !objCase.Is_Integration_User__c ) {
					objCase.Org_Original_Team_Name__c = objCase.Owner_Team_Name__c;
				}
				if(objOldCase.Id != null)
					objCase.Reassigned_Date__c = system.now();
				objCase.Previous_Team_Name__c = objOldCase.Org_Current_Team_Name__c;
			}

			if(string.valueOf(objCase.OwnerId).startsWith('00G') && objCase.OwnerId != objOldCase.OwnerId) {
				String sOwnerId15Char = String.valueOf(objCase.OwnerId).left(15); // v1.75
				objCase.Current_Queue_Name__c = objCase.Owner_Team_Name__c;
                //v1.75
                if(BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char) != null){
                    objCase.Org_Current_Team_Name__c = BusinessUnitMappingUtility.mQueueIdToQueueRecord.get(sOwnerId15Char).Org_Team_Name__c;
                }
                //End v1.75
                
                objCase.Current_Queue_ID__c = objCase.OwnerId; //v1.76
                
				if(objOldCase.Id == null) {
					objCase.Original_Queue_Name__c = objCase.Owner_Team_Name__c;
				}else if(objCase.Original_Queue_Name__c == null) {
					objCase.Original_Queue_Name__c = objCase.Owner_Team_Name__c;
				}
				if(objOldCase.Id != null)
					objCase.Reassigned_Date__c = system.now();
					objCase.Previous_Queue_Name__c = objOldCase.Current_Queue_Name__c;
					objCase.Previous_Team_Name__c = objOldCase.Org_Current_Team_Name__c; //v1.75
			}

			system.debug(' objCase.Org_Current_Team_Name__c is '+objCase.Org_Current_Team_Name__c);
			system.debug(' objCase.Org_Original_Team_Name__c is '+objCase.Org_Original_Team_Name__c);
			system.debug(' objCase.Previous_Team_Name__c is '+objCase.Previous_Team_Name__c);

			system.debug(' objCase.Current_Queue_Name__c is '+objCase.Current_Queue_Name__c);
			system.debug(' objCase.Original_Queue_Name__c is '+objCase.Original_Queue_Name__c);
			system.debug(' objCase.Previous_Queue_Name__c is '+objCase.Previous_Queue_Name__c);

		}
	}

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 26 March 2020
     * @description: method to link contact to account //v1.69
     * @history:
    */
    public static void linkContactToAccount(list<Case> lstCases){
    	
		map<Id,Id> accountContactIdMap = new map<Id,Id>();
		set<Id> contactIds = new set<Id>();
		list<Contact> lstContacts = new list<Contact>();
		
		for(Case cse : lstCases){
			if(cse.AccountId != null && cse.ContactId != null){
				accountContactIdMap.put(cse.ContactId,cse.AccountId);
				contactIds.add(cse.ContactId);
			}			
		}
		
		for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id IN: contactIds]){
			if(con.AccountId == null && accountContactIdMap.containsKey(con.Id)){
				con.AccountId = accountContactIdMap.get(con.Id);
				lstContacts.add(con);
			}
		}
		
		if(lstContacts.size() > 0){
			update lstContacts;
		}
		
    }	

    /**
    * @author: Mark Anthony Pamintuan
    * @date: 3 June 2020
    * @description: method to populate Milestone target date on Case //v1.71
    * @history:                
    */
	@future    
    public static void populateMilestoneTargetDate(set<Id> setCaseIds){

		Id sfChangeRequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Change Request').getRecordTypeId();
	    Id sfIncidentsRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Incidents').getRecordTypeId();
		Id sfGenericRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Generic').getRecordTypeId();

        
		list<Case> lstNewCases = [SELECT Id, Milestone_Target_Date__c, RecordtypeId FROM Case WHERE Id IN: setCaseIds];
		map<Id, list<CaseMilestone>> caseMilestoneMap = new map<Id, list<CaseMilestone>>();
		set<String> milestoneTypeIDs = new set<String>();
		map<String,MilestoneType> milestoneTypeMap = new map<String,MilestoneType>();
        list<Case> casesToUpdateMilestoneTargetDate = new list<Case>();
		
        for(Case newCase : lstNewCases){
			caseMilestoneMap.put(newCase.Id, new list<CaseMilestone>());
        }
		
		list<CaseMilestone> lstCaseMilestones = [SELECT Id, CaseId, MilestoneTypeId, TargetDate FROM CaseMilestone WHERE CaseId IN: setCaseIds AND CompletionDate = null];
        if(lstCaseMilestones.size() > 0){
			for(CaseMilestone cm : lstCaseMilestones){
				milestoneTypeIDs.add(cm.MilestoneTypeId);
				if(caseMilestoneMap.containsKey(cm.CaseId)){
					caseMilestoneMap.get(cm.CaseId).add(cm);
				}	
			}

			for(MilestoneType mt : [SELECT Id, Name FROM MilestoneType WHERE Id IN: milestoneTypeIDs]){
				milestoneTypeMap.put(mt.Id, mt);
			}
			
			for(Case newCase : lstNewCases){
				if(caseMilestoneMap.containsKey(newCase.Id)){
					for(CaseMilestone cm : caseMilestoneMap.get(newCase.Id)){
						if(milestoneTypeMap.containsKey(cm.MilestoneTypeId)){
							MilestoneType mType = milestoneTypeMap.get(cm.MilestoneTypeId);
							if(mType.Name == 'In Progress' && newCase.RecordtypeId == sfChangeRequestRTId){
								newCase.Milestone_Target_Date__c = cm.TargetDate;
                                casesToUpdateMilestoneTargetDate.add(newCase);
							}
							
							if(mType.Name == 'Resolution' && (newCase.RecordtypeId == sfIncidentsRTId || newCase.RecordtypeId == sfGenericRTId)){
                                if(newCase.Milestone_Target_Date__c == null || newCase.Milestone_Target_Date__c != cm.TargetDate){
									newCase.Milestone_Target_Date__c = cm.TargetDate;
	                                casesToUpdateMilestoneTargetDate.add(newCase);
								}												
							}	
						}	
					}	
				}	
			}			
			
		}
        
        if(casesToUpdateMilestoneTargetDate.size() > 0){
            update casesToUpdateMilestoneTargetDate;
        }
        
    }  

    /**
     * @author: Mark Anthony Pamintuan
     * @date: 26 April 2021
     * @description: method to stamp Retail Store on Case
     * @history:
    */
    public static void stampRetailStore(list<Case> lstCases){

        set<Id> ownerIds = new set<Id>();
        map<Id,User> userIdMap = new map<Id,User>();

        for(Case cse : lstCases){
            ownerIDs.add(cse.OwnerId);
        }

        for(User u : [SELECT Id, Store__c FROM User WHERE Id IN: ownerIds]){
            if(string.IsNotEmpty(u.Store__c)){
                userIdMap.put(u.Id,u);
            }
        }

        for(Case c : lstCases){
            if(userIdMap.containsKey(c.OwnerId)){
                c.Current_Retail_Store__c = userIdMap.get(c.OwnerId).Store__c;
                if(string.IsEmpty(c.Retail_Store__c)){
                    c.Retail_Store__c = userIdMap.get(c.OwnerId).Store__c;
                }
            }
        }

    }
	
}