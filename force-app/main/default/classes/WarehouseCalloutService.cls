public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {  

    private static final String urlWarehouse = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void execute(QueueableContext context){
        runWarehouseEquipmentSync();
    }
    
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(urlWarehouse);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(response.getBody());
            List<Product2> productList = new List<Product2>();
            for(Object ob : jsonList) {
                Map<String,Object> mapJson = (Map<String,Object>)ob;
                Product2 pr = new Product2();
                pr.Replacement_Part__c = (Boolean)mapJson.get('replacement');
                pr.Name = (String)mapJson.get('name');
                pr.Maintenance_Cycle__c = (Integer)mapJson.get('maintenanceperiod');
                pr.Lifespan_Months__c = (Integer)mapJson.get('lifespan');
                pr.Cost__c = (Decimal) mapJson.get('lifespan');
                pr.Warehouse_SKU__c = (String)mapJson.get('sku');
                pr.Current_Inventory__c = (Double) mapJson.get('quantity');
                productList.add(pr);
            }            
            if(productList.size()>0)
                upsert productList;
        }        
    }    
 }