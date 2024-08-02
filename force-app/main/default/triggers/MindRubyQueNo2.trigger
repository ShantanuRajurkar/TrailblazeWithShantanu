trigger MindRubyQueNo2 on Account (after update) {
    Set<Id> accIds = new Set<Id>();
    for(Account acc : Trigger.new){
        if(acc.Status__c=='InActive'){
            accIds.add(acc.Id);
        }
    }
    List<Opportunity> oppList = new list <Opportunity>();
    for(Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE AccountId IN :accIds]){
        opp.StageName = 'Closed Lost';
        oppList.add(opp);
        system.debug('hi'+opp.StageName);
    }
    try{
        update oppList;
    }catch(Exception ex){
        system.debug('Error : '+ ex.getMessage());
    }
}