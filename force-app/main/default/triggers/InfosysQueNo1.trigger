/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger InfosysQueNo1 on Opportunity (after insert, after update, after delete, after undelete) {
     
    // Step 1: Identify the Account IDs needing recalculation
    Set<Id> accountIds = new Set<Id>();
     
    // Collect relevant Account IDs based on trigger events
    if (Trigger.isInsert || Trigger.isUndelete) {
        for (Opportunity inv : Trigger.new) {
            accountIds.add(inv.AccountId);
        }
    }
    if (Trigger.isUpdate) {
        for (Opportunity inv : Trigger.new) {
            accountIds.add(inv.AccountId);
        }
        for (Opportunity oldInv : Trigger.old) {
            accountIds.add(oldInv.AccountId);
        }
    }
    if (Trigger.isDelete) {
        for (Opportunity inv : Trigger.old) {
            accountIds.add(inv.AccountId);
        }
    }
     
    // Step 2: Aggregate query to calculate the total of TotalAmount on Opportunity Amount
    Map<Id, Decimal> accountOppTotals = new Map<Id, Decimal>();
    for (AggregateResult ar : [
        SELECT AccountId, SUM(Amount) Amount
        FROM Opportunity
        WHERE AccountId IN :accountIds
        GROUP BY AccountId
    ]) {
        accountOppTotals.put((Id)ar.get('AccountId'), (Decimal)ar.get('Amount'));
    }
     
    // Step 3: Prepare Account records for update with recalculated TotalAmount__c
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accountId : accountIds) {
        Account accountToUpdate = new Account(Id = accountId);
        accountToUpdate.TotalAmount__c = accountOppTotals.containsKey(accountId) ? accountOppTotals.get(accountId) : 0;
        accountsToUpdate.add(accountToUpdate);
    }
     
    // Step 4: Update Account records with the calculated TotalAmount__c
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}