@isTest
public class ContactTriggerHelperTest {
    static testMethod void sendEmailOnDriverCreateTest() {
        //Insert Custom setting data
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Alabama';
        obj_Address.City__c ='Abbeville';
        obj_Address.Abbreviation__c ='AL';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
         
        //Insert Account data Using Utility class
        Account acc = TestUtilityClass.getTestSingleAccount();
		acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
		update acc;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Contact';
        con2.AccountId = acc.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Abbeville';
        con2.MailingState = 'AL';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'CA';
        con2.Phone = '1232434445';
        con2.External_Email__c = 'minkesh.patel14@gmail.com';
        con2.Deactivated_Date__c = Null;
        con2.isCommunityUser__c = True;
		con2.Triplog_UserID__c = '23rcdsf';
        con2.Role__c = 'Manager';
        con2.Monthly_Mileage_Limit__c = 0;
        con2.IsCreatedFromCommunity__c = true; 
        insert con2;
        
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Fixed_Amount__c = 10;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'AL';
		con.Triplog_UserID__c = '23rcdssf';
        con.MailingPostalCode = '36310';
        con.Manager__c = con2.Id;
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel14232378@gmail.com';
        con.Deactivated_Date__c = system.today();
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 0;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        con.compliancestatus__c = 'Yes';
        insert con;
        
        con.Deactivated_Date__c = null;
        con.compliancestatus__c = 'No – Vehicle Age';
        update con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test2';
        con1.LastName = 'Contact2';
        con1.AccountId = acc.Id;
        con1.Fixed_Amount__c = 10;
        con1.MailingStreet = 'Test Street';
        con1.MailingCity = 'Test City';
        con1.MailingState = 'AL';
        con1.MailingPostalCode = '36310';
        con1.Manager__c = con2.Id;
        con1.MailingCountry = 'CA';
        con1.Phone = '1232434445';
		con1.Triplog_UserID__c = '23rcdsf';
        con1.External_Email__c = 'minkesh33.patel14232378@gmail.com';
        con1.Deactivated_Date__c = system.today();
        con1.isCommunityUser__c = True;
        con1.Role__c = 'Driver';
        con1.Monthly_Mileage_Limit__c = 0;
        con1.IsCreatedFromCommunity__c = true; 
        con1.Vehicle_Type__c  = '2019 Full-Size Sedan';
        con1.compliancestatus__c = 'No – Vehicle Age';
        insert con1;
        
        con1.compliancestatus__c = 'Yes';
		update con1;
        Map<String,String> contactInfo = new Map<String,String>();
        Map<String,String> accountInfo = new Map<String,String>();
        contactInfo.put(con1.Triplog_UserID__c, con1.Phone);
        accountInfo.put(con1.Triplog_UserID__c, acc.Triplog_API__c);
        ContactTriggerHelper.putHTTPEnableUserTriplog(con1.Id);
        ContactTriggerHelper.putHTTPUpdateUserPhoneTriplog(contactInfo,accountInfo);
        
    }
    static testMethod void testmethod3() {
        //Insert Custom setting data
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        Address__c obj_Address1 = new Address__c();
        obj_Address1.State__c ='Alabama';
        obj_Address1.City__c ='Abbeville';
        obj_Address1.Abbreviation__c ='AL';
        obj_Address1.ZIP_Code__c ='36310'; 
        obj_Address1.Time_Zone__c = 'America/Anchorage';
        
        Address__c obj_Address = new Address__c(); 
        obj_Address.State__c ='kabila';
        obj_Address.City__c ='Abbeville';
        obj_Address.Abbreviation__c ='AK';
        obj_Address.ZIP_Code__c ='36311'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        obj_list_Address.add(obj_Address1);
        insert obj_list_Address;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
         
        //Insert Account data Using Utility class
        Account acc = TestUtilityClass.getTestSingleAccount();

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Contact';
        con2.AccountId = acc.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Abbeville';
        con2.MailingState = 'AL';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'CA';
        con2.Phone = '1232434445';
        con2.External_Email__c = 'minkesh.patel14@gmail.com';
        con2.Deactivated_Date__c = Null;
        con2.isCommunityUser__c = True;
        con2.Role__c = 'Manager';
        con2.Monthly_Mileage_Limit__c = 0;
        con2.IsCreatedFromCommunity__c = true; 
        
        
        insert con2;
        
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Fixed_Amount__c = 10;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = null;
        con.MailingPostalCode = '36310';
        con.Manager__c = con2.Id;
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel14232378@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Triplog_UserID__c = '370415';
        con.Monthly_Mileage_Limit__c = 0;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        con.compliancestatus__c = 'No – Vehicle Value';
        con.Driving_States__c = 'AL';
        insert con;
        
        con.compliancestatus__c = 'No – Insurance not meeting minimum';      
        con.Phone = '24777';
        update con;
    }
    static testMethod void testmethod4() {
        //Insert Custom setting data
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        Address__c obj_Address1 = new Address__c();
        obj_Address1.State__c ='Alabama';
        obj_Address1.City__c ='Abbeville';
        obj_Address1.Abbreviation__c ='AL';
        obj_Address1.ZIP_Code__c ='36310'; 
        obj_Address1.Time_Zone__c = 'America/Anchorage';
        
        Address__c obj_Address = new Address__c(); 
        obj_Address.State__c ='kabila';
        obj_Address.City__c ='Abbeville';
        obj_Address.Abbreviation__c ='AK';
        obj_Address.ZIP_Code__c ='36311'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        obj_list_Address.add(obj_Address1);
        insert obj_list_Address;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
         
        //Insert Account data Using Utility class
        Account acc = TestUtilityClass.getTestSingleAccount();

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Contact';
        con2.AccountId = acc.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Abbeville';
        con2.MailingState = 'AL';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'CA';
        con2.Phone = '1232434445';
        con2.External_Email__c = 'minkesh.patel14@gmail.com';
        con2.Deactivated_Date__c = Null;
        con2.isCommunityUser__c = True;
        con2.Role__c = 'Manager';
        con2.Monthly_Mileage_Limit__c = 0;
        con2.IsCreatedFromCommunity__c = true; 
        
        
        insert con2;
        
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Fixed_Amount__c = 10;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = null;
        con.MailingPostalCode = '36310';
        con.Manager__c = con2.Id;
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel14232378@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 0;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        con.compliancestatus__c = 'No – Vehicle Value';
        con.Driving_States__c = 'AL';
        insert con;
        
        con.compliancestatus__c = 'Yes';        
        update con;
    }
   
}