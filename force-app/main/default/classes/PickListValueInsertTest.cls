@isTest
public class PickListValueInsertTest {
    
    public static testmethod void PickListValueInsertTest_method1() {
        Test.startTest();
        Vehicle_URL_Mapping__c vm = new Vehicle_URL_Mapping__c();
        vm.Name = '2021 test Vehicle';
        vm.Year__c = '2021';
        vm.vehicle__c = 'test Vehicle';
        insert vm;   
        Test.stopTest();
    }
}