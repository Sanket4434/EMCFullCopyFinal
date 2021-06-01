/**
 * @File Name          : CheckVehicleAccountTrigger.trigger
 * @Description        : Verify the availablity of vehicle based on vehicle value entered in Account records.
 * @Author             : Minkesh Patel
**/
trigger CheckVehicleAccountTrigger on Account(before insert,before update) {
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore) {
        CheckVehicleAccountTriggerHandler.ValidateVehicle(Trigger.new);
    }
}