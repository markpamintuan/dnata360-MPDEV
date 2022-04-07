public class SurveyResponseTriggerHandler {

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 29 January 2019
	 * @description: method for before insert trigger event
	 * @history:                
	 */
    public static void onBeforeInsert(List<Survey_Response__c> lstSurveyResponses) {  
    	//reparentResponses(lstSurveyResponses);    
		//linkPostChatSurveyResponse(lstSurveyResponses);
    }

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 13 September 2020
	 * @description: method for after insert trigger event
	 * @history:                
	 */
    public static void onAfterInsert(List<Survey_Response__c> lstSurveyResponses) {

		set<Id> marhabaResponseIDs = new set<Id>();

		for(Survey_Response__c sResponse : lstSurveyResponses){
			if(string.IsNotEmpty(sResponse.Survey_Group__c) && (sResponse.Survey_Group__c == 'marhaba' || sResponse.Survey_Group__c == 'marhaba Contact Centre' || sResponse.Survey_Group__c == 'marhaba Sales' || sResponse.Survey_Group__c == 'marhaba Online')){
				marhabaResponseIDs.add(sResponse.Id);
			}
		}
		
		if(!marhabaResponseIDs.isEmpty()){
			reparentResponses(marhabaResponseIDs);
		}
    	    
    }

	/**
	* @author: Keith Rogers
	* @date: 29 January 2019
	* @description: Link Post Chat Survey Response with Chat Transcript and Account
	* @history:                
	*//*
    public static void linkPostChatSurveyResponse(List<Survey_Response__c> newSR){ 
		List<LiveChatTranscript> lChatTranscript = new List<LiveChatTranscript>();
		List<String> lChatKeys = new List<String>();
		Map<String, Id> mChatKeyLiveChatTranscriptId = new Map<String,Id>();
		Map<String, Id> mChatKeyAccountId = new Map<String,Id>();

		for(Survey_Response__c sResponse: newSR){
			if(sResponse.Chat_Key__c != null){
				lChatKeys.add(sResponse.Chat_Key__c);
			}
		}

		if(lChatKeys.size()>0){
			for(LiveChatTranscript lchatTrans: [	SELECT 	Id, 
															AccountId, 
															CaseId,
															ChatKey
													FROM LiveChatTranscript 
													WHERE ChatKey IN:lChatKeys]){
				mChatKeyLiveChatTranscriptId.put(lchatTrans.ChatKey, lchatTrans.Id);
				mChatKeyAccountId.put(lchatTrans.ChatKey, lchatTrans.AccountId);
			}
			
		}
		
		if(mChatKeyAccountId.size() > 0 || mChatKeyAccountId.size() >0){ //If any of the maps are popualated
			for(Survey_Response__c sResponse: newSR){
				//populate the live chat lookup
				if(mChatKeyLiveChatTranscriptId.get(sResponse.Chat_Key__c) != null) 
					sResponse.Org_Live_Chat_Transcript__c = mChatKeyLiveChatTranscriptId.get(sResponse.Chat_Key__c);
				
				//populate the Account lookup
				if(mChatKeyAccountId.get(sResponse.Chat_Key__c) != null) 
					sResponse.Org_Account__c = mChatKeyAccountId.get(sResponse.Chat_Key__c);
		}
		}


		
	}*/

	/**
	 * @author: Mark Anthony Pamintuan
	 * @date: 29 January 2019
	 * @description: populate survey response's fields and create parent survey sent record
	 * @history:                
	 */
	@future
    public static void reparentResponses(set<Id> sResponseIDs) { 
        
		list<Survey_Response__c> sResponseToUpdate = new list<Survey_Response__c>();
		map<String,Account> responseIdAccountMap = new map<String,Account>();
		set<Id> accountIDs = new set<Id>();
		map<Id,Account> accountIdMap = new map<Id,Account>();
		list<Survey_Response__c> sResponseList = [SELECT Id, 
														Org_Account__c,
														Survey_Date__c,
														Survey_Count__c, 
														Booking_Reference__c
													FROM Survey_Response__c 
													WHERE Id IN: sResponseIDs];

		for(Survey_Response__c surveyResp : sResponseList){
			if(string.IsNotEmpty(surveyResp.Org_Account__c)){
				accountIDs.add(surveyResp.Org_Account__c);
			}
		}
		
		if(!accountIDs.isEmpty()){
			for(Account acc : database.query(CRK_UtilityClass.constructQueryString('Account', 'Id =: accountIDs'))){
				accountIdMap.put(acc.Id,acc);
			}
		}

		for(Survey_Response__c sResp : sResponseList){
			if(accountIdMap.containsKey(sResp.Org_Account__c)){
				responseIdAccountMap.put(sResp.Id,accountIdMap.get(sResp.Org_Account__c));
			}
		}

		for(Survey_Response__c sResponse : sResponseList){
			Survey_Sent__c ss = new Survey_Sent__c();
			if(responseIdAccountMap.containsKey(sResponse.Id)){
				Account customer = responseIdAccountMap.get(sResponse.Id);
				sResponse.Survey_Date__c = customer.Survey_Date__pc;
				sResponse.Survey_Count__c = customer.Survey_Count__pc;
				sResponse.Booking_Reference__c = customer.Booking_Reference__pc;
				
				String sName = sResponse.Survey_Name__c;
				String sSurveyGroup = sResponse.Survey_Group__c;
				Decimal sCount = customer.Survey_Count__pc;
				Date sDate = sResponse.Survey_Date__c; 				

				try{
					ss = database.query(CRK_UtilityClass.constructQueryString('Survey_Sent__c', 'Survey_Name__c =: sName AND Survey_Group__c =: sSurveyGroup AND Survey_Count__c =: sCount AND Survey_Date__c =: sDate LIMIT 1'));                
					sResponse.Survey_Sent__c = ss.Id;                
				}catch (exception e){
					ss.Survey_Name__c = sName;
					ss.Survey_Group__c = sSurveyGroup;
					ss.Survey_Count__c = sCount;
					ss.Survey_Date__c = sDate;
					insert ss;
					sResponse.Survey_Sent__c = ss.Id;                    
				}
				sResponseToUpdate.add(sResponse);
			}
		}

		if(sResponseToUpdate.size() > 0){
			update sResponseToUpdate;
		}

		/*
        set<String> setLOB = new set<String>();
        set<String> setSurveyName = new set<String>();
        set<Date> setSurveyDate = new set<Date>();        
        set<String> contactIds = new set<String>();

        for(Survey_Response__c sr: newSR){     
        	if(string.IsNotEmpty(sr.Survey_Group__c) && (sr.Survey_Group__c == 'marhaba' || sr.Survey_Group__c == 'marhaba Contact Centre' || sr.Survey_Group__c == 'marhaba Sales' || sr.Survey_Group__c == 'marhaba Online')){
	            String customerID = sr.Org_Account__c;
	            Survey_Sent__c ss = new Survey_Sent__c();
	            Account customer = new Account();
	            
	            try{
	            	customer = database.query(CRK_UtilityClass.constructQueryString('Account', 'Id =: customerID LIMIT 1'));
	            	sr.Survey_Date__c = customer.Survey_Date__pc;
	            	sr.Survey_Count__c = customer.Survey_Count__pc;
	            	sr.Booking_Reference__c = customer.Booking_Reference__pc;
	            }catch (exception e){
	            	system.debug(e.getMessage());
	            }
	            
	            
	            String sName = sr.Survey_Name__c;
	            String sSurveyGroup = sr.Survey_Group__c;
	            Decimal sCount = customer.Survey_Count__pc;
	            Date sDate = sr.Survey_Date__c; 
	            
	            try{
	                ss = database.query(CRK_UtilityClass.constructQueryString('Survey_Sent__c', 'Survey_Name__c =: sName AND Survey_Group__c =: sSurveyGroup AND Survey_Count__c =: sCount AND Survey_Date__c =: sDate LIMIT 1'));                
	                sr.Survey_Sent__c = ss.Id;                
	            }catch (exception e){
	                ss.Survey_Name__c = sName;
	                ss.Survey_Group__c = sSurveyGroup;
	                ss.Survey_Count__c = sCount;
	                ss.Survey_Date__c = sDate;
	                insert ss;
	                sr.Survey_Sent__c = ss.Id;                    
	            }
        	}
 
        }
		*/
	}
  
    
    
}