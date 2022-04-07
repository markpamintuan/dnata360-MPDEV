/**************************************************************************************************
* Name               : QuotesController 
* Description        : This is the quotes class where new Quotes are created and updated.           
* Created Date       : 09-May-2018                                                                 
* Created By         : Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Evendo        08-Aug-2018    Initial version
* v1.1        Sri Bala      27-Nov-2018    T-00302 -  Flight Class on Quotation
* v1.2        Sri Bala      16-Dec-2018    T-00312 -  Flight Dates sorting on quotation page
* v1.3        Sri Bala      23-Jan-2018    T-00387 -  Hotel Dates sorting on Quotation page
* v1.4        Sri Bala      14-Mar-2019    T-      -  Flight total package cost
* v1.5        Maruf         14-Mar-2019    T-00501 -  Follow up task should be mandatory field for quotation sent stage
* v1.6        Sri Bala      11-Jul-2019    Disable Errata for TRP and Populating Rooms and Brand for TRP
* v1.7        Sri Bala      14-Jul-2019    To insert notes into quote option for TRP
* v1.8        Sri Bala      06-Aug-2018    Populating TRP Email Template Merge values
* v1.9        Mark			06-Aug-2019	   T-00675 -  Fixed lock row error on saving quote
* v1.11	      Mark			23-Oct-2019	   T-00786 - applied changes on email template on send email screen
* v1.12       Sri Bala      03-Nov-2019    Bug fix of v1.11
* v1.13       Sri bala      24-Nov-2019    Fix for is valid price
* v1.14		  Mark			10-Dec-2019	   T-00811 - fixed Quote option's price field population
* v1.15		  Mark			13-Feb-2020	   T-00970 - made store contact number displayed on email and store email as from address
**************************************************************************************************/
 

public class QuotesController {
    
    public Map<Integer,Decimal> totalAmount{get;set;}
    public boolean priceisvalid{get;set;}
    
    public integer myMapSize { get { return mapQuoteItems.size( ); } }
    public String getDisclaimer{get;set;}
    public void setDisclaimer(){ 
        if(header.id != null){
            quote_header__c disc = [select disclaimer__c from quote_header__c where id = :header.id]; 
           
            getDisclaimer = disc.Disclaimer__c;
             system.debug(getDisclaimer);
        }
    }
    public boolean sentmail{get;set;}
    public Case parentRecord {get;set;}
    public Decimal Flight_Package_Cost{get;set;}//added as a part v1.4
    public Decimal totalFlightPrice{get;set;} //added as a part of v1.4
    public String Notes{get;set;}//added as a part of v1.7
    public CaseDetail caseDetails {get;set;}
    public List<AgeDetail> ageDetails {get;set;}
    public List<Quote_Product_Segment__c> prodSegments {get;set;}
    public Quote_Header__c header {get;set;}
    public String headerId {get;set;}
    public List<Quote_Option__c> lstOptions {get;set;}
    public List<Quote_Line_Item__c> lstLineItems {get;set;}
    
    public Map<Integer, Decimal> totalOptionAmount {get;set;}
    public Map<Integer, Decimal> totalOptionflightPrice  {get;set;} //added as a part of v1.4
    public Map<Integer, List<Quote_Line_Item__c>> mapQuoteItems {get;set;}

    public Map<Integer, List<Quote_Line_Item__c>> mapQuoteOptionWithItems {get;set;}
    
    public Quote_Line_Item__c airline {get;set;}
    public Quote_Line_Item__c hotel {get;set;}
    public Quote_Line_Item__c other {get;set;}
    public List<SelectOption> flightClasslist{get;set;}
    public String selectedFilterValue{get;set;} //Added by Sri Bala
    public Boolean editQuote{get;set;}
    public Case pageRecord {get;set;}
    public String totalPrice {get;set;}
    public String childAges {get;set;}
    public String tailormadeItinerary {get;set;}//jed T-00413
    public String qOptionId {get;set;}//jed T-00413
        
    public String activeTab {get;set;}
    
    public String disclaimer {get;set;}
    
    public string lineItemRecordId {get;set;}
    public string lineItemRecordType {get;set;}
    public String currentOptionCount {get;set;}
    public String totalOptionCount {get;set;}
    public String recCurrency {get;set;}
    
    public String caseId {get;set;}
    
    public String selectedTab {get;set;}
    public Map<String, String> mapTabs {get;set;}
    public String emailHtml{get; set;}
    public Boolean isClone{get; set;}
    public Boolean removeFPC{get;set;} //added by SB
    public Boolean showHideEmailPopup{get; set;}
    public Decimal totalPriceValue{get;set;} //v1.13
    public map<String,Decimal> mapTotalPriceRollup {get; set;} //v1.14
    
    public void isPriceValid(){
        if(totalPrice == ''){
            totalPrice = '0';
         }
        system.debug('totalAmount >>>>>  '+totalAmount.get(Integer.valueOf(currentoptionid)));
        system.debug('totalPriceValues >>>>> '+totalPriceValue);
        system.debug('setFPCflag >>>>> '+ setFPCflag);
        system.debug((totalAmount.get(Integer.valueOf(currentoptionid)) == totalPriceValue));
        // Modified as a part of v1.13
        if((totalAmount.get(Integer.valueOf(currentoptionid)) == totalPriceValue) && !setFPCflag )
             priceisvalid = true;
        else if(totalPriceValue != totalAmount.get(Integer.valueOf(currentoptionid)))
            priceisvalid = false;
        system.debug('priceisvalid >>>>> '+priceisvalid);
        //end of v1.13
    }
    
    public void addAmount(Quote_Line_Item__c item, String currid){
        totalAmount.put(Integer.valueof(currid),(item.dtme_price__c + totalAmount.get(Integer.valueOf(currid))));
        system.debug('IF Price Total '+totalAmount);
        totalPrice = String.valueOf(totalAmount);
        system.debug('rollup'+rollup);
        if(totaloptionFlightPrice.get(Integer.valueOf(currentoptionid)) > 0)
        	totaloptionamount.put(Integer.valueOf(currid),( totaloptionFlightPrice.get(Integer.valueOf(currentoptionid)) + (totalAmount.get(Integer.valueOf(currid)) -  rollup)) );
        else{
            system.debug('entered');
            system.debug('totalAmount'+totalAmount);
             totaloptionamount.put(Integer.valueOf(currid),totalAmount.get(Integer.valueOf(currid)));
        }
        totalPriceValue = totalAmount.get(Integer.valueOf(currid));  
        System.debug(totaloptionamount);
    }
    
