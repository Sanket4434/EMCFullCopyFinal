/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Webservice class to fetch Mileages of contacts from TripLog 
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanjay Halpati - 12 May 2020
 * @Description: Added MLOGACCOUNT to Identify new MLOG API accounts for fetching Trips
 * Added a boolean variable for put call on 09/07/2020
 */
global class GetTripCallout {
    
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL; 
    
    Webservice static void GetTripCalloutForMileage(ID empReID, String contactEmail, ID contactid, String priMin, String priMax, String fuel, String mpg, String maintenansAndTires, String apiToken, String tripStatus,Boolean putCall) 
    {
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();   
        List<Employee_Mileage__c> empList = new List<Employee_Mileage__c>();
        Double totalmileages = 0;
        
        //Request Variables
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        // MLOG URL Change | Sanjay Halpati | 12 May 2020 | START
        String endPoint = 'startDate=' + priMin + '&userEmail=' + contactEmail + '&endDate=' + priMax + '&status=' + 
                    tripStatus + '&activity=Business';
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;

        req.setEndpoint(baseURL + StaticValues.GETTRIP_SUFFIX + endPoint );
        // MLOG URL Change | Sanjay Halpati | 12 May 2020 | END

        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'apikey ' + apiToken);
        HttpResponse res = h.send(req);

        Set<Integer> trip_IDs = new Set<Integer>();
        String empMilName = String.valueOf(empReID).substring(0, 15);
        Integer index = 0;
        if(res.getStatusCode() == 200) {                
            TripLogJSONClass.TripLogJSONClassInner tripLog = TripLogJSONClass.parse(res.getBody());
            List<TripLogJSONClass.Trips> listTrips = tripLog.trips;
            Datetime MaxTime;
            /**** Create Employee Mileage Record ****/
            for(TripLogJSONClass.Trips lt : listTrips) 
            {   
                Employee_Mileage__c emp = new Employee_Mileage__c();
                emp.Name = 'EMP-' + empMilName + index;
                emp.Trip_Status__c = StaticValues.noApprovedYet;
                emp.Trip_Id__c = lt.id;
                emp.Mileage__c = lt.mileage;
                //AI-000408
                /*if(emp.Mileage__c == null || emp.Mileage__c == 0) {
                    emp.Trip_Status__c = 'Approved';
                    emp.Approved_Date__c = System.Today();
                }*/
                emp.EmployeeReimbursement__c = empReID;
                emp.Contact_Email_Id__c = contactEmail;
                emp.StartTime__c = !CheckNull(lt.startTime) ? ConvertToDateTime(lt.startTime) : null;
                emp.Day_Of_Week__c = !CheckNull(lt.startTime) ? emp.StartTime__c.format('EEEE') : null;
                emp.EndTime__c = !CheckNull(lt.endTime) ? ConvertToDateTime(lt.endTime) : null;
                emp.Fuel_price__c = !CheckNull(fuel) ? Decimal.valueof(fuel) : null;
                emp.MPG__c = !CheckNull(mpg) ? Decimal.valueof(mpg) : null;
                emp.Maintenance_and_Tires__c = !CheckNull(maintenansAndTires) ? Decimal.valueof(maintenansAndTires) : null;

                
                if(lt.fromLocation != null && lt.fromLocation.display != null ) {
                    emp.FromLocationId__c = lt.fromLocation.id;
                    emp.Trip_Origin__c = lt.fromLocation.display;
                    if(lt.fromLocation.display.contains(',')) {
                        emp.Origin_Name__c = (lt.fromLocation.display.split(','))[0];  
                    } else if(lt.fromLocation.display.contains(' ')) {
                        emp.Origin_Name__c = (lt.fromLocation.display.split(' '))[0];
                    } else {
                        emp.Origin_Name__c =  lt.fromLocation.display;
                    }
                }
                if(lt.toLocation != null && lt.toLocation.display != null) {
                    emp.ToLocationId__c = lt.toLocation.id;
                    emp.Trip_Destination__c = lt.toLocation.display;
                    if(lt.toLocation.display.contains(',')) {
                        emp.Destination_Name__c = (lt.toLocation.display.split(','))[0];  
                    } else if(lt.toLocation.display.contains(' ')) {
                        emp.Destination_Name__c = (lt.toLocation.display.split(' '))[0];
                    } else {
                        emp.Destination_Name__c =  lt.toLocation.display;
                    }
                }

                emp.Notes__c = !CheckNull(lt.notes) ? lt.notes : null;
                emp.Tracing_Style__c = !CheckNull(lt.trackingMethod) ? lt.trackingMethod : null;
                emp.Tag__c = !CheckNull(lt.tags) ? lt.tags : null;
                emp.Stay_Time__c = !CheckNull(String.valueOf(lt.stayTimeMins)) ? lt.stayTimeMins : null;
                /*if( MaxTime != null && emp.StartTime__c.day() > MaxTime.day() && !empList.isEmpty()){
                    empList.get(empList.size()-1).Stay_Time__c = 0;
                }
                MaxTime = emp.EndTime__c;*/
                if(!CheckNull(lt.map_Z)){
                    emp.Triplog_Map__c = baseURL + '/kml/embed/' +  ( lt.map_Z.contains('/') ? lt.map_Z.split('/')[4] : ''); // MLOG Change | Sanjay Halpati | 12 May 2020
                } else {
                    emp.Triplog_Map__c = null;
                }

                emp.Trip_Date__c = !CheckNull(lt.startTime) ? Date.valueof(lt.startTime.split('T')[0]) : null;
                empList.add(emp);
                trip_IDs.add(Integer.valueOf(lt.id));
                totalmileages += Double.valueOf(emp.Mileage__c);    
                index ++;                
            }

            Integer successCount = 0;
            if(!empList.isEmpty()) {
                SendEmailToMe__c objSendEmailToMe = SendEmailToMe__c.getValues('GetTripCallOutApprovePutCall');
                if(objSendEmailToMe.Send_email_to_me__c && putCall == true){
                    GetTripCallout.putHTTP(apiToken, contactid, empReID, trip_IDs); 
                }

                Database.UpsertResult[] insertedTrips = Database.upsert(empList,Employee_Mileage__c.Fields.Trip_Id__c, false);
                
                for(Database.UpsertResult srresult : insertedTrips) {
                    if(srresult.isSuccess())
                        successCount ++;
                }
               
            }
            Tripslog__c obj = new Tripslog__c();
            obj.Contact__c = contactid;
            obj.Employee_Reimbursement__c = empReID;
            obj.Endpoint__c = baseURL + StaticValues.GETTRIP_SUFFIX + endPoint;
            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
            obj.Status__c ='Success'; 
            obj.Total_Trips__c= successCount;
            obj.Total_Mileages__c = totalmileages;
            obj_Tripslog_list.add(obj); 
        }
        else {
            Tripslog__c obj = new Tripslog__c();
            obj.Contact__c = contactid;
            obj.Employee_Reimbursement__c = empReID;
            obj.Endpoint__c = baseURL + StaticValues.GETTRIP_SUFFIX + endPoint;
            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
            obj.Status__c ='Fail'; 
            obj.Total_Trips__c = 0;
            obj.Total_Mileages__c = 0;
            obj_Tripslog_list.add(obj); 
        }
        if(!obj_Tripslog_list.isEmpty()) {
            insert obj_Tripslog_list;
            
            if(!System.isBatch() ) {
                Database.executeBatch(new LoadMileageLocationBatch(new Set<Id>{ empReID }, true ),50);
            }
        }
    }

    public static void putHTTP(String apiToken,String contactid,String empReID, Set<Integer> trip_IDs) {
        
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
        HttpRequest putReq = new HttpRequest();
        Http putHTTP = new Http();
        String body = '{"status":"Submitted","ids":[';
        String part = '';

        for (Integer i : trip_IDs) {
            part += String.valueof(i) + ',';
        }
        part = part.removeEnd(',');
        body += part +']}';
        String endPoint = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        endPoint += StaticValues.STATUS_SUFFIX;
        putReq.setEndpoint(endPoint);
        putReq.setMethod('PUT');                 
        putReq.setBody(body);
        putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ' + apiToken);
        HttpResponse putRes = putHTTP.send(putReq);

        Tripslog__c obj = new Tripslog__c();
        obj.Body__c = body;
        obj.Contact__c = contactid;
        obj.Employee_Reimbursement__c = empReID;
        obj.Endpoint__c = endPoint;
        if(!Test.IsRunningTest())
        {
            obj.Response__c = String.valueOf(putRes.getStatusCode()) + ' ######## ' + putRes.getStatus();
        }
        
        obj.Total_Trips__c= 0;
        obj.Total_Mileages__c = 0;
        obj.Status__c = putRes.getStatusCode() == 200 ? 'Success' : 'Fail';
        obj_Tripslog_list.add(obj);

        if(!obj_Tripslog_list.isEmpty()) {
            insert obj_Tripslog_list;
        }
    }

    public static Boolean CheckNull(String param1) {
        return param1 == null || param1 == '' ? true : false;
    }

    public Static DateTime ConvertToDateTime(String param1) {
        
        param1 = param1.replace(':','-');
        param1 = param1.replace('T','-');
        return DateTime.newInstance(
                Integer.valueof(param1.split('-')[0]), 
                Integer.valueof(param1.split('-')[1]), 
                Integer.valueof(param1.split('-')[2]), 
                Integer.valueof(param1.split('-')[3]), 
                Integer.valueof(param1.split('-')[4]), 
                Integer.valueof(param1.split('-')[5].removeEnd('.000Z'))
            );
    }
}