@isTest
private class MaintenanceRequestHelperTest {
    @testSetup
    static void allTheDataForThisTestClass() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Contact contact = new Contact();
        contact.FirstName = 'test';
        contact.LastName = 'last';
        contact.Email = 'test@test.com';
        contact.AccountId = acc.Id;
        insert contact;
        
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Name = 'car';
        insert vehicle;
        
        Product2 product = new Product2();
        product.Name = 'test';
        product.isActive = true;
        product.Maintenance_Cycle__c = 2;
        product.Replacement_Part__c = true;
        insert product;
    }
    
    static testMethod void test_triggerMaintenanceRequestHelperTest() {

        //Create User and assign Profile
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User();
        u.Alias = 'depttest'; 
        u.Email='dept@testorg.com'; 
        u.EmailEncodingKey='UTF-8'; 
        u.LastName='Testing'; 
        u.LanguageLocaleKey='en_US'; 
        u.LocaleSidKey='en_US'; 
        u.ProfileId = p.Id; 
        u.TimeZoneSidKey='America/Sao_Paulo'; 
        u.UserName='dept@testorg.com';
        
        System.runAs(u) {
            
            List<Case> caseList = new List<Case>();
            List<Case> secondList = new List<Case>();
            
            //grab created data
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'test' LIMIT 1]; 
            Contact contact  = [SELECT Id, FirstName, LastName,Email,AccountId FROM Contact WHERE Email = 'test@test.com' LIMIT 1]; 
            Vehicle__c vehicle = [SELECT Id, Name FROM Vehicle__c WHERE Name = 'car' LIMIT 1]; 
            Product2 product = [SELECT Id, Name, isActive, Maintenance_Cycle__c, Replacement_Part__c FROM Product2 WHERE Name = 'test' LIMIT 1]; 
            
            //Start test
            Test.startTest();
            
            //Test has to have 200+ records 
            for(Integer i=1;i<=201;i++){
                Case maintenanceNew = new Case();
                maintenanceNew.Subject = 'Other';
                maintenanceNew.Vehicle__c = vehicle.Id;
                maintenanceNew.Product__c = product.Id;
                maintenanceNew.ContactId = contact.Id;
                maintenanceNew.AccountId = acc.Id;
                maintenanceNew.Type = 'Other';
                maintenanceNew.Status = 'New';
                maintenanceNew.ProductId = product.Id;
                maintenanceNew.Cloned_Case_Id__c = maintenanceNew.Id;
                maintenanceNew.Date_Reported__c = Date.today();
                maintenanceNew.Date_Due__c = Date.today();
                caseList.add(maintenanceNew);   
            }
            
            insert caseList;
            
            //Assert Results from creation
            System.assertEquals(201,caseList.size());
            
            //Validate the cases.
            for(Case cas:caseList){
                cas.Type = 'Repair';
                cas.Status = 'Closed';
                secondList.add(cas);
            }
            
            update secondList;
            List<Case> createdCases = [Select Id from Case where Type = 'Routine Maintenance'];
            System.assertEquals(201,createdCases.size());

            Test.stopTest();
        }
        
    }   
}