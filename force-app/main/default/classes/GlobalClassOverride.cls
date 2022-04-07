global class GlobalClassOverride {
	global static Boolean AllowCaseTrigger = true;
    global static Boolean AllowCCTrigger = true;
    global static  SavePoint sp;
    
    
    global static String getInitialSavepoint(){
        sp =  Database.setSavepoint();
		return String.valueOf(sp);        
    }
    
    public static void revertSavepoint(){
        System.debug(sp);
        Database.rollback(sp);
    }
}