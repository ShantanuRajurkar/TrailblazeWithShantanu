public with sharing class SalesforceToWhatsAppCallout {
    @AuraEnabled(cacheable=true)
    public static list<WhatsApp__c> allMessages(){
        try {
            list<WhatsApp__c> whatAppList = [SELECT Id, Name, Customer_Name__c, Message_Content__c, Message_Type__c, Agent_Name__c, Outgoing__c, CreatedDate FROM WhatsApp__c ORDER BY CreatedDate ASC];
            return whatAppList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}