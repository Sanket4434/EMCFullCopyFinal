@istest
public class SendEmailForSubmittedMileageTest {
    public static testmethod void testMethod4(){
        

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'SendEmailForSubmittedMileage';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'SendEmailForSubmittedMileage';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;

        Account acc = TestUtilityClass.getTestSingleAccount();
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093359.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        //RecordUtilityClass.vehicleUrlMapping();

        Contact con = RecordUtilityClass.buildAdminContact(acc);
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Time_Zone__c = 'US/Mountain' ;
        insert con;
        //Contact con = TestUtilityClass.getTestSingleContact(acc);
        //Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement3(con);
        
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_3 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_3.year__c='2020';
        obj_IRS_Mileage_Rate_3.IRS_Rate__c =0.567;
        insert obj_IRS_Mileage_Rate_3;
        
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 12;
        empReim.MPG__c = 45;
        empReim.Month__c =  ilmr.getLastMonthValue(-1);
        //empReim.Month__c =  '01-2020';
        empReim.Approved_Date__c = null;
        empReim.Monthly_Mileage__c = 50;
        empReim.IRS_Mileage_Rate__c =obj_IRS_Mileage_Rate_3.id;
        empReim.Maintenance_and_Tires__c =10;
        insert empReim;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = empReim.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.Mileage__c = 10.00;
        emp.Day_Of_Week__c = 'Mon';
        emp.Stay_Time__c = 10;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        insert emp;
            
        
        SendEmailForSubmittedMileage mil = new SendEmailForSubmittedMileage();
         Database.executeBatch(mil, 1);
    }
}