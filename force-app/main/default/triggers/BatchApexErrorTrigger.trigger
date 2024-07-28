trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {
    set<Id> apexAyncJobIds = new set<Id>();
    for(BatchApexErrorEvent bApexError : Trigger.new){
        apexAyncJobIds.add(bApexError.AsyncApexJobId);
    }
    Map<Id,AsyncApexJob> apexAyncJobMap = new Map<Id,AsyncApexJob>(
        [SELECT Id, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id IN :apexAyncJobIds]
    );
    List<Task> tsList = new List<Task>();
    for(BatchApexErrorEvent evt : Trigger.new){
        AsyncApexJob job = apexAyncJobMap.get(evt.AsyncApexJobId);
        System.debug('Class Name : '+job.ApexClass.Name);
        if(job.ApexClass.Name == 'OpportunityBatchApexClass'){
            for(String item : evt.JobScope.split(',')){
                Task t = new Task();
                t.WhatId = (Id) item;
                t.Subject = 'Error in OpportunityBatchApex : '+evt.ExceptionType;
                t.OwnerId = UserInfo.getUserId();
                t.Description = 'Error Occured In OpportunityBatchApex';
                t.Status = 'Not Started';
                t.ActivityDate = Date.today();
                tsList.add(t);
            }
        }
    }
    try{
        insert tsList;
    }catch(Exception ex){
        System.debug('Exception during inserting the task '+ex.getMessage());
    }
}