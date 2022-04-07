/*****
 * Name         :   SMSWrapper
 * Description  :   This class is used make json for SMS Integration which will be used bu other class
 *                  Customer_CommunicationHelper
 ****/
public class SMSWrapper {
    
    // this will constact as it will given by esendex
    public string accountreference {get;set;}
    
    // this will be used to save the SMS Details
    public List<MessageWrapper> messages {get;set;}
    
    
    // contructor
    public SMSWrapper(string accountreference, List<MessageWrapper> messages){
        
        // saving constant given by esendex
        this.accountreference = accountreference;
        
        // saving message details
        this.messages = messages;
    }
    
    // This class will be used to save messgae to send ph. numbers
    public Class MessageWrapper{
        
        // this will be used save number
        public string to {get;set;}
        
        // this will used to save the body
        public string body {get;set;}
        
        //Customer Communication Id
        public string ccid{get;set;}
        
        public MessageWrapper(string to, string body){
            this.body = body;
            this.to = to;
            
        }
    }
    
}