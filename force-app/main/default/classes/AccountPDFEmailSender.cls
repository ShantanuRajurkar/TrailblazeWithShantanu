/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AccountPDFEmailSender {
  @future(callout = true)
  public static void sendAccountDetailsAsPDF(Map<Id, Account> accountsMap) {

    if (accountsMap.isEmpty()) {
      return;
    }

      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
      system.debug('accountIds : '+accountIds);
      system.debug('accountOnwerEmail : '+accountsMap);
      for (Id accountId : accountsMap.keySet()) {
          Account accRec = accountsMap.get(accountId);
          String ownerEmail = accRec.Owner?.Email;
          if (String.isNotBlank(ownerEmail)) {
              // Step 1: Generate PDF content from Visualforce page
              PageReference pdfPage = Page.AccountPDFPage;
              pdfPage.getParameters().put('id', accountId);
              Blob pdfBlob = pdfPage.getContentAsPDF();

              // Step 2: Create email message
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              email.setToAddresses(new List<String>{ownerEmail});
              email.setSubject('New Account Created - Account Details');
              email.setPlainTextBody('A new account has been created. Please find attached the account details in PDF format.');
              
              // Step 3: Attach the PDF file
              Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
              attachment.setFileName('AccountDetails_' + accountId + '.pdf');
              attachment.setBody(pdfBlob);
              attachment.setContentType('application/pdf');
              email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});

              // Add email to the list
              emails.add(email);
          }
      }
      system.debug('emails: ' + emails);
      // Step 4: Send all emails
      if (!emails.isEmpty()) {
          Messaging.sendEmail(emails);
      }
  }
}
