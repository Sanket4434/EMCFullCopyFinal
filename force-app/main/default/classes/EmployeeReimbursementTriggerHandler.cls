/*Description: Trigger populates Fuel Price and Fixed Amount values of Employee Reimbersment object.
Fuel Price is populated from Gas Price record having same City, State as Contact Mailing Address AND
having same month and year in Month Year field as Employee Reimbersment's Month field.
Fixed Price is populated from Contact's Fixed Price.
*/
public with sharing class EmployeeReimbursementTriggerHandler {
    /*public static Void populateFields(List<Employee_Reimbursement__c> newEmpReimbursements) {
        Set<Id> empReimIds = new Set<Id>();
        Set<String> cityNames = new Set<String>();
        Set<String> stateNames = new Set<String>();
        Set<Date> monthYears = new Set<Date>();
        Map<String, List<Employee_Reimbursement__c>> keyToReimbersment = new Map<String, List<Employee_Reimbursement__c> >();
        String month, year;
        List<Employee_Reimbursement__c> updateReimbersments = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reimbers : [SELECT Id, Month__c, City_State__c, Fixed_Amount__c, Fuel_Price__c,
            Contact_Id__c, Contact_Id__r.Fixed_Amount__c FROM Employee_Reimbursement__c WHERE Fixed_Amount__c = NULL AND Fuel_Price__c = NULL AND Id IN : newEmpReimbursements]) {
            if(reimbers.Contact_Id__r.Fixed_Amount__c != null) {
                reimbers.Fixed_Amount__c = reimbers.Contact_Id__r.Fixed_Amount__c;
            }
            if(reimbers.City_State__c.length() > 1) {
                cityNames.add(reimbers.City_State__c.split('-')[0]);
                stateNames.add(reimbers.City_State__c.split('-')[1]);
            }
            String tempStrDate = '';
            if(!String.isBlank(reimbers.Month__c)) {
                month = reimbers.Month__c.split('-')[0];
                if(month.substring(0,1).contains('0')) {
                    month = month.replace('0', '');
                }
                year = reimbers.Month__c.split('-')[1];
                date monthYear = date.parse(month  +  '/1/'  +  year);
                tempStrDate = monthYear.format();
                monthYears.add(monthYear);
            }
            
            String temp = '';
            if(!String.isBlank(reimbers.City_State__c)) {
                temp = reimbers.City_State__c  +  '-'  +  tempStrDate;
            }
            if(!keyToReimbersment.containsKey(temp)) {
                keyToReimbersment.put(temp, new List<Employee_Reimbursement__c>{reimbers});
            } else {
                keyToReimbersment.get(temp).add(reimbers);
            }
        }
        
        for(Gas_Prices__c gasPrice : [SELECT City__c, State__c, Fuel_Price__c, Month_Year__c FROM Gas_Prices__c
            WHERE City__c IN : cityNames AND State__c IN : stateNames AND Month_Year__c IN : monthYears]) {
            String tempStrDateGP = gasPrice.Month_Year__c.format();
            String key = gasPrice.City__c  +  '-' +  gasPrice.State__c  +  '-'  +  gasPrice.Month_Year__c;
            if(keyToReimbersment.containsKey(key) && gasPrice.Fuel_Price__c != null) {
                for(Employee_Reimbursement__c er : keyToReimbersment.get(key)) {
                    er.Fuel_Price__c = gasPrice.Fuel_Price__c;
                    updateReimbersments.add(er);
                }
            }
        }
        if(!updateReimbersments.isEmpty()) {
            update updateReimbersments;
        }
    }*/

    public static Void mileagefieldupdate(List<Employee_Reimbursement__c> empReimbursList, Map<Id,Employee_Reimbursement__c> empReimburseOld, Map<Id,Employee_Reimbursement__c> empReimburseNew) {         
        
        //Set<Id> empReimbursId = new Set<Id>();
        /*for(Employee_Reimbursement__c empreimbuseobj : empReimbursList) {
            if(empreimbuseobj.Status__c != empReimburseOld.get(empreimbuseobj.Id).Status__c && empreimbuseobj.Status__c == 'Approved') {
                empReimbursId.add(empreimbuseobj.Id);
            }
        }*/

        List<Employee_Mileage__c> mileageUpdatelist = new List<Employee_Mileage__c>();
        Employee_Reimbursement__c reimForMil = new Employee_Reimbursement__c();
        for(Employee_Mileage__c empmilege : [Select id, name, Trip_Status__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c 
            from Employee_Mileage__c where EmployeeReimbursement__c in : empReimbursList]) {
              
            if(empmilege.EmployeeReimbursement__r.Status__c == 'Approved'){
                //this static value is used for bypass from here when MappingGasPriceTrigger is called. this is while 'Mileage update after the lock date' is updated  
                StaticValues.isCalledFromReimTri = false;
                reimForMil = empReimburseNew.get(empmilege.EmployeeReimbursement__c);
                    
                if(empmilege.Approved_Date__c == null) {
                    empmilege.Approved_Date__c = reimForMil.Approved_Date__c;
                }
                if(empmilege.Trip_Status__c == StaticValues.noApprovedYet && (empmilege.Trip_Status__c != 'Rejected' || empmilege.Rejected__c == false) ) {
                    empmilege.Trip_Status__c = 'Approved';
                }
                if(empmilege.Rejected__c == true){
                    empmilege.Trip_Status__c = 'Rejected';
                }
                mileageUpdatelist.add(empmilege);
            }
        }
        if(!mileageUpdatelist.isEmpty()) {
            update mileageUpdatelist;    
        }     
    }
    public static void updateStatusMail(Map<Id,Employee_Reimbursement__c> empReimburseNew){
        List<String> accountNamesList = new List<String>();
        accountNamesList = Label.SendEmailToManagerAccount.split(',');        

        List<String> accountNamesList2 = new List<String>();
        accountNamesList2 = Label.SendEmailToAdminAccount.split(',');
        
        List<Employee_Reimbursement__c> empReimList = new List<Employee_Reimbursement__c>();
        empReimList = [Select id, 
                              name,
                              Contact_Id__c,
                              Contact_Id__r.Manager__c,                              
                              Contact_Id__r.Manager__r.Manager__c,
                              Contact_Id__r.Name,
                              Contact_Id__r.Email,
                              Contact_Id__r.Manager__r.Role__c,
                              Contact_Id__r.Manager__r.Manager__r.Role__c,
                              Contact_Id__r.Account.Name, 
                              Total_Mileage__c,
                              Variable_Rate__c, 
                              Monthly_Variable_Amount__c,
                              Fixed_Amount__c,
                              Total_Monthly_Reimbursement__c,
                              Month__c
                       From Employee_Reimbursement__c 
                       Where Id In: empReimburseNew.keyset() and 
                             (Contact_Id__r.Account.Name In:accountNamesList OR Contact_Id__r.Account.Name In:accountNamesList2)
                       Order by Contact_Id__c Asc];        
        
        Map<String,String> emailMap = new Map<String,String>();
        // Set<Id> contactIdSet = new Set<Id>();
        
        for(Employee_Reimbursement__c emp:empReimList){
            List<String> monthAndYear = new List<String>();
            datetime monthValue = System.Now();
            if(emp.Month__c != null && emp.Month__c.contains('-'))
            {
                monthAndYear = emp.Month__c.split('-');
                monthValue = datetime.newInstance(Integer.valueOf(monthAndYear[1]), integer.valueOf(monthAndYear[0]), 1,00,00,00);
            }
            String monthName = monthValue.format('MMMMM'); 
            String htmlTemplate = '';
            String htmlTemplate2 = '';
            String htmlTemplate3 = '';

            if(accountNamesList.contains(emp.Contact_Id__r.Account.Name)){
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__c))
                {
                    htmlTemplate = emailMap.get(emp.Contact_Id__r.Manager__c);
                    htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'
                                                + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                + monthName +'</td><td style="border:2px solid black;">'
                                                + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                +'</tr>';
                }
                else{                 
                    htmlTemplate = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                emailMap.put(emp.Contact_Id__r.Manager__c,htmlTemplate);
                // contactIdSet.add(emp.Contact_Id__r.Manager__c); 
                
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__c))
                {
                    htmlTemplate2 = emailMap.get(emp.Contact_Id__c);
                    htmlTemplate2 = htmlTemplate2 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                } 
                else{                 
                    htmlTemplate2 = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">' 
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'   
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                emailMap.put(emp.Contact_Id__c,htmlTemplate2);
                // contactIdSet.add(emp.Contact_Id__c); 
            }
            if(accountNamesList2.contains(emp.Contact_Id__r.Account.Name)){            
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__c) && (emp.Contact_Id__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Role__c == 'Driver/Admin'))
                {
                    htmlTemplate3 = emailMap.get(emp.Contact_Id__r.Manager__c);
                    htmlTemplate3 = htmlTemplate3 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                }
                else if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__r.Manager__c) && (emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Driver/Admin'))
                {
                    htmlTemplate3 = emailMap.get(emp.Contact_Id__r.Manager__r.Manager__c);
                    htmlTemplate3 = htmlTemplate3 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                } 
                else{                 
                    htmlTemplate3 = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">' 
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'   
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                if(emp.Contact_Id__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Role__c == 'Driver/Admin'){
                    emailMap.put(emp.Contact_Id__r.Manager__c,htmlTemplate3);
                    // contactIdSet.add(emp.Contact_Id__r.Manager__c);
                }
                else if(emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Driver/Admin'){
                    emailMap.put(emp.Contact_Id__r.Manager__r.Manager__c,htmlTemplate3);
                    // contactIdSet.add(emp.Contact_Id__r.Manager__r.Manager__c); 
                } 
            }
        }
        
        EmailTemplate emailTemplate = [SELECT Id,
                                              HtmlValue,
                                              Name,
                                              Subject 
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'year_to_date_reimbursement_statement_template2']; 
                                        
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        List<String> bccList = new List<String>();
        bccList = System.Label.Send_Email_Bcc_Address.split(',');
        SendEmail__c sendCustomSet = SendEmail__c.getValues('EmployeeReimbursementTrigger');
        SendEmailToMe__c sendMeCustomSet = SendEmailToMe__c.getValues('EmployeeReimbursementTriggerHandler');

        for(Contact currentContact : [Select id, Name, Email, FirstName From Contact Where Id In: emailMap.keySet()])
        {
           String htmlTemplate = '';
           if(emailMap.containsKey(currentContact.id))
           {
                htmlTemplate = emailMap.get(currentContact.id);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String newBody = emailTemplate.HtmlValue;
                newBody = newBody.replace('{tableDynamicData}',htmlTemplate);
                newBody = newBody.replace('{!Employee_Reimbursement__c.Contact_Id_Name__c}',currentContact.FirstName);
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                mail.setSubject(emailTemplate.Subject);
                mail.setHtmlBody(newBody);
                List<String> toAddress = new List<String>();
                toAddress.add(currentContact.Email);
                mail.setToAddresses(toAddress);
                if(!bccList.isEmpty() && bccList != null && sendMeCustomSet != null && sendMeCustomSet.Send_email_to_me__c == true){                
                    mail.setBccAddresses(bccList);
                }  
                singleEmailMessageList.add(mail);          
           }
        }
        if(!singleEmailMessageList.isEmpty() && !Test.isRunningTest() && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true) 
        {   
            Messaging.sendEmail(singleEmailMessageList);
        }
    }

    public static void checkDeactivatedContact(List<Employee_Reimbursement__c> empReimbursList){
        for(Employee_Reimbursement__c empReimb : empReimbursList){
            if(empReimb.Contact_Id_Deactivated_Date__c != null ){
                Datetime convertDateTimeToDate = empReimb.Contact_Id_Deactivated_Date__c;  
                Date ModifiedDate = convertDateTimeToDate.Date();
                if(ModifiedDate != System.today()){
                    empReimb.AddError('User is deactivated so you can not create a reimbursement.');
                }
            }
            if((empReimb.Status__c == 'Approved' || empReimb.Status__c == 'Rejected') && empReimb.Approved_Date__c == null){ 
                empReimb.AddError('Please insert Approval date');
            }
        }
    }
    //This method is used to set fuel price and mpg 0 to gps account and all other contact who has vehicle type is mileage rate.
    public static void updateFuelMpgPrice (Set<Id> reimIds){
        List<String> accIds = new List<String>();
        List<Employee_Reimbursement__c> reimList = new List<Employee_Reimbursement__c>();
        if(System.label.FuelPriceAccId != null && System.label.FuelPriceAccId.contains(',')){
            accIds = System.label.FuelPriceAccId.split(',');
        } else {
            accIds.add(System.label.FuelPriceAccId);
        }
        for(Employee_Reimbursement__c reimObj : [SELECT id, Contact_Id__r.Vehicle_Type__c, Contact_Id__r.AccountId,
                                                        Fuel_Price__c, MPG__c 
                                                    FROM Employee_Reimbursement__c 
                                                    WHERE Id IN : reimIds
                                                        AND (Contact_Id__r.AccountId IN: accIds
                                                        OR Contact_Id__r.Vehicle_Type__c LIKE '%Mileage Rate%' )]) {
                                                            reimObj.Fuel_Price__c = 0;
                                                            reimObj.MPG__c = 0;
                                                            reimList.add(reimObj);
        }
        if(!reimList.isEmpty()){
            update reimList;
        }
    }
}