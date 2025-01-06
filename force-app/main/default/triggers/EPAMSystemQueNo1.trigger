/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger EPAMSystemQueNo1 on Account (after insert) {
    List<Id> accountIds = new List<Id>();
    Map<Id, String> accountOwnerEmails = new Map<Id, String>();
    set<Id> accIds = new Set<Id>();
    for (Account acc : Trigger.new) {
        accIds.add(acc.Id);
    }
    // Collect Account IDs and their owner's email addresses
    for (Account acc : [SELECT Id, Owner.Email FROM Account WHERE Id IN :accIds]) {
        if (acc.OwnerId != null) {
            accountIds.add(acc.Id);
            accountOwnerEmails.put(acc.Id, acc.Owner.Email);
        }
    }

    // Call helper class to send emails
    if (!accountIds.isEmpty() && !accountOwnerEmails.isEmpty()) {
        AccountPDFEmailSender.sendAccountDetailsAsPDF(accountIds, accountOwnerEmails);
    }
}
