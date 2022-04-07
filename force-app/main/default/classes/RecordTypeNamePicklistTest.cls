@isTest
public class RecordTypeNamePicklistTest {
    static testMethod void pick(){
        RecordTypeNamePicklist rt = new RecordTypeNamePicklist();
        RecordTypeNamePicklistTR rttr = new RecordTypeNamePicklistTR();
        rt.getDefaultvalue();
        rt.getValues();
        rttr.getDefaultvalue();
        rttr.getValues();
    }
}