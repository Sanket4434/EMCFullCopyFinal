@isTest
public with sharing class ChangeTripStatusinTripLogTest {
   
    public static testmethod void method1() {

        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'ChangeTripStatusinTripLog';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;

        RecordUtilityClass.createRecordsAdminDashboardController();
            Test.setMock(HttpCalloutMock.class, new ChangeTripStatusinTripLogTestMock());
            Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            Contact selectedDriver = RecordUtilityClass.getDriverContact();
            List<String> approvedIdList = new List<String>();
            List<String> rejectedIdList = new List<String>();   
            List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
            List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
            List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
            driverMileagesList[0].Trip_Id__c = 104976448;
            update driverMileagesList;
            system.debug('selected List'+selectedReimList);
            approvedIdList.add(driverMileagesList[0].id);
            
            
            System.debug('approvedIdList'+approvedIdList);
            Test.startTest();
            
            Database.executeBatch(new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com') );
            //ChangeTripStatusinTripLog.getMileages();
            Test.stopTest();



    }
    public static testmethod void method2() {

        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'ChangeTripStatusinTripLog';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        SendEmailonDeactivation__c sendemailme1 = new SendEmailonDeactivation__c();
        sendemailme1.name = 'mileageprocess';
        sendemailme1.Send_to_me__c = true;
        sendemailme1.BCCEmailaddresses__c = 'abc@gmail.com';
        sendemailme1.Send_to_Admin__c = true;
        sendemailme1.Send_to_Manager__c = true;
        insert sendemailme1;

        RecordUtilityClass.createRecordsAdminDashboardController();
            Test.setMock(HttpCalloutMock.class, new ChangeTripStatusinTripLogTestMock());
            Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            Contact selectedDriver = RecordUtilityClass.getDriverContact();
            List<String> approvedIdList = new List<String>();
        
            List<String> rejectedIdList = new List<String>();   
            List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
            List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
            List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
            driverMileagesList[0].Trip_Id__c = 104976448;
        	driverMileagesList[0].Trip_Date__c = system.today().toStartOfMonth().addDays(-1);
        	driverMileagesList[1].Trip_Id__c = 104976442;
            update driverMileagesList;
        	approvedIdList.add(driverMileagesList[0].id);
        	approvedIdList.add(driverMileagesList[1].id);
            system.debug('selected List'+selectedReimList);
            rejectedIdList.add(driverMileagesList[0].id);
            
        	ChangeTripStatusinTripLog obj = new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com');
            obj.UpdateMileages(approvedIdList,'Approved');
        ChangeTripStatusinTripLog.BuildBody('Approved',approvedIdList);
        obj.callPutApi('asdfghjytrew56789jhgfd', '', selectedDriver.id, empReimbursementList[0].id, 10);
            System.debug('approvedIdList'+approvedIdList);
            Test.startTest();
            
            Database.executeBatch(new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com') );
            //ChangeTripStatusinTripLog.getMileages();
            Test.stopTest();



    }
}