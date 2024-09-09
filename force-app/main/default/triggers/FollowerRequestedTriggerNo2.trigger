/*
Given Scenario: When the 'Number_Of_Locations__c' field changes. Whenever this field is updated—whether during record creation or modification—it 
triggers the addition or removal of related 'Location__c' (a custom object) records under the corresponding contact.This approach not only streamlines 
data management but also boosts workflow efficiency. (Note: Parent object- (Contact), child object- (Location__c) and Relationship- (Lookup))
*/

trigger FollowerRequestedTriggerNo2 on Contact (after insert, after update) {
    set<Id> conIds = new set<Id>();
    map<Id, Location__c> locationMap;
    map<Id, Integer> conIdToNumOdLocation = new map<Id, Integer>();
    list<Location__c> insertList = new list<Location__c>();
    list<Location__c> deleteList = new list<Location__c>();
    if(Trigger.isInsert){
        for(Contact conNew : Trigger.new){
            if(conNew.Number_Of_Locations__c != null){
                conIds.add(conNew.Id);
                if(!conIdToNumOdLocation.keySet().contains(conNew.Id)){
                    conIdToNumOdLocation.put(conNew.Id, (Integer)conNew.Number_Of_Locations__c);
                }
            }        
        }
    }
    if(Trigger.isUpdate){
        locationMap = new map<Id, Location__c>([SELECT Id, Contact__c, Name FROM Location__c WHERE Contact__c IN :Trigger.oldMap.keySet()]);
        system.debug('Location Map : '+locationMap);
        for(Contact conNew : Trigger.new){
            if(Trigger.oldMap.get(conNew.Id).Number_Of_Locations__c != conNew.Number_Of_Locations__c){
                conIds.add(conNew.Id);
                if(!conIdToNumOdLocation.keySet().contains(conNew.Id)){
                    conIdToNumOdLocation.put(conNew.Id, (Integer)conNew.Number_Of_Locations__c);
                }
            }
        }
    }
    for(Contact con : [SELECT Id, (SELECT Id, Contact__c FROM Locations__r) FROM Contact WHERE Id IN: conIds]){
        Integer n = 0;
        if(conIdToNumOdLocation.get(con.Id) > con.Locations__r.size()){   
			n = conIdToNumOdLocation.get(con.Id) - con.Locations__r.size();         	
        }else if(conIdToNumOdLocation.get(con.Id) < con.Locations__r.size()){
            n = 0;
           	for(Location__c loc : con.Locations__r){
                if(deleteList.size() < (con.Locations__r.size() - conIdToNumOdLocation.get(con.Id))){
                    deleteList.add(locationMap.get(loc.Id));
                }
        	}
        }else{
            n = conIdToNumOdLocation.get(con.Id);
        }
        for(Integer i = 1; i <= n; i++){
                Location__c l = new Location__c();
                l.Contact__c = con.Id;
                l.Name = 'Location '+i;
                insertList.add(l);
        }
    }
    if(!insertList.isEmpty()){
        insert insertList;
    }
    if(!deleteList.isEmpty()){
        delete deleteList;
    }
}