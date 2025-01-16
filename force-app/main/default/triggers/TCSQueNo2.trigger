/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger TCSQueNo2 on Task (after update) {
    set<Id> oppIds = new set<Id>();
    map<Id, list<String>> oppIdsToTask = new map<Id, list<String>>();
    list<Opportunity> oppsList = new list<Opportunity>();
    for(Task tsNew : Trigger.new){
        if(tsNew.Status == 'Completed'){
            if(Trigger.oldMap.get(tsNew.Id).Status != tsNew.Status && tsNew.WhatId.getSObjectType() == Opportunity.SObjectType){
                oppIds.add(tsNew.WhatId);
            }
        }
    }
    for(Task ts : [SELECT Id, Status, WhatId FROM Task WHERE WhatId IN :oppIds]){
        if(oppIdsToTask.containsKey(ts.WhatId)){
            oppIdsToTask.get(ts.WhatId).add(ts.Status);
        }else {
            oppIdsToTask.put(ts.WhatId, new list<String>{ts.Status});
        }
    }
    for(Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE Id IN :oppIds]){
        boolean allCompleted = false;
        if(!oppIdsToTask.get(opp.Id).Contains('Completed')){
            allCompleted = false;
        }else if(!oppIdsToTask.get(opp.Id).Contains('In Progress') && !oppIdsToTask.get(opp.Id).Contains('Waiting on someone else') && !oppIdsToTask.get(opp.Id).Contains('Not Started') && !oppIdsToTask.get(opp.Id).Contains('Deferred')){
            allCompleted = true;
        }
        if (allCompleted == true){
            opp.StageName = 'Closed Won';
            oppsList.add(opp);         
        }
    }
    if(oppsList.size() > 0){
        update oppsList;
    }
}