public with sharing class LeadDetails {
    @AuraEnabled(cacheable=true)
    public static list<lead> getLeadListForCoachingAcademy(){
        try {
            return [SELECT Id, Name, Company, Status, Reference_By__c, Reference_Employee_ID__c FROM Lead WHERE (Reference_Employee_ID__c != null)];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}