public with sharing class AccountDetails {
    @AuraEnabled
    public static string updateAccountRecords(string recordId, string newPhone) {
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
    public static list<Account> getAccountRecordsForRowAndHeraderActionOnLightningDataTables(){
        try {
            return [SELECT Id, Name, Rating, Phone, Industry, AccountNumber, Type FROM Account WITH SECURITY_ENFORCED LIMIT 10];  
       } catch (Exception e) {
            system.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> loadDataById(){
        try {
            return [SELECT Id, Name, Industry, Rating FROM Account ORDER BY Name, Id LIMIT 100 ];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Account> loadMoreData(String lastName, string lastId){
        try {
            return [SELECT Id, Name, Industry, Rating FROM Account  WHERE (Name > :lastName) OR (Name = :lastName AND Id > :lastId) ORDER BY Name, Id LIMIT 100];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer countOfAccounts(){
        try {
            AggregateResult agr = [SELECT count(Id) recordCount FROM Account];
            return (Integer)agr.get('recordCount');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
