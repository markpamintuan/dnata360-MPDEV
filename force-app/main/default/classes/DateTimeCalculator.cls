public class DateTimeCalculator {
    
    public static Integer calculateStandardMinutes(String beginDate,String endDate){
        Id businessHoursId = [select Id from BusinessHours where name = 'Travel Republic 24/7'].id;
        DateTime dateTime1 = Datetime.valueOf(beginDate);
        DateTime dateTime2 = Datetime.valueOf(endDate);
        Integer mins = Integer.valueOf(Math.abs(BusinessHours.diff(businessHoursId,dateTime1,dateTime2)/1000/60));
        system.debug(mins);
        return mins;
    }



}