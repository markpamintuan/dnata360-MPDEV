/**************************************************************************************************
* Name               : CustomerResponse 
* Description        : This is the class generated for the json response for getting Customers          
* Created Date       : 08-Aug-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE   
* v1.0        Kaavya        08-Aug-2018    Initial version                                                          
* v1.1        Kaavya        17-Oct-2018    T-00185: Adding customer domain    
* v1.2        Kaavya        09-Oct-2019    T-00700,T-00695: Adding Culture Code, Created Date                                           
**************************************************************************************************/

public class CustomerResponse {

    public class Customers {
        public String CustomerId {get;set;}
        public Integer TenantId{get;set;}
        public String Email{get;set;}
        public String Title{get;set;}
        public String FirstName{get;set;}
        public String LastName{get;set;}
        public String CountryCode{get;set;}
        public String PostCode{get;set;}
        public String Address{get;set;}
        public String City{get;set;}
        public String County{get;set;}
        public String HomeTel{get;set;}
        public String MobileTel{get;set;}
        public String Notes{get;set;}
        public String LoyaltyId{get;set;}
        public String Nationality{get;set;}
        public Boolean SendTextAlerts {get;set;}
        public Boolean EmailSignup {get;set;}
        public String CultureCode{get;set;} //Added as part of V1.2
        public String LastRegisteredOnDomainId {get;set;} //Added as part of V1.1
        public List<CommunicationPreferenceDetails> CommunicationPreferenceDetails;
        public String Created{get;set;} //Added as part of V1.2
    }

    public class CommunicationPreferenceDetails {
        public String CommunicationChannel;
        public String Source;
        public String Reason;
        public String EventDate;
    }
    public List<Customers> Customers;
    public List<String> NotFoundCustomers;

    
    public static CustomerResponse parse(String json) {
        return (CustomerResponse) System.JSON.deserialize(json, CustomerResponse.class);
    }
}