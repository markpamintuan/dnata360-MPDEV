@isTest
public class Org_FormatDateTime_Test {
    static testmethod void Org_FormatDateTime(){
	    Org_FormatDateTime test = new Org_FormatDateTime();
	    test.getTimeZoneValue();
	    test.dateTimeValue = DateTime.now();
	    test.getTimeZoneValue();
    }
}