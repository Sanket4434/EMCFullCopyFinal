@isTest
public class ReportListController_Test {
    public static testmethod void ReportListControllerTestMethod() {
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        //sendEmail custom setting
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;

        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;

        //Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        //Contact driver List
        List<Contact> driList = new List<Contact>();
        //Contact Admin
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact Admin';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.pateladmin01@gmail.com';
        con.Deactivated_Date__c = null;
        con.IsCommunityUser__c = true;
        con.Role__c = 'Admin';
        con.Monthly_Mileage_Limit__c = 200;
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert con;
        //Contact Manager
        Contact co = new Contact();
        co.FirstName = 'Test';
        co.LastName = 'Contact Manager';
        co.AccountId = acc.Id;
        co.MailingStreet = 'Test Street';
        co.MailingCity = 'Test City';
        co.MailingState = 'ON';
        co.MailingPostalCode = '123';
        co.MailingCountry = 'CA';
        co.Phone = '1232434445';
        co.External_Email__c = 'minkesh.patelmanager01@gmail.com';
        co.Deactivated_Date__c = null;
        co.IsCommunityUser__c = true;
        co.Role__c = 'Manager';
        co.Monthly_Mileage_Limit__c = 210;
        co.Manager__c = con.Id;
        co.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert co;
        //Contact Driver
        Contact c;
        for(Integer i = 0; i<5; i++) {
            c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact Manager'+i;
            c.AccountId = acc.Id;
            c.MailingStreet = 'Test Street';
            c.MailingCity = 'Test City';
            c.MailingState = 'ON';
            c.MailingPostalCode = '123';
            c.MailingCountry = 'CA';
            c.Phone = '1232434445';
            c.External_Email__c = 'minkesh.pateldriver01'+i+'@gmail.com';
            c.Deactivated_Date__c = null;
            c.IsCommunityUser__c = true;
            c.Role__c = 'Driver';
            c.Monthly_Mileage_Limit__c = 210;
            c.Manager__c = co.Id;
            c.Vehicle_Type__c = '2019 Full-Size Sedan';
            driList.add(c);
        }
        insert driList;

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = driList[0].Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '06-2020';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        //User
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];
      

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8',FirstName='Test', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId=p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Testingapexclass@gmail.com',Contactid=driList[0].id);
    
        insert u;
        //Custom report

        Custom_Report__c currentReport = new Custom_Report__c();
        currentReport.Name = 'Variable Reimbursement Report';
        currentReport.Sort_By__c = 'asc';
        currentReport.Report_For__c = 'Frank Saverino Accessibility';
        currentReport.Report_Category__c = 'Reimbursement Reports  ';
        currentReport.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport.Use_Manager_List__c = true;
        currentReport.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c';
        currentReport.Date_Time_Fields__c = 'Contact_Id_Name__c';
        currentReport.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport ; 

        // Custom_Report__c rep = new Custom_Report__c();
        // rep.Name = 'Test Productivity Report';
        // rep.Report_Category__c = 'My Custom Reports';
        // rep.Report_For__c = 'tesst';
        // rep.Report_Soql__c = 'SELECT id,Name,email from contact where Account.name=\'Test Account\'';
        // rep.Report_Type__c = 'test';
        // rep.Sort_By__c = 'asc';
        // rep.Sort_From__c = '2';
        // insert rep;

        
        Report_Accessibility__c repAcc = new Report_Accessibility__c();
        repAcc.Custom_Report__c = currentReport.Id;
        repAcc.User__c = u.Id;
        insert repAcc;

        Test.startTest();
        Test.setCurrentPage(Page.reportlist);
        String accId = ApexPages.currentPage().getParameters().put('accid',acc.Id);
        String conid = ApexPages.currentPage().getParameters().put('id',driList[0].Id);
        ReportListController mddc = new ReportListController();
        ReportListController.getAccountid();
        ReportListController.getContactid();
        ReportListController.getRedirected();
        ReportListController.getAllReports();
        ReportListController.getRole();
        ReportListController.reimbursementListModal(er.Id);
        ReportListController.contactListModal(acc.Id);
        String startDate = '2020-01-01';
        String endDate = '2020-03-22';
        ReportListController.postTimeSheetImportAPI(startDate,endDate,con.id);
        ReportListController.postVariablePaymentAPI(startDate,con.id);
        ReportListController.postFixedAmountAPI(startDate,con.id);
        ReportListController.postHalfFPFullDriverAPI(startDate,endDate,con.id);
        ReportListController.CheckStatus(1234567654,'NetchexDeleteCallout');
        Test.stopTest();
    }
}