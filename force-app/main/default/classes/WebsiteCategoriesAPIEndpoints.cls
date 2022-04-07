/**************************************************************************************************
* Name               : WebsiteCategoriesAPIEndpoints 
* Description        : This is the endpoint class for the integration with the website and categories
* Created Date       : 13-jun-2019                                                                 
* Created By         : Keith Rogers                                                       
* ----------------------------------------------------------------------------------------------- 

**************************************************************************************************/
@RestResource(urlMapping='/website-categories')

global class WebsiteCategoriesAPIEndpoints {

    @HttpGet //Need to make a dynamic query here 
    global static List<WebsiteDataStructure.Category> getCategories() {
        RestRequest request = RestContext.request;
        List<WebsiteDataStructure.Category> lCategoryResponse = new List<WebsiteDataStructure.Category>();
		String derwentBookingId = '';
		String bookingTypeNumber = '';
		String categoryGroupName = '';

		derwentBookingId = request.params.get('booking-id');
		bookingTypeNumber = request.params.get('booking-type-number');
		categoryGroupName = request.params.get('category-group-name'); 

		if(derwentBookingId!=null){
			Booking__c book = new Booking__c();
			book = queryBooking(derwentBookingId);
			String bookingType = '%'+book.Org_Booking_Type__c+'%';
		 
	        for(Travel_Republic_Category__mdt catMap: [SELECT   Category_Group__c, Category_Id__c,  Category_Text__c,   Product_Types__c  FROM Travel_Republic_Category__mdt WHERE Product_Types__c LIKE: bookingType AND Do_Not_Show_On_Website__c = FALSE ]){
	            lCategoryResponse.add(new WebsiteDataStructure.Category(catMap.Category_Text__c,catMap.Category_Id__c));
	        }
	        return lCategoryResponse;
		}

		if(bookingTypeNumber!=null){
			String bookingType = '%'+ bookingTypeNumber+'-%'; 		
	        for(Travel_Republic_Category__mdt catMap: [SELECT   Category_Group__c,  Category_Id__c,   Category_Text__c,   Product_Types__c  FROM Travel_Republic_Category__mdt  WHERE Product_Types__c LIKE: bookingType AND Do_Not_Show_On_Website__c = FALSE]){
	            lCategoryResponse.add(new WebsiteDataStructure.Category(catMap.Category_Text__c,catMap.Category_Id__c));
	        }
	        return lCategoryResponse;
		}

		if(categoryGroupName!=null){		
	        for(Travel_Republic_Category__mdt catMap: [SELECT   Category_Group__c, 
	                                                            Category_Id__c, 
	                                                            Category_Text__c, 
	                                                            Product_Types__c
	                                                    FROM Travel_Republic_Category__mdt
	                                                    WHERE Category_Group__c =: categoryGroupName
	                                                    AND Is_Default_Text_For_Category_Group__c = TRUE]){
	            lCategoryResponse.add(new WebsiteDataStructure.Category(catMap.Category_Text__c,catMap.Category_Id__c));
	        }
	        return lCategoryResponse;
		}
        return lCategoryResponse;

    }


    private static Booking__c queryBooking(String derwentBookingId){
        Id bookingItemRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();               
  		Booking__c book = new Booking__c();

        book = [ SELECT Id, 
                    Org_Booking_Type__c, 
                    Booking_ID__c
                FROM Booking__c 
                WHERE Booking_ID__c =: derwentBookingId 
                AND RecordTypeId =: bookingItemRecordTypeId
                Limit 1];
        return book;
    }
}