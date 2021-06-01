global class MassSyncTrips implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public string accid;
    public string startDate;
    public string endDate;
    public string lastMonth;
    public string tripStatus;
    public Boolean putcall;
    global Set<Id> reimbursementIds = new Set<Id>();
    public MassSyncTrips(String accountId,String minDate,String maxDate,String month,String status,Boolean putapi) {
        accid = accountId;
        startDate = minDate;
        endDate = maxDate;
        lastMonth = month;
        tripStatus = status;
        putcall = putapi;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query;
        //String lastMonth = Utils.fetchMonths(1, 0)[0];
        if(!Test.isRunningTest()){
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c, Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE Status__c = \'Pending\' AND Month__c = \''+lastMonth+'\' AND Contact_Id__r.AccountId = \''+accid+'\' ';
        } else {
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c, Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c';
        }
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {

        for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope)
        {
            reimbursementIds.add(reim.id);
            if( !Test.IsRunningTest()){
                GetTripCallout.GetTripCalloutForMileage(reim.id, reim.Contact_Id__r.External_Email__c, reim.Contact_Id__c, startDate, endDate, String.valueOf(reim.Fuel_Price__c), String.valueOf(reim.MPG__c), String.valueOf(reim.Maintenance_and_Tires__c), reim.Contact_Id__r.Account.Triplog_API__c, tripStatus ,putcall);
            }
        }
    }

    global void finish(Database.BatchableContext BC) 
    {
        if(!reimbursementIds.isEmpty()){
            Database.executeBatch(new LoadMileageLocationBatch(reimbursementIds, true ),50);
        }
    }
}