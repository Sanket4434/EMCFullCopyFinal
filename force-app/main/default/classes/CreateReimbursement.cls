global class CreateReimbursement implements  Database.Batchable<Contact>, Database.Stateful {
    public Integer currentMonth;
    public string tempYear;
    public List<IRS_Mileage_Rate__c> objIRSRate;
    public String lastMonth;
    public CreateReimbursement (){
        currentMonth = date.today().Month();
        tempYear = String.valueOf(date.today().Year());
        objIRSRate = new List<IRS_Mileage_Rate__c>();
        objIRSRate = [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c Where year__c =: tempYear Limit 1];
        lastMonth = Utils.fetchMonths(1, -1)[0];
    }
    global List<Contact> start(Database.BatchableContext BC) {
		Date myDate = system.today();
        system.debug('myDate'+myDate);
        List<Contact> conList = new List<Contact>();
        if(!Test.isRunningTest()){
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c 
                                FROM contact 
                                WHERE Role__c != 'Admin' 
                                    AND Role__c != 'Manager' 
                                    AND Deactivated_Date__c = NULL 
                                    AND Account.isUsingTriplog__c = true 
                                    AND Activation_Date__c <= : myDate];
        } else {
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c 
                                FROM contact 
                                WHERE Role__c != 'Admin' 
                                    AND Role__c != 'Manager'];
        }
                system.debug('conList'+conList);
        return conList;
    }
    global Void execute(Database.BatchableContext BC, List<SObject> Scope) { 
        List<Employee_Reimbursement__c> reimToInsert   = new List<Employee_Reimbursement__c>();
        MAP<Id,Employee_Reimbursement__c> accMap = new MAP<Id,Employee_Reimbursement__c>();
        for(Contact currentContact : (List<Contact>) Scope){
            Employee_Reimbursement__c er = new Employee_Reimbursement__c();
            er.Fixed_Amount__c = currentContact.Fixed_Amount__c;
            er.Status__c = 'Pending';
            er.Maintenance_and_Tires__c = currentContact.Maintenance_and_Tires__c;
            er.MPG__c = currentContact.MPG__c;
            er.Contact_Id__c = currentContact.id;
            er.Name = currentContact.Name + ':' + lastMonth;
            er.Month__c = lastMonth;
            er.Fuel_Price__c = 0;
            if(!objIRSRate.isEmpty()){
                er.IRS_Mileage_Rate__c = objIRSRate[0].ID;
            }
            reimToInsert.add(er);
        }
        accMap.putall(reimToInsert);
        if(!accMap.isEmpty() && !Test.isRunningTest()) {
            insert accmap.values();
        }
    }
    global Void finish(Database.BatchableContext BC) {
        
    }
}