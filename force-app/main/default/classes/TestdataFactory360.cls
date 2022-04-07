/***************
 * Name         :   TestdataFactory
 * Description  :   This is the class which will help in creating new record for test classes
 * 
 ****/
@isTest
public class TestdataFactory360 {

    /**********
     * Name         :   createContact
     * Description  :   This create an contact object and all the field asre passed in parameters
     *              
     * Param        :   @mapContactDetails : Map<field API name and its values
     ******/
	public static contact createContact(map<string,object> mapContactDetails){
	    
	    Contact con = new Contact();
	    
	    if(mapContactDetails != null
	        && !mapContactDetails.isEmpty()){
	    
    	    // making instance of Contact Object
    	    for(string strFields : mapContactDetails.keySet()){
    	        con.put(strFields, mapContactDetails.get(strFields));
    	    }
	    }
	    return con;
	}

}