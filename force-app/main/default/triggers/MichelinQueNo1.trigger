trigger MichelinQueNo1 on Custom_Task__c (after insert, after update) {
    set<Id> proIds = new set<Id>();
    map<Id, list<String>> projectIdsToTaskStatus = new map<Id, list<String>>();
    list<Project__c> proToUpdate = new list<Project__c>();

    if(Trigger.isAfter && Trigger.isInsert){
        for(Custom_Task__c ctNew : Trigger.new){
        	proIds.add(ctNew.Project__c);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        for(Custom_Task__c ctNew : Trigger.new){
            if(ctNew.Status__c != Trigger.oldMap.get(ctNew.Id).Status__c){
            	proIds.add(ctNew.Project__c);
            }
        }
    }

    for(Project__c proNew : [SELECT Id, Status__c, (SELECT Id, Status__c, Project__c FROM Custom_Tasks__r) FROM Project__c WHERE Id IN :proIds]){
        list<String> TaskStatus = new list<String>();
        for(Custom_Task__c ct : proNew.Custom_Tasks__r){
            TaskStatus.add(ct.Status__c);
        }
        projectIdsToTaskStatus.put(proNew.Id, TaskStatus);
    }

    for(Project__c proNew : [SELECT Id, Status__c FROM Project__c WHERE Id IN :proIds]){
        if(!projectIdsToTaskStatus.get(proNew.Id).contains('In Progress') && !projectIdsToTaskStatus.get(proNew.Id).contains('Not Started')){
            proNew.Status__c = 'Completed';
        }else if(!projectIdsToTaskStatus.get(proNew.Id).contains('In Progress') && !projectIdsToTaskStatus.get(proNew.Id).contains('Completed')){
            proNew.Status__c = 'Not Started';
        }else if(projectIdsToTaskStatus.get(proNew.Id).contains('In Progress')){
            proNew.Status__c = 'In Progress';
        }
        proToUpdate.add(proNew);
    }
    
    if(!proToUpdate.isEmpty()){
        update proToUpdate;
    }
}