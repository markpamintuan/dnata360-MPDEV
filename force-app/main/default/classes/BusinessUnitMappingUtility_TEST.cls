@isTest
public class BusinessUnitMappingUtility_TEST {
	@testSetup static void dataSetup(){
		Id accountId = TestDataFactory.createEKUK_AccountId();
		system.debug('#### dataSetup with accountId: ' + accountId);
		
				
		BusinessHours bhs = [select id from BusinessHours where IsDefault=true limit 1];
		TestDataFactory.createEntitlement(accountId, bhs.Id);
		TestDataFactory.createBusinessUnitRecordsEKH(bhs.Id);
		//Create Cases
		
	}

	@isTest static void testQuery() {
		BusinessUnitMappingUtility.populateBusinessQueueMap();
        BusinessUnitMappingUtility.getBusinessUnitMap();
	}
}