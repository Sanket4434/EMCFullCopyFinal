@isTest
public class TriplogStateUpdateBatchTest {
    @isTest static void myUnitTest() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
       
        Account acc = new Account(); 
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'AL';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'abc';        
        acc.Enable_Email_For_Managers__c = True;
        insert acc;
       
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'AL';
        con.Driving_States__c = 'AL';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'USA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = null;
        con.Triplog_UserID__c = null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 100;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        insert con;

        contact con2 = new contact();
        con2.FirstName = 'Test';
        con2.LastName = 'contact2';
        con2.AccountId = acc.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Test City';
        con2.MailingState = 'AL';
        con2.Driving_States__c = 'AL';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'USA';
        con2.Phone = '1232434445';
        con2.External_Email__c = 'test2@gmail.com';
        con2.Deactivated_Date__c = null;
        con2.Triplog_UserID__c = null;
        con2.isCommunityUser__c = True;
        con2.Role__c = 'Driver';
        con2.Monthly_Mileage_Limit__c = 100;
        con2.IsCreatedFromCommunity__c = true; 
        con2.Vehicle_Type__c  = '2019 Full-Size Sedan';
        insert con2;

        Test.StartTest();
            TriplogStateUpdateBatch batchobj = new TriplogStateUpdateBatch();         
            Database.executeBatch(batchobj,1);
        Test.StopTest();
    }
}