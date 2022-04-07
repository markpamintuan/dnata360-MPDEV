/**************************************************************************************************
* Name               : QuotePDFGenerationController 
* Description        : This is the quotes pdf class where pdf format is generated.           
* Created Date       : 09-May-2018                                                                 
* Created By         : Evendo                                                      
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR        DATE           COMMENTS                
* v1.0        Evendo        08-Aug-2018    Initial version
* v1.1        Sri Bala      27-Nov-2018    T-00302 -  Flight Class on Quotation     
* v1.2        Sri Bala		03-Mar-2019    T-00472 - SF Quote VF and PDF for Derwent Quotes
* v1.3        Sri bala      11-Mar-2019    T-00499 - Quotation changes for Retail
* v1.4        Mark	        22-Apr-2019    T-00545 - Staff signature in Quote
* v1.5		  Mark			24-Jul-2019	   T-00478 - dynamic Contact Number for dnata/emiratesholidays
* v1.6        Sri Bala      14-Jul-2019    To display notes on quote pdf for TRP
* v1.7        Sri Bala      05-Aug-2019    Display package Cost for TRP
* v1.8        Sri Bala      03-11-2019     Total Package Cost
* v1.9		  Mark			13-Feb-2020	   T-00970 - made store contact number displayed on quote pdf
* v1.10       PwC           23-Mar-2020    TRP Total Package fix
**************************************************************************************************/


public class QuotePDFGenerationController {
    
    public Quote_Header__c record {get;set;}
    public List<Quote_Option__c> options {get;set;}
    public List<Quote_Line_Item__c> lineItems {get;set;}
    public List<Quote_Traveller__c> travellers {get;set;}
    public List<Quote_Product_Segment__c> prodSegment{get;set;} //added as a part of v1.2
    public Map<String, Services> mapOptionWithServices {get;set;}
    public Integer flightSize{get;set;}
    public Integer HotelSize{get;set;}
    public integer noOfAdults {get;set;}
    public integer noOfChildren {get;set;}
    public integer noOfInfants {get;set;}
    public Decimal flightPrice{get;set;}
    public Boolean qflag = false;
    public Map<String,Boolean> totalpricematchMap{get;set;} //v1.10
    public Boolean totalpricematch{get;set;}
    public Decimal totalprice{get;set;}//v1.6
    public Map<String,Boolean> setFPflag {get;set;}
    
