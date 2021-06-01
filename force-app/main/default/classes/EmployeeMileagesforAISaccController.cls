/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for total reimbursment for AIS account.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * Page Name :- MileagesforAISAccountReport
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 22 Feb 2021
 */
public with sharing class EmployeeMileagesforAISaccController {
    public List<milWrapper> milWrapList {get; set; }
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public EmployeeMileagesforAISaccController() {
        getEmployeeMileages();
    }
    
    // This method is used to get the mileages and do sum of that trips and calculate total reimbursement.
    public void getEmployeeMileages() {
        //String startDate = '2021-01-01';
        //String endDate = '2021-01-31';
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        milWrapList = new List<milWrapper>();
        Map<Id, Decimal> mileageMap = new Map<Id, Decimal>();
        Map<Id, Decimal> fixedAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> totalVariAmountMap = new Map<Id, Decimal>();
        List<String> lastPaydateSplitted = new List<String>();
        system.debug('startDate=='+startDate);
        if((String.valueOf(startDate).contains('-'))) {
                        lastPaydateSplitted = String.valueOf(startDate).split('-');                
        }
        String reimMonth = lastPaydateSplitted[1]+'-'+lastPaydateSplitted[0];
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Mileage__c) rtotal
                                FROM Employee_Mileage__c 
                                WHERE   EmployeeReimbursement__r.Contact_Id__r.Account.Name = 'Advanced Inventory Solutions'
                                        AND Trip_Date__c >= : Date.valueOf(startDate)
                                        AND Trip_Date__c <= : Date.valueOf(endDate)
                                        AND Trip_Status__c = 'Approved' 
                                  AND Approved_Date__c != null group by EmployeeReimbursement__r.Contact_Id__c]) {
            mileageMap.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal')); 
                                   
        }

        for(Employee_Mileage__c objMil : [SELECT EmployeeReimbursement__r.Contact_Id__c,
                                                    EmployeeReimbursement__r.Fixed_Amount__c, 
                                                    EmployeeReimbursement__r.Total_Variable_Rate__c
                                            FROM Employee_Mileage__c 
                                            WHERE   EmployeeReimbursement__r.Contact_Id__r.Account.Name = 'Advanced Inventory Solutions'
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    AND Trip_Status__c = 'Approved' 
                                          AND Approved_Date__c != null]) {
            if(objMil.EmployeeReimbursement__r.Fixed_Amount__c == null){
                objMil.EmployeeReimbursement__r.Fixed_Amount__c = 0;
            } 
            fixedAmountMap.put(objMil.EmployeeReimbursement__r.Contact_Id__c,objMil.EmployeeReimbursement__r.Fixed_Amount__c); 
            totalVariAmountMap.put(objMil.EmployeeReimbursement__r.Contact_Id__c,objMil.EmployeeReimbursement__r.Total_Variable_Rate__c);                                         
        }
        for(Contact currentContact : [SELECT id,Name,External_Email__c FROM Contact WHERE Account.Name = 'Advanced Inventory Solutions']){
            Decimal monthlyVariableAmount;
            if(totalVariAmountMap.containsKey(currentContact.Id) && mileageMap.containsKey(currentContact.Id)){
                monthlyVariableAmount = totalVariAmountMap.get(currentContact.Id) * mileageMap.get(currentContact.Id);
            } else {
                monthlyVariableAmount = 0;
            }
            
            milWrapper objWrap = new milWrapper();
            objWrap.name = currentContact.Name;
            objWrap.email = currentContact.External_Email__c;
            if(fixedAmountMap.containsKey(currentContact.Id)){
                objWrap.TotalReim = (monthlyVariableAmount + fixedAmountMap.get(currentContact.Id)).setScale(2);
            } else {
                objWrap.TotalReim = (monthlyVariableAmount + 0).setScale(2);
            }
            milWrapList.add(objWrap);
        }
     
    }

    public class milWrapper {
        public string name { get; set; }
        public string email { get; set; }
        //public string tripdate { get; set; }
        public decimal TotalReim { get; set; }
        public milWrapper(){}
    }
}