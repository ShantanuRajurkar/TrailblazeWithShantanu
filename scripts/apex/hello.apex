// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

OpportunityBatchApexClass obj = new OpportunityBatchApexClass();
Database.executeBatch(obj, 200);

SalesforceToWhatsAppCallout.SalesforceWACallout();

SendMessagesFromSalesforceToWhatsApp.sentTextMessage('I am doing good bro', '919420181774');

list<WhatsApp__c> obj = [select Id from WhatsApp__c];
delete obj;