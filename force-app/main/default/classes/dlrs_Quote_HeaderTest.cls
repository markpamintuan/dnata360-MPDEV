/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Quote_HeaderTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Quote_HeaderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Quote_Header__c());
    }
}