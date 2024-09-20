public with sharing class CourseDetails {
    @AuraEnabled(cacheable=true)
    public static List<Course__c> getCoursesWithTopics() {
        return [SELECT Id, Name, (SELECT Id, Name FROM Topics__r) FROM Course__c];
    }
}