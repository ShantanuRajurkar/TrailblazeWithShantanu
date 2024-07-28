global class OpportunityBatchApexClass implements Database.Batchable<Opportunity>, Database.RaisesPlatformEvents {
    global System.Iterable<Opportunity> start(database.BatchableContext bcontext){
        return new CustomOpportunityIterable();
    }
    
    global void execute(database.batchableContext bcontext, list<Opportunity> oppList){
        for(Opportunity opp : oppList){
                opp.Name = null;
            }
        update oppList;   
    }
    
    
    global void finish(database.batchableContext bcontext){
        system.debug('Batch Ended');
    }
}