    public QuotePDFGenerationController(ApexPages.StandardController stdController) {
        this.record = (Quote_Header__c)stdController.getRecord();
        totalpricematchMap = new Map<String,Boolean>();//v1.10
        setFPflag = new Map<String,Boolean>();
        mapOptionWithServices = new Map<String, Services>();
        noOfAdults = 0;
        noOfChildren = 0;
        totalprice = 0.0;//v1.8
        noOfInfants = 0;
        flightprice = 0;
        if(this.record.Id != null ){
            //Edited as a part of v1.1
                        record = [SELECT Case__r.Org_Destination_list__c,Quote_Amount__c,Tailormade__c,Case__r.Org_Destinations__c,Case__r.Record_Type_Name__c,Case__r.Org_Case_Owner__c,No_of_Adults__c,
                        No_of_Children__c,No_of_Infants__c,Case__c,Case__r.Org_Destination__c,CreatedById,CreatedDate,CurrencyIsoCode,Customer__c,Customer__r.Salutation,
                        Customer__r.Name,Disclaimer__c, Duration__c,Date_From__c,Date_To__c,Id,Name,Price__c,Quote_Ref_No__c,Status__c,Errata__c, Case__r.Org_Brand__c 
                      FROM Quote_Header__c 
                      WHERE Id = :this.record.Id];//jed - T-00413
                      
            // changed order by Date_Calculated__c top Departure date and Check in
            options = new List<Quote_Option__c>([SELECT Id, Name, Flight_Price__c, Org_Notes__c, Tailormade_Itinerary__c, Flight_Price_Roll_up__c, Flight_Package_Cost__c, Hotel_Package_Cost__c, Additional_Services_Package_Cost__c,
                                                    CurrencyISOCode, CreatedById, CreatedDate, Price__c,Quote_Price__c, Quote_Header__c, Quote_Header__r.RecordType.Name,Status__c,
                                                	(SELECT Duration__c,Additional_Details__c,Airline__c,Org_Airline__c,Arrival_Date_Time__c,Check_In__c,Check_Out__c,CreatedById,CreatedDate,CurrencyIsoCode,Departure_Date_Time__c,
                                                	    dtme_price__c,Flight_Details__c,Flight_No__c,From_Airport__c,From__c,Hotel_Details__c,Hotel_Location__c,Hotel_Name__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                                	    Meal_Type__c,Name,Other_Service_Description__c,Other_Service_Type__c,Quote_Option__c,Room_Type__c,SystemModstamp,To_Airport__c,To__c,Type__c,Flight_Class__c,No_Of_Rooms__c
                                                	 FROM Quote_Line_Items__r
                                                	 ORDER BY Departure_Date_Time__c,Check_in__c)
                                                 FROM Quote_Option__c
                                                 WHERE Quote_Header__c = :record.Id 
                                                 ORDER BY  Option_Number__c ASC]); //jed - T-00413 // Added Org_Notes__c as a part of v1.6
                                                  
            // added as a part of v1.2
            prodSegment = new List<Quote_Product_Segment__c>([Select Arrival_Date__c,Quote_Line_Item__r.Type__c,Quote_Line_Item__r.Flight_No__c,Carrier_Name__c,Departure_Airport_Title__c,Departure_Date__c,Destination_Airport_Title__c,Description__c, Quote_Line_Item__r.dtme_price__c ,Destination_Terminal__c,Flight_Number__c,SupplierFareClass__c,Quote_Line_Item__r.Hotel_Name__c,Quote_Line_Item__r.Room_Type__c,Quote_Line_Item__r.Check_In__c,Quote_Line_Item__r.Check_Out__c,Quote_Line_Item__r.Duration__c ,Quote_Line_Item__r.Meal_Type__c ,Quote_Line_Item__r.Hotel_Details__c FROM Quote_Product_Segment__c where Quote_Line_Item__r.Quote_Option__c IN: options]);
            lineItems = new List<Quote_Line_Item__c>([Select Flight_Details__c,Other_Service_Type__c,Title__c,Other_Service_Description__c,PickUpDate__c,PickUpLocation__c,Additional_Details__c,Check_In__c,Duration__c,dtme_price__c,Check_Out__c,CheckInDate__c,CheckOutDate__c,End_Date__c,Hotel_country__c,Hotel_Details__c,Hotel_Location__c,Hotel_Name__c,Hotel_Province__c,Meal_Type__c,No_Of_Rooms__c,ID,Type__c,Room_Type__c   FROM Quote_Line_Item__c where Quote_Option__r.Quote_Header__c = :record.Id]);
            noOfAdults = Integer.valueOf(record.No_of_Adults__c);
            noOfChildren = 0; //Integer.valueOf(record.No_of_Children__c);
            noOfInfants = 0; //Integer.valueOf(record.No_of_Infants__c);
            travellers = new List<Quote_Traveller__c>( [SELECT Age_of_child__c ,Age_in_yrs__c,Id,Name,Quote__c,Traveller_Type__c FROM Quote_Traveller__c Where Quote__c = :record.Id]);
            //changed as part of v1.1
            for(Quote_Traveller__c qt : travellers){
                if( qt.Traveller_Type__c == 'Infant'){
                    noOfInfants++;
                } else if( qt.Traveller_Type__c == 'Child'){
                    noOfChildren++;
                }
            }
            
            /*if(travellers != null && travellers.size() > 0){
for(Quote_Traveller__c qt : travellers){
if(qt.Traveller_Type__c == 'Adult'){
noOfAdults++;
} else if(qt.Traveller_Type__c == 'Child'){
noOfChildren++;
} else if(qt.Traveller_Type__c == 'Infant'){
noOfInfants++;
}
}
}*/
                        if(!options.isEmpty()){
                /*List<Flights> tempFlights = new List<Flights>();
List<Hotels> tempHotels = new List<Hotels>();
List<AdditionalServices> tempAdditionalServices = new List<AdditionalServices>();*/
                integer counter = 1;
                
                for(Quote_Option__c op : options){
                    system.debug('Record Type'+op.Quote_Header__r.RecordType.Name);
                    Decimal fpc = op.Flight_Price__c ;
                    if(fpc > 0)
                        setFpflag.put('OPTION '+counter , true);
                    else
                        setFpflag.put('OPTION '+counter , false);
                    List<Flights> tempFlights = new List<Flights>();
                    List<Hotels> tempHotels = new List<Hotels>();
                    List<AdditionalServices> tempAdditionalServices = new List<AdditionalServices>();
                    Services s = new Services();
                    for(Quote_Line_Item__c li : op.Quote_Line_Items__r){
                        if(op.Quote_Header__r.RecordType.Name == 'SF Quote') //added as a part of v1.2
                        {
                            system.debug('Entered');
                            if(li.Type__c == 'Flight'){
                                Flights f = new Flights();
                                f.Airline  = li.Airline__c ;
                                f.Routing  = li.From__c + ' to ' + li.To__c;
                                f.FlightDate  = li.Departure_Date_Time__c.format() ;
                                f.FlightNo  = li.Flight_No__c ;
                                f.DepartureDateTime  = li.Departure_Date_Time__c.format() ;
                                f.ArrivalDateTime  = li.Arrival_Date_Time__c.format() ;
                                f.FlightDetails = li.Flight_Details__c;
                                f.flightprice = String.valueOf(li.dtme_price__c);
                                //Added as a part of v1.1
                                f.FlightClass = li.Flight_Class__c;
                                tempFlights.add(f);
                                if(f.flightprice !=null){
                                	flightPrice =  Decimal.ValueOf(f.flightprice);
                                    totalprice += Decimal.valueOf(f.flightprice);//v1.8
                                }
                            } else if(li.Type__c == 'Hotel'){
                                Hotels h = new Hotels();
                                h.HotelName = li.Hotel_Name__c;
                                h.RoomType  = li.Room_Type__c ;
                                h.CheckIn  = li.Check_In__c.format() ;
                                h.CheckOut  = li.Check_Out__c.format() ;
                                h.Duration  = li.Duration__c ;
                                system.debug('Duration'+ li.Duration__c);
                                h.MealType  = li.Meal_Type__c ;
                                h.Transfers  = 'None' ;
                                h.NoOfRooms = Integer.valueof(li.No_Of_Rooms__c);
                                h.HotelDetails = li.Hotel_Details__c;
                                h.HotelCity = li.Hotel_Location__c;
                                h.hotelprice = String.valueOf(li.dtme_price__c);
                                tempHotels.add(h);
                                if(h.hotelprice != null){
                                    totalprice += Decimal.valueOf(h.hotelprice);//v1.8
                                }
                                
                            } else if(li.Type__c == 'Other Services'){
                                AdditionalServices ads = new AdditionalServices();
                                ads.ServiceType = li.Other_Service_Type__c;
                                ads.ServiceDesc = li.Other_Service_Description__c;
                                ads.AddDetails = li.Additional_Details__c;
                                ads.ASPrice = String.valueOf(li.dtme_price__c);
                                tempAdditionalServices.add(ads);
                                if(ads.AsPrice != null){
                                    totalprice += Decimal.valueOf(ads.AsPrice);//v1.8
                                }
                            } else if(li.Type__c == 'Package'){
                                Flights f = new Flights();
                                f.FlightDetails = li.Flight_Details__c;
                                tempFlights.add(f);
                                
                                Hotels h = new Hotels();
                                h.HotelDetails = li.Hotel_Details__c;
                                tempHotels.add(h);
                                
                                AdditionalServices ads = new AdditionalServices();
                                ads.AddDetails = li.Additional_Details__c;
                                tempAdditionalServices.add(ads);
                            }
                        }
                        
                    }
                    
                    //s.add(tempFlights);
                    //s.add(tempHotels);
                    //s.add(tempAdditionalServices);
                    // }  
                    //added by Sri Bala as a part of v1.2
                    if(op.Quote_Header__r.RecordType.Name == 'Derwent Quote'){
                        for(Quote_Product_Segment__c qps :prodSegment )
                        {
                            if(qps.Quote_Line_Item__r.Type__c == 'Flight'){
                                    Flights f = new Flights();
                                    f.Airline  = qps.Carrier_Name__c;
                                    f.Routing  = qps.Departure_Airport_Title__c + ' to ' + qps.Destination_Airport_Title__c;
                                    f.FlightDate  = qps.Departure_Date__c.format() ;
                                    f.FlightNo  = qps.Flight_Number__c ;
                                    f.DepartureDateTime  = qps.Departure_Date__c.format() ;
                                    f.ArrivalDateTime  = qps.Arrival_Date__c.format() ;
                                    f.FlightDetails = qps.Description__c;
                                    f.flightprice = String.valueOf(qps.Quote_Line_Item__r.dtme_price__c);
                                    //Added as a part of v1.1
                                    //f.FlightClass = li.Flight_Class__c;
                                    tempFlights.add(f);
                                } 
                        }
                            
                                for(Quote_Line_Item__c li : lineItems){
                                    system.debug('Hotel'+lineItems);
                                  if(li.Type__c == 'Accommodation'){
                                    Hotels h = new Hotels();
                                    h.HotelName = li.Hotel_Name__c;
                                    h.RoomType  = li.Room_Type__c ;
                                    h.CheckIn  = li.CheckInDate__c.format() ;
                                    h.CheckOut  = li.CheckOutDate__c.format() ;
                                    h.Duration  = li.Duration__c ;
                                    h.MealType  = li.Meal_Type__c ;
                                    h.Transfers  = 'None' ;
                                    h.HotelDetails = li.Hotel_Details__c;
                                    h.HotelCity = li.Hotel_Location__c;
                                    h.hotelprice = String.valueOf(li.dtme_price__c);
                                    tempHotels.add(h);
                                    system.debug('Hotels');  
                                }else if(li.Type__c == 'Transfer' ){
                                AdditionalServices ads = new AdditionalServices();
                                ads.ServiceType = li.Type__c;
                                ads.ServiceDesc = li.Title__c;
                                ads.AddDetails = li.Additional_Details__c;
                                ads.ASPrice = String.valueOf(li.dtme_price__c);
                                tempAdditionalServices.add(ads);
                            }else if(li.Type__c == 'Insurance' ){
                                AdditionalServices ads = new AdditionalServices();
                                ads.ServiceType = li.Type__c;
                                ads.ServiceDesc = li.Title__c;
                                ads.AddDetails = li.Additional_Details__c;
                                ads.ASPrice = String.valueOf(li.dtme_price__c);
                                tempAdditionalServices.add(ads);
                            }else if(li.Type__c == 'Marhaba' ){
                                AdditionalServices ads = new AdditionalServices();
                                ads.ServiceType = li.Type__c;
                                ads.ServiceDesc = li.Title__c;
                                ads.AddDetails = li.Additional_Details__c;
                                ads.ASPrice = String.valueOf(li.dtme_price__c);
                                tempAdditionalServices.add(ads);
                            } else if(li.Type__c == 'Package'){
                                Flights f = new Flights();
                                f.FlightDetails = li.Flight_Details__c;
                                tempFlights.add(f);
                                
                                Hotels h = new Hotels();
                                h.HotelDetails = li.Hotel_Details__c;
                                tempHotels.add(h);
                                
                                AdditionalServices ads = new AdditionalServices();
                                ads.AddDetails = li.Additional_Details__c;
                                tempAdditionalServices.add(ads);
                            }
                                
                            }
						 		
                        
                   
                    } 
                    //end of v1.2
                    s.Flights = tempFlights;
                    s.Hotels = tempHotels;
                    s.Notes = op.Org_Notes__c; //v1.6
                    s.AdditionalServices = tempAdditionalServices;
                    s.tailormadeOption = op.Tailormade_Itinerary__c;//jed - T-00413
                    //added by sribala
                    if(op.Quote_Header__r.RecordType.Name == 'Derwent Quote')
                    	s.TotalPrice = record.Quote_Amount__c;
                    else 
                        s.TotalPrice  = op.Price__c;
                    if(op.Flight_Price__c!=0){
                         s.FlightPrice = op.Flight_Price__c;
                        qflag = true;
                    }
                    //Added as a part of v1.6
                    system.debug('totalprice >>>> '+totalprice);
                    system.debug('s.TotalPrice >>>> '+s.TotalPrice);
                    if(s.TotalPrice == totalprice){
                        totalpricematch = true ;
                        totalpricematchMap.put('OPTION '+ counter,true);//v1.10
                    }
                        
                    else{ 
                        totalpricematch = false;
                        totalpricematchMap.put('OPTION '+ counter,false);//v1.10
                    }
                    system.debug('totalpricematch >>> ' +totalpricematchMap);
                    //v1.6
                    s.CurrencyISOCode = op.CurrencyIsoCode;
                    /******* Added as a part of v1.6 ******************/
                    Decimal flightPackage = op.Flight_Price_Roll_up__c.setScale(2);
                    Decimal hotelPackage = op.Hotel_Package_Cost__c.setScale(2);
                    Decimal OtherPackage = op.Additional_Services_Package_Cost__c.setScale(2);
                    s.FLightPackageCost = flightPackage ; // v1.6
                    s.HotelPackageCost = hotelPackage; //v1.6
                    //s.AdditionalServicesPackageCost = OtherPackage;//v1.6
                    /*******End of v1.16****************************/
                    HotelSize = tempHotels.size();
                    flightSize = tempFlights.size();
                    mapOptionWithServices.put('OPTION '+ counter, s);
                    system.debug('Total Cost'+op.Quote_Price__c);
                    system.debug('FlightPrice==>'+op.Flight_Price__c);
                    system.debug('FlightPrice2==>'+s.FlightPrice);
                    counter++;
                }
                            for(String key:mapOptionWithServices.keySet()){
                                for(Flights flt:mapOptionWithServices.get(key).Flights){
                                    if(flt.flightprice != null && flt.flightprice != '' && flt.flightprice != '0'){
                                        mapOptionWithServices.get(key).isFlightPriceVailable = true;
                                    }
                                }
                                for(Hotels htl:mapOptionWithServices.get(key).Hotels){
                                    if(htl.HotelPrice != null && htl.HotelPrice != '' && htl.HotelPrice != '0'){
                                        mapOptionWithServices.get(key).isHotelPriceVailable = true;
                                    }
                                }
                                for(AdditionalServices AdServ:mapOptionWithServices.get(key).AdditionalServices){
                                    if(AdServ.ASPrice != null && AdServ.ASPrice != '' && AdServ.ASPrice != '0'){
                                        mapOptionWithServices.get(key).isAdServicePriceVailable = true;
                                    }
                                }
                            }
                            
                            
            }
        } 
    }
    
