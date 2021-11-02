@isTest
public class WarehouseSyncScheduleTest {
    
    @isTest
    static void test() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());   		
        String CRON_EXP =  '0 0 0 2 6 ? 2024';
        Test.startTest();
        
        //Schedule job
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new WarehouseSyncSchedule());
        
        Test.stopTest();
        
        //Get CronTrigger
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        //Verify expressions
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}