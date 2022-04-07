/******
 * Name         :   DuplicateRecordManagementCntrlTest
 * Description  :   This will be used to provider covrage for following class
 *                  DuplicateRecordManagementCntrl
 *                  DuplicateRecordsHelper
 *                  CommonUtils
 *                  ContainerWrapperClass
 *                  Constants
 *                  ConsolidatedReportCtrl
 ****/
@isTest
private class DuplicateRecordManagementCntrlTest {


    public static string fieldSetName = 'DuplicateTableHeader';
    public static string linkingFieldName = 'LinkingField360__c';

    /********
     * Name         :   createTestData
     * Description  :   THis is for creating data for the test class
     *                  by using test data factory
     ****/
    @testSetup static void createTestData() {

        // creating contact record
        map<string,object> mapContact = new map<string,object>();
        mapContact.put('LastName','Last Name 1'+system.today());
        
        Contact con = TestdataFactory360.createContact(mapContact);
        insert con;
        
        // creating second Contact for searching
        mapContact = new map<string,object>();
        mapContact.put('LastName','Last Name 2'+system.today());
        mapContact.put('LinkingField360__c',con.Id);
        con = TestdataFactory360.createContact(mapContact);
        insert con;
        
        //update contect 2
        con.LinkingField360__c = null;
        update con;

    }

    /***
     * Name         :   validate_FindDuplicates
     * Description  :   This is the method which will provider the covrage for the FindDuplicates method
     ****/
	private static testMethod void validate_FindDuplicates() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
            
        // calling class method to find duplicates
        ContainerWrapperClass.DuplicateWrapper result = DuplicateRecordManagementCntrl.findDuplicates(con.Id,fieldSetName,'Name','id');
            

	}
	
	
	/***
     * Name         :   validate_FindDuplicates
     * Description  :   This is the method which will provider the covrage for the FindDuplicates method
     *                  to generate exception
     ****/
	private static testMethod void validate_FindDuplicatesException() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
            
        // calling class method to find duplicates
        ContainerWrapperClass.DuplicateWrapper result = DuplicateRecordManagementCntrl.findDuplicates(con.Id,fieldSetName,'Name','irrd');
            

	}
	
	
	/***
     * Name         :   validate_FindDuplicates
     * Description  :   This is the method which will provider the covrage for the FindDuplicates method
     *                  when no parameter is passed
     ****/
	private static testMethod void validate_FindDuplicatesParameterNotPassed() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
            
        // calling class method to find duplicates
        ContainerWrapperClass.DuplicateWrapper result = DuplicateRecordManagementCntrl.findDuplicates(con.Id,null,'Name','id');
	}
	
	/***
     * Name         :   validate_getsearchForm
     * Description  :   This is the method which will provider the covrage for the getsearchForm method
     ****/
	private static testMethod void validate_getsearchForm() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
            
        // calling class method to get search form data
        ContainerWrapperClass.SearchWrapper result = DuplicateRecordManagementCntrl.getsearchForm(con.Id,fieldSetName); 
	}
	
	
	/***
     * Name         :   validate_getsearchfetchSearchRecords
     * Description  :   This is the method which will provider the covrage for the getsearchfetchSearchRecords method
     ****/
	private static testMethod void validate_getsearchfetchSearchRecords() {
        string lstName = 'Last Name 1'+system.today();
        string lstName2 = 'Last Name 2'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
        fieldSetName = 'SearchFormFields';
            
        // calling class method to search records
        ContainerWrapperClass.SearchResultWrapper result = DuplicateRecordManagementCntrl.fetchSearchRecords(con.Id, '{"LastName" : "'+lstName2+'"}',fieldSetName, fieldSetName,'Id', JSON.serialize(new List<string>{con.Id}));
	}
	
	
	/***
     * Name         :   validate_fetchLinkedRecords
     * Description  :   This is the method which will provider the covrage for the fetchLinkedRecords method
     ****/
	private static testMethod void validate_fetchLinkedRecords() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
        fieldSetName = 'DisplayFieldSet';
            
        // calling class method to get search form data
        ContainerWrapperClass.SearchResultWrapper result = DuplicateRecordManagementCntrl.fetchLinkedRecords(con.Id,fieldSetName,'Id'); 
	}
	
	
	/***
     * Name         :   validate_fetchLinkedRecords
     * Description  :   This is the method which will provider the covrage for the linkRecords method
     ****/
	private static testMethod void validate_linkRecords() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
        
        // getting seconf contact id which has to be linked
        string lstName2 = 'Last Name 2'+system.today();
        contact con2 = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName2];
        system.assertNotEquals(con2, null ,'Sobejct Recprd Not found');
        
        // calling class method to get search form data
        ContainerWrapperClass.DuplicateWrapper result = DuplicateRecordManagementCntrl.linkRecords(con.Id, fieldSetName, linkingFieldName, con2.Id, 'Id');
	}
	
	
	/***
     * Name         :   validate_deLinkRecord
     * Description  :   This is the method which will provider the covrage for the deLinkRecord method
     ****/
	private static testMethod void validate_deLinkRecord() {
        string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName];
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
        
        // getting seconf contact id which has to be linked
        string lstName2 = 'Last Name 2'+system.today();
        contact con2 = [SELECT ID
                            FROM CONTACT
                            WHERE LastName = :lstName2];
        system.assertNotEquals(con2, null ,'Sobejct Recprd Not found');
        
        // calling class method to get search form data
        ContainerWrapperClass.SearchResultWrapper result = DuplicateRecordManagementCntrl.deLinkRecord(con2.Id, fieldSetName, linkingFieldName,con2.Id, 'Id');
	}
	
	
	/***
     * Name         :   validate_getConsolidatedReport
     * Description  :   This is the method which will provider the covrage for the getsearchfetchSearchRecords method
     ****/
	private static testMethod void validate_getConsolidatedReport() {
        
        // calling class method to search records
        List<Report> reports = ConsolidatedReportCtrl.getConsolidatedReport(UserInfo.getUserId());
	}
	
	
	/***
     * Name         :   validate_getConsolidatedReport
     * Description  :   This is the method which will provider the covrage for the getsearchfetchSearchRecords method
     ****/
	private static testMethod void validate_fetchHistoryLinkedRecords() {
	    
	    string lstName = 'Last Name 1'+system.today();
        contact con = [SELECT ID, LinkingField360__c
                            FROM CONTACT
                            WHERE LastName = :lstName];
                            
        // getting seconf contact id which has to be linked
        string lstName2 = 'Last Name 2'+system.today();
        contact con2 = [SELECT ID,LinkingField360__c
                            FROM CONTACT
                            WHERE LastName = :lstName2];
                            
        system.assertNotEquals(con2, null ,'Sobejct Recprd Not found');
        system.assertNotEquals(con, null ,'Sobejct Recprd Not found');
        
        //Contacthistory ch = [SELECT ContactId,  OldValue,  NewValue FROM Contacthistory WHERE ContactId !=: con.id limit 1];
        //system.debug('\n--ch--'+ch);
        
        // calling class method to search records
        ContainerWrapperClass.SearchResultWrapper result = DuplicateRecordManagementCntrl.fetchHistoryLinkedRecords(con.Id, fieldSetName, linkingFieldName, 'Id');
	}

}