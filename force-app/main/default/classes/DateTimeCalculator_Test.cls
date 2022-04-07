@isTest
public class DateTimeCalculator_Test {
    static testmethod void test1(){
        DateTimeCalculator.calculateStandardMinutes(Datetime.now().format('yyyy-MM-dd hh:mm:ss'),Datetime.now().format('yyyy-MM-dd hh:mm:ss'));
    }
}