    public class Services{
        public List<Flights> Flights {get;set;} 
        public List<Hotels> Hotels {get;set;} 
        public List<AdditionalServices> AdditionalServices {get;set;} 
        public Decimal TotalPrice {get;set;}
        public string Notes{get;set;} //v1.6
        public Decimal FlightPrice {get;set;}
        public boolean isFlightPriceVailable{get;set;}
        public boolean isHotelPriceVailable{get;set;}
        public boolean isAdServicePriceVailable{get;set;}
        public String CurrencyISOCode {get;set;}
        public String tailormadeOption {get;set;}//jed - T-00413
        public Decimal FlightPackageCost{get;set;} //v1.6
        public Decimal HotelPackageCost{get;set;} //added by SB v1.6 
        public Decimal AdditionalServicesPackageCost{get;set;} //added by SB v1.6
        public Services(){
            isFlightPriceVailable = false;
            isHotelPriceVailable = false;
            isAdServicePriceVailable = false;
        }
    }
    //v1.4  - Start
    /**
     * @author: Mark Anthony Pamintuan
     * @date: 22 April 2019
     * @description: method to return dynamic phone number
     * @history:                
     */
    public String dynamicPhoneNumber {
    
        get{
        	//v1.9
	        map<String,String> storeNameNumberMap = new map<String,String>();
	        for(User_Role_And_Store_Map__mdt customMetadataType : [SELECT Store_Name__c, Store_Contact_Number__c, Store_Email__c FROM User_Role_And_Store_Map__mdt]){
	            storeNameNumberMap.put(customMetadataType.Store_Name__c,customMetadataType.Store_Contact_Number__c);
	        }

            String quoteContactNumber;
            User runningUser = [SELECT Phone, Profile.Name, Store__c FROM User WHERE Id =: Userinfo.getUserId()];
            if(runningUser.Profile.Name.containsIgnoreCase('Retail')){
            	if(storeNameNumberMap.containsKey(runningUser.Store__c)){//v1.9
            		quoteContactNumber = storeNameNumberMap.get(runningUser.Store__c);
            	} else {
            		quoteContactNumber = runningUser.Phone;
            	}
            } else {
            	//v1.5
            	if(record.Case__r.Org_Brand__c == 'EKH'){
            		quoteContactNumber = Label.ekh_Contact_Number;            		
            	} else {
            		quoteContactNumber = Label.dnata_Contact_Number;
            	}
            	//End v1.5	
            }
            
            return quoteContactNumber;
        
        }
        set;
    
    }
    //v1.4 - End
    public class Flights{
        public String Airline {get;set;}
        public String Routing {get;set;}
        public String FlightDate {get;set;}
        public String FlightNo {get;set;}
        public String DepartureDateTime {get;set;}
        public String ArrivalDateTime {get;set;}
        public String FlightDetails {get;set;}
        public String flightprice {get;set;}
        //Added as a part of v1.1
        public string FlightClass{get;set;}
    }
    
    public class Hotels {
        public String HotelName {get;set;}
        public String RoomType {get;set;}
        public String CheckIn {get;set;}
        public String CheckOut {get;set;}
        public String Duration {get;set;}
        public String MealType {get;set;}
        public String Transfers {get;set;}
        public String HotelDetails {get;set;}
        public String HotelPrice{get;set;}
        public string HotelCity{get;set;}
        public Integer NoOfRooms{get;set;}
    }
    
    public class AdditionalServices {
        public String ServiceType {get;set;}
        public String ServiceDesc {get;set;}
        public String AddDetails {get;set;}
        public String ASPrice{get;set;}
    }
    
}