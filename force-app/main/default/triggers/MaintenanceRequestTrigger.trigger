trigger MaintenanceRequestTrigger on Case (before update, after update) {
    if(Trigger.isUpdate && Trigger.isBefore){
    	MaintenanceRequestHelper.getInstance().updateWorkOrders(Trigger.New, (Map<Id, Case>) trigger.oldMap);
    }
}
