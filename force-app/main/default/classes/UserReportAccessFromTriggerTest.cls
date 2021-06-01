@isTest
public with sharing class UserReportAccessFromTriggerTest {
    public static testmethod void test1() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.mileageremoveapprovaldate__c = false;
        customSetting.MappingGasPriceTrigger__c = false;
        customSetting.MappingGasPriceTriggerUpdateConvertedDat__c = false;
        customSetting.UserTrigger__c = true;
        insert customSetting;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'Acme Corporation';
        acc.Enable_Email_For_Managers__c = true;
        acc.Approval_Template_Message__c = 'test message';
        insert acc;

        Contact cont = new Contact();
        cont.LastName = 'TestdataContact';
        cont.AccountId = acc.Id;
        cont.External_Email__c = 'testd@email.com';
        cont.Fixed_Amount__c = 371.28;
        cont.MailingCity = 'Abilene';
        cont.MailingState = 'TX';
        cont.Driving_States__c = 'TX';
        cont.Time_Zone__c = 'America/Chicago';
        cont.Monthly_Mileage_Limit__c = 100.00;
        cont.Deactivated_Date__c = Date.today().addMonths(4);
        cont.Role__c = 'Driver/Admin';
        cont.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Super Manager/Driver']; 
        User user = new User(Alias = 'standt', 
                            Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser2@testorg.com',
                            Contactid = cont.id,
                            IsActive = True
                        );
        insert user;
        
        set<Id> currentUserIdsSet = new set<Id>();
        currentUserIdsSet.add(user.Id);
        UserReportAccessFromTrigger.createReportAccessibility(currentUserIdsSet);        
    }
}