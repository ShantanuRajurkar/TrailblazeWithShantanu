public with sharing class SalesforceToWhatsAppCallout {
    @AuraEnabled//(cacheable=true)
    public static list<WhatsApp__c> allMessages(String CustomerPhone){
        try {
            list<WhatsApp__c> whatAppList = [SELECT Id, Name, Customer_Name__c, Customer_Phone__c, Message_Content__c, Message_Type__c, Agent_Name__c, Outgoing__c, CreatedDate FROM WhatsApp__c WHERE Customer_Phone__c =: CustomerPhone ORDER BY CreatedDate ASC];
            return whatAppList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static WhatsApp__c sentTextMessage(String messageContent, String toPhone){
        try {
            WhatsApp__c WA = SendMessagesFromSalesforceToWhatsApp.sentTextMessage(messageContent, toPhone); 
            return [SELECT Id, Name, Customer_Name__c, Customer_Phone__c, Message_Content__c, Message_Type__c, Agent_Name__c, Outgoing__c, CreatedDate FROM WhatsApp__c WHERE Id =: WA.Id ORDER BY CreatedDate ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static WhatsApp__c sendTextMessageForPlatformEvent(String recordId, String customerPhone){
        try {
            return [SELECT Id, Name, Customer_Name__c, Customer_Phone__c, Message_Content__c, Message_Type__c, Agent_Name__c, Outgoing__c, CreatedDate FROM WhatsApp__c WHERE Customer_Phone__c =: customerPhone AND Id =:recordId ORDER BY CreatedDate ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}