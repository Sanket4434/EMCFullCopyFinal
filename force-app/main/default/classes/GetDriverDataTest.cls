@isTest
public with sharing class GetDriverDataTest {
    public static testmethod void method1() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = false;
        customEmailSetting.ContactTriCommunityReimCreate__c = false;
        insert customEmailSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        SendEmailToMe__c customEmail =  new SendEmailToMe__c();
        customEmail.Name = 'ChangeTripStatusinTripLogBatch';
        customEmail.Send_email_to_me__c = false;
        insert customEmail;
        
        Account acc = new Account();
        acc.Name = 'Anton Paar';
        acc.Triplog_API__c = 'test1';
        acc.IsUsingTriplog__c = true;
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Contact con1 = new Contact();
        con1.LastName = 'testsdfsdfs';
        con1.Triplog_UserID__c = 'test';
        //con1.Deactivated_Date__c =  system.now()-35;
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = acc.Id;
        con1.Employee_ID__c = 'eid';
        con1.Role__c = 'Manager';
        con1.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert con1;  

        Contact conList = new Contact();
        conList.FirstName = 'testFn';
        conList.LastName = 'testLn';
        conList.accountid = acc.id;
        conList.MPG__c = 5;
        conList.Maintenance_and_Tires__c = 3;
        conList.Triplog_UserID__c = con1.Triplog_UserID__c;
        //conList.Deactivated_Date__c = con1.Deactivated_Date__c;
        conList.External_Email__c = 'testManagr101@gmail.com';
        conList.IsDeactivated__c = con1.IsDeactivated__c;
        conList.Manager__c = con1.Id;
        conList.Fixed_Amount__c = 20;
        conList.Vehicle1Odometer__c = 10;
        conList.isCommunityUser__c = true;
        conList.MailingStreet = 'denverstreet';
        conList.MailingCity = 'Denver';
        conList.MailingState = 'CA';
        conList.MailingPostalCode = '110085';
        conList.MailingCountry = 'US';
        conList.compliancestatus__c = 'Yes';
        conList.Time_Zone__c = 'US/Mountain' ;
        conList.Vehicle_Type__c = '2019 Full-Size Sedan';
        conList.Role__c = 'Driver';
        conList.compliancestatus__c = 'No – Vehicle Value';
        conList.Monthly_Mileage_Limit__c = 100;
        insert conList;
        
        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conList.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = lastMonth;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = conList.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Not Approved Yet';
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.TimeZone__c = 'US/Mountain';
        emp.Trip_Date__c = date.today().adddays(-1);
        insert emp;
        
        String json = '[{\"Id\":\"'+emp.id+'\",\"employeeEmailId\":\"testManagr101@gmail.com\"}]';

        GetDriverData.fetchLookUpValues(acc.Id,con1.Id,'AccountId',conList.Id, 'Id', '', 'id', 'contact','Name',true);
        GetDriverData.fetchMileages(acc.Id,con1.id,1,2);
        GetDriverData.fetchMileagesSize(acc.Id,con1.id);
        GetDriverData.buildDateforactivation(System.today());
        GetDriverData.approveMileages(true,json,false);
        GetDriverData.getMilegesData(acc.Id,conList.Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc',1,2);
        GetDriverData.fetchWayPointPostAPI(1234555,'apikey');
        GetDriverData.getMilegesDataSize(acc.Id,conList.Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc');
        GetDriverData.updateMileages(emp.id,'test');
        GetDriverData.deleteMileages(json);
        GetDriverData.mileageListData(acc.Id,con1.Id,System.today(),System.today()+10);
        GetDriverData.deleteTrips(acc.Id,'05-2021');
    }
}