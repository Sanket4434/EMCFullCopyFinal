//////////////////////////////////////////////////////////////////////////////////
//																				
//
//
//
//
//////////////////////////////////////////////////////////////////////////////

public class PickListValueInsert_handler{
    public class MetadataServiceExamplesException extends Exception { }
    @Future(callout=true)
    public static void createPickValue(Set<String> pick1,String newMapString){
        try{            
            system.debug('pick1==' + pick1);
            system.debug('newMapString'+ newMapString);
            Map<Id, Account> newMap = (Map<Id, Account>)JSON.deserialize(newMapString, Map<Id, Account>.class);
            system.debug('newMap=='+ newMap);
            
            //existing picklist value map currently available value of multiselect picklist
            map<String,String> existPickValueMap = new map<String,String>();
            
            Schema.DescribeFieldResult fieldResult = Account.Vehicle_Types__c.getDescribe(); 
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
            
            for( Schema.PicklistEntry v : values) { 
                existPickValueMap.put(v.getLabel(),v.getValue());
            }
            system.debug('existPickValueMap=='+ existPickValueMap);
            
            MetadataService.MetadataPort service = createService();     
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = 'Account.Vehicle_Types__c';  
            customField.label = 'Vehicle Types'; 
            customField.type_x = 'MultiselectPicklist';
            customField.visibleLines = 4;
            
            metadataservice.Picklist pt = new metadataservice.Picklist();
            pt.sorted= false;
            pt.picklistValues = new list<metadataservice.PicklistValue>();
            for(String obj : pick1){
                if(!existPickValueMap.containskey(obj)){
                    metadataservice.PicklistValue plValue = new metadataservice.PicklistValue();
                    plValue.fullName= obj;
                    plValue.default_x=false ;
                    pt.picklistValues.add(plValue);
                }  
            }
            customField.picklist = pt ;
            
            List<MetadataService.SaveResult> results =
                service.updateMetadata(
                    new MetadataService.Metadata[] { customField });
            handleSaveResults(results[0]);
            
            system.debug('results=='+results);
        }
        catch(exception e){
            system.debug('excaption=='+ e.getmessage()+' and line number is '+e.getlinenumber());
        }
    }
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0){
                system.debug('message='+messages);
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
            }
        }
        if(!saveResult.success){
            
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
        }  
    }
    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
}