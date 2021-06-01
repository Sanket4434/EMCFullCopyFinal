public with sharing class GetDriverData {
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL;
    @AuraEnabled(cacheable=true)
    public static List < sObject > fetchLookUpValues(String accId,String adminId,String accField,String idOfDriver,String whereField, String searchKey,String fieldName, String ObjectName,String keyField,Boolean isActive) {
        List < sObject > returnList = new List < sObject > ();
        Contact conObj ;
        String sQuery ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        
        if((String.isBlank(idOfDriver) || String.isEmpty(idOfDriver)) && ((String.isBlank(adminId) || String.isEmpty(adminId)))){
            //sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' LIMIT 9999' ;
            sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND '+searchKey+ ' != null LIMIT 49999' ;
        }
        else if((!String.isBlank(adminId) || !String.isEmpty(adminId)) && ObjectName == 'Contact' && (conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver))){
            if(isActive == true){
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c = null LIMIT 9999' ;
            }
            else {
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c != null LIMIT 9999' ;
            }
        }
        else if((!String.isBlank(adminId) || !String.isEmpty(adminId)) && ObjectName == 'Contact'){
            if(isActive == true){
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where ((Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+')) AND '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c = null LIMIT 9999' ;
            }
            else {
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where ((Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+')) AND '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c != null LIMIT 9999' ;
            }
        }
        else {
            sQuery =  'select '+fieldName+','+keyField+' from '+ObjectName+' where '+whereField+'='+'\''+idOfDriver+'\''+' and '+accField+'='+'\''+accId+'\'';
        }
        System.debug('sQuery'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static string fetchWayPointPostAPI(Integer tripId,String apikey){
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        String body;
        String baseURL ;
        baseURL = !MLOGACCOUNT.Contains(apikey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        baseURL = baseURL + '/api/trips/'+tripId+'/routes';
        if(!Test.isRunningTest()){
            HttpResponse res = ApiCalloutUtility.executeCallout(apikey,'GET',baseURL,'','');
            if(res.getStatusCode() == 200) {
                body = res.getBody();
            }
        }
        
        if(body != null){
            for(Employee_Mileage__c mileage : [SELECT id,Trip_Id__c,Way_Points__c 
                                                FROM Employee_Mileage__c 
                                                WHERE Trip_Id__c =: tripId LIMIT 10]){
                mileage.Way_Points__c = body;
                mileageList.add(mileage);
            }
        }
        if(!mileageList.isEmpty()){
            System.debug('mileageList'+mileageList);
            update mileageList;
        }
        return body;
    }
    
    @AuraEnabled
    public static String fetchMileagesSize(String accID,String adminId){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        Contact conObj ;
        if(!String.isBlank(adminId) || !String.isEmpty(adminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: adminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                        Stay_Time__c, Driving_Time__c,
                        EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                        Mileage__c,Trip_Origin__c, Trip_Destination__c,
                        Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                        ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                        Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                        From_Location__Latitude__s, From_Location__Longitude__s,
                        To_Location__Latitude__s, To_Location__Longitude__s,
                        Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                        EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                        TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c 
                    FROM Employee_Mileage__c
                    WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                    AND EmployeeReimbursement__r.Month__c =: lastMonth
                    AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                    order by ConvertedStartTime__c asc 
                    limit 9999
                    ];
        }
        else {
            mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                        Stay_Time__c, Driving_Time__c,
                        EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                        Mileage__c,Trip_Origin__c, Trip_Destination__c,
                        Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                        ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                        Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                        From_Location__Latitude__s, From_Location__Longitude__s,
                        To_Location__Latitude__s, To_Location__Longitude__s,
                        Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                        EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                        TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c 
                    FROM Employee_Mileage__c
                    WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                        AND EmployeeReimbursement__r.Month__c =: lastMonth
                        AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId) 
                        )
                        AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                        order by ConvertedStartTime__c asc
                        LIMIT 1999];
        }
        return String.valueOf(mileageList.size());
    }

    @AuraEnabled
    public static List<Employee_Mileage__c> fetchMileages(String accID,String AdminId,Integer limitSize, Integer offset){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        Contact conObj ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                        Stay_Time__c, Driving_Time__c,
                        EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                        Mileage__c,Trip_Origin__c, Trip_Destination__c,
                        Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                        ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                        Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                        From_Location__Latitude__s, From_Location__Longitude__s,
                        To_Location__Latitude__s, To_Location__Longitude__s,
                        Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                        EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                        TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c 
                    FROM Employee_Mileage__c
                    WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                        AND EmployeeReimbursement__r.Month__c =: lastMonth AND 
                        EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                        order by ConvertedStartTime__c desc
                        LIMIT :limitSize
                        OFFSET :offset];
        }
        else {
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                        Stay_Time__c, Driving_Time__c,
                        EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                        Mileage__c,Trip_Origin__c, Trip_Destination__c,
                        Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                        ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                        Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                        From_Location__Latitude__s, From_Location__Longitude__s,
                        To_Location__Latitude__s, To_Location__Longitude__s,
                        Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                        EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                        TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c 
                    FROM Employee_Mileage__c
                    WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                        AND EmployeeReimbursement__r.Month__c =: lastMonth
                        AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId) 
                        OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId) 
                        ) AND 
                        EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                        order by ConvertedStartTime__c desc
                        LIMIT : limitSize
                        OFFSET :offset];
        }
    }
    
    @AuraEnabled
    public static String getMilegesDataSize(Id accountId,Id idOfDriver, Date StartDate, Date EndDate, String OriginName, String DestinationName,Boolean ActiveDriver,String StartMileage,String EndMileage,String TripStatus,String TrackingMethod,String Tag,String Notes) {

        String query = 'SELECT id,Trip_Date__c,Stay_Time__c,Tag__c, Driving_Time__c,EmployeeReimbursement__r.Contact_Id_Name__c,ConvertedStartTime__c,ConvertedEndTime__c,EmployeeReimbursement__r.Contact_Id__r.Name,Mileage__c,Trip_Origin__c, Trip_Destination__c,Origin_Name__c, Destination_Name__c,EmployeeReimbursement__r.Contact_Id__c,Triplog_Map__c,Day_Of_Week__c,Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c,Notes__c, Tracing_Style__c,From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,Trip_Id__c,Way_Points__c,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,TimeZone__c,EmployeeReimbursement__r.Contact_Id__r.AccountId,Drive_Stay_Time__c FROM Employee_Mileage__c';
      
        String whereClause = '';
        if(accountId != null || idOfDriver != null || StartDate != null || EndDate != null || OriginName != null || DestinationName != null || StartMileage != null || EndMileage != null || TripStatus != null || TrackingMethod != null || Tag != null || Notes != null ){
            whereClause = ' WHERE ';
        }

        if( accountId != null ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.AccountId', accountId , '=','String');
        }

        if( idOfDriver != null ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__c', idOfDriver , '=','String');
        }
        
        if(StartDate != null){
           whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', buildDateforactivation(StartDate), '>=', 'Date');
        }
        
        if(EndDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', buildDateforactivation(EndDate), '<=', 'Date');
        }
        if(OriginName != null){
         
            whereClause = GenerateWhereClause (whereClause, 'Trip_Origin__c', OriginName, '=', 'String');
        }
        if(DestinationName != null){
         
            whereClause = GenerateWhereClause (whereClause, 'Trip_Destination__c', DestinationName, '=', 'String');
        }
        if(StartMileage != null){
           whereClause = GenerateWhereClause (whereClause, 'Mileage__c', StartMileage, '>=', 'Number');
        }
        if(EndMileage != null){
           whereClause = GenerateWhereClause (whereClause, 'Mileage__c', EndMileage, '<=', 'Number');
        }
        if(TripStatus != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Status__c', TripStatus, '=', 'String');
        }
        if(TrackingMethod != null){
            whereClause = GenerateWhereClause (whereClause, 'Tracing_Style__c', TrackingMethod, '=', 'String');
        }
        if(ActiveDriver == true){
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c', null, '=', 'Number');
        }
        if(Tag != null){
            whereClause = GenerateWhereClause (whereClause, 'Tag__c', Tag, '=', 'String');
        }
        if(Notes != null){
            //whereClause = GenerateWhereClause (whereClause, 'Notes__c', '%' + Notes + '%', 'LIKE', 'String');
        }
        system.debug('whereClause'+whereClause);
        query += whereClause;
        system.debug('query='+query);
        query += ' order by ConvertedStartTime__c asc ';
        query += ' LIMIT 9999';
        system.debug('query'+query);
        List<Employee_Mileage__c> mileageDetail = Database.query(query); 
        return string.valueOf(mileageDetail.size());
    }

    @AuraEnabled
    public static List <Employee_Mileage__c> getMilegesData(Id accountId,Id idOfDriver, Date StartDate, Date EndDate, String OriginName, String DestinationName,Boolean ActiveDriver,String StartMileage,String EndMileage,String TripStatus,String TrackingMethod,String Tag,String Notes, Integer limitSize, Integer offset) {
        System.debug('limitSize'+limitSize);
        System.debug('offset'+offset);
         System.debug('accountId'+accountId);
        System.debug('idOfDriver'+idOfDriver);
        System.debug('StartDate'+StartDate);
        System.debug('EndDate'+EndDate);
        String query = 'SELECT id,Trip_Date__c,Stay_Time__c,Tag__c, Driving_Time__c,EmployeeReimbursement__r.Contact_Id_Name__c,ConvertedStartTime__c,ConvertedEndTime__c,EmployeeReimbursement__r.Contact_Id__r.Name,Mileage__c,Trip_Origin__c, Trip_Destination__c,Origin_Name__c, Destination_Name__c,EmployeeReimbursement__r.Contact_Id__c,Triplog_Map__c,Day_Of_Week__c,Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c,Notes__c, Tracing_Style__c,From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,Trip_Id__c,Way_Points__c,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,TimeZone__c,EmployeeReimbursement__r.Contact_Id__r.AccountId,Drive_Stay_Time__c FROM Employee_Mileage__c';
      
        String whereClause = '';
        if(accountId != null || idOfDriver != null || StartDate != null || EndDate != null || OriginName != null || DestinationName != null || StartMileage != null || EndMileage != null || TripStatus != null || TrackingMethod != null || Tag != null || Notes != null ){
            whereClause = ' WHERE ';
        }

        if( accountId != null ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.AccountId', accountId , '=','String');
        }

        if( idOfDriver != null ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__c', idOfDriver , '=','String');
        }
        
        if(StartDate != null){
           whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', buildDateforactivation(StartDate), '>=', 'Date');
        }
        
        if(EndDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', buildDateforactivation(EndDate), '<=', 'Date');
        }
        if(OriginName != null){
         
            whereClause = GenerateWhereClause (whereClause, 'Trip_Origin__c', OriginName, '=', 'String');
        }
        if(DestinationName != null){
         
            whereClause = GenerateWhereClause (whereClause, 'Trip_Destination__c', DestinationName, '=', 'String');
        }
        if(StartMileage != null){
           whereClause = GenerateWhereClause (whereClause, 'Mileage__c', StartMileage, '>=', 'Number');
        }
        if(EndMileage != null){
           whereClause = GenerateWhereClause (whereClause, 'Mileage__c', EndMileage, '<=', 'Number');
        }
        if(TripStatus != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Status__c', TripStatus, '=', 'String');
        }
        if(TrackingMethod != null){
            whereClause = GenerateWhereClause (whereClause, 'Tracing_Style__c', TrackingMethod, '=', 'String');
        }
        if(ActiveDriver == true){
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c', null, '=', 'Number');
        }
        if(Tag != null){
            whereClause = GenerateWhereClause (whereClause, 'Tag__c', Tag, '=', 'String');
        }
        if(Notes != null){
            //whereClause = GenerateWhereClause (whereClause, 'Notes__c', '%' + Notes + '%', 'LIKE', 'String');
        }
        query += whereClause;
        query += ' order by ConvertedStartTime__c asc ';
        //query += ' LIMIT 9999';
        query += 'LIMIT ' + limitSize +' ';
        query += 'OFFSET ' + offset;
        system.debug('query'+query);
        List<Employee_Mileage__c> mileageDetail = Database.query(query); 
        system.debug('mileageDetail'+mileageDetail.size());
        return mileageDetail;
    }

    public static String buildDateforactivation( Date datefield )
    {
        return (Datetime.newInstance(datefield, system.now().time())).format('YYYY-MM-dd');   
    }

    public static String GenerateWhereClause( String whereClause, String fieldAPI , String fieldValue, String operator, String dateType) {
        
        whereClause = ( whereClause != ' WHERE ' ? whereClause + ' AND ' : whereClause ) + 
                      fieldAPI + ' ' + operator + ' ' + ( dateType == 'String'? '\'' + fieldValue + '\'' : fieldValue);
        return whereClause;
    }
    
    @AuraEnabled
    public static String approveMileages(Boolean checked,String emailaddress,Boolean sendEmail)
    { 
        system.debug('checked'+checked);
        system.debug('emailaddress'+emailaddress);
        system.debug('sendEmail'+sendEmail);
        Map<String,List<String>> approveRejectMileageMap = new Map<String,List<String>>(); 
        List<String> nullList = new List<String>();
        List<String> mileageIds = new List<String>();
        List<Employee_Mileage__c> mileagesToApprove = new List<Employee_Mileage__c>();
        List<MileageJsonDeserialize> emailIdJson = MileageJsonDeserialize.parse(emailaddress);
        
        for(MileageJsonDeserialize objMileages : emailIdJson) {
            mileageIds.add(objMileages.Id);
           if(approveRejectMileageMap.size() > 0 && approveRejectMileageMap.containsKey(objMileages.employeeEmailId))
            {
                List<String> mileagesEmailList = approveRejectMileageMap.get(objMileages.employeeEmailId);
                mileagesEmailList.add(String.valueOf(objMileages.id));
                approveRejectMileageMap.put(objMileages.employeeEmailId,mileagesEmailList);
            }
            else
            {
                List<String> mileagesEmailList = new List<String>();
                mileagesEmailList.add(String.valueOf(objMileages.id));
                approveRejectMileageMap.put(objMileages.employeeEmailId,mileagesEmailList);
            }  
        }
        if(checked == true ) {
            mileagesToApprove = WrapperUtils.UpdateMileages(mileageIds,'Approved');
        }
        else {
            mileagesToApprove = WrapperUtils.UpdateMileages(mileageIds,'Rejected');
        }
        if(!mileagesToApprove.isEmpty()) {
            system.debug('mileagesToApprove'+mileagesToApprove);
            update mileagesToApprove;
        }
    
            SendEmailToMe__c customSetValue = SendEmailToMe__c.getValues('ChangeTripStatusinTripLogBatch');
            if(customSetValue != null && customSetValue.Send_email_to_me__c == true)
            {
                if(approveRejectMileageMap.size() > 0 && !Test.isRunningTest()){
                    for(String currentMileages : approveRejectMileageMap.keySet()){
                        if(checked == true ) {
                            if(sendEmail == true){
                                Database.executeBatch(New ChangeTripStatusinTripLog(approveRejectMileageMap.get(currentMileages),nullList,'',currentMileages),1);
                            }
                            else {
                                Database.executeBatch(New ChangeTripStatusinTripLog(approveRejectMileageMap.get(currentMileages),nullList,'',''),1);
                            }
                            
                        }
                        else {
                            if(sendEmail == true){
                                Database.executeBatch(New ChangeTripStatusinTripLog(nullList,approveRejectMileageMap.get(currentMileages),'',currentMileages),1);
                            }
                            else {
                                Database.executeBatch(New ChangeTripStatusinTripLog(nullList,approveRejectMileageMap.get(currentMileages),'',''),1);
                            }
                            
                        }
                     
                    } 
                }
            }    
        return 'success';
    }

    @AuraEnabled
    public static string deleteMileages(String emailaddress)
    { 
        Set<Id> mileagesIds = new Set<Id>();
        List<MileageJsonDeserialize> emailIdJson = MileageJsonDeserialize.parse(emailaddress);
        for(MileageJsonDeserialize objMileages : emailIdJson) {
            mileagesIds.add(objMileages.Id);
        }
        if(mileagesIds.size() > 0 ){
            delete[SELECT id FROM Employee_Mileage__c WHERE id =: mileagesIds];
        }
        return 'deleted';
    }

    @AuraEnabled
    public static string updateMileages(String tripId,String tripTag)
    { 
        Employee_Mileage__c mil = new Employee_Mileage__c();
        mil.Id = tripId;
        mil.Tag__c = tripTag;
        update mil;
        return 'updated';
    }
    
    @AuraEnabled
    public static List<Employee_Mileage__c> mileageListData(String accId,String adminId, date startDate, date endDate){
        system.debug('accId'+accId);
        system.debug('adminId'+adminId);
                system.debug('startDate'+startDate);
                        system.debug('endDate'+endDate);
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        List<Contact> conList = new List<Contact>();
        if(adminId != null) {
            conList = [SELECT Id, Name, Role__c FROM Contact WHERE id =: adminId];
        }
        
        if(conList[0].Role__c =='Manager' || conList[0].Role__c =='Driver/Manager'){
            if(startDate != null && endDate != null ) {
                mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                            Stay_Time__c, Driving_Time__c,
                            EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                            Mileage__c,Trip_Origin__c, Trip_Destination__c,
                            Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                            ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                            Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                            From_Location__Latitude__s, From_Location__Longitude__s,
                            To_Location__Latitude__s, To_Location__Longitude__s,
                            Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                            EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                            TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c
                        FROM Employee_Mileage__c where  (Trip_Date__c >=: startDate AND Trip_Date__c<=: endDate)
                            AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                            AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId) 
                            OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId) 
                            OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId) 
                            OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId) )
                            order by ConvertedStartTime__c asc
                            limit 49999]; 
            }
        } else {
            if(startDate != null && endDate != null ) {
                mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,
                            Stay_Time__c, Driving_Time__c,
                            EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,
                            Mileage__c,Trip_Origin__c, Trip_Destination__c,
                            Origin_Name__c, Destination_Name__c,ConvertedStartTime__c,
                            ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,
                            Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,
                            From_Location__Latitude__s, From_Location__Longitude__s,
                            To_Location__Latitude__s, To_Location__Longitude__s,
                            Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,
                            EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                            TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c
                        FROM Employee_Mileage__c where  (Trip_Date__c >=: startDate AND Trip_Date__c<=: endDate)
                            AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID 
                            order by ConvertedStartTime__c asc
                            limit 49999]; 
            }
        }
        
        system.debug('mileageList'+mileageList);
                system.debug('mileageList'+mileageList.size());
        return mileageList;
    }

    @AuraEnabled
    public static string deleteTrips(String accountId,String month){
        
        /*if(accountId != null){
            delete [SELECT id 
                    FROM Employee_Mileage__c 
                    WHERE Trip_Status__c = 'Not Approved Yet' 
                        AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accountId
                        AND EmployeeReimbursement__r.Month__c =: month];
        }*/
        return 'deleted';
    }

    @AuraEnabled
    public static string MassSyncTrips(String accountId,String startDate,String endDate,String month,String tripStatus){
        System.debug('startDate'+startDate+'=======endDate'+endDate+'accountId'+accountId);
        MassSyncTrips  obj = new MassSyncTrips(accountId,startDate,endDate,month,tripStatus,false);
        Database.executeBatch (obj,1);
        return 'Success';
    } 
}