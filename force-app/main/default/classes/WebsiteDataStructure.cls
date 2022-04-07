global class WebsiteDataStructure {
    
    global class ServiceRequest{
        
        //Do Not change these parameters without consulting with TR team.
        global String Id;
        global String BookingId; //This is the DerwentId
        global String Subject;
        global String Status;
        global Boolean ReceiveTextAlert;
        global String SalesforceCaseId;
        global List<Note> Notes;

        global ServiceRequest(Case cse, List<Note> notes){
            this.Id = (String)cse.get('CaseNumber');
            this.BookingId = (String)cse.get('Org_Booking_Id__c');
            this.Subject = (String)cse.get('Subject');
            this.Status = (String)cse.get('Status');
            this.ReceiveTextAlert = (Boolean)cse.get('Receive_Text_Messages__c');
            this.Notes = notes;
             this.SalesforceCaseId  = (String)cse.get('Id');
        }
    }
    
    //Customer Communication mappings. 
    //Do not change this method unless consulting with TR. This can result in the integration breaking.
    global class Note{
        public String Text;
        public Boolean AddedByCustomer;
        public Boolean CustomerResponseRequired;
        public DateTime Created;
        public String AgentName;
        public Note(SObject sob){
            if((String)sob.get('Message__c') != null){ 
               String responseNote = (String)sob.get('Message__c'); 
                this.Text = responseNote.replaceall('\n', ' ');
                this.Text = responseNote.replaceall('\r', ' ');
            }         
            this.AddedByCustomer = (Boolean)sob.get('Created_By_Customer__c');
            this.CustomerResponseRequired = (Boolean)sob.get('Response_Required__c');
            this.Created = (DateTime)sob.get('CreatedDate');
            this.AgentName = (String)sob.get('Agent_Name__c');
        }
    }
    
    global class AutoCancellation {
       public Boolean Success;
    }

    global class CustomerCommunicationCreationParams{
        public String CaseNumber;
        public String Text;
    }

    global class CreateServiceRequestParams{
        public String BookingId;
        public String CategoryId;
        public Boolean ReceiveTextAlert;
        public String Subject;
        public String Text;
        public String DerwentId;
        public boolean CreatedByCustomer;
        public boolean CreatedByCancellation;
    }

    global class CaseIdResponse{
        global String CaseNumber;
        global String SalesforceCaseId; 
        global CaseIdResponse(String caseId,String salesforceId){
            this.CaseNumber = caseId;
            this.SalesforceCaseId = salesforceId;
        }
    }

    global class Category{
        global Integer CategoryId;
        global String Text;

        global Category(String catText, Decimal catId){
             this.CategoryId = Integer.valueOf(catId);
             this.Text = catText;
        }
    }
    
     global class BookingIdSalesforce{
        global String SalesforceBookingId;
        
        global BookingIdSalesforce(String bookingID){
            this.SalesforceBookingId = bookingID;
        }
    }

}