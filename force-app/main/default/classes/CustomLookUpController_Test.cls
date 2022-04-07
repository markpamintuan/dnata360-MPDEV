@isTest
private class CustomLookUpController_Test {

    @testSetup
    static void setupData(){
        
        list<Hotel__c> lstHotels = new list<Hotel__c>();
        for(integer i = 0; i < 10; i++){
            Hotel__c hotel = new Hotel__c();
            hotel.Name = 'Hotel Name ' + i;
            hotel.Country__c = 'United Kingdom';
            hotel.Estab_ID__c = '100000' + i;
            hotel.CL_Derwent_Master_Id__c = '0000001' + i;
            lstHotels.add(hotel);
        }   
        
        insert lstHotels;

    }

    static testMethod void testCustomLookupController(){
        
        Hotel__c  hotel1 = [SELECT Id FROM Hotel__c LIMIT 1];
        
        test.startTest();
            
            List <Hotel__c> lstHotels = CustomLookUpController.fetchLookUpValues('Hotel','Hotel__c');
            Hotel__c hotel2 = CustomLookUpController.fetchDefaultLookupValue(hotel1.Id,'Hotel__c');
            
        test.stopTest();    

    }

}