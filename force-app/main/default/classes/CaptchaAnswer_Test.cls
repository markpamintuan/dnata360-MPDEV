/**
 * @author: Mark Anthony Pamintuan
 * @date: 13 July 2021
 * @description: Test class for CaptchaAnswer class
 * @history:                
 */
@isTest
public class CaptchaAnswer_Test {

	static testMethod void testCaptchaAnswer() {
	   	
		Test.startTest();
            CaptchaAnswer ctlr = new CaptchaAnswer('testValue','testPath');
            CaptchaAnswer newCtlr = new CaptchaAnswer();
            ctlr.getPath();
            ctlr.getValue();
            ctlr.getObfuscatedName();
            ctlr.setPath('testPath');
            ctlr.setValue('testValue');
            ctlr.toString();
		Test.stopTest();
    	
	}

}