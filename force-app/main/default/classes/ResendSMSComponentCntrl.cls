public class ResendSMSComponentCntrl {
	@AuraEnabled
    public static void resendSMS(string recordId){
        List<Customer_Communication__c> lstCustomer = [select id,Send_SMS__c,Message__c,Service_Request__c,SMS_Batch_Id__c from Customer_Communication__c where id = :recordid];
        if(Label.Allow_Send_SMS == 'true'){
            system.debug('\n--lstCustomer--'+lstCustomer);
            
            // saving the case id which will be used get the client phone
            set<id> setCase = new set<id>();
            List<Id> lCasesIds = new List<Id>();
            
            // this will have the record which has to be processed
            List<Customer_Communication__c> lstProcessProcess = new List<Customer_Communication__c>();
            
            // for each record is created 
            for(Customer_Communication__c CC : lstCustomer){
                
                // checking if the SMS check is send 
                // Added by SB
               /* if(CC.Send_SMS__c == false){
                    // saving case id
                    setCase.add(CC.Service_Request__c);
                    
                    // saving CC records
                    lstProcessProcess.add(CC);
                }*/
                if(CC.Send_SMS__c
                    && cc.Message__c != null){
                    
                    // saving case id
                    setCase.add(CC.Service_Request__c);
                    
                    // saving CC records
                    lstProcessProcess.add(CC);
                }
                lCasesIds.addAll(setCase); //Add all cases to the list for the query
            }
            system.debug('\n---setCase--'+setCase+'\n--lstProcessProcess--'+lstProcessProcess);
            
            // checking if we have the records for which SMS has to be send
            if(!lstProcessProcess.isEmpty()){
                
                // this will save the message details to be sent
                List<SMSWrapper.MessageWrapper> lstMessageDetails = new List<SMSWrapper.MessageWrapper>();
                
                // gettig phone number
                map<id,case> mapCaseRecord = new map<id,case>([SELECT ID,
                                                                        Contact.Phone,
                                                                        Org_Booking__r.Mobile__c,
                                                                        Org_Booking__r.Org_First_Name__c,
                                                                        Org_Booking_Id__c,
                                                                        Org_Booking__r.Name,
                                                                        ContactId
                                                                    FROM Case
                                                                    WHERE Id IN: lCasesIds ]);
                system.debug('\n--mapCaseRecord--'+mapCaseRecord);
               
                // for each record for which we have to send the SMS
                for(Customer_Communication__c CC : lstProcessProcess){
                    
                    if(mapCaseRecord.containsKey(CC.Service_Request__c)){
                        case casRec = mapCaseRecord.get(CC.Service_Request__c);
                        system.debug('\n--casRec--'+casRec);
                        
                        /*
                        // checking if the phone number is present
                        if(casRec.ContactId != null
                            && casRec.Contact.Phone != null){
                                
                            // making list if message wrapper
                            lstMessageDetails.add(new SMSWrapper.MessageWrapper(string.valueOf(casRec.Org_Booking__r.Mobile__c),CC.Message__c));
                                
                        }
                        */
                        
                        //NEED A WAY TO ONLY SEND MESSAGES TO CERTAIN NUMBERS IN PRODUCTION..IDEA IS TO USE THE WFR that is being used for email at the moment.
                        // checking if the phone number is present on Booking/ Reuqirement to be decided where this is coming from. (case, Account, Booking)
                        
                        //Should only send SMS's for outgoing messages to the customer.
                        //Depending on how the customer opts in for SMS when creating an SMS, we may need to default text messages being sent based on Case
                        // The message needs to be different depending on Ireland/ Uk customers.
                        //This is a reminder to fix the UI of the emails.
                        String mobileNumber = '';
                        if(Label.Send_SMS_Number == 'test'){
                            mobileNumber = 'test';
                        }else{
                            mobileNumber = casRec.Org_Booking__r.Mobile__c;
                        }
                        //if(casRec.Org_Booking__r.Mobile__c != null && casRec.Org_Booking__r.Mobile__c=='+353864034983'){
                            String message = 'Hi ' + casRec.Org_Booking__r.Org_First_Name__c + 
                                            '. There is an update by an agent on your booking ' + casRec.Org_Booking__r.Name + '.' +
                                            'Please log into the Manage Your Booking section of the website at www.travelRepublic.co.uk.' + 
                                            'From Travel Republic Support.';
                            // making list if message wrapper
                            lstMessageDetails.add(new SMSWrapper.MessageWrapper(string.valueOf(mobileNumber),message));
                                
                        //}
                        
                    }       	
                }
                system.debug('\n--lstMessageDetails--'+lstMessageDetails);
                	
                // making json to be send to esendex
                if(!lstMessageDetails.isEmpty()){
                    
                    // code to send SMS
                    SMSWrapper SMSObj = new SMSWrapper(label.SMS_Account_Ref,lstMessageDetails);
                    string Json = JSON.serialize(SMSObj);
                    system.debug('\n--Json--'+Json);
                    
                    // making the request to send SMS
                    // SMSUtility.sendSMS_Method(Json)
                    
                   system.enqueueJob(new SMSUtility(Json,lstCustomer));
                    
                }
            }
    	}
    }
}