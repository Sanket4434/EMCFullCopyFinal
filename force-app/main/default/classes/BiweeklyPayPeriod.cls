public with sharing class BiweeklyPayPeriod {
    public BiweeklyPayPeriod() {
        
        //getEmployeeMileages();
    }

    /*public static List<MileageWrap> getEmployeeMileages() {
        List<String> dateRange = new List<String>();
        List<String> startEnddate = new List<String>();
        List<MileageWrap> milWrapList = new List<MileageWrap>();
        MileageWrap obj;
        if(System.Label.PayPeriodDate!=null)
        {
            if(System.Label.PayPeriodDate.contains(','))
            {
                dateRange = System.Label.PayPeriodDate.split(',');
            }
            Integer i=0;    
            for(String s : dateRange)
            {
                String startdate;
                String enddate;
                s = s.trim();
                if(s.contains('to'))
                {
                    startEnddate = s.split('to');
                    startdate = startEnddate[0].trim();
                    enddate = startEnddate[1].trim();
                    String contactid = '0033r00003f3UaKAAU';
                    Date d1 = Date.today();
                    Date d2 = date.valueof(startdate);
                    if(d2 < d1){
                        obj = calculateReim(startdate,enddate,contactid);
                        milWrapList.add(obj);
                    }
                    
                }
                
            }
        }
        System.debug('milWrapList=='+milWrapList);
        return milWrapList;
    }*/

    /*public static MileageWrap calculateReim (String startdate,String enddate,String contactid){
        List<mileageWrap> milWrapList = new List<mileageWrap>();
        Map<Id, Decimal> mileageMap = new Map<Id, Decimal>();
        Map<Id, Decimal> fixedAmountMap = new Map<Id, Decimal>();
        //Map<Id, Decimal> totalVariAmountMap = new Map<Id, Decimal>();
        Decimal fuelprice ;
        Decimal fixed;
        Decimal totalVariableRate;
        Decimal monthlyVariableAmount;
        for(Employee_Mileage__c objMil : [SELECT EmployeeReimbursement__r.Contact_Id__c,
                                                    EmployeeReimbursement__r.Fixed_Amount__c, 
                                                    EmployeeReimbursement__r.Total_Variable_Rate__c,
                                                    EmployeeReimbursement__r.Fuel_Price__c,
                                                    Mileage__c
                                            FROM Employee_Mileage__c 
                                            WHERE   EmployeeReimbursement__r.Contact_Id__c =: contactid
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    //AND Trip_Status__c = 'Approved' 
                                                    //AND Approved_Date__c != null
                                          ]) {

            
            fuelprice = objMil.EmployeeReimbursement__r.Fuel_Price__c;
            
            fixed = objMil.EmployeeReimbursement__r.Fixed_Amount__c;
            totalVariableRate = objMil.EmployeeReimbursement__r.Total_Variable_Rate__c;

            if(mileageMap.size() > 0 && mileageMap.containsKey(objMil.EmployeeReimbursement__r.Contact_Id__c)){
                double mileage = mileageMap.get(objMil.EmployeeReimbursement__r.Contact_Id__c);
                mileage = mileage + objMil.Mileage__c ;
                mileageMap.put(objMil.EmployeeReimbursement__r.Contact_Id__c, mileage);
            } else {
                mileageMap.put(objMil.EmployeeReimbursement__r.Contact_Id__c, objMil.Mileage__c);
            }

        }
        
        MileageWrap milObj = new MileageWrap();
        milObj.dates = startdate +' to '+ enddate;
        if(fuelprice == null){
            fuelprice = 0;
        }
        milObj.fuel = fuelprice;
        System.debug('mileageMap=='+mileageMap);
        if(mileageMap.containsKey(contactid)){
            milObj.approvemileage = mileageMap.get(contactid);
           
        } else {
           
            milObj.approvemileage = 0;
        }
        if(totalVariableRate == null){
            totalVariableRate = 0;
        }
        milObj.totalvariable = totalVariableRate;
        milObj.fixedamount = fixed;
        monthlyVariableAmount = milObj.approvemileage * milObj.totalvariable;
        if(monthlyVariableAmount == null){
            monthlyVariableAmount = 0;
        }
        if(milObj.fixedamount == null){
            milObj.fixedamount = 0;
        }
        milObj.totalReim = monthlyVariableAmount + milObj.fixedamount;
        System.debug(milObj);
        return milObj;
    }*/

    public static List<TimeAttedanceWrap> getTimeAndAttendance(String contactid,String year) {
        List<String> dateRange = new List<String>();
        List<String> startEnddate = new List<String>();
        List<TimeAttedanceWrap> timeWrapList = new List<TimeAttedanceWrap>();
        TimeAttedanceWrap obj;
        String payPeriodDate;
        if(year == '2021' && System.Label.PayPeriodDate2021 != null) {
            payPeriodDate = System.Label.PayPeriodDate2021;
        } else if(year == '2022' && System.Label.PayPeriodDate2022 != null) {
            payPeriodDate = System.Label.PayPeriodDate2022;
        } else if(year == '2020' && System.Label.PayPeriodDate2020 != null) {
            payPeriodDate = System.Label.PayPeriodDate2020; 
        }
        if(payPeriodDate != null)
        {
            if(payPeriodDate.contains(','))
            {
                dateRange = payPeriodDate.split(',');
            }
            Integer i = 0;    
            for(String s : dateRange)
            {
                String startdate;
                String enddate;
                s = s.trim();
                if(s.contains('to'))
                {
                    startEnddate = s.split('to');
                    startdate = startEnddate[0].trim();
                    enddate = startEnddate[1].trim();
                    //String contactid = '0033r00003f3UaKAAU';
                    Date d1 = Date.today();
                    Date d2 = date.valueof(startdate);
                    if(d2 < d1){
                        obj = calculateTimeAtt(startdate,enddate,contactid);
                        timeWrapList.add(obj);
                    }
                }   
            }
        }
        System.debug('timeWrapList=='+timeWrapList);
        return timeWrapList;
    }
    public static TimeAttedanceWrap calculateTimeAtt (String startdates,String enddates,String contactid){
        Map<Id,Decimal> tripdateDrivingTimeMap = new Map<Id,Decimal>();
        Map<Id,Decimal> tripStayTimeMap = new Map<Id,Decimal>();
        Map<Id,Decimal> tripTotalTimeMap = new Map<Id,Decimal>();
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c cid, SUM(Driving_Time__c) rtotal, 
                                        SUM(Stay_Time__c) stay , SUM(Total_Time__c) ttime
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: contactid 
                                    AND Trip_Date__c >= : Date.valueOf(startdates)
                                    AND Trip_Date__c <= : Date.valueOf(enddates) group by EmployeeReimbursement__r.Contact_Id__c ]) {

                                        tripdateDrivingTimeMap.put((Id)ar.get('cid'),(Decimal)ar.get('rtotal'));
                                        tripStayTimeMap.put((Id)ar.get('cid'),(Decimal)ar.get('stay'));
                                        tripTotalTimeMap.put((Id)ar.get('cid'),(Decimal)ar.get('ttime'));
        }
        TimeAttedanceWrap objWrap = new TimeAttedanceWrap();
        objWrap.startDate = startdates;
        objWrap.endDate = enddates;
        objWrap.totaldrivingTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripdateDrivingTimeMap.get(contactid)));
        objWrap.totalStayTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripStayTimeMap.get(contactid)));
        objWrap.totalTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripTotalTimeMap.get(contactid)));
        return objWrap;
    }
    //Total Variable Rate	 * Total Approved	= Monthly Variable Amount
    //Monthly Variable Amount + Fixed Amount = Total Monthly Reimbursement
    /*public class MileageWrap {
        public string dates { get; set; }
        public decimal fuel { get; set; }
        public Decimal approvemileage { get; set; }
        public decimal totalvariable { get; set; }
        public decimal fixedamount { get; set; }
        public decimal totalReim { get; set; }
    }*/

    public class TimeAttedanceWrap {
        public string startDate { get; set; }
        public string endDate { get; set; }
        public String totaldrivingTime { get; set; }
        public String totalStayTime { get; set; }
        public String totalTime { get; set; }
    }
}