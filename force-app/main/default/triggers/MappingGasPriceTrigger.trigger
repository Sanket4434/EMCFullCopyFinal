Trigger MappingGasPriceTrigger on Employee_Mileage__c (before insert, before update, after insert,after update) {
    
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    
    if( Trigger.isInsert && Trigger.isBefore && customSetting.MappingGasPriceTrigger__c)
    {
        Set<String> reimIds = new Set<String>();
        Set<String> reimbursementIds = new Set<String>();
        Map<String,Decimal> reimbursementWiseFuelMap = new Map<String,Decimal>();
        Map<String,Decimal> gasPriceFuelMap = new Map<String,Decimal>();
        Map<String,String> reimbursementWiseMonthMap = new Map<String,String>();
        Map<String,String> reimWiseStateCityMap = new Map<String,String>();
        for(Employee_Mileage__c mil : Trigger.New)
        { 
           
            reimIds.add(mil.EmployeeReimbursement__c);                    
        }
        
        if(!reimIds.isEmpty()) {
            for(Employee_Reimbursement__c reim : [SELECT Id,
                                                  Month__c,
                                                  Fuel_Price__c,
                                                  Contact_Id__r.MailingState,
                                                  Contact_Id__r.MailingCity,
                                                  Contact_Id__r.Vehicle_Type__c,
                                                  Contact_Id__r.AccountId 
                                                  FROM Employee_Reimbursement__c 
                                                  WHERE Id In: reimIds]) {
                                                      
                                                        if( reim.Month__c.contains('-') 
                                                            && ( String.isNotBlank(reim.Contact_Id__r.MailingCity) || String.isNotBlank(reim.Contact_Id__r.MailingState) ) ) 
                                                        {
                                                            reimWiseStateCityMap.put( reim.id, reim.Contact_Id__r.MailingCity + '' + reim.Contact_Id__r.MailingState.toUpperCase() );    
                                                        }  
                                                        if(reim.Fuel_Price__c != null && reim.Fuel_Price__c > 0 )
                                                            reimbursementWiseFuelMap.put(reim.id, reim.Fuel_Price__c);
                                                        
                                                        if(String.isNotBlank(reim.Month__c))
                                                            reimbursementWiseMonthMap.put(reim.Id, reim.Month__c );
                                                        
                                                        if((System.label.FuelPriceAccId.contains(reim.Contact_Id__r.AccountId))
                                                            ||  (reim.Contact_Id__r.Vehicle_Type__c.contains('Mileage Rate'))){
                                                            reimbursementIds.add(reim.Id);
                                                        }
                                                    }
            
            Set<String> cityStateDate = new Set<String>();
            for(Employee_Mileage__c mil : Trigger.New) {
                
                if( mil.Trip_Date__c != null ) {
                    String month = ( mil.Trip_Date__c.month() < 10 ? '0' : '') + mil.Trip_Date__c.month() + '-' + mil.Trip_Date__c.Year();
                    
                    if( reimbursementWiseMonthMap.containsKey(mil.EmployeeReimbursement__c) 
                       && ( month == reimbursementWiseMonthMap.get(mil.EmployeeReimbursement__c)) 
                       && reimbursementWiseFuelMap.containsKey(mil.EmployeeReimbursement__c))
                    {
                        System.debug('It have same reimbursmeent and it is setting fuel price here for Month ' + month);
                        mil.Fuel_Price__c = reimbursementWiseFuelMap.get(mil.EmployeeReimbursement__c);
                    }
                    else if(reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c) )
                    {
                        String stateCity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                        stateCity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                        cityStateDate.add(stateCity);
                    } 
                }                 
                
                if(!reimbursementIds.isEmpty() && reimbursementIds.contains(mil.EmployeeReimbursement__c)){
                    mil.Fuel_Price__c = 0;
                    mil.MPG__c = 0;
                }
                
            }
            
            //System.debug('cityStateDate has no of records ' + cityStateDate);
            if(!cityStateDate.isEmpty())
            {
                for(Gas_Prices__c gs : [Select Id,
                                        Fuel_Price__c,
                                        Month_State_City__c 
                                        FROM Gas_Prices__c 
                                        WHERE Month_State_City__c IN: cityStateDate])
                {
                    gasPriceFuelMap.put( gs.Month_State_City__c, gs.Fuel_Price__c);
                }
                
                if(!gasPriceFuelMap.isEmpty()) {
                    for(Employee_Mileage__c mil : Trigger.New) {
                        if( mil.Trip_Date__c != null && reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c)) {
                            String statecity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                            System.debug('Finally Settinig Fuel price with a part of a key having state and City :- ' + statecity);
                            statecity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                            System.debug('Added dates in to it :- ' + statecity);
                            if( gasPriceFuelMap.containsKey(statecity) ) {
                                System.debug('Finally it is Setting here the fuel price.');
                                mil.Fuel_Price__c = gasPriceFuelMap.get(statecity);
                            }
                        } 

                        if(!reimbursementIds.isEmpty() && reimbursementIds.contains(mil.EmployeeReimbursement__c)){
                            mil.Fuel_Price__c = 0;
                            mil.MPG__c = 0;
                        }
                    }
                }
                
            }
        }
        
    }
    
    if(customSetting.MappingGasPriceTriggerUpdateConvertedDat__c){
        if(Trigger.isInsert && Trigger.isBefore) {
            MappingGasPriceTriggerHelper.updateConvertedDates(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate){
            List<Employee_Mileage__c> updateMileagesList = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c mil : Trigger.New)
            {
                if(mil.TimeZone__c != Trigger.oldMap.get(mil.id).TimeZone__c 
                   || mil.StartTime__c != Trigger.oldMap.get(mil.id).StartTime__c 
                   || mil.EndTime__c != Trigger.oldMap.get(mil.id).EndTime__c)
                {
                    updateMileagesList.add(mil);
                }
                
                if(customSetting.MapTriAppReje__c){
                    if( (mil.Mileage__c == Trigger.oldMap.get(mil.id).Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Not Approved Yet') && (mil.Trip_Status__c == 'Approved')) {
                        
                    }
                    else if( (mil.Mileage__c == Trigger.oldMap.get(mil.id).Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Approved')) {
                        System.debug('mil.Mileage__c'+mil.Mileage__c);
                        System.debug('Trigger.oldMap.get(mil.id).Mileage__c'+Trigger.oldMap.get(mil.id).Mileage__c);
                        mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                        
                        if(mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        } else if (Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = System.today();
                        } else {
                            mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                        }
                        
                    }
                }
                
            }
            if(!updateMileagesList.isEmpty())
                MappingGasPriceTriggerHelper.updateConvertedDates(updateMileagesList);
            
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert && customSetting.MappingGasStayTime__c){
        set<Id> reimbursementIdsSet = new set<Id>();
        List<datetime> tripList = new List<datetime>();
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c empmilege : Trigger.new) {
            reimbursementIdsSet.add(empmilege.EmployeeReimbursement__c); 
        }
        System.debug('reimbursementIdsSet'+reimbursementIdsSet);
        System.debug('StaticValues.isFirstTime===='+StaticValues.isFirstTime);
        if(!reimbursementIdsSet.isEmpty() && StaticValues.isFirstTime){
            StaticValues.isFirstTime = false; 
            System.debug('StaticValues.isFirstTime'+StaticValues.isFirstTime);
            for(AggregateResult objMileage : [SELECT MIN(ConvertedStartTime__c) 
                                              FROM Employee_Mileage__c 
                                              WHERE EmployeeReimbursement__c In : reimbursementIdsSet 
                                              Group By Trip_Date__c ]){
                                                  tripList.add((Datetime)objMileage.get('expr0'));
                                              }
            System.debug('tripList===='+tripList);
            for(Employee_Mileage__c objMil : [SELECT id,ConvertedStartTime__c,Stay_Time__c 
                                              FROM Employee_Mileage__c 
                                              WHERE (ConvertedStartTime__c In :tripList OR Mileage__c = 0)
                                              AND EmployeeReimbursement__c In : reimbursementIdsSet
                                              Order By Stay_Time__c]){
                                                  objMil.Stay_Time__c = 0;
                                                  mileageList.add(objMil);
                                              }
            
            System.debug('mileageList===='+mileageList);
            If(!mileageList.isEmpty()){
                update mileageList;
            }
        }
    }
    
    if(Trigger.isUpdate && Trigger.isAfter && checkRecursive.runOnce() && customSetting.TrackHistory__c) {
        
        MappingGasPriceTriggerHelper.TrackHistory(Trigger.oldMap,Trigger.new);
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // AI-000570                                                                                                         //
    // Mileage update after the lock date                                                                                //
    //When ANY modifications are made to mileage after the lock date:                                                    //
    //The mileage needs to move to the next reimbursement period as soon as the modification happens after the lock date.//
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // if(Trigger.isUpdate && Trigger.isAfter && customSetting.Mileage_Lockdate__c){
    //     //&& MappingGasPriceTriggerHelper.recersive 
    //     //  MappingGasPriceTriggerHelper.recersive = false;
    //     Set<Id> reimIds = new Set<Id>();
    //     for(Employee_Mileage__c empMil : trigger.new){
    //         system.debug('empMil==' +empMil);
    //         reimIds.add(empMil.EmployeeReimbursement__c);
    //     }
        
    //     Map<Id,Employee_Reimbursement__c> reimMap = new Map<Id,Employee_Reimbursement__c>([SELECT id,Name,Mileage_Lock_Date__c,Month__c,Contact_Id__c,Contact_Id__r.Name FROM Employee_Reimbursement__c 
    //                                                                                        WHERE Mileage_Lock_Date__c != null AND Mileage_Lock_Date__c <=: date.today() AND ID IN: reimIds LIMIT 100]);
        
    //     system.debug('reimMap='+reimMap);
    //     set<id> conIds = new set<id>();
    //     for(Employee_Reimbursement__c er : reimMap.values()){
    //         conIds.add(er.Contact_Id__c);
    //     }
        
    //     Map<string,Employee_Reimbursement__c> erNameMap = new Map<string,Employee_Reimbursement__c>();
    //     for(Employee_Reimbursement__c er : [SELECT id,Name,Mileage_Lock_Date__c,Month__c,Contact_Id__c,Contact_Id__r.Name FROM Employee_Reimbursement__c where Contact_Id__c IN:conIds]){
    //         erNameMap.put(er.Name,er);
    //     }
    //     system.debug('erNameMap='+erNameMap);
    //     list<Employee_Mileage__c> emToUpdate = new list<Employee_Mileage__c>();
    //     for(Employee_Mileage__c empMil : trigger.new){
    //         if(empMil.Trip_Status__c == 'Approved' || empMil.Trip_Status__c == 'Rejected'){
    //             if(reimMap.containsKey(empMil.EmployeeReimbursement__c)){
    //                 string contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name;
    //                 integer month = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[0])+1;
    //                 integer year = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[1]);
    //                 integer nextYear = integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[1])+1;
                    
    //                 if(month<10 ) {
    //                     contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':0'+month+'-'+year;
    //                     system.debug('month==1-9=='+contactName);
    //                 }
                    
    //                 else if( integer.valueof((reimMap.get(empMil.EmployeeReimbursement__c).Month__c).split('-')[0]) == 12){
    //                     system.debug('Inserted');
    //                     contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':01'+'-'+nextYear;
    //                     system.debug('contactNamefor12m== '+ contactName);
    //                 }
                    
    //                 else
    //                 {
    //                     contactName = reimMap.get(empMil.EmployeeReimbursement__c).Contact_Id__r.Name+':'+month+'-'+year;
    //                     system.debug('else part contactName='+contactName);
    //                 }
                    
    //                 if(erNameMap.containsKey(contactName)){
    //                     Employee_Mileage__c em = new Employee_Mileage__c();
    //                     em.id = empMil.id;
    //                     system.debug('contactName : '+contactName);
    //                     system.debug('erNameMap.get(contactName).id=='+erNameMap.get(contactName).id );
    //                     em.EmployeeReimbursement__c = erNameMap.get(contactName).id;
    //                     system.debug('erNameMap.get(contactName).id='+erNameMap.get(contactName).id);
    //                     system.debug('StaticValues.isCalledFromReimTri=='+StaticValues.isCalledFromReimTri);
    //                     if(StaticValues.isCalledFromReimTri == true){
    //                         emToUpdate.add(em);
    //                     }
    //                 }   
    //             }   
    //         }
    //     }
    //     if(!emToUpdate.isEmpty()){
    //         update emToUpdate;
    //     }
    // }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // AI-000570                                                                                                         //
    // Mileage update after the lock date                                                                                //
    //When ANY modifications are made to mileage after the lock date:                                                    //
    //The mileage needs to move to the next reimbursement period as soon as the modification happens after the lock date.//
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if(Trigger.isUpdate && Trigger.isAfter && customSetting.Mileage_Lockdate__c && !Test.isRunningTest()){
        MappingGasPriceTriggerHelper.updateMileagesLockDate(Trigger.new);
    }
}