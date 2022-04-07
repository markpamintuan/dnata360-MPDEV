/**
 * @author: Mark Anthony Pamintuan
 * @date: 13 July 2021
 * @description: Test class for CaptchaFrontEndData class
 * @history:                
 */
@isTest
public class CaptchaFrontEndData_Test {

	static testMethod void testCaptchaFrontEndData() {
	   	
        list<String> lstOptions = new list<String>{'option1','option2','option3','option4','option5'};
        list<CaptchaAnswer> answers = new list<CaptchaAnswer>();

		Test.startTest();
            CaptchaAnswer captchaAnswer = new CaptchaAnswer('testValue','testPath');
            answers.add(captchaAnswer);
            CaptchaFrontEndData cfedClass = new CaptchaFrontEndData('imageName','imageFieldName',lstOptions,'audioFieldName',answers);
            cfedClass.getAudioFieldName();
            cfedClass.getImageFieldName();
            cfedClass.getImageName();
            cfedClass.getValues();
		Test.stopTest();
    	
	}

}