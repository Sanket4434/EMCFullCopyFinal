@isTest
public with sharing class GetDailyTripsFromTriplogTest {
    public static testmethod void GetTriptest() {
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendEmail = new SendEmailToMe__c();
        sendEmail.Name = 'GetTripCallOutApprovePutCall';
        sendEmail.Send_email_to_me__c = true;
        insert sendEmail;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Get_Trip_Date_Settings__c obj_Get_Trip_Date_Settings = new Get_Trip_Date_Settings__c();
        obj_Get_Trip_Date_Settings.Name ='Date Settings';
        obj_Get_Trip_Date_Settings.Start_Date__c ='2020-08-01';
        obj_Get_Trip_Date_Settings.End_Date__c ='2020-08-31';
        obj_Get_Trip_Date_Settings.Last_N_Days__c ='31';
        insert obj_Get_Trip_Date_Settings;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id;
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.isCommunityUser__c = true;
        contact.MailingCity='ahmedabad';
        contact.Vehicle_Type__c = '2019 Mileage Rate';
        contact.MailingState='GJ';
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Triplog_Status__c = 'U';
        con.Vehicle_Type__c = '2019 Mileage Rate';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = '08-2020';
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        conReim.put(con.Id,er);
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetDailyTripsFromTriplog obj = new GetDailyTripsFromTriplog('U');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}