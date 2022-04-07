/**
* response class for rest services - post methods
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-14 
*/
global with sharing class SCCReturnResponse {

    @TestVisible private String objectType                   {get; set;}
    @TestVisible private String recordId                     {get; set;}   
    @TestVisible private SCCErrorHandlingTemplate errors     {get; set;}

    /**
    * This is the constructor for SCCReturnResponse class.
    * @param recordId String
    * @param objectType String
    * @param errors SCCErrorHandlingTemplate
    * @return None.
    */
    public SCCReturnResponse(String recordId, String objectType, SCCErrorHandlingTemplate errors) {
        this.recordId       = recordId;
        this.objectType     = objectType;
        this.errors         = errors;
    }    
    
    /**
    * This method used for creating json text for response of rest services.
    * @param recordId: Id
    * @return SCCReturnResponse.
    */
    public static SCCReturnResponse createResponse(Id recordId) {
        return new SCCReturnResponse((String)recordId, recordId.getSObjectType().getDescribe().getLabel(), null); 
    }

    /**
    * This method used for creating json text if there is error on processing.
    * @param e: Exception
    * @return SCCReturnResponse.
    */
    public static SCCReturnResponse createError(Exception e) {
        return new SCCReturnResponse(null, null, SCCErrorHandlingTemplate.createError(e)); 
    }
    
     /**
     * This method used for creating json text if there is error of missing default account in SC.
     * @param e: Exception
     * @return SCCReturnResponse.
     */
    public static SCCReturnResponse createDefaultAccountError() {
    	return new SCCReturnResponse(null, null,SCCErrorHandlingTemplate.createError('Missing Default Account'));
    }
}