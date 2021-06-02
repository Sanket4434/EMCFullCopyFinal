/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for Timesheet report same as netchex time and attedance report.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 2 Sept 2020
 */
public with sharing class TimeSheetReportController {
    public List<ReibursementWrapper> timeWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public TimeSheetReportController() {
        TimeSheet();
    }
    public void TimeSheet(){
        //String Id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        timeWrapperList = new List<ReibursementWrapper>();
        Map<Id, Decimal> reimbTotalTimeMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Drive_Stay_Time__c) rtotal 
                                FROM Employee_Mileage__c 
                                WHERE (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' 
                                        OR EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time') 
                                        AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: System.Label.ERMI_Account
                                        AND Trip_Date__c >= : Date.valueOf(startDate)
                                        AND Trip_Date__c <= : Date.valueOf(endDate) group by EmployeeReimbursement__r.Contact_Id__c]) {
                                reimbTotalTimeMap.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal')); 
        }
        for(Contact currentContact : [SELECT id,Employee_Netchex_Id__c,Code__c FROM Contact WHERE (Driver_Type__c = 'Driver - Full Time' OR Driver_Type__c = 'Driver - Part Time')AND Employee_Netchex_Id__c != null AND AccountId =: System.Label.ERMI_Account]){
            ReibursementWrapper objWrapper = new ReibursementWrapper();
            objWrapper.CompanyCode = 'LIL';
            objWrapper.EntryDate = endDate;
            objWrapper.EmployeeId = currentContact.Employee_Netchex_Id__c;
            objWrapper.GrossToNetCode = '1';
            objWrapper.TypeCode = 'R';
            if(reimbTotalTimeMap.get(currentContact.Id) == null ){
                objWrapper.HoursOrAmount = 0;
            }
            else{
                objWrapper.HoursOrAmount = (reimbTotalTimeMap.get(currentContact.Id)).divide(60, 2);
            }
            timeWrapperList.add(objWrapper);
        }
    }

    public class ReibursementWrapper{
        public string CompanyCode { get; set; }
        public string EntryDate { get; set; }
        public string EmployeeId { get; set; }
        public string GrossToNetCode { get; set; }
        public string TypeCode { get; set; }
        public double HoursOrAmount { get; set; }
        public ReibursementWrapper(){
        }
    }
}