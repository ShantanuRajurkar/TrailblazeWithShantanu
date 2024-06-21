public with sharing class AccountDetails {
    @AuraEnabled
    public static string updateAccountRecord(string recordId, string newPhone) {
        Account acc = new Account(Id=recordId, Phone=newPhone);
        try{
            update acc;
            return 'Success';
        }catch(Exception Ex){
            return ex.getMessage();
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> getAccountRecordsForSalesforceAccountManager(){
        try {
            return [SELECT Id, Name, Rating, Phone, Industry, Description, SLAExpirationDate__c, ParentId, NumberofLocations__c, SLA__c, AccountNumber, Type FROM Account WITH SECURITY_ENFORCED];  
       } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> getAccountRecordsForRowAndHeraderActionOnLightningDataTable(){
        try {
            return [SELECT Id, Name, Rating, Phone, Industry, AccountNumber, Type FROM Account WITH SECURITY_ENFORCED];  
       } catch (Exception e) {
            system.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}