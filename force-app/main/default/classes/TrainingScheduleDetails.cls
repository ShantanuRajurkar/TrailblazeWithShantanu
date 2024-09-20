public with sharing class TrainingScheduleDetails {
    @AuraEnabled(cacheable=true)
    public static list<Training_Schedule__c> getTrainingScheduleDetailsList(){
        try {
            return [SELECT Id, Name, Candidate__c, Course__c, Scheduled_Time_And_Date__c, Status__c, Trainer__c FROM Training_Schedule__c ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}