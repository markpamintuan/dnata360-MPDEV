@isTest
private class SCCCustomerPlaceOrderBatchService_Test {
	
    public static string oStr = '[{"couponLineItems":{},"customerName":"christian jed canlas","customerLocaleID":"en_AE","paymentInstruments":{"0":{"paymentTransaction":"3ea894aa5fad94b61fd7f33da5","maskedCreditCardNumber":"************8769","creditCardExpirationMonth":5,"creditCardNumber":"************8769","creditCardExpired":false,"creditCardHolder":"test jed cc","creditCardNumberLastDigits":"8769","creditCardType":"Visa","UUID":"2213d17de749a3344b54861d74","permanentlyMasked":false,"paymentMethod":"CREDIT_CARD","creditCardExpirationYear":2021}},"priceAdjustments":{},"totalTax":133.4,"customerEmail":"test.jed@test.com","shippingStatus":{"displayValue":"NOTSHIPPED","value":0},"paymentStatus":{"displayValue":"PAID","value":2},"custom":{"cpgOrderCode":"MAR/00012701/080420","passengers":{"0":"{\"services\":[\"d8ada243407a174175072ab92b\",\"61a7ccc01c8f4020cd3c73fe30\",\"6a86b8ec61ddf9f95392cb903a\",\"6f686133339b2e8d439a50f3d1\"],\"title\":\"\",\"firstName\":\"test\",\"lastName\":\"test\",\"day\":\"2\",\"month\":\"2\",\"year\":\"1940\",\"age\":\"80\",\"passengerClass\":\"economy\",\"save\":false,\"additional\":\"\",\"index\":0}"},"paymentCaptured":true,"siteID":"marhaba","sscSyncStatus":{"displayValue":"Order Created","value":"created"},"successBooking":true},"productQuantityTotal":4,"billingAddress":{"UUID":"ec66aa74ae52fa46c0b6e81656","creationDate":{},"firstName":"test jed","phone":"+971 123123123","lastName":"cc","city":"Angeles City","countryCode":{"displayValue":"PH","value":"PH"},"address1":"123 abc 123","custom":{},"fullName":"test jed cc"},"productLineItems":{"0":{"gift":false,"productID":"DXB_LNG_MRB_4H_T3_D","productName":"T3 Lounge - 4 Hours","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"6f64f72a74dd62207780217c06","manufacturerName":"MH","UUID":"bc8181743ad367ebd1ac85cf1c","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"T3 Lounge - 4 Hours","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":1,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":441,"quantityValue":1},"1":{"gift":false,"productID":"DXB_LNG_MRB_8H_T3_D","productName":"T3 Lounge - 8 Hours","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"12971319b79ccaee91532258ab","manufacturerName":"MH","UUID":"7f37dea0481bb4a13b4e4aea96","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"T3 Lounge - 8 Hours","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":2,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":882,"quantityValue":1},"2":{"gift":false,"productID":"FRA_MAAS_A","productName":"Frankfurt Meet and Greet Service","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"8ed0d6307098c3cd19c4623361","manufacturerName":"MH","UUID":"99af6773c46be03d1bf1d0790a","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"Frankfurt Meet and Greet Service","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":3,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":492.8,"quantityValue":1},"3":{"gift":false,"productID":"FRA_MAAS_A","productName":"Frankfurt Meet and Greet Service","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"8ed0d6307098c3cd19c4623361","manufacturerName":"MH","UUID":"1bb5cf1e4f4302fb243b7b16fb","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"Frankfurt Meet and Greet Service","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":4,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":985.6,"quantityValue":1}},"adjustedMerchandizeTotalGrossPrice":2801.4,"status":{"displayValue":"NEW","value":3},"adjustedShippingTotalPrice":0,"totalGrossPrice":2801.4,"shippingPriceAdjustments":{},"UUID":"1721ccaa161162a23a6d1dccab","orderNo":"IN00012701","creationDate":{},"shipments":{"0":{"gift":false,"adjustedShippingTotalGrossPrice":0,"productLineItems":{"0":{"gift":false,"productID":"DXB_LNG_MRB_4H_T3_D","productName":"T3 Lounge - 4 Hours","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"6f64f72a74dd62207780217c06","manufacturerName":"MH","UUID":"bc8181743ad367ebd1ac85cf1c","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"T3 Lounge - 4 Hours","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":1,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":441,"quantityValue":1},"1":{"gift":false,"productID":"DXB_LNG_MRB_8H_T3_D","productName":"T3 Lounge - 8 Hours","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"12971319b79ccaee91532258ab","manufacturerName":"MH","UUID":"7f37dea0481bb4a13b4e4aea96","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"T3 Lounge - 8 Hours","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":2,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":882,"quantityValue":1},"2":{"gift":false,"productID":"FRA_MAAS_A","productName":"Frankfurt Meet and Greet Service","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"8ed0d6307098c3cd19c4623361","manufacturerName":"MH","UUID":"99af6773c46be03d1bf1d0790a","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"Frankfurt Meet and Greet Service","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":3,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":492.8,"quantityValue":1},"3":{"gift":false,"productID":"FRA_MAAS_A","productName":"Frankfurt Meet and Greet Service","catalogProduct":true,"minOrderQuantityValue":1,"bundledProductLineItem":false,"productUUID":"8ed0d6307098c3cd19c4623361","manufacturerName":"MH","UUID":"1bb5cf1e4f4302fb243b7b16fb","shipment":{"UUID":"f1345dfb67f26f85e725dd4549","ID":"me"},"lineItemText":"Frankfurt Meet and Greet Service","optionProductLineItem":false,"taxRate":0.05,"taxClassID":"AE VDU STANDARD 5%","position":4,"bonusProductLineItem":false,"stepQuantityValue":1,"priceValue":985.6,"quantityValue":1}},"ID":"me","adjustedShippingTotalNetPrice":0,"shippingTotalNetPrice":0,"merchandizeTotalPrice":2801.4,"adjustedMerchandizeTotalGrossPrice":2801.4,"adjustedShippingTotalPrice":0,"totalGrossPrice":2801.4,"adjustedMerchandizeTotalTax":133.4,"merchandizeTotalNetPrice":2668,"default":true,"shippingTotalTax":0,"shipmentNo":"00064001","shippingTotalGrossPrice":0,"shippingAddress":{"UUID":"afc65bd2c9dd0a5dba45b8ccc2","creationDate":{},"countryCode":{"displayValue":"","value":""},"custom":{}},"shippingPriceAdjustments":{},"merchandizeTotalTax":133.4,"shippingMethodID":"freeShipping","totalTax":133.4,"UUID":"f1345dfb67f26f85e725dd4549","adjustedMerchandizeTotalPrice":2801.4,"shippingMethod":{"displayName":"Free Shipping","ID":"freeShipping","UUID":"d4def7749ac495d57f726d698b","custom":{"storePickupEnabled":false},"creationDate":{},"taxClassID":"freeTax","dependentMethods":{},"defaultMethod":true,"online":true,"currencyCode":"AED"},"totalNetPrice":2668,"giftCertificateLineItems":{},"adjustedMerchandizeTotalNetPrice":2668,"creationDate":{},"adjustedShippingTotalTax":0,"merchandizeTotalGrossPrice":2801.4,"shippingStatus":{"displayValue":"NOTSHIPPED","value":0},"shippingLineItems":{"0":{"shippingPriceAdjustments":{},"netPrice":0,"taxBasis":0,"grossPrice":0,"adjustedGrossPrice":0,"price":0,"ID":"STANDARD_SHIPPING","UUID":"3d8bbebae8e3f55b772c49c771","basePrice":0,"lineItemText":"Shipping","tax":0,"creationDate":{},"taxRate":0,"taxClassID":"freeTax","adjustedPrice":0,"custom":{},"adjustedTax":0,"priceValue":0,"adjustedNetPrice":0}},"proratedMerchandizeTotalPrice":2801.4,"shippingTotalPrice":0,"custom":{}}},"customerNo":"00041501","customer":{"authenticated":false,"registered":true,"ID":"ab1Qvnd5TuIqH01riKrlLtnzuK","externallyAuthenticated":false,"anonymous":false},"site_id":"dnata-UAE"}]';
    public static String body = '[{"customerName":"christian jed canlas","customerEmail":"test.jed@test.com","orderNo":"12345","status":"Draft","customerNo":"00041501","custom":{"siteID":"marhaba"}},{"orderNo":"23456","status":"Draft","custom":{"siteID":"Arabian Adventures"},"customerNo":"00041502"}]';
    public static String body2 = '[{"customerName":"christian jed canlas","customerEmail":"test.jed2@test.com","orderNo":"12345","status":"Draft","custom":{"siteID":"marhaba"}},{"orderNo":"23456","status":"Draft","custom":{"siteID":"Arabian Adventures"}}]';
    @testSetup 
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();    	
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();  
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});        
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'orderNo'=>'SFCC_Order_Number__c', 'crmcontact_id'=>'Order_Contact__c', 'status'=>'Status', 'order_total'=>'SFCC_Order_Total__c'}, 'Order');             
        SCCConnectorPostInstallScript.insertCustomSettingsData();
    }
    
    
    @isTest 
    static void test_create_1() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];   
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        //List<SCCCustomerOrderResponse> l = SCCCustomerPlaceOrderBatchService.createAccountOrderRecord(req, new SCCFileLogger);
        List<Order> orders = [Select Id, SFCC_Order_Number__c from order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();  
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        //System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));
        
    }
    
    @isTest 
    static void test_create_2() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];   
        req.requestBody = Blob.valueOf(body2);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        //List<SCCCustomerOrderResponse> l = SCCCustomerPlaceOrderBatchService.createAccountOrderRecord(req, new SCCFileLogger);
        List<Order> orders = [Select Id, SFCC_Order_Number__c from order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();  
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        //System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));
        
    }
    

}