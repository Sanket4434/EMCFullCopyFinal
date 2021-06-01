public with sharing class UpdateInsuranceDataController {
    public static String accId;
    public List<ContactWrapper> conWrapList {get; set;}
    public string conWrapper {get; set;}
    public UpdateInsuranceDataController() {
        accId = ApexPages.currentPage().getParameters().get('id');
        System.debug('accId=='+accId);
        if(accId != null){
            System.debug('accId'+accId);
           conWrapper = updatedNewEmployee();
        }
    }
    
    @RemoteAction
    public static string updatedNewEmployee()
    {
        System.debug('updatedNewEmployee');
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            for(Contact con : [SELECT id,name,Insurance__c, Meeting_Minimum__c,
                                        Current_Level__c, Expiration_Date__c, 
                                        Vehicle_Value_Check__c, Vehicle_Age__c 
                                FROM Contact 
                                WHERE AccountId =: accId ]) {
                                    ContactWrapper conWrap = new ContactWrapper();
                                    conWrap.contactId = con.Id;
                                    conWrap.name = con.Name;
                                    conWrap.insurance = con.Insurance__c;
                                    conWrap.meetingMinimum = con.Meeting_Minimum__c;
                                    if(con.Current_Level__c != null){
                                        conWrap.currentLeval = con.Current_Level__c;
                                    }
                                    if(con.Expiration_Date__c != null){
                                        conWrap.expirationDate = con.Expiration_Date__c;
                                    }
                                    conWrap.vehicleValue = con.Vehicle_Value_Check__c;
                                    conWrap.vehicleAge = con.Vehicle_Age__c;
                                    conWrap.isEditable = false;
                                    conWrapList.add(conWrap);
            }
            System.debug('conWrapList'+conWrapList.size());
            String wrapjson = JSON.serialize(conWrapList);
            System.debug('wrapjson'+wrapjson);
            return wrapjson;
    }
    @RemoteAction
    public static string editInlineNewEmployee(String listofemployee)
    {
        System.debug('editInlineNewEmployee'+listofemployee);
        List<Contact> updateEmployeeList = new List<Contact>();
        if(listofemployee!=null)
        {
            List<ContactWrapper> conWrapUpdateList = new List<ContactWrapper>();
            conWrapUpdateList = (List<ContactWrapper>)Json.deserialize(listofemployee,List<ContactWrapper>.class);
            
            for(ContactWrapper conwrap : conWrapUpdateList){
                 System.debug('conwrap.meetingMinimum'+conwrap.meetingMinimum);
                Contact currentContact = new Contact();
                currentContact.Id = conwrap.contactId;
                currentContact.Insurance__c = conwrap.insurance;
                
                currentContact.Meeting_Minimum__c = conwrap.meetingMinimum;
                currentContact.Current_Level__c = conwrap.currentLeval;
                currentContact.Expiration_Date__c = conwrap.expirationDate;
                currentContact.Vehicle_Value_Check__c = conwrap.vehicleValue;
                currentContact.Vehicle_Age__c = conwrap.vehicleAge;
                updateEmployeeList.add(currentContact);
            }
        }
        if(!updateEmployeeList.isEmpty()){
            System.debug('updateEmployeeList'+updateEmployeeList.size());
            update updateEmployeeList;
        }
        System.debug('2nd updatedNewEmployee');
        return 'Success';
    }

    public class ContactWrapper {
        public string contactId { get; set; }
        public string name { get; set; }
        public string insurance { get; set; }
        public Boolean meetingMinimum { get; set; }
        public Boolean isEditable { get; set; }
        public date currentLeval { get; set; }
        public date expirationDate { get; set; }
        public Boolean vehicleValue { get; set; }
        public Boolean vehicleAge { get; set; }
    }
}