public with sharing class MaintenanceRequestHelper {

    //Declaring Instance, useful for calling non static classes on trigger
    private static MaintenanceRequestHelper instance = new MaintenanceRequestHelper();

    public static MaintenanceRequestHelper getInstance()
	{
		return instance;
	}
    
    //First Part - Filtering Cases that the trigger will use
    public void updateWorkOrders(List<Case> lstCase, Map<Id,Case> mapOld) {
        //Map of cases to be processed
        Map<Id,Case> mapIdCase;

        //Map for filtering updates and non closed cases
        mapOld = mapOld == null ? new Map<Id,Case>() : mapOld;
        mapIdCase = new Map<Id,Case>();

        for(Case cases : lstCase) {
            Case oldCase;

            oldCase = mapOld.get(cases.Id);

            //IF for filtering cases
            if( cases.Status == 'Closed') {
                if(cases.Type == 'Repair' || cases.Type == 'Routine Maintenance') {
                    mapIdCase.put(cases.Id, cases);
                }
            }
        }
        //send data to the next method
        updateWorkOrders(mapIdCase);
    }

    public void updateWorkOrders(Map<Id,Case> MaplstCases) {

        List<Case> lstNewCases = new List<Case>();

        //Get the minimun maintenance cycle value
        Map<String,Integer> IDToCycleMap = getMinMaintenanceCycleByCaseID(MaplstCases);

        //create the new case based on the values of the last one
        for(Case cs : MaplstCases.values()) {
            Case newCase = new Case();
            newCase.Status = 'New';
            newCase.Vehicle__c = cs.Vehicle__c;
            newCase.ProductId = cs.ProductId;
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = String.isBlank(cs.Subject) ? 'Routine Maintenance Request' : cs.Subject + ' New';
            newCase.Date_Reported__c = Date.today();
            //check if the value of the maintenance cycle field is null; if it is, set today as the due date, else, set the lowest date plus today
            newCase.Date_Due__c = IDToCycleMap.get(cs.Id) == null ? Date.today() : Date.today()+IDToCycleMap.get(cs.Id);
            newcase.Cloned_Case_Id__c = cs.Id;      
            lstNewCases.add(newCase);
        }
        insert lstNewCases;
    }

    //Get min Maintenance Cycle by Case    
    public static Map<String,Integer> getMinMaintenanceCycleByCaseID(Map<Id, Case> caseList){
        Map<String,Integer> IDToCycleMap = new Map<String,Integer>();
        List<String> CaseIDList = new List<String>();

        for(Case eachCase  : caseList.values()){
            caseIDList.add(eachCase.ID);
        }

        //Aggregate MIN to discover the lowest maintenance cycle value of a case
        List<AggregateResult> result =[SELECT Maintenance_Request__r.ID CaseID, MIN(Equipment__r.Maintenance_Cycle__c)  Cycle FROM Equipment_Maintenance_Item__c WHERE 
                                       Maintenance_Request__r.ID IN :caseIDList AND Equipment__r.Maintenance_Cycle__c != null group by Maintenance_Request__r.ID];
        
        //Use the case Id as key and cycle as value for the map
        for(AggregateResult a : result){
            IDToCycleMap.put((String)a.get('CaseID'),Integer.valueOf(a.get('Cycle'))); 
        }    
        return IDToCycleMap;
    }
    
}
