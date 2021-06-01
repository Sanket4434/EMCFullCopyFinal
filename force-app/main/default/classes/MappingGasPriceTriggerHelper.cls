public without sharing class MappingGasPriceTriggerHelper{

    public static void updateConvertedDates(List<Employee_Mileage__c> mileagesList){
        
        Map<String,String> timeZoneMap = new Map<String,String>();
        set<Id> reimIds = new Set<Id>();
        daylight_saving_time_config__c DSTzconfig = daylight_saving_time_config__c.getValues(String.valueOf(System.today().year()));
        
        for(Employee_Mileage__c currentMileage : mileagesList)
        {
            reimIds.add(currentMileage.EmployeeReimbursement__c);
            
            /*if(currentMileage.EmployeeReimbursement__c != null && !timeZoneMap.containsKey(currentMileage.EmployeeReimbursement__c))
            {
                timeZoneMap.put(currentMileage.EmployeeReimbursement__c,currentMileage.EmployeeReimbursement__r.Contact_Id__r.Time_Zone__c);
            }*/
            if(currentMileage.Stay_Time__c != 0 && (currentMileage.Tag__c == 'Admin' || currentMileage.Tag__c == 'admin')){
                currentMileage.Stay_Time__c = 0;
            }
            
            if(currentMileage.Stay_Time__c != 0 && currentMileage.Origin_Name__c != null && currentMileage.Destination_Name__c != null && ((currentMileage.Origin_Name__c).toUppercase() == 'HOME' && (currentMileage.Destination_Name__c).toUppercase() == 'HOME' )){
                currentMileage.Stay_Time__c = 0;
            }
        }
        for(Employee_Reimbursement__c currentReimbursement : [Select id,Contact_Id__r.Time_Zone__c from Employee_Reimbursement__c where id IN: reimIds])
        {
           if(!timeZoneMap.containsKey(currentReimbursement.id))
            {
                timeZoneMap.put(currentReimbursement.id,currentReimbursement.Contact_Id__r.Time_Zone__c);
            } 
        }
        for(Employee_Mileage__c currentMileage : mileagesList)
        {
            
            if(timeZoneMap.containsKey(currentMileage.EmployeeReimbursement__c))
            {
                currentMileage.TimeZone__c = timeZoneMap.get(currentMileage.EmployeeReimbursement__c);
                if(currentMileage.StartTime__c != null) 
                {
                    currentMileage.ConvertedStartTime__c = ConvertDateTimeGMT(currentMileage.StartTime__c, currentMileage.TimeZone__c).addHours(HoursToAdjust(currentMileage.StartTime__c, DSTzconfig, currentMileage.TimeZone__c));
                    currentMileage.Trip_Date__c = currentMileage.ConvertedStartTime__c.date();
                    currentMileage.Day_Of_Week__c = currentMileage.ConvertedStartTime__c.format('EEEE');
                }
                
                if(currentMileage.EndTime__c != null )
                {
                    currentMileage.ConvertedEndTime__c = ConvertDateTimeGMT(currentMileage.EndTime__c, currentMileage.TimeZone__c).addHours(HoursToAdjust(currentMileage.EndTime__c, DSTzconfig, currentMileage.TimeZone__c));
                }
            }
        }
    }

    static Integer getPacificOffset(Integer year, Integer month, Integer day, String timezonestr)
    {
        return TimeZone.getTimeZone(timezonestr)
            .getOffset(Datetime.newInstanceGmt(year, month, day)) /
            (1000 * 60 * 60);
    }

    static DateTime ConvertDateTimeGMT(DateTime dTime, String timeZoneStr)
    {
        String strConvertedDate = dTime.format('MM/dd/yyyy HH:mm:ss', timeZoneStr);
        List<String> dtList = new List<String>( strConvertedDate.split(' ') );
        
        return Datetime.newInstanceGMT(Integer.valueOf(dtList[0].split('/')[2]),Integer.valueOf(dtList[0].split('/')[0]),Integer.valueOf(dtList[0].split('/')[1]),Integer.valueOf(dtList[1].split(':')[0]),Integer.valueOf(dtList[1].split(':')[1]),Integer.valueOf(dtList[1].split(':')[2]));
    }

    static Integer HoursToAdjust(DateTime dateToCompare, daylight_saving_time_config__c DSTconfig, String timeZoneStr) {
        if(Label.Daylight_Saving_TimeZone.Contains(timeZoneStr) && DSTconfig.Start_Date__c < dateToCompare && DSTconfig.End_Date__c > dateToCompare) {
            return 1;
        }
        return 0;
    }

    public static void TrackHistory(Map<ID,Employee_Mileage__c> mileageOld,List<Employee_Mileage__c> mileageNew){

        list<AuditTrail__c> newAuditTrialCreate=new list<AuditTrail__c>();
        for(Employee_Mileage__c objMil : mileageNew) {
            if(objMil.id == mileageOld.get(objMil.id).id) {
                if(objMil.Trip_Status__c != mileageOld.get(objMil.id).Trip_Status__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Trip Status',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(objMil.Trip_Status__c),OldValue__c=String.Valueof(mileageOld.get(objMil.id).Trip_Status__c),Employee_Mileage__c = objMil.id));
                if(objMil.Approved_Date__c != mileageOld.get(objMil.Id).Approved_Date__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Approval Date',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.valueOf(objMil.Approved_Date__c),OldValue__c=String.valueOf(mileageOld.get(objMil.id).Approved_Date__c),Employee_Mileage__c=objMil.id));
            }
            if(newAuditTrialCreate.Size() > 0)
            upsert newAuditTrialCreate; 
        }
    }

    public static void updateMileagesLockDate(List<Employee_Mileage__c> mileagesList){
        Set<Id> reimIds = new Set<Id>();
        for(Employee_Mileage__c empMil : mileagesList){
            reimIds.add(empMil.EmployeeReimbursement__c);
        }
        system.debug('reimIds.size()='+reimIds.size());
        Map<Id,Employee_Reimbursement__c> reimMap = new Map<Id,Employee_Reimbursement__c>();
        set<id> conIds = new set<id>();
      
        for(Employee_Reimbursement__c reimObj : [SELECT id,Name,Mileage_Lock_Date__c,Month__c,Contact_Id__c,Contact_Id__r.Name 
                                            FROM Employee_Reimbursement__c 
                                            WHERE Mileage_Lock_Date__c != null 
                                                AND Mileage_Lock_Date__c <=: date.today() 
                                                AND ID IN: reimIds
                                            ]){
            reimMap.put(reimObj.Id,reimObj);
            conIds.add(reimObj.Contact_Id__c);
        }
        Map<string,Id> erNameMap = new Map<string,Id>();
        for(Employee_Reimbursement__c er : [SELECT id,Name,Mileage_Lock_Date__c,Month__c,Contact_Id__c,Contact_Id__r.Name FROM Employee_Reimbursement__c where Contact_Id__c IN:conIds]){
            erNameMap.put(er.Name,er.id);
        }
        list<Employee_Mileage__c> emToUpdate = new list<Employee_Mileage__c>();
        for(Employee_Mileage__c empMil : mileagesList){
            if(empMil.Trip_Status__c == 'Approved' || empMil.Trip_Status__c == 'Rejected'){
                system.debug('empMil='+empMil);
                if(reimMap.containsKey(empMil.EmployeeReimbursement__c)){
                    system.debug('reimMap.containsKey(empMil.EmployeeReimbursement__c)=');
                    string contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name;
                    integer month = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[0])+1;
                    integer year = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[1]);
                    integer nextYear = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[1])+1;
                    
                    if(month<10 ) {
                        contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':0'+month+'-'+year;
                        system.debug('month==1-9=='+contactName);
                    } else if( integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[0]) == 12){
                        system.debug('Inserted');
                        contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':01'+'-'+nextYear;
                        system.debug('contactNamefor12m== '+ contactName);
                    } else {
                        contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':'+month+'-'+year;
                        system.debug('else part contactName='+contactName);
                    }
                    
                    if(erNameMap.containsKey(contactName)) {
                        Employee_Mileage__c em = new Employee_Mileage__c();
                        em.id = empMil.id;
                        em.EmployeeReimbursement__c = erNameMap.get(contactName);
                        if(StaticValues.isCalledFromReimTri == true){
                            emToUpdate.add(em);
                        }
                    }   
                }   
            }
        }
        if(!emToUpdate.isEmpty()){
            update emToUpdate;
        }
    }
}