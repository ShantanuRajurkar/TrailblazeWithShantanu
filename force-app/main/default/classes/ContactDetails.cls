public with sharing class ContactDetails {
    @AuraEnabled(cacheable=true)
    public static list<Contact> getConListForLigthningDataTable(){
        try {
            return [SELECT Id, Title, Name, Phone, Email, Picture__c, Rank__c, Account.Name FROM Contact WHERE AccountId!=null AND Picture__c!=null WITH SECURITY_ENFORCED LIMIT 10];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}