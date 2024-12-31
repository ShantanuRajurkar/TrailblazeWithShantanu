/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger NTTDataQueNo1 on Opportunity (after insert, after update) {
    set<Id> AccIds = new set<Id>();
    set<Id> oppIds = new set<Id>();
    list<Account> accToUpdate = new list<Account>();
    map<Id, String> oppIdToMultiPick = new map<Id, String>(); 
    map<Id, Id> accIdToOppId = new map<Id, Id>();
    if(Trigger.isInsert){
        for(Opportunity oppNew : Trigger.new){
            AccIds.add(oppNew.AccountId);
            oppIds.add(oppNew.Id);
        }
    }
    if(Trigger.isUpdate){
        for(Opportunity oppNew : Trigger.new){
            if(Trigger.oldMap.get(oppNew.Id).Multi_Pick__c != oppNew.Multi_Pick__c){
                AccIds.add(oppNew.AccountId);
                oppIds.add(oppNew.Id);
            }
        }
    }
    
    for(Opportunity opp : [SELECT Id, AccountId,  Multi_Pick__c FROM Opportunity WHERE Id IN: oppIds]){
        if(opp.Multi_Pick__c != null){
        	oppIdToMultiPick.put(opp.Id, opp.Multi_Pick__c);
        }
        accIdToOppId.put(opp.AccountId, opp.Id);
    }
    system.debug('Opp Id to Multi   '+oppIdToMultiPick);
    system.debug('Acc Id to Opp Id   '+accIdToOppId);
    for(Account acc : [SELECT Id, Multi_Pick__c FROM Account WHERE Id IN: AccIds]){
        list<String> oppMulPick = oppIdToMultiPick.get(accIdToOppId.get(acc.Id)).split(';');
        acc.Multi_Pick__c = String.join(oppMulPick, ';');
        accToUpdate.add(acc);
    }
    if(!accToUpdate.isEmpty()){
        update accToUpdate;
    }
}