 //   public void totalAmounts(){
   //     List<Quote_Line_Item__c> QuoteItems = 
     //   
    //}
    //added by SB
    public Boolean showContent{get;set;}
    public boolean oneditFPC{get;set;}
     public PageReference toggleContent() {
         system.debug('showContent'+showContent);
         system.debug('edit'+oneditFPC);
        //If the showContent variable is true, set it to false, else, set it to true
        if(showContent){
      
            showContent = false;
            oneditFPC = true;
            showFPCButton = true;
                     system.debug('showContent'+showContent);

        }
        else{
       
            oneditFPC = false;
            showContent = true;
            showFPCButton = false;
        }
        return null;
    }
    //end
    public List<SelectOption> currencyOptions {
        set;get{
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult =
                Quote_Option__c.CurrencyIsoCode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                options.add(new SelectOption(f.getValue(), f.getValue()));
            }       
            return options;
        }
    }    
    
     //Added as a part of v1.1
     public List<SelectOption> getflightOptions() {
            List<SelectOption> Classoptions = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Quote_Line_Item__c.Flight_Class__c.getDescribe();
            system.debug('values:'+fieldResult);
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                Classoptions.add(new SelectOption(f.getValue(), f.getValue()));
            }       
            return Classoptions;
    }   
    
    public List<SelectOption> getAge() {
            List<SelectOption> Ageoptions = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Quote_Traveller__c.Age_of_child__c.getDescribe();
            system.debug('values:'+fieldResult);
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                Ageoptions.add(new SelectOption(f.getValue(), f.getValue()));
            }       
            return Ageoptions;
    }   
    //added by sribala
    public List<SelectOption> getflightpriceOption() {
            List<SelectOption> flightoptions = new List<SelectOption>();
            flightoptions.add(new SelectOption('--None--','--None--'));
            flightoptions.add(new SelectOption('Individual Price','Individual Price'));
            flightoptions.add(new SelectOption('Flight Package cost','Flight Package Cost'));
            return flightoptions;
    }   
    public pageReference specifyAction(){
       
        airline.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
        airline.dtme_price__c = 0;
        system.debug('airline.dtme_price__c'+airline.dtme_price__c);    
        updateData(airline.Id);
        system.debug('flightoption'+selectedFilterValue);
        return null;
    }
    public boolean flag{get;set;}
    public boolean validateOtherDetails(){
         flag = true;
      /*  if(other.Other_Service_Type__c == null || other.Other_Service_Type__c == '--None--'){
            other.Other_Service_Type__c.addError('Please enter the required detail');
            flag = false;
        } */
       // if(other.dtme_price__c == null){
         //   other.dtme_price__c.addError('Please enter the price');
           // flag = false;
       // }
        return flag;
    }
    
    public boolean validateHotelDetails(){
        boolean flag = true;
        
       /// if(hotel.Hotel_Name__c == null || hotel.Hotel_Name__c == '' || hotel.Check_In__c == null || hotel.Check_Out__c == null){
          //  ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please enter the required fields for hotel.'));
        //}
        if(hotel.Hotel_Name__c == null || hotel.Hotel_Name__c == ''){
            hotel.Hotel_Name__c.addError('Please enter the required detail(s)');
            flag = false;
        }
        if(hotel.Check_In__c == null ){
            hotel.Check_In__c.addError('Please enter the required detail(s)');
            flag = false;
        }
        if(hotel.Check_Out__c == null ){
            hotel.Check_Out__c.addError('Please enter the required detail(s)');
            flag = false;
        } 
        if(hotel.Check_In__c > hotel.Check_Out__c){
            hotel.Check_Out__c.addError('You cannot checkout before the check in date.');
            flag = false;
        }
        
     //   if(hotel.dtme_price__c == null){
       //     hotel.dtme_price__c.addError('Please Enter the price');
         //   flag = false;
        //}
        return flag;
    }
    
    public boolean validateFlightDetails(){
        boolean flag = true;
        Decimal flghtPrc = totaloptionFlightPrice.get(Integer.valueOf(currentOptionId));
        //if(airline.Airline__c == null || airline.Airline__c == '--None--' || airline.From__c == null || airline.From__c == '' || airline.To__c == null || airline.To__c == '' || airline.Departure_Date_Time__c == null || airline.Arrival_Date_Time__c == null || airline.Arrival_Date_Time__c == airline.Departure_Date_Time__c ||){}
        
        if(airline.Airline__c == null || airline.Airline__c == '--None--'){
            airline.Airline__c.addError('Please enter the required detail(s)'); flag = false;
        }
        
     //   if(airline.Flight_No__c == null || airline.Flight_No__c == '--None--'){
       //     airline.Flight_No__c.addError('Please enter the required detail(s)'); flag = false;
        //}
        
        if(airline.From__c == null || airline.From__c == ''){
            airline.From__c.addError('Please enter the required detail(s)'); flag = false;
        }
        
        if(airline.To__c == null || airline.To__c == ''){
            airline.To__c.addError('Please enter the required detail(s)'); flag = false;
        }
        
        if(airline.Departure_Date_Time__c == null ){
            airline.Departure_Date_Time__c.addError('Please enter the required detail(s)'); flag = false;
        }
        
        if(airline.Arrival_Date_Time__c == null ){
            airline.Arrival_Date_Time__c.addError('Please enter the required detail(s)'); flag = false;
        }
        
        //if(airline.Arrival_Date_Time__c == airline.Departure_Date_Time__c){
          //  airline.Departure_Date_Time__c.addError('Departure Date/Time Cannot be the same as Arrival Date/Time'); flag =false;
        //}
        
        if(airline.From__c == airline.To__c && airline.To__c != null && airline.From__c != null && airline.From__c != '' && airline.To__c != ''){
            airline.To__c.addError('Destination and Arrival locations cannot be the same'); flag =false;
        }

         if(airline.Arrival_Date_Time__c <= airline.Departure_Date_Time__c){
            airline.Departure_Date_Time__c.addError('Arrival Date/Time should be greater than Departure Date/Time'); flag =false;
        }
        
        if(airline.Arrival_Date_Time__c < Date.today()){
            airline.Arrival_Date_Time__c.addError('Arrival date cannot be before todays date'); flag=false;
        }
        
        if(airline.Departure_Date_Time__c < Date.today()){
            airline.Departure_Date_Time__c.addError('Departure date cannot be before todays date'); flag=false;
        }
        
        
        if(airline.dtme_price__c > 0 && flghtPrc >0){
          //airline.dtme_price__c.addError('Please enter either flight price or flight package cost');flag = false;
        }
        
        if(Rollup > 0 && flghtPrc >0){
           //airline.dtme_price__c.addError('Please enter either flight price or flight package cost');flag = false;
        }
       
        // if(airline.dtme_price__c == null){
         //   airline.dtme_price__c.addError('Please Enter the price');
          //  flag = false;
        //}
        return flag;
    }
   
    public void editLineItem(){
        if(lineItemRecordId != null && lineItemRecordId != ''){
            
            List<List<Quote_Line_Item__c>> lstQItems = mapQuoteItems.values();
            Map<String, Quote_Line_Item__c> qItems = new Map<String, Quote_Line_Item__c>();
            if(lstQItems != null){
                for(Integer k : mapQuoteItems.keySet()){
                    for(Quote_Line_Item__c q : mapQuoteItems.get(k)){
                        qItems.put(q.Id, q) ;
                    }
                }
            }
            
            if(lineItemRecordType == 'Flight'){
                airline = qItems.get(lineItemRecordId);
                if(totaloptionFlightPrice.get(Integer.valueOf(currentoptionid)) != 0 && totalAmount.get(Integer.valueof(currentoptionid)) >= totaloptionFlightPrice.get(Integer.valueOf(currentoptionid))){
                    totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - totaloptionFlightPrice.get(Integer.valueOf(currentoptionid))));
                    system.debug('totalAmount'+totalAmount);
                }
                else if(totaloptionFlightPrice.get(Integer.valueOf(currentoptionid)) != 0 && totalAmount.get(Integer.valueof(currentoptionid)) <= totaloptionFlightPrice.get(Integer.valueOf(currentoptionid)))    {
                    totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - totaloptionFlightPrice.get(Integer.valueOf(currentoptionid))));
                    system.debug('totalAmount'+totalAmount);
                }
                else
                    totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - airline.dtme_price__c));
                system.debug('totalAmount'+totalAmount);
                Rollup = totalAmount.get(Integer.valueof(currentoptionid));
                
               
            } else if(lineItemRecordType == 'Hotel') {
                hotel = qItems.get(lineItemRecordId);
               totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - hotel.dtme_price__c));
            } else if(lineItemRecordType == 'Other') {
                other = qItems.get(lineItemRecordId);
               totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - other.dtme_price__c));
                
            }
        }
    }
    
    public void deleteLineItem(){
        system.debug(lineItemRecordId);
        if(lineItemRecordId != null && lineItemRecordId != ''){
            String mapquoteid = mapQuoteOptIds.get(currentOptionId);
            Quote_Option__c qo = [select Status__c from Quote_Option__c where Id = :mapquoteid];
            if(qo.Status__c!='Finalized'){
                Quote_Line_Item__c li = new Quote_Line_Item__c(Id = lineItemRecordId);
                List<Quote_Line_Item__c> deleteprice = [Select dtme_price__c from quote_line_item__C where id = :lineItemRecordId];
                totalAmount.put(Integer.valueof(currentoptionid),(totalAmount.get(Integer.valueof(currentoptionid)) - (Decimal)deleteprice[0].get('dtme_price__c'))); 
                totalOptionAmount.put(Integer.valueOf(currentoptionid), totalAmount.get(Integer.valueOf(currentoptionid)));
                totalOptionFlightPrice.put(Integer.valueOf(currentOptionId),totalflightPrice);
                totalPriceRollup = totalPriceRollup - (Decimal)deleteprice[0].get('dtme_price__c');//added by SB
                delete li;
                system.debug('totalPriceRollup'+totalPriceRollup);
                system.debug('before calling update data for each line item');
                system.debug(lineItemRecordId);
                updateData(lineItemRecordId);
            }
            else{
                  ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Cannot add or edit a confirmed option.')); 
            }
        }
    }
    
    public void returnLineItem(){
        if(lineItemRecordId != null && lineItemRecordId != ''){
            
            List<List<Quote_Line_Item__c>> lstQItems = mapQuoteItems.values();
            Map<String, Quote_Line_Item__c> qItems = new Map<String, Quote_Line_Item__c>();
            if(lstQItems != null){
                for(Integer k : mapQuoteItems.keySet()){
                    for(Quote_Line_Item__c q : mapQuoteItems.get(k)){
                        qItems.put(q.Id, q) ;
                    }
                }
            }
            
            
                airline = qItems.get(lineItemRecordId);
                string temp = airline.From__c ;
                airline.From__c = airline.To__c;
                airline.To__c = temp;
                
          
                
        }
        
    }
    
    @RemoteAction
    public static Set<String> getFromFlights(string flightname){
        Set<String> airports = new Set<String>();
        if(flightname.length() > 1){
            string newflightname = '%'+flightname+'%';
            
            for(lookup__c fa: [select name from lookup__c where (name  LIKE :newflightname AND (name != '' OR name != null)  And  Type__c ='Airport') OR (code__c LIKE :newflightname  And  Type__c ='Airport') ORDER BY name ASC LIMIT 10]){
                airports.add(fa.name);
            }
        }
            return airports;
        
    }
    
     @RemoteAction
    public static Set<String> getToFlights(string flightname){
        Set<String> airportsto = new Set<String>();
        if(flightname.length() > 1){
            string newflightname = '%'+flightname+'%';
            
            for(lookup__c fa: [select name from lookup__c where (name  LIKE :newflightname AND (name != '' OR name != null) And  Type__c ='Airport') OR (code__c LIKE :newflightname And Type__c ='Airport') ORDER BY name ASC LIMIT 10 ]){
                airportsto.add(fa.name);
            }
        }
            return airportsto;
        
    }
    
    @RemoteAction
    public static Set<String> getHotelName(string hotelName){
        Set<String> cities = new Set<String>();
        if(hotelName.length() > 1){
            string newhotelName = '%'+hotelName+'%';
            system.debug('hotelName'+hotelName);
            for(City__c fa: [select name from City__c where (name  LIKE :newhotelName AND (name != '' OR name != null))  ORDER BY name ASC LIMIT 10 ]){
                cities.add(fa.name);
            }
            system.debug('cities'+cities);
        }
        if(cities.size() == 0)
        {
            string newhotelName = hotelName;
            cities.add(newhotelName);
            
        }
            
        return cities;
    }
    
    
    
    public void cloneQuoteOption(){
        if(currentOptionId != null && currentOptionId != ''){
            isClone = true;
            
            // Save Quote Option's high level details using below fn
            saveQuoteOption();
            //Integer currItem = Integer.valueOf(currentOptionId.split(' ')[1]);
             if(mapquoteitems.size() == Integer.valueOf(currentOptionId) ){
                currentOptionId = currentOptionId;
                //totalPrice = '0';
            }else{
                currentOpt -= 1;
                currentOptionId = String.valueOf(Integer.valueOf(currentOptionId) - 1);
            } 
          //  Integer curid = Integer.valueOf(currentOptionId) ;
            //currentOptionId = String.valueOf(curid);
            system.debug('cl    oning ' + currentOptionId);
            //Add next number to the option as we are cloning and adding a new option here
            Integer currItem = mapQuoteItems.keySet().size();
            currItem+=1;
            mapQuoteItems.put(currItem, new List<Quote_Line_Item__c>());
          
            system.debug(mapQuoteItems);
            //insert new option
            
            list<Quote_Option__c> options = new List<Quote_Option__c>();
            //for(integer i = 1; i <= 1; i++){
                //mapQuoteItems.put('Option '+ i, new List<Quote_Line_Item__c>());
                Quote_Option__c opt = new Quote_Option__c();
                opt.Quote_Header__c = header.Id;
                opt.Option_Number__c = currItem;
            	opt.Org_Notes__c = notes;//v1.7
                options.add(opt);
            //}
            insert options;
            
            for(Quote_Option__c qo : options){
                mapQuoteOptIds.put(''+ String.valueOf(qo.Option_Number__c), qo.Id);
            }
            
            // fetch the selected option's line items and prepare a new list
            // once the list is prepared put it with newly created option
            List<Quote_Line_Item__c> tempLIs = new List<Quote_Line_Item__c>();
            
            for(Quote_Line_Item__c qli : mapQuoteItems.get(Integer.valueof(currentOptionId))){
                Quote_Line_Item__c temp = qli.clone();
                temp.Quote_Option__c = options[0].Id;
                tempLIs.add(temp);
            }
            
            insert tempLIs;
            totalOptionAmount.put(currItem,totalOptionAmount.get(Integer.valueOf(currentoptionid)));
            totalOptionFlightPrice.put(currItem,totaloptionflightPrice.get(Integer.valueOf(currentoptionId))); //added by Sb
            totalAmount.put(currItem,totalAmount.get(Integer.valueOf(currentoptionid)));
            //put the newly created list
            mapQuoteItems.put(currItem, tempLIs);

            currentOptionId = ''+currItem;
            totalOptions = mapQuoteOptIds.keySet().size();
            currentOpt = Integer.valueOf(currentOptionId/*.split('-')[1]*/);
            caseDetails.noOfOptions = caseDetails.noOfOptions + 1;
            totalPrice = tempQuoteAmt != null && tempQuoteAmt != '' ? tempQuoteAmt : '';
            caseDetails.Tailormade = header.Tailormade__c;//jed T-00413
            savequoteoption2();
        }
    }
    
    public void finalizeQuoteOption(){
        if(currentOptionId != null && currentOptionId != '' && !mapquoteitems.get(Integer.valueOf(currentOptionId)).isEmpty()){
            String mapquoteid = mapQuoteOptIds.get(currentOptionId);
            Quote_Option__c qo = [select Status__c from Quote_Option__c where Id = :mapquoteid];
           // Quote_Option__c qo = new Quote_Option__c(Id = mapQuoteOptIds.get(currentOptionId));
            if(qo.Status__c != 'Finalized'){
                if(totaloptionamount.get(Integer.valueOf(currentOptionId)) != 0.0){
                    system.debug(qo.Status__c);
                  //  Quote_Option__c qo = new Quote_Option__c(Id = mapQuoteOptIds.get(currentOptionId));
                    system.debug(mapquoteitems);
                    qo.Status__c = 'Finalized';
                    update qo;
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'Option Confirmed'));
                }else{
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Total Option Price cannot be 0'));
                }
            }else {
                ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Current Quote Option has already been finalized'));
            }
        } else{
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Add items to option to confirm it.'));
        }
    }
    
    public void deleteQuoteOption(){
        if(currentOptionId != null && currentOptionId != ''){
            
            Quote_Option__c li = new Quote_Option__c(Id = mapQuoteOptIds.get(currentOptionId));
            delete li;
            system.debug('before calling update data for option');
            system.debug(currentOptionId);
            updateDataDelete(currentOptionId);
            system.debug(mapQuoteOptIds.keySet().size());
            /*if(mapQuoteOptIds.keySet().size() == 0){
                system.debug('got 0 size');
                currentOptionId = 'QuoteInformation';
            }else {
                system.debug('got more size');
                system.debug(String.valueOf(Integer.valueOf(currentOptionId) - 1));
                if(Integer.valueOf(currentOptionId) == 1){
                    integer temp = Integer.valueOf(currentOptionId);
                    temp += 1;
                    currentOptionId = String.valueOf(temp);
                    system.debug('1 ' + currentOptionId);
                } else {
                    integer temp = Integer.valueOf(currentOptionId);
                    temp -= 1;
                    currentOptionId = String.valueOf(temp);
                    system.debug('else ' + currentOptionId);
                }
                
            }*/
            currentOptionId='1';
            caseDetails.noOfOptions = caseDetails.noOfOptions - 1;
            //mapQuoteItems
        }
    }
    
    public void updateDataDelete(String recId){
         if(mapQuoteItems.containsKey(Integer.valueOf(recId))){
            //mapQuoteItems.put(recId, new List<Quote_Line_Item__c>());
            mapQuoteItems.remove(Integer.valueOf(recId));
           
            mapQuoteOptIds.remove(recId);
            totalAmount.remove(Integer.valueOf(recId));
            totalOptionAmount.remove(Integer.valueOf(recId));
            totalOptionFlightPrice.remove(Integer.valueOf(recId));
            Map<String,String> tempmapQuoteOptIds = new Map<String,String>();
            Map<Integer,List<Quote_Line_Item__c>> tempmapQuoteItems = new Map<Integer, List<Quote_Line_Item__c>>();
            Map<Integer,Decimal> temptotalAmount = new Map<Integer,Decimal>();
            Map<Integer,Decimal> temptotalOptionAmount = new Map<Integer, Decimal>(); 
            
           // tempmapQuoteOptIds.putAll(mapQuoteOptIds);
            // tempmapQuoteItems.putAll(mapQuoteItems);
            Integer counter = 1;
             for(List<Quote_Line_Item__c> lineitems : mapQuoteItems.values()){
                 
                 tempmapQuoteItems.put(counter,lineitems);
                 counter++;
             }
             counter = 1;
             mapQuoteItems.clear();
             
             for(List<Quote_Line_Item__c> templineitems : tempmapQuoteItems.values()){
                 
                 mapQuoteItems.put(counter,templineitems);
                 counter++;
             }
             
             counter = 1;
              for(String lineitems : mapQuoteOptIds.values()){
                 
                 tempmapQuoteOptIds.put(String.valueOf(counter),lineitems);
                 counter++;
             }
             counter = 1;
             mapQuoteOptIds.clear();
             for(String templineitems : tempmapQuoteOptIds.values()){
                 
                 mapQuoteOptIds.put(String.valueOf(counter),templineitems);
                 counter++;
             }
             
             counter = 1;
              for(Decimal lineitems : totalAmount.values()){
                 
                 temptotalAmount.put(counter,lineitems);
                 counter++;
             }
             counter = 1;
             totalAmount.clear();
             for(Decimal templineitems : temptotalAmount.values()){
                 
                 totalAmount.put(counter,templineitems);
                 counter++;
             }
             
             counter = 1;
              for(Decimal lineitems : totalOptionAmount.values()){
                 
                 temptotalOptionAmount.put(counter,lineitems);
                 counter++;
             }
             counter = 1;
             totalOptionAmount.clear();
             for(Decimal templineitems : temptotalOptionAmount.values()){
                 
                 totalOptionAmount.put(counter,templineitems);
                 counter++;
             }
             
            system.debug(tempmapQuoteItems);
            system.debug(mapQuoteItems);
        }
    }
    public void updateData(String recId){
        
            //mapQuoteOptIds.get(currentOptionId)
            for(Integer key : mapQuoteItems.keySet()){
                integer counter = 0;
                for(Quote_Line_Item__c qli : mapQuoteItems.get(key)){
                    counter++;
                    if(qli.Id == recId){
                        List<Quote_Line_Item__c> temp = mapQuoteItems.get(key);
                        temp.remove(counter - 1);
                        temp.sort();
                        mapQuoteItems.put(key, temp);
                    }
                }
            }
            
         
    }
    
    public Integer noOfChilds {get;set;}
    public void addChildAgeRecords(){
        ageDetails = new List<AgeDetail>();
        for(Integer i = 1; i <= caseDetails.NoOfChildren; i++){
            AgeDetail ad =  new AgeDetail();
            ad.ChildTraveller = new Quote_Traveller__c();
            ad.ChildName = 'Age: Child ' + i;
            ad.UID = 'date-child-'+i;
            ad.CSSClass = Math.mod(i, 2) == 0 ? 'right-cell right-cell-label' : 'left-cell';
            ageDetails.add(ad);
        }
    }
    
    public QuotesController(ApexPages.StandardController stdController) {
        showHideEmailPopup = false;
        editQuote = false;
        sentmail=false;
        isClone = false;
        priceisvalid = true;
        emailHtml = ''; //<p>test test</p>';
     
         removeFPC = false;//added by SB
        oneditFPC = false;
        showFPCButton = true;
        showDivFlag = true;
        setFPCFlag = false;
        parentRecord = (Case)stdController.getRecord();
        parentRecord = [Select id,org_brand__c,CurrencyIsoCode from Case where id = :parentrecord.id];
        system.debug('in std controller constructor');
        airline = new Quote_Line_Item__c();
        hotel = new Quote_Line_Item__c();
        other = new Quote_Line_Item__c();   
        recCurrency = parentRecord.CurrencyIsoCode;             
        totalPrice = '';
        totalFlightPrice = 0.0;
        childAges = '';
        notes = '';//v1.7
        airline.dtme_price__c = 0;
         totalPriceValue = 0.0; //v1.13
        hotel.dtme_price__c = 0;
        other.dtme_price__c = 0;
        caseDetails = new CaseDetail();
        ageDetails = new List<AgeDetail>();
        pageRecord = new Case();
        totalOptions = 0;
        currentOpt = 0;
        showContent = false;
        Boolean editage = false;
        currentOptionId = 'QuoteInformation';
        qOptionId = '';//jed T-00413
		mapTotalPriceRollup = new map<String,Decimal>(); //v1.14
        
        totaloptionamount = new Map<Integer,Decimal>();
        totaloptionFlightPrice = new Map<Integer,Decimal>();    
        totaloptionFlightPrice.put(1,0.0);
        totalamount = new Map<Integer,Decimal>();
        mapQuoteOptIds = new Map<String,String>();
        mapQuoteItems = new Map<Integer, List<Quote_Line_Item__c>>();
        headerId = ApexPages.currentPage().getParameters().get('headerId');
       
        if(headerId != null){
        	Quote_header__c quoteheader = [SELECT Id FROM Quote_Header__c WHERE Id =: headerId FOR UPDATE]; //v1.9
            header = new Quote_header__c(Id = quoteheader.Id); //v1.9
            editQuote = true;
            quote_header__c disc = [select disclaimer__c from quote_header__c where id = :header.id];            
            getDisclaimer = disc.Disclaimer__c;
            caseDetails.Tailormade = [select tailormade__c from quote_header__c where id = :header.id limit 1].Tailormade__c;//jed-jul22 T-00413
            ageDetails = new List<AgeDetail>();
            List<quote_traveller__c> childages = [select Age_of_child__c from quote_Traveller__c where quote__c = :header.Id];
            Integer i = 1;
            for(Quote_traveller__c childage : childages){               
                AgeDetail ad =  new AgeDetail();
                ad.ChildTraveller = new Quote_Traveller__c();
                ad.ChildName = 'Age: Child ' + i;
                ad.UID = 'date-child-'+i;
                ad.CSSClass = Math.mod(i, 2) == 0 ? 'right-cell right-cell-label' : 'left-cell';
                ad.ChildTraveller.Age_of_child__c = childage.Age_of_child__c;
                ageDetails.add(ad);
                i++;
            }
            editage = true; 
        }else{
            header = new Quote_header__c();
        }
        caseId = parentRecord.Id;
        otherDesc = '';
        EmailTemplate bookingQuote;
         String emailTempDeveloperName = '';
        if(parentRecord.Org_Brand__c == 'trp'){
            emailTempDeveloperName = 'TR_Quotation';
        } else if(parentRecord.Org_Brand__c == 'ekh'){
            emailTempDeveloperName = 'EKH_Booking_Quotation'; //T-00478
        } else {
            emailTempDeveloperName = 'Booking_Quotation';
        }
        for(EmailTemplate emailTemp : [SELECT Id,BrandTemplateId, Name, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTempDeveloperName LIMIT 1]){
            bookingQuote = emailTemp;
        }
        /*
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'invalid@emailaddr.es'};
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('MMPT');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId('00X0E000000GWMtUAO');
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Database.rollback(sp);
        String mailTextBody = mail.getPlainTextBody();
        String mailHtmlBody = mail.getHTMLBody();
        String mailSubject = mail.getSubject();
        
        system.debug(mailTextBody);
        system.debug(mailHtmlBody);
        */
       // BrandTemplate bt = [Select Value from BrandTemplate Where Id = :bookingQuote.BrandTemplateId];
        
       // emailHtml = bt.Value;
        //emailHTML = '<table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450"><tbody><tr valign="top"><td style="background-color: rgb(255, 255, 255); vertical-align: top; height: 100px; text-align: left; width: 500px;"><img border="0" beditid="r1sp1" blabel="headerImage" id="r1sp1" src="https://dnatapwcdev--pwcdev.cs89.my.salesforce.com/servlet/servlet.ImageServer?id=0150E000000CQCK&amp;oid=00D0E0000004pp6"></td></tr><tr valign="top"><td style=" background-color:#FFFFFF; bEditID:r2st1; bLabel:accent1; height:0;"></td></tr><tr valign="top"><td styleinsert="1" height="300" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;"></td></tr><tr valign="top"><td style=" background-color:#FFFFFF; bEditID:r4st1; bLabel:accent2; height:0;"></td></tr><tr valign="top"><td style=" background-color:#FFFFFF; bEditID:r5st1; bLabel:footer; vertical-align:top; height:100; text-align:left;"></td></tr><tr valign="top"><td style=" background-color:#FFFFFF; bEditID:r6st1; bLabel:accent3; height:0;"></td></tr></tbody></table>';
        //emailHtml = mailHtmlBody;
        system.debug(emailHtml);
        emailHtml += bookingQuote.HtmlValue;
        system.debug(emailHtml);
        
        if(headerId != null && headerId != ''){
            getExistingOptions(headerId);
        }
        if(caseId != null && caseId != ''){
            
            List<Case> lstRecs = [SELECT No_of_Infants_Travelling__c ,Org_No_of_Rooms__c ,Org_Brand__c,Org_Number_of_Nights__c,Org_Estimated_Arrival_Date__c,Org_Destinations__c,Org_Destination__c,Org_Destination_list__c ,Org_Departure_Date__c,AccountId,Account.Name,CaseNumber,ContactId,Contact.Name,Org_No_of_Adults_Travelling__c,Org_No_of_Children_Travelling__c,Org_Traveller__c,Org_Travel_Agent_Name__c,Org_Travel_Agent__c,Org_Type__c,Status,Org_Case_Status__c, Subject,Record_Type_Name__c FROM Case Where Id = :caseId];// Added Org_No_of_Rooms__c ,Org_Brand__c as a part of v1.6
            if(!lstRecs.isEmpty()){
                
                parentRecord = lstRecs[0];
                pageRecord = parentRecord;
                
                caseDetails.CustomerName = parentRecord.Account.Name;
                caseDetails.CustomerRecId = parentRecord.AccountId;
                caseDetails.CaseNumber = parentRecord.CaseNumber;
                caseDetails.CaseRecId = parentRecord.Id;
                caseDetails.TravellerType = parentRecord.Org_Traveller__c;
                caseDetails.Destination = parentRecord.Org_Destinations__c;
                caseDetails.Brand = parentRecord.Org_Brand__c;//added as a part of v1.6
                caseDetails.NoOfRooms = Integer.valueof(parentRecord.Org_No_of_Rooms__c);//added as a part of v1.6
                
                //caseDetails.DateFrom = parentRecord.Org_Departure_Date__c;
                if(!editquote){
                    system.debug('test');
                    system.debug(parentRecord.Org_Departure_Date__c);
                    header.Date_From__c = (parentRecord.Org_Departure_Date__c != null ) ? Date.valueOf(parentRecord.Org_Departure_Date__c) : Date.today();
                    Date d = header.Date_From__c;
                    if(parentRecord.Record_Type_Name__c != 'Duty Travel - New Enquiry' && parentRecord.Record_Type_Name__c != 'Duty Travel UK - New Enquiry') //T-00826
                        header.Date_To__c = d.addDays(Integer.valueOf(parentRecord.Org_Number_of_Nights__c));
                    caseDetails.NoOfOptions = 1;
                    caseDetails.NoOfAdults = ((parentRecord.Org_No_of_Adults_Travelling__c != null && parentRecord.Org_No_of_Adults_Travelling__c != 0) ? Integer.valueOf(parentRecord.Org_No_of_Adults_Travelling__c) : 0);
                    if(parentRecord.Org_No_of_Children_Travelling__c == null){
                        parentRecord.Org_No_of_Children_Travelling__c = 0;
                    }
                    caseDetails.NoOfChildren = Integer.valueOf(parentRecord.Org_No_of_Children_Travelling__c) + ((parentRecord.No_of_Infants_Travelling__c != null && parentRecord.No_of_Infants_Travelling__c != 0) ? Integer.valueOf(parentRecord.No_of_Infants_Travelling__c) : 0);
                }else{
                    System.debug('Errata'+header.Errata__c);
                    System.debug('adults'+header.No_of_Adults__c);
                    System.debug('children'+header.No_of_Children__c);
                    quote_header__c editcasedetail = [select No_of_Adults__c,No_of_Children__c,Errata__c,date_from__c,date_to__c from quote_header__c where id = :header.Id];
                    header.Date_From__c = editcasedetail.Date_From__c;
                    header.Date_To__c = editcasedetail.Date_To__c;
                    caseDetails.NoOfAdults = (Integer)editcasedetail.No_of_Adults__c;
                    caseDetails.NoOfChildren = (Integer)editcasedetail.No_of_Children__c;
                    caseDetails.Errata = editcasedetail.errata__c;
                    caseDetails.NoOfOptions = mapquoteitems.size();
                }
                System.debug(caseDetails.NoOfChildren);
                if(caseDetails.NoOfChildren != null && caseDetails.NoOfChildren != 0 && caseDetails.NoOfChildren > 0 && !editage){
                    for(Integer i = 1; i <= caseDetails.NoOfChildren; i++){
                        AgeDetail ad =  new AgeDetail();
                        ad.ChildTraveller = new Quote_Traveller__c();
                        //Changed as part of v1.1
                        ad.ChildName = 'Age: Child ' + i;
                        ad.UID = 'date-child-'+i;
                        ad.CSSClass = Math.mod(i, 2) == 0 ? 'right-cell right-cell-label' : 'left-cell';
                        ageDetails.add(ad);
                    }
                }
               
                
            }
        }else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please navigate through correct case!');
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void preview(){
        
    }
    
    public void sendQuote(){
        if(header != null && header.Id != null ){
            
            system.debug('emailText');
            system.debug(header.Customer__c);
            system.debug(header.Case__c);
            system.debug(emailText); 
            Quote_Header__c emailtosend = [select customer__c,case__c from quote_header__c where id= :header.id];
            header.Customer__c = emailtosend.Customer__c;
            header.Case__c = emailtosend.Case__c;
            //emailText = '<style>td p { color: #000000 !important} .im{color: #000000 !important}</style>' + emailText;
            try{
            system.debug(emailtosend.Case__c);
            SendQuotationController.sendQuoteToCustomer(header.Id, header.Customer__c, header.Case__c, 'Quotation for '+parentRecord.Org_Destinations__c,emailText);      
            Quote_Header__c h = new Quote_Header__c(Id = header.Id);
            h.Status__c = 'Submitted';
            update h;
            system.debug('h'+h);
            Case c = new Case(Id = header.Case__c);
            c.Org_Case_Status__c = 'Quotation Sent';
            update c;
            sentmail=true;
            system.debug(sentmail);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Quotation Email sent successfully');
                ApexPages.addMessage(myMsg);
            } catch (Exception e){
               
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Quotation Email Couldn\'t be sent.');
                ApexPages.addMessage(myMsg);
                 sentmail = false;
                system.debug(sentmail);
                system.debug(e);
            }
            
            
        }
        //return 'Failed to Send Quote';
    }
    
    public void setMail(){
        
		Case c = new Case(Id = header.Case__c);
        Case emailcase = [select org_brand__c, Account.Name,Account_Name__c,Owner_Name__c,Destination__c,Record_Type_Name__c from case where id = :parentRecord.id];        // modified as a part of v1.8
        User agent = [SELECT Name, Phone, MobilePhone ,Profile.Name, Store__c FROM User WHERE Id =: Userinfo.getUserId()]; //v1.11
        
        EmailTemplate emailTemplate;
        
        system.debug('Team Name:'+c.Org_Current_Team_Name__c);
        if(c.Org_Current_Team_Name__c == 'Duty Travel All'){
        	emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'duty_Travel_Booking_Quotation'];
            system.debug('@@@'+emailTemplate);
        }
        
        system.debug('email case brand '+ emailcase.Org_Brand__c);
        if(emailcase.Org_Brand__c == 'trp'){
            emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'TR_Quotation'];
        } else if(emailcase.Org_Brand__c == 'ekh'){
			emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'EKH_Booking_Quotation']; //T-00478
        } else {
        	emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Booking_Quotation'];
        }
        
        //EmailTemplate emailtemplate = [select id from EmailTemplate where developername = 'booking_Quotation'];

		//v1.15
        map<String,String> storeNameNumberMap = new map<String,String>();
        for(User_Role_And_Store_Map__mdt customMetadataType : [SELECT Store_Name__c, Store_Contact_Number__c, Store_Email__c FROM User_Role_And_Store_Map__mdt]){
            if(customMetadataType.Store_Contact_Number__c != ''){
                storeNameNumberMap.put(customMetadataType.Store_Name__c,customMetadataType.Store_Contact_Number__c);
            }
        }        
        //End - v1.15        

        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'invalid@emailaddr.es'};
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('MMPT');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId(emailtemplate.id);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Database.rollback(sp);
        String mailTextBody = mail.getPlainTextBody();
        String mailHtmlBody = mail.getHTMLBody();
        String mailSubject = mail.getSubject();
            
            system.debug('hi');
            
            //emailHtml = '<style>td {color: #000000 !important;}</style>' + mailHtmlBody; 
           emailHtml = mailHtmlBody;
            emailHtml = emailHtml.replaceAll('style="', 'style="color:#000000; ');
            //
            
        //v1.11
        if(emailcase.Org_Brand__c == 'dnata'){
        	if(emailHtml.contains('&lt;Customer&gt;') && emailHtml.contains('&lt;UserName&gt;')){
	        	emailHtml = emailHtml.replace('&lt;Customer&gt;', emailcase.Account.Name).replace('&lt;UserName&gt;', agent.Name);
        	}
        	
        	if(emailHtml.contains('&lt;UserContactNo&gt;')){
		       /*if(agent.Phone != null && !agent.Profile.Name.containsIgnoreCase('Retail')){
		        	emailHtml = emailHtml.replace('&lt;UserContactNo&gt;', agent.Phone);
		        } else if(agent.MobilePhone != null){
		        	emailHtml = emailHtml.replace('&lt;UserContactNo&gt;', agent.MobilePhone);
		        } else {
		        	emailHtml = emailHtml.replace('&lt;UserContactNo&gt;', '');
		        }*/ //Commented as a part of v1.12
                
                //v1.12
                if(agent.Profile.Name.containsIgnoreCase('Retail')){
                	if(storeNameNumberMap.containsKey(agent.Store__c)){//v1.15
                		emailHtml = emailHtml.replace('&lt;UserContactNo&gt;', storeNameNumberMap.get(agent.Store__c));
                	} else if(agent.phone != null){
                    	emailHtml =  emailHtml.replace('&lt;UserContactNo&gt;', agent.Phone);
                	} else if(agent.MobilePhone != null){
                        emailHtml =  emailHtml.replace('&lt;UserContactNo&gt;', agent.MobilePhone);
                	} else {
		        		emailHtml = emailHtml.replace('&lt;UserContactNo&gt;', '');
                	}	
                } else { 
                    emailHtml =  emailHtml.replace('&lt;UserContactNo&gt;','800dnata(36282)');
                }
                //v1.12
        	}
        }       
        //End v1.11
        
        //Added by sri bala v1.8
       if(mailHtmlBody!= null && emailcase.Org_Brand__c == 'trp'){
            system.debug('entered Case Mail');
            if(mailHtmlBody.contains('CaseAccount') && mailHtmlBody.contains('OwnerFirstName'))
                emailHtml=  mailHtmlBody.replace('CaseAccount', emailcase.Account_Name__c).replace('OwnerFirstName', emailcase.Owner_Name__c);
           
            system.debug('emailHtml'+emailHtml);
        }	
        //end v1.8

        system.debug(emailHtml);
    }
    
    
    public void updateQuoteDetails(){
        if(header.Date_From__c <= header.Date_To__c){
        if(caseDetails.NoOfOptions >= mapQuoteItems.size()){
            Boolean validages = true;
            for(AgeDetail agd : ageDetails){
                if(agd.ChildTraveller.Age_of_child__c == null){
                    validages = false;
                    system.debug('@@@@'+agd.ChildTraveller.Age_of_child__c);
                }
            }
            if(caseDetails.NoOfOptions != null && caseDetails.NoOfOptions > 0 && validages){
                if(casedetails.noofoptions > 99){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Options cannot be more than 99.'));
                } else{
                    header.No_of_Adults__c = caseDetails.NoOfAdults;
                    header.No_of_Children__c = caseDetails.NoOfChildren; 
                    header.Disclaimer__c = disclaimer;
                    header.Errata__c = caseDetails.Errata;
                    header.Tailormade__c = caseDetails.Tailormade;//jed-jul22 T-00413

                    update header;                    
                    currentOptionId = '1';
                    
                    system.debug(getDisclaimer);
                    List<Quote_Traveller__c> deletetravellers = new List<Quote_Traveller__c>();
                    deletetravellers = [select id from quote_traveller__c where Quote__c = :header.Id];
                    delete deletetravellers;
                    List<Quote_Traveller__c> updatedtravellers = new List<Quote_Traveller__c>();
                    for(AgeDetail agd : ageDetails){
                    Quote_Traveller__c t = new Quote_Traveller__c();
                    //if(agd.ChildTraveller.Date_of_Birth__c > Date.today()){
                      //   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Age of Child cannot be greater than todays date'));
                        //  break;
                    //}
                    
                    t.Age_of_child__c = agd.ChildTraveller.Age_of_child__c;
                    t.Quote__c = header.Id;
                    t.Traveller_Type__c = 'Child';
                    //Edited as a part of v1.1
                     if(t.Age_of_child__c != null && t.Age_of_child__c !='--None--'){
                        
                        if( t.Age_of_child__c == '< 1 year' ){
                            t.Traveller_Type__c = 'Infant';
                        } else {
                            t.Traveller_Type__c = 'Child';
                        }
                    }
                    updatedtravellers.add(t);                                               
                }
                    insert updatedtravellers;
                    system.debug(mapquoteoptids);
                    system.debug(mapquoteitems);
                    system.debug('alkjs'+totaloptionFlightPrice);
                    list<Quote_Option__c> options = new List<Quote_Option__c>();
                    for(integer i = mapQuoteItems.size() + 1; i <= caseDetails.NoOfOptions; i++){
                        system.debug(i);
                        totalamount.put(i,0.0);
                        totaloptionFlightPrice.put(i,0.0);
                        system.debug('alkjs'+totaloptionFlightPrice);
                        totaloptionamount.put(i,0.0);
                        mapQuoteItems.put(i, new List<Quote_Line_Item__c>());
                        Quote_Option__c opt = new Quote_Option__c();
                        opt.Quote_Header__c = header.Id;
                        opt.Option_Number__c = i;
                        opt.Org_Notes__c = notes;//added as a part of v1.7
                        options.add(opt);
                    }
                    system.debug(mapQuoteItems);
                    insert options;
                    system.debug(options);
                    for(Quote_Option__c qo : options){
                        mapQuoteOptIds.put(''+ String.valueOf(qo.Option_Number__c), qo.Id);
                       
                    }
                    system.debug(mapQuoteOptIds);
                    totalOptions = mapQuoteOptIds.keySet().size();
                    currentOpt = Integer.valueOf(currentOptionId/*.split('-')[1]*/);
                    quote_header__c discl = [select disclaimer__c from quote_header__c where id = :header.id];
                    getDisclaimer = discl.Disclaimer__c;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Updated Quote Information Successfully.'));
                }
            } else if(validages == false){  ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please enter age of child.'));} else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please enter number of options to proceed.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Number of options entered cannot be less than the previous number of options entered.'));
        }
            
        }else{
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Date To Should be ahead from Date From.'));
        } 
    }
    
    
    public string optionOperation {get;set;}
    public void saveQuoteDetails(){
        if(header.Date_From__c <= header.Date_To__c){
        setMail();
        //try {
        //if(optionOperation == 'INSERT') 
        {      
            
            //Email Template test
           // Messaging.reserveSingleEmailCapacity(1);
     //   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     //   String[] toAddresses = new String[]{'invalid@emailaddr.es'};
       // mail.setToAddresses(toAddresses);
        //mail.setUseSignature(false);
        //mail.setSaveAsActivity(false);
        //mail.setSenderDisplayName('MMPT');
        //mail.setTargetObjectId(UserInfo.getUserId());
     //   mail.setTemplateId('00X0E000000GWMtUAO');
     //   Savepoint sp = Database.setSavepoint();
     //   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
     //   Database.rollback(sp);
      //  String mailTextBody = mail.getPlainTextBody();
      //  String mailHtmlBody = mail.getHTMLBody();
     //   String mailSubject = mail.getSubject();
            
     //       system.debug('hi');
            
            //emailHtml = '<style>td {color: #000000 !important;}</style>' + mailHtmlBody; 
     //      emailHtml = mailHtmlBody;
      //      emailHtml = emailHtml.replaceAll('style="', 'style="color:#000000; ');
            //
            system.debug(emailHtml);
            Boolean validages = true;
            for(AgeDetail agd : ageDetails){
                if(agd.ChildTraveller.Age_of_child__c == null){
                    validages = false;
                    system.debug('@#$'+agd.ChildTraveller.Age_of_child__c);
                }
            }
            if(caseDetails.NoOfOptions != null && caseDetails.NoOfOptions > 0 && validages){
                if(casedetails.noofoptions > 99){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Options cannot be more than 99.'));
                } else{
                if(header != null && header.Id != null){
                  //  headerid = header.id;
                }else {
                   // header = new Quote_Header__c();
                  //  headerid = header.id;
                }
                Case brand = [select org_brand__c from case where id = :parentrecord.Id];
                header.Case__c = parentRecord.Id;
                header.Customer__c = parentRecord.AccountId;
                system.debug(caseDetails);
                
                header.RecordTypeId = Schema.SObjectType.quote_header__c.getRecordTypeInfosByName().get('SF Quote').getRecordTypeId(); 
                
                System.debug(parentRecord.Id);
                header.Brand__c = brand.Org_Brand__c;
                
                header.No_of_Adults__c = caseDetails.NoOfAdults;
                header.No_of_Children__c = caseDetails.NoOfChildren;
                header.Errata__c = caseDetails.Errata;
                /*    System.debug('Errata'+header.Errata__c);
                    System.debug('adults'+header.No_of_Adults__c);
                    System.debug('children'+header.No_of_Children__c); */
                system.debug(disclaimer);
                header.Disclaimer__c = disclaimer;
                getDisclaimer = disclaimer;
                if(caseDetails.Tailormade != null){
                	header.Tailormade__c = caseDetails.Tailormade;//jed-jul22 T-00413
                }                
                if(!Test.isrunningtest()){
                insert header;
                }
                
                system.debug(header.Id);
                system.debug(childAges);
                system.debug(ageDetails);
                
                List<Quote_Traveller__c> travellers = new List<Quote_Traveller__c>();
                for(AgeDetail agd : ageDetails){
                    Quote_Traveller__c t = new Quote_Traveller__c();
                    //if(agd.ChildTraveller.Date_of_Birth__c > Date.today()){
                      //   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Age of Child cannot be greater than todays date'));
                        //  break;
                    //}
                    
                    //Changed as part of v1.1
                    t.Age_of_child__c = agd.ChildTraveller.Age_of_child__c;
                    t.Quote__c = header.Id;
                    t.Traveller_Type__c = 'Child';
                    if(t.Age_of_child__c != null || t.Age_of_child__c !='--None--'){
                       // Integer monthsBetween =  t.Age_of_child__c.monthsBetween(Date.today());
                        if( t.Age_of_child__c == '< 1 year' ){
                            t.Traveller_Type__c = 'Infant';
                        } else {
                            t.Traveller_Type__c = 'Child';
                        }
                    }
                    travellers.add(t);
                }
                /*for(String s : childAges.split(';')){
Quote_Traveller__c t = new Quote_Traveller__c();
t.Date_of_Birth__c = s != null && s != '' ? Date.valueOf(s) : null;
t.Quote__c = header.Id;
t.Traveller_Type__c = 'Child';
travellers.add(t);
}*/
                
                insert travellers;
                currentOptionId = '1';
                mapQuoteOptIds = new Map<String,String>();
                mapQuoteItems = new Map<Integer, List<Quote_Line_Item__c>>();
                
                mapQuoteOptionWithItems = new Map<Integer, List<Quote_Line_Item__c>>();
                list<Quote_Option__c> options = new List<Quote_Option__c>();
                for(integer i = 1; i <= caseDetails.NoOfOptions; i++){
                    system.debug(i);
                    totalamount.put(i,0.0);
                    totaloptionamount.put(i,0.0);
                    mapQuoteItems.put(i, new List<Quote_Line_Item__c>());
                    Quote_Option__c opt = new Quote_Option__c();
                    opt.Quote_Header__c = header.Id;
                    opt.Tailormade_Itinerary__c = tailormadeItinerary;//jed T-00413
                    qOptionId = opt.Id;//jed T-00413 
                    opt.Option_Number__c = i;
                    opt.Org_Notes__c = notes; //v1.7
                    options.add(opt);
                }
                system.debug(mapQuoteItems);
                system.debug(options);
                insert options;
                
                for(Quote_Option__c qo : options){
                    mapQuoteOptIds.put(''+ String.valueOf(qo.Option_Number__c), qo.Id);
                   
                }
                system.debug(mapQuoteOptIds);
                totalOptions = mapQuoteOptIds.keySet().size();
                currentOpt = Integer.valueOf(currentOptionId/*.split('-')[1]*/);
                } } else if(validages == false){  ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please enter age for child.'));} else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please enter number of options to proceed.'));
            }
            
            
        }
        
        //insert mapQuoteOptionWithItems.keySet();
        /*} catch(Exception ex){
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Something went wrong, please refresh the page!');
ApexPages.addMessage(myMsg);

}*/
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Date To Should be ahead from Date From.'));
        }
    }
    
    public void setCurrentOption(){
        system.debug('setcurrentoption ' + currentOptionId);
        string optId = mapQuoteOptIds.get(currentOptionId);
        system.debug('##################' + mapQuoteOptIds);
        
        //v1.14
        if(mapTotalPriceRollup.containsKey(optId)){
        	totalPriceRollup = mapTotalPriceRollup.get(optId); 
        }
        //end v1.14
        
        try{
            tailormadeItinerary = [select Tailormade_Itinerary__c from Quote_Option__c where id=: optId limit 1].Tailormade_Itinerary__c;//jed T-00413
        }catch (exception e){
            system.debug(e.getmessage());
        }
        
        qOptionId = optId;//jed T-00413       
        if(currentOptionId == 'QuoteInformation'){
            currentOptionId = 'QuoteInformation'; 
        } else {
            savequoteoption2();
            system.debug(mapQuoteOptIds);
            system.debug(currentOpt);
            totalOptions = mapQuoteOptIds.keySet().size();
            currentOpt = Integer.valueOf(currentOptionId/*.split('-')[1]*/);
        }
        
    }
    
    public void getExistingOptions(string headerId){
        system.debug('in header getexisting options');
         // changed order by Date_Calculated__c to Departure date and Check in date
        List<Quote_Option__c> lstOptions = new List<Quote_Option__c>(//jed T-00413 // added Org_Notes__c for v1.7
            [SELECT Id, Name,Option_Number__c,Tailormade_Itinerary__c,Org_Notes__c,Price__c,Flight_Package_Cost__c,Flight_Price__c,Quote_Header__c,Quote_Header__r.Case__c,Status__c,CurrencyIsoCode,(SELECT Additional_Details__c,Airline_Name__c,Org_Airline__c,Airline__c,Arrival_Date_Time__c,Check_In__c,Check_Out__c,CreatedById,CreatedDate,CurrencyIsoCode,Departure_Date_Time__c,dtme_price__c,Duration__c,Flight_Details__c,Flight_No__c,From_Airport__c,From__c,Hotel_Details__c,Hotel_Location__c,Hotel_Name__c,No_Of_Rooms__c,Id,Meal_Type__c,Name,Other_Service_Description__c,Other_Service_Type__c,Quote_Option__c,Room_Type__c,To_Airport__c,To__c,Type__c,Special_Request__c,Date_calculated__c,Flight_Class__c FROM Quote_Line_Items__r order by  Departure_Date_Time__c,Check_in__c) FROM Quote_Option__c Where Quote_Header__c =: headerId ORDER BY Option_Number__c ASC]);
        system.debug(lstOptions);
       List<Quote_Product_Segment__c> prodSegment = new List<Quote_Product_Segment__c>([Select Arrival_Date__c,Quote_Line_Item__r.Type__c,Quote_Line_Item__r.Flight_No__c,Carrier_Name__c,Departure_Airport_Title__c,Departure_Date__c,Destination_Airport_Title__c,Description__c, Quote_Line_Item__r.dtme_price__c ,Destination_Terminal__c,Flight_Number__c,SupplierFareClass__c,Quote_Line_Item__r.Hotel_Name__c,Quote_Line_Item__r.Room_Type__c,Quote_Line_Item__r.Check_In__c,Quote_Line_Item__r.Check_Out__c,Quote_Line_Item__r.Duration__c ,Quote_Line_Item__r.Meal_Type__c ,Quote_Line_Item__r.Hotel_Details__c FROM Quote_Product_Segment__c where Quote_Line_Item__r.Quote_Option__c IN: lstOptions]);
       List<Quote_Line_Item__c> lineItemsList = new List<Quote_Line_Item__c>([Select Other_Service_Type__c,Title__c,Quote_Option__r.Flight_Price__c,Other_Service_Description__c,PickUpDate__c,PickUpLocation__c,Additional_Details__c,Check_In__c,Duration__c,dtme_price__c,Check_Out__c,CheckInDate__c,CheckOutDate__c,End_Date__c,Hotel_country__c,Hotel_Details__c,Hotel_Location__c,Hotel_Name__c,Hotel_Province__c,Meal_Type__c,No_Of_Rooms__c,ID,Type__c,Room_Type__c   FROM Quote_Line_Item__c where Quote_Option__r.Quote_Header__c = :headerId]);
        if(!lstOptions.isEmpty()){
           
            caseId = lstOptions[0].Quote_Header__r.Case__c;
            for(Quote_Option__c qo : lstOptions){
                 if(qo.Flight_Price__c == null)
                qo.Flight_Price__c =0.0;
                mapQuoteOptIds.put(''+ String.valueOf(qo.Option_Number__c), qo.Id);
                mapQuoteItems.put((qo.Option_Number__c).intValue(), qo.Quote_Line_Items__r);
                
                //totalPriceRollup = qo.Price__c; //v1.14
                mapTotalPriceRollup.put(qo.Id,qo.Price__c); //v1.14
                
                totalFlightPrice = qo.Flight_Price__c;// added by sri bala
                totaloptionamount.put((qo.Option_Number__c).intValue(),qo.Price__c);
                totaloptionFlightPrice.put((qo.Option_Number__c).intValue(),qo.Flight_Price__c);
                system.debug('asqiuweyqw'+totaloptionFlightPrice);
                totalAmount.put((qo.Option_Number__c).intValue(),qo.Price__c);
            }
            Map<String,String> tempmapQuoteOptIds = new Map<String,String>();
            Map<Integer,List<Quote_Line_Item__c>> tempmapQuoteItems = new Map<Integer, List<Quote_Line_Item__c>>();
            Map<Integer,Decimal> temptotalAmount = new Map<Integer,Decimal>();
            Map<Integer,Decimal> temptotalOptionAmount = new Map<Integer, Decimal>(); 
            MAp<Integer,Decimal> temptotaloptionFlightPrice = new Map<Integer,Decimal>();
           // tempmapQuoteOptIds.putAll(mapQuoteOptIds);
            // tempmapQuoteItems.putAll(mapQuoteItems);
            Integer counter = 1;
             for(List<Quote_Line_Item__c> lineitems : mapQuoteItems.values()){
                 
                 tempmapQuoteItems.put(counter,lineitems);
                 counter++;
             }
             counter = 1;
             mapQuoteItems.clear();
             for(List<Quote_Line_Item__c> templineitems : tempmapQuoteItems.values()){
                 
                 mapQuoteItems.put(counter,templineitems);
                 counter++;
             }
             
             counter = 1;
              for(String lineitems : mapQuoteOptIds.values()){
                 
                 tempmapQuoteOptIds.put(String.valueOf(counter),lineitems);
                 counter++;
             }
             counter = 1;
             mapQuoteOptIds.clear();
             for(String templineitems : tempmapQuoteOptIds.values()){
                 
                 mapQuoteOptIds.put(String.valueOf(counter),templineitems);
                 counter++;
             }
             
             counter = 1;
              for(Decimal lineitems : totalAmount.values()){
                 
                 temptotalAmount.put(counter,lineitems);
                 counter++;
             }
             counter = 1;
             totalAmount.clear();
             for(Decimal templineitems : temptotalAmount.values()){
                 
                 totalAmount.put(counter,templineitems);
                 counter++;
             }
             
             counter = 1;
              for(Decimal lineitems : totalOptionAmount.values()){
                 
                 temptotalOptionAmount.put(counter,lineitems);
                 counter++;
             }
            counter = 1;
            for(Decimal lineItems : totalOptionFlightPrice.values()){
                temptotaloptionFlightPrice.put(counter,lineitems);
                counter++;
            }
            system.debug('temptotaloptionFlightPrice'+temptotaloptionFlightPrice);
             counter = 1;
             totalOptionAmount.clear();
             totaloptionFlightPrice.clear();
             for(Decimal templineitems : temptotalOptionAmount.values()){
                 
                 totalOptionAmount.put(counter,templineitems);
                 counter++;
             }
            counter = 1;
             for(Decimal templineItems : temptotalOptionFlightPrice.values()){
                totaloptionFlightPrice.put(counter,templineitems);
                counter++;
            }
            system.debug('totaloptionFlightPrice'+totaloptionFlightPrice);
        }
    }
    
    public String currentOptionId {get;set;}
    public String lineItemName {get;set;}
    public String otherDesc {get;set;}
    public Integer count{get;set;}
  
    public Boolean setFPCFlag{get;set;}//added by SB
    public Boolean showDivFlag{get;set;}//added by SB
    public Decimal Rollup =0; //SB
    //added as a part of v1.4
    public pagereference removePriceforFlightPackageCost(){
        
        oneditFPC = false;
        showContent = false;
        showDivFlag = true;
        showFPCButton = true;
        lineitemName = 'Flight';
        String mapquoteid = mapQuoteOptIds.get(currentOptionId);
        Quote_Option__c qo = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
        setFPCFlag = false;
        system.debug('flag'+setfpcflag  );
        if(qo.Status__c!='Finalized'){
            
            system.debug(currentOptionId);
            qo.Flight_Price__c = 0;
            update qo;
        }
        Quote_Option__c qot = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
        Flight_Package_Cost = qo.Flight_Package_Cost__c;
        totaloptionflightPrice.put(Integer.valueOf(CurrentOptionId),0); 
        if(totaloptionflightPrice.get(Integer.valueof(currentoptionId)) == 0)
            	totalPriceRollup = qot.Price_Roll_up__c;
            else
                totalPriceRollup = (qot.Price_Roll_up__c + totaloptionflightPrice.get(Integer.valueof(currentoptionId))) - qot.Flight_Price_Roll_up__c;
            
        addAmount(airline,currentoptionid);
        return null;
        
    }
    public pagereference showEdit(){
        showContent = true;
        showDivFlag = true;
        setFPCFlag = false;
        system.debug(showContent );
        return null;
    }
    public Boolean showFPCButton{get;set;} 
    public Decimal totalPriceRollup{get;set;}
    public Decimal roundedtotalPriceRollup{get;set;}
    public pagereference updatePriceforFlightPackageCost(){
        
        String mapquoteid = mapQuoteOptIds.get(currentOptionId);
        Quote_Option__c qo = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
        setFPCFlag = true;
        oneditFPC = true;
        removeFPC = true;
        showFPCButton = false;
        showDivFlag = false;
        showContent = false;
        lineitemName = 'Flight';
        system.debug('asd'+oneditFPC+ '' +showContent);
        if(qo.Status__c!='Finalized'){
            Flight_Package_Cost = qo.Flight_Package_Cost__c;
            system.debug(currentOptionId);
            qo.Flight_Price__c = totaloptionflightPrice.get(Integer.valueOf(CurrentOptionId));
            update qo;
        }
       Quote_Option__c qot = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
        Flight_Package_Cost = qot.Flight_Package_Cost__c;
        if(totaloptionflightPrice.get(Integer.valueof(currentoptionId)) == 0)
            	totalPriceRollup = qot.Price_Roll_up__c;
            else
                totalPriceRollup = (qot.Price_Roll_up__c + totaloptionflightPrice.get(Integer.valueof(currentoptionId))) - qot.Flight_Price_Roll_up__c;
         totalPriceRollup = totalPriceRollup.setScale(2);
         addAmount(airline,currentoptionid);
        return null;
    }
    //end
    public void saveQuoteLineItem(){
        String mapquoteid = mapQuoteOptIds.get(currentOptionId);//jed T-00413
        Quote_Option__c qo = [select Status__c,Tailormade_Itinerary__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
        qo.Tailormade_Itinerary__c = tailormadeItinerary;//jed T-00413
        qOptionId = qo.Id;//jed T-00413
        
        if(qo.Status__c!='Finalized'){
        system.debug(currentOptionId);
        if(lineItemName == 'Flight'){
            if(airline.dtme_price__c == null) {
                        airline.dtme_price__c = 0;
                    }
            
            system.debug(mapQuoteOptIds);
            system.debug(currentOptionId);
            if(validateFlightDetails()){
                airline.Type__c = 'Flight';
                
                if(!(airline != null && airline.Id != null)){
                   
                     //added as a part of v1.4
                            qo.Flight_Price__c = totaloptionflightPrice.get(Integer.valueOf(CurrentOptionId));
                            update qo;
                           
                            system.debug('rolup'+rollup);
                            //end of v1.4
                            
                            totalFlightPrice = totaloptionflightPrice.get(Integer.valueOf(CurrentOptionId));
                            system.debug('total price'+totalFlightPrice);
                            
                    
                    airline.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
                    system.debug('@@'+airline.Quote_Option__r.Flight_Price__c); 
                    
                    insert airline;
                        
                    
         
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(airline);
                    
                    //Added as part of v1.2
                    List<Quote_Line_Item__c> finalList = new List<Quote_Line_Item__c>();
                    finalList = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    for(Integer i = items.size()-1; i>=0;i--)
                    {
                        for(Quote_Line_Item__c q:items){
                                
                                if((finallist.get(i)!= items.get(i)) && (items[i].Departure_Date_Time__c < items[i+1].Departure_Date_Time__c))
                                finalList.add(items.get(i));
                        }
                        //mapQuoteItems.put(Integer.valueOf(currentOptionId),finalList);
                    }
                    finalList.sort();
                    Quote_Option__c qot = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
                    Flight_Package_Cost = qot.Flight_Package_Cost__c;
                    rollup = qot.Flight_Price_Roll_up__c;
                    if(qot.Price_Roll_up__c != 0)
                    	totalPriceRollup = qot.Price_Roll_up__c;
                    totalPriceRollup = totalPriceRollup.setScale(2);
                    system.debug('rollup'+rollup);
                    system.debug('Airline'+finalList);
                    
                    mapQuoteItems.put(Integer.valueOf(currentOptionId),finalList);
                    //added as a part of v1.4
                    
                    
                    system.debug('Flight Package Cost'+Flight_Package_Cost);
                    if(qo.Flight_Price_Roll_up__c == 0)
                        qo.Flight_Price__c = Flight_Package_Cost;
                    update qo;
                    
                    //end of v1.4
                    system.debug(items);
                    system.debug(airline);
                    system.debug(mapQuoteItems);
                }else {
                    
                    update airline;
                    updateData(airline.Id);
                    count = [Select count() from Quote_Line_Item__c where Type__c = 'Flight'];
                    system.debug('count'+count);
                    //end 
                    
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(airline);
                    //Added as part v1.2
                    List<Quote_Line_Item__c> finalList = new List<Quote_Line_Item__c>();
                    finalList = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    for(Integer i = items.size()-1; i>=0;i--)
                    {
                        for(Quote_Line_Item__c q:items){
                               
                                if((finallist.get(i)!= items.get(i)) && (items[i].Departure_Date_Time__c < items[i+1].Departure_Date_Time__c))
                                finalList.add(items.get(i));
                        }
                        //mapQuoteItems.put(Integer.valueOf(currentOptionId),finalList);
                    }
                    update finalList;
                    finalList.sort();
                    Quote_Option__c qot = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
                    Flight_Package_Cost = qot.Flight_Package_Cost__c;
                      rollup = qot.Flight_Price_Roll_up__c;
                   
                    system.debug('rollup'+rollup);
                    system.debug('Airline'+finalList);
                    mapQuoteItems.put(Integer.valueOf(currentOptionId), finalList);   
                }                
                addAmount(airline,currentoptionid);
                ispricevalid();
                airline = new Quote_Line_Item__c();
            }
            
        } else if(lineItemName == 'Hotel'){
            
            if(validateHotelDetails()){
                if(hotel.dtme_price__c == null) {
                        hotel.dtme_price__c = 0;
                    }
                hotel.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
                hotel.Type__c = 'Hotel';
                
                if(!(hotel != null && hotel.Id != null)){
                    hotel.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
                    insert hotel;
                    system.debug(hotel);
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(hotel);
                    //added as a part of v1.3
                    List<Quote_Line_Item__c> finalList = new List<Quote_Line_Item__c>();
                    finalList = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    for(Integer i = items.size()-1; i>=0;i--)
                    {
                        for(Quote_Line_Item__c q:items){
                                if((finallist.get(i)!= items.get(i)) && (items[i].Check_In__c < items[i+1].Check_In__c))
                                finalList.add(items.get(i));
                        }
                        //mapQuoteItems.put(Integer.valueOf(currentOptionId),finalList);
                    }
                    finalList.sort();
                    mapQuoteItems.put(Integer.valueOf(currentOptionId), finalList);
                }else {
                    update hotel;
                    updateData(hotel.Id);
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(hotel);
                    //added as a part of v1.3
                    List<Quote_Line_Item__c> finalList = new List<Quote_Line_Item__c>();
                    finalList = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    for(Integer i = items.size()-1; i>=0;i--)
                    {
                        for(Quote_Line_Item__c q:items){
                                if((finallist.get(i)!= items.get(i)) && (items[i].Check_In__c < items[i+1].Check_In__c))
                                finalList.add(items.get(i));
                        }
                        //mapQuoteItems.put(Integer.valueOf(currentOptionId),finalList);
                    }
                    finalList.sort();
                    mapQuoteItems.put(Integer.valueOf(currentOptionId), finalList);
                }
                
                addAmount(hotel,currentoptionid);
                ispricevalid();
                hotel = new Quote_Line_Item__c();
            }  
        } else if (lineItemName == 'Other'){
            if(validateOtherDetails()){
                if(other.dtme_price__c == null) {
                        other.dtme_price__c = 0;
                    }
                other.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
                other.Type__c = 'Other Services';
                if(!(other != null && other.Id != null)){
                    other.Other_Service_Description__c = otherDesc;
                    other.Quote_Option__c = mapQuoteOptIds.get(currentOptionId);
                    insert other;
                    system.debug(other);
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(other);
                    mapQuoteItems.put(Integer.valueOf(currentOptionId), items);
                }else {
                    other.Other_Service_Description__c = otherDesc;
                    update other;
                    updateData(other.Id);
                    system.debug(other);
                    List<Quote_Line_Item__c> items = mapQuoteItems.get(Integer.valueOf(currentOptionId));
                    items.add(other);
                    mapQuoteItems.put(Integer.valueOf(currentOptionId), items);
                }
                //insert other;
                otherDesc = '';
                
                addAmount(other,currentoptionid);
                ispricevalid();
                other = new Quote_Line_Item__c();
            }
        }
            Quote_Option__c qot = [select Status__c,Flight_Price__c,Flight_Package_Cost__c,Flight_Price_Roll_up__c,Price_Roll_up__c from Quote_Option__c where Id = :mapquoteid FOR UPDATE];
            if(totaloptionflightPrice.get(Integer.valueof(currentoptionId)) == 0){
                if(qot.Price_Roll_up__c != 0)
            	totalPriceRollup = qot.Price_Roll_up__c;
            }
                
            else
                totalPriceRollup = (qot.Price_Roll_up__c + totaloptionflightPrice.get(Integer.valueof(currentoptionId))) - qot.Flight_Price_Roll_up__c;
            totalPriceRollup = totalPriceRollup.setScale(2);
            }else{
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Cannot add or edit a confirmed option.'));
    }
    }
    
    public Map<String, Id> mapQuoteOptIds {get;set;} 
    public integer totalOptions {get;set;}
    public integer currentOpt {get;set;}
    public Map<String, String> mapQuoteWithAmts {get;set;}
    public Map<String, Quote_Option__c> mapQuoteOpts {get;set;}
    public String tempQuoteAmt {get;set;}
    public void saveQuoteOption(){
        tempQuoteAmt = '';
        if(currentOptionId != null && currentOptionId != '' && currentOptionId != 'QuoteInformation'){
            Quote_Option__c qo = new Quote_Option__c();
            qo.Id = mapQuoteOptIds.get(currentOptionId);
           // if bottom price is different than sum total , replace bottom price with sum total 
           // isPriceValid();
           // if (priceisvalid == false){
           //   totalPrice = String.valueOf(totalAmount);
           // }
          
            //qo.Price__c = totalPrice != '' ? Decimal.valueOf(totalPrice) : 0;
            //totalOptionAmount
            //if(totalOptionAmount.get(Integer.valueOf(currentOptionId))!=0){
                      
            system.debug('totalPriceRollup'+totalPriceRollup);
            qo.Price__c = totalPriceRollup;
            
            //}
           // else
              //  qo.Price__c = totalOptionAmount.get(Integer.valueOf(currentOptionId));
            qo.Flight_Price__c = totaloptionFlightPrice.get(Integer.valueOf(currentOptionId));
            system.debug('!!'+qo.Flight_Price__c);
            system.debug('Price total'+qo.Price__c);
            qo.Tailormade_Itinerary__c = tailormadeItinerary;//jed-jul21 T-00413
            qOptionId = qo.Id;//jed T-00413               
            qo.CurrencyIsoCode = recCurrency;
            qo.Org_Notes__c = notes;
            update qo;
            //mapQuoteOpts.put(currentOptionId, qo);
            tempQuoteAmt = totalPrice;
            
            system.debug('updating qoute option ');
            system.debug(currentOptionId);
            
            totalOptions = mapQuoteOptIds.keySet().size();
            currentOpt = Integer.valueOf(currentOptionId/*.split('-')[1]*/);
            if(totalOptions == currentOpt ){
                currentOptionId = currentOptionId;
                //totalPrice = '0';
            }else{
                currentOpt += 1;
                currentOptionId = ''+currentOpt;
            }
            system.debug('Saving ' + currentOptionId);
            //currentOptionId
            isClone = false;
        }
        else if(currentOptionId == 'QuoteInformation'){
           currentOptionId = '' + 1; 
        }     
    
    }
    
    public void saveQuoteOption2(){
        tempQuoteAmt = '';
        if(currentOptionId != null && currentOptionId != ''){
            Quote_Option__c qo = new Quote_Option__c();
            qo.Id = mapQuoteOptIds.get(currentOptionId);
           	qo.Org_Notes__c = notes;//v1.7
           // if bottom price is different than sum total , replace bottom price with sum total 
           // isPriceValid();
           // if (priceisvalid == false){
           //   totalPrice = String.valueOf(totalAmount);
           // }
          
            //qo.Price__c = totalPrice != '' ? Decimal.valueOf(totalPrice) : 0;
            qo.Price__c = totalOptionAmount.get(Integer.valueOf(currentOptionId));
            qo.Flight_Price__c =totalOptionFlightPrice.get(Integer.valueOf(currentOptionId));
            qo.Tailormade_Itinerary__c = tailormadeItinerary;//jed-jul21 T-00413
            system.debug('totalOptionFlightPrice'+totalOptionFlightPrice);
            system.debug('clone price'+qo.Flight_Price__c);
            system.debug('Clone Price '+qo.Price__c);
            qo.CurrencyIsoCode = recCurrency;
            update qo;
            qOptionId = qo.Id;//jed T-00413 
            //mapQuoteOpts.put(currentOptionId, qo);
            tempQuoteAmt = totalPrice;
            
            system.debug('updating qoute option ');
            system.debug(currentOptionId);
            
           
            isClone = false;
        }        
    }
    
   
    public String emailText {get;set;}
    
    public class CaseDetail {
        public String CustomerName {get;set;}
        public String CustomerRecId {get;set;}
        public String CaseRecId {get;set;}
        public String CaseNumber {get;set;}
        public String Destination {get;set;}
        public String TravellerType {get;set;}
        public String DateFrom {get;set;}
        public String DateTo {get;set;}
        public String Errata{get;set;}
        public Integer NoOfAdults {get;set;}
        public Integer NoOfChildren {get;set;}
        public Integer NoOfOptions {get;set;}
        public Boolean Tailormade {get;set;}//jed-jul22 T-00413
        public String TailormadeItinerary {get;set;}//jed-jul22 T-00413  
        public Integer NoOfRooms{get;set;}//added as a part of v1.6
        public String Brand{get;set;}//added as a part of v1.6
    }
    
    public class AgeDetail{
        public Quote_Traveller__c ChildTraveller {get;set;}
        public String ChildName {get;set;}
        //public String DateOfBirth {get;set;}
        public string ageOfChild{get;set;}
        public String UID {get;set;}
        public String CSSClass {get;set;}
    }
    
    //v1.5
    public void validateCaseBfrEmail(){
        List<Task> tasksList = new List<Task>([SELECT Id,WhatId,Due_DateTime__c,Status FROM Task WHERE WhatId =:parentRecord.Id AND Due_DateTime__c > :System.now() AND Status = 'Open']); 
        Case currentCase = new Case(); 
        currentCase  = [SELECT Current_User_Profile_Name__c,RecordTypeId FROM Case WHERE Id =: parentRecord.Id];
        string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('dTME - New Enquiry').getRecordTypeId();
        if(currentCase.Current_User_Profile_Name__c.contains('Retail') && currentCase.RecordTypeId == caseRecordTypeId && (tasksList == null || tasksList.size() == 0)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please create a follow up task before sending email'));
        } else {
            showHideEmailPopup = true;
            System.debug('showHideEmailPopup1==>'+showHideEmailPopup);
        }                               
    }
    
    public void closeEmailPopup(){
        showHideEmailPopup = false;
    }
    //end v1.5
 
}
    
    



//////////////////
//
//
//