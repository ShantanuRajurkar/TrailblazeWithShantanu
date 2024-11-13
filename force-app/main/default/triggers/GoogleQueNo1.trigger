/**
 * @description       : 
 * @author            : Shantanu Rajurkar
 * @last modified on  : 11-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger GoogleQueNo1 on Patient__c (after update) {
    set<Id> fatalPatIds = new Set<Id>();
    set<Id> curedPatIds = new Set<Id>();
    List<Area__c> areasToUpdate = new List<Area__c>();
    for(Patient__c pNew : Trigger.new){
        if(pNew.Stage__c != Trigger.oldMap.get(pNew.Id).Stage__c && pNew.Stage__c == 'Fatal'){
            fatalPatIds.add(pNew.Area__c);
        }else if(pNew.Stage__c != Trigger.oldMap.get(pNew.Id).Stage__c && pNew.Stage__c == 'Cured'){
            curedPatIds.add(pNew.Area__c);
        }
    }
    
    for(Area__c area : [SELECT Id, Average_Days_Required_To_Cured__c, (SELECT Id, CreatedDate FROM Patients__r) FROM Area__c WHERE Id IN :curedPatIds]){
        Integer sum = 0;
        for(Patient__c pt : area.Patients__r){
            DateTime createdDateTime = pt.CreatedDate;
            Date today = Date.today();
            Date createdDate = createdDateTime.date();
            system.debug('Difference '+Math.abs(createdDate.daysBetween(today)));
            sum = sum + (Math.abs(createdDate.daysBetween(today)));
        }    
        area.Average_Days_Required_To_Cured__c = sum/area.Patients__r.size();
        areasToUpdate.add(area);
    }
    
    for(Area__c area : [SELECT Id, Average_Fatal_Days__c, (SELECT Id, CreatedDate FROM Patients__r) FROM Area__c WHERE Id IN :fatalPatIds]){
        Integer sum = 0;
        for(Patient__c pt : area.Patients__r){
            DateTime createdDateTime = pt.CreatedDate;
            Date today = Date.today();
            Date createdDate = createdDateTime.date();
            sum = sum + (Math.abs(createdDate.daysBetween(today)));
        }    
        area.Average_Fatal_Days__c = sum/area.Patients__r.size();
        areasToUpdate.add(area);
    }
    
    if(!areasToUpdate.isEmpty()){
        update areasToUpdate;
    }
}