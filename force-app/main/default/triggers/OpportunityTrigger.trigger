trigger OpportunityTrigger on Opportunity (after insert, after update, after delete) {
    /* When opportunity get Deleted, Inserted or Updated, the field on the account (Total_Opportunities__c) which has total number of related opportunities having StageName = 'Closed Won', will get updated accordingly */
    if(Trigger.isAfter){
        set<Id> accIds = new set<Id>();
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Opportunity op : Trigger.new){
                if(op.StageName == 'Closed Won'){
                    accIds.add(op.AccountId);
                }else{
                    if(Trigger.isUpdate){
                        for(Opportunity opp : Trigger.old){
                            if(opp.StageName == 'Closed Won' && op.StageName != 'Closed Won'){
                                accIds.add(op.AccountId);
                            }
                        }
                    }
                }
            }
            list<Account> accToUpdate = new list<Account>();
            for(Account acc : [
                SELECT Id, Total_Opportunities__c, (SELECT Id, Name, StageName FROM Opportunities WHERE StageName = 'Closed Won') 
                FROM Account WHERE Id IN :accIds WITH SECURITY_ENFORCED]
                ){
                system.debug('Total oportunity : '+acc.Total_Opportunities__c+' Opp Name :'+acc.Opportunities);
                acc.Total_Opportunities__c = acc.Opportunities.size();
                accToUpdate.add(acc);
            }
            if(!accToUpdate.isEmpty()){
                update accToUpdate;
            }
        }
        if(Trigger.isDelete){
            for(Opportunity opp : Trigger.old){
                if(opp.StageName == 'Closed Won'){
                	accIds.add(opp.AccountId);
                }
            }
            list<Account> accToUpdate = new list<Account>();
            for(Account acc : [
                SELECT Id, Total_Opportunities__c, (SELECT Id, Name, StageName FROM Opportunities WHERE StageName = 'Closed Won')
                FROM Account WHERE Id IN :accIds WITH SECURITY_ENFORCED]
                ){
                acc.Total_Opportunities__c = acc.Opportunities.size();
                system.debug('Total oportunity : '+acc.Total_Opportunities__c+' Opp Name :'+acc.Opportunities);
                accToUpdate.add(acc);
            }
            if(!accToUpdate.isEmpty()){
                update accToUpdate;
            }
        }
    }
}