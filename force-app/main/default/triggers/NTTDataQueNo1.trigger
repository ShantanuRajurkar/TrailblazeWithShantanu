/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger NTTDataQueNo1 on Opportunity (after insert, after update) {
    set<Id> oppIds = new Set<Id>();
    if(Trigger.isInsert){
        for(Opportunity opp : Trigger.new){
            oppIds.add(opp.Id);
        }
    }
    if(Trigger.isUpdate){
        for(Opportunity oppNew : Trigger.new){
            if(Trigger.oldMap.get(oppNew.Id).Multi_Pick__c != oppNew.Multi_Pick__c){
                oppIds.add(oppNew.Id);
            }
        }
    }
    list<Account> accToUpdate = new list<Account>();
    for(Opportunity opp : [SELECT Id, AccountId, Multi_Pick__c FROM Opportunity WHERE Id IN: oppIds]){
        if(opp.Multi_Pick__c != null){
            list<String> oppMulPick = opp.Multi_Pick__c.split(';');
            Account acc = new Account();
            acc.Id= opp.AccountId;
            acc.Multi_Pick__c = String.join(oppMulPick, ';');
            accToUpdate.add(acc);
        }
    }
    if(!accToUpdate.isEmpty()){
        update accToUpdate;
    }
}
