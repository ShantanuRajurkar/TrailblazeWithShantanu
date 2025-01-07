/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger EPAMSystemQueNo1 on Account (after insert) {
    Set<Id> accIds = trigger.newMap.keySet();
    Map<Id, Account> accountsMap = new Map<Id,Account> ([SELECT Id, Owner.Email FROM Account WHERE Id IN :accIds]);

    // Call helper class to send emails
    AccountPDFEmailSender.sendAccountDetailsAsPDF(accountsMap);
    
}
