trigger EmployeeReimbursementTrigger on Employee_Reimbursement__c (after update, after insert,before insert) {
   /*if(Trigger.isAfter && Trigger.isInsert) {
        EmployeeReimbursementTriggerHandler.populateFields(Trigger.New);
    }else*/
    SendEmail__c sendCustomSet = SendEmail__c.getValues('EmployeeReimbursementTrigger');
    
        
    if(Trigger.isUpdate && (checkRecursive.runOnce() || Test.isRunningTest())) {
       
        EmployeeReimbursementTriggerHandler.mileagefieldupdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        
        //AI-000436 start
        Map<Id,Employee_Reimbursement__c> sendMailReimbursMap = new Map<Id,Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reimb:Trigger.New){
            if(reimb.Status__c != Trigger.oldMap.get(reimb.Id).Status__c && reimb.Status__c == 'Approved'){
                sendMailReimbursMap.put(reimb.Id,reimb);
            }
        }
       
        if(sendMailReimbursMap.size() > 0 && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true){
            EmployeeReimbursementTriggerHandler.updateStatusMail(sendMailReimbursMap);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true){
        Map<Id,Employee_Reimbursement__c>  sendMailEmpReimbursMap = new  Map<Id,Employee_Reimbursement__c>();
        Set<Id> reimIds = new Set<Id>();
        for(Employee_Reimbursement__c reimb:Trigger.New){
            reimIds.add(reimb.ID);
            if(reimb.Status__c == 'Approved'){
                sendMailEmpReimbursMap.put(reimb.Id,reimb);
            }
        }
      
        if(sendMailEmpReimbursMap.size() > 0){
            EmployeeReimbursementTriggerHandler.updateStatusMail(sendMailEmpReimbursMap);
        }
        if(!reimIds.isEmpty()) {
            EmployeeReimbursementTriggerHandler.updateFuelMpgPrice(reimIds);
        }
    } //AI-000436 end
    
    //AI-000459 Start
    //If contact is deactivated then no user can manually create a reimbursement record for that contact.
    if(Trigger.isInsert && Trigger.isBefore) 
    {
        EmployeeReimbursementTriggerHandler.checkDeactivatedContact(Trigger.New);
    }
}