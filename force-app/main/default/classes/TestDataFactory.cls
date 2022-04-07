/* v2.0       Keith        5-Nov-2019    Change Account Record Type Names For EKH */

@isTest
public class TestDataFactory{
    
    // Creating DTME account
    public static void createDTME_Account(){
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;
    }
    
    // Creating DTME account and Returning Account Id
    public static string createDTME_AccountId(){
        Account acc= new Account(lastname='DTME_Test1',PersonEmail='DTME_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('dTME_B2C Customer - New').getRecordTypeId());
        insert acc;
        return acc.id;
    }
     
    // Creating TRP account
    public static void createTRP_Account(){
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
    }
    
      // Creating TRP account and Returning Account Id
    public static string createTRP_AccountId(){
        Account acc= new Account(lastname='TRP_Test1',PersonEmail='TRP_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('TRP_B2C Customer - New').getRecordTypeId());
        insert acc;
        return acc.id;
    }
    // Creating EKUK account    
    public static void createEKUK_Account(){
        Account acc= new Account(lastname='EKUK_Test1',PersonEmail='EKUK_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId());
        insert acc;
    }
    
    // Creating EKUK account and Returning Account Id   
    public static string createEKUK_AccountId(){
        Account acc= new Account(lastname='EKUK_Test1',PersonMobilePhone='0123456778',PersonEmail='EKUK_Test1@gmail.com',PersonHomePhone='01234567789',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('EKH B2C Customer - New').getRecordTypeId()); //v2.0
        insert acc;
        return acc.id;
    }
    
    public static void createDTME_Case(){
        Case cse= new Case(recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId());
        insert cse;     
    }

    public static Booking__c createActiveBookingHeader(Id accountId){
        Booking__c book = new Booking__c();
        book.Org_Travel_Start_Date__c = System.today();
        book.Org_Travel_End_Date__c = System.today() + 7;
        book.Org_Booked_Date__c = System.today() - 1;
        book.Booking_Status__c = 'Active';
        book.Org_Account_Name__c = accountId;
        book.Name = 'Active Header test1234';
        book.recordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        return book;
    }

    public static void createCaseEKH(Id accountId){
        Case cse = new Case();
        cse.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKUK - Emails').getRecordTypeId();
        cse.AccountId = accountId;
        cse.Org_Case_Status__c = 'New';
        cse.Staff_Location__c = 'Dubai';
        insert cse;
        system.debug('### TestDataFactory createCaseEKH WITH CSE: ' + cse);
    }

    public static void createCaseEKHWithEmail(Id accountId){
        Case cse = new Case();
        cse.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EKUK - Emails').getRecordTypeId();
        cse.AccountId = accountId;
        cse.Org_Current_Team_Name__c = 'EKUK Queue';
        cse.Org_Case_Status__c = 'New';
        cse.Org_Email_From_Customer__c = true;
        insert cse;
        system.debug('### TestDataFactory createCaseEKHWithEmail WITH CSE: ' + cse);
    }

    public static Booking__c createActiveBooking(Id accountId, Id bookingHeaderId){
        Booking__c book = new Booking__c();
        book.Org_Travel_Start_Date__c = System.today();
        book.Org_Travel_End_Date__c = System.today() + 7;
        book.Org_Booked_Date__c = System.today() - 1;
        book.Org_Account_Name__c = accountId;
        book.Booking_Status__c = 'Active';
        book.Booking_Header__c = bookingHeaderId;
        book.Name = 'Line Items test1234';
        book.recordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        return book;
    }

    public static Booking__c createHistoricBookingHeader(Id accountId){
        Booking__c book = new Booking__c();
        book.Org_Travel_Start_Date__c = System.today() - 20;
        book.Org_Travel_End_Date__c = System.today() - 10;
        book.Org_Booked_Date__c = System.today() - 25;
        book.Org_Account_Name__c = accountId;
        book.Name = 'Header test1234';
        book.recordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking Header').getRecordTypeId();
        return book;
    }

    public static Booking__c createHistoricBooking(Id accountId, Id bookingHeaderId){
        Booking__c book = new Booking__c();
        book.Org_Travel_Start_Date__c = System.today() - 20;
        book.Org_Travel_End_Date__c = System.today() - 10;
        book.Org_Booked_Date__c = System.today() - 25;
        book.Org_Account_Name__c = accountId;
        book.Booking_Header__c = bookingHeaderId;
        book.Name = 'Line Items test1234';
        book.recordtypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        return book;
    }

    public static void createEntitlement(Id accountId, Id businessHoursId){
        Entitlement ent = new Entitlement();
        ent.Name = 'dnata Entitlement';
        ent.BusinessHoursId = businessHoursId;
        ent.AccountId = accountId;
        insert ent;
    }
	
     public static void createTRPEntitlement(Id accountId, Id businessHoursId){
        Entitlement ent = new Entitlement();
        ent.Name = 'TR Entitlement';
        ent.BusinessHoursId = businessHoursId;
        ent.AccountId = accountId;
        insert ent;
    }

    public static void createBusinessUnitRecordsEKH(Id businessHoursId){
        map<String, Schema.RecordTypeInfo> mBusUnitRT = Schema.SObjectType.Business_Unit__c.getRecordTypeInfosByName();
        Business_Unit__c busUnitParent = new Business_Unit__c();
        busUnitParent.Name = 'EKUK';
        busUnitParent.RecordTypeId = mBusUnitRT.get('Business Unit').getRecordTypeId();
        busUnitParent.Org_Brand__c = 'EKH';
        busUnitParent.Org_Region__c = 'UK';
        insert busUnitParent;
        system.debug('### createBusinessUnitRecordsEKH busUnitParent: ' + busUnitParent);


        //insert SLA
        Business_Unit__c busUnitSLA = new Business_Unit__c();
        busUnitSLA.Name = 'Email Response - EKUK';
        busUnitSLA.Org_SLA_Type__c = 'Email';
        busUnitSLA.SLA_Hrs__c = 24.00;
        busUnitSLA.Org_SLA_Mins__c = 1440.00;
        busUnitSLA.RecordTypeId = mBusUnitRT.get('SLA').getRecordTypeId();
        busUnitSLA.Org_Brand__c = 'EKH';
        busUnitSLA.Org_Queue_Name__c = 'EKUK Queue';
        busUnitSLA.Org_Business_Unit_SLA__c = busUnitParent.Id;
        insert busUnitSLA;

        //insert SLA
        Business_Unit__c busUnitEmail= new Business_Unit__c();
        busUnitEmail.Name = 'Email Response - EKUK';
        busUnitEmail.Org_SLA_Type__c = 'Email';
        busUnitEmail.SLA_Hrs__c = 24.00;
        busUnitEmail.Org_SLA_Mins__c = 1440.00;
        busUnitEmail.RecordTypeId = mBusUnitRT.get('Email').getRecordTypeId();
        busUnitEmail.Org_Brand__c = 'EKH';
        busUnitEmail.Org_Queue_Name__c = 'EKUK Queue';
        busUnitEmail.Org_Business_Unit_SLA__c = busUnitParent.Id;
        insert busUnitEmail;

        //insert SLA
        Business_Unit__c busUnitTeam = new Business_Unit__c();
        busUnitTeam.Name = 'Email Response - EKUK';
        busUnitTeam.Org_SLA_Type__c = 'Email';
        busUnitTeam.SLA_Hrs__c = 24.00;
        busUnitTeam.Org_SLA_Mins__c = 1440.00;
        busUnitTeam.RecordTypeId = mBusUnitRT.get('Team').getRecordTypeId();
        busUnitTeam.Org_Brand__c = 'EKH';
        busUnitTeam.Queue_ID__c = '000123456780';
        busUnitTeam.Org_Queue_Name__c = 'EKUK Queue';
        busUnitTeam.Org_Business_Unit_SLA__c = busUnitParent.Id;
        insert busUnitTeam;
    }



    public static void createCSR(Id bookingId){
        CSR__c csr = new CSR__c();
        csr.Status__c = 'In Progress';
        csr.Booking_ID__c = bookingId;
        insert csr;
        system.debug('#### csr: ' + csr);
    }

    public static Itinerary__c createItinerary(Id bookingId){
        Itinerary__c itin = new Itinerary__c();
        itin.Org_Booking__c = bookingId;
        itin.Org_Start_Date__c = System.today() - 40;
        itin.Org_End_Date__c = System.today()  + 1;
        return itin;

    }

    public static Itinerary_Detail__c createItineraryDetail(Id itineraryId){
        Itinerary_Detail__c itinDetail = new Itinerary_Detail__c();
        itinDetail.Itinerary__c = itineraryId;
        itinDetail.Org_Check_In__c = System.today() - 40;
        itinDetail.Org_Check_Out__c = System.today()  + 1;
        itinDetail.Itinerary_Detail_Type__c = 'Segment';
        return itinDetail;

    }

     /*public static GetFeedback_Aut__Survey__c createPostTravelSurvey(Decimal feedbackId){
        GetFeedback_Aut__Survey__c survey = new GetFeedback_Aut__Survey__c();
        survey.Name = 'Post Travel Test Survey';
        survey.GetFeedback_Aut__GetFeedbackId__c = feedbackId;
        insert survey;
        return survey;

    }

    public static GetFeedback_Aut__Survey__c createPostBookSurvey(Decimal feedbackId ){
        GetFeedback_Aut__Survey__c survey = new GetFeedback_Aut__Survey__c();
        survey.Name = 'Post Booking Test Survey';
        survey.GetFeedback_Aut__GetFeedbackId__c = feedbackId;
        insert survey;
        return survey;
    }

    public static GetFeedback_Aut__Response__c createResponse(Id accountId, Id bookingId, Id surveyId, Decimal feedbackId){
        GetFeedback_Aut__Response__c resp = new GetFeedback_Aut__Response__c();
        resp.GetFeedback_Aut__Account__c = accountId;
        resp.GetFeedback_Aut__GetFeedbackId__c = feedbackId;
        resp.Booking__c = bookingId;
        resp.GetFeedback_Aut__Survey__c = surveyId;
        insert resp;
        return resp;
    }

    public static void createAnswer(Id responseId, String feedbackID){
        GetFeedback_Aut__Answer__c ans = new GetFeedback_Aut__Answer__c();
        ans.GetFeedback_Aut__GetFeedbackId__c = feedbackID;
        ans.GetFeedback_Aut__Response__c = responseId;
        ans.GetFeedback_Aut__Number__c = 3.0;
        ans.GetFeedback_Aut__QuestionType__c = 'NetPromoter';
        insert ans;
    } */
    
    public static Survey_Response__c createPostBookingSurveyResponse(Id accountId, Id bookingId, Decimal rating) {
        Survey_Response__c surveyResponse = new Survey_Response__c();
        surveyResponse.Org_Account__c = accountId;
        surveyResponse.Org_Booking__c = bookingId;
        surveyResponse.Org_Customer_Journey__c = 'Post Booking';
        surveyResponse.Org_Survey_Model__c ='NPS B2C Post Booking';
        surveyResponse.Org_Rating__c = rating;
        insert surveyResponse;
        return surveyResponse;
    }

    public static Survey_Response__c createPostTravelSurveyResponse(Id accountId, Id bookingId, Decimal rating) {
        Survey_Response__c surveyResponse = new Survey_Response__c();
        surveyResponse.Org_Account__c = accountId;
        surveyResponse.Org_Booking__c = bookingId;
        surveyResponse.Org_Customer_Journey__c = 'Post Travel';
        surveyResponse.Org_Rating__c = rating;
        surveyResponse.Org_Survey_Model__c ='NPS B2C Post Travel';
        insert surveyResponse;
        return surveyResponse;
    }
}