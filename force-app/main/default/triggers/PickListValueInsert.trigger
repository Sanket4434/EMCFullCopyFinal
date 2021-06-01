trigger PickListValueInsert on Vehicle_URL_Mapping__c (after Insert, after Update) {
    Set<String> pick1 = new Set<String>();

    for(Vehicle_URL_Mapping__c test4 : Trigger.New){
        pick1.add(test4.Name);
        
    }
    PickListValueInsert_handler.createPickValue(pick1,JSON.serialize(Trigger.NewMap));
}