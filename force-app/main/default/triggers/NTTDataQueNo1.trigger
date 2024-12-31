/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger NTTDataQueNo1 on Opportunity (after insert, after update) {
    list<Account> accToUpdate = new list<Account>();
    for(Opportunity opp : Trigger.new){
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
