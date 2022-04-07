public Class AvoidRecursion{
    private static boolean firstRun = true;
    public static boolean futurRun = true;
    public static boolean recurRun = true;
    public static boolean receiptBookingRun = true;
    public Static boolean rollUpBookingRun = true;

    public static boolean isFirstRun(){
        if(firstRun){
            firstRun = false;
            return true;
        }else{
            return firstRun;
        }
    }
    
    public static boolean isRollUpBookingRun()
    {
        if(rollUpBookingRun ){
            rollUpBookingRun = false;
            return true;
        }else{
            return rollUpBookingRun;
        }
    }
    
}