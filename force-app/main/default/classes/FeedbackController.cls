public with sharing class FeedbackController {
    
    @AuraEnabled
    public static String submitFeedback(String candidateName, String trainerName, String courseName, String feedbackRating, String feedbackComments) {
        try {
            system.debug('candidateName : '+candidateName+' trainerName : '+trainerName+' courseName : '+courseName);
            Id candidateId = [SELECT Id FROM Candidate__c WHERE Id =: candidateName LIMIT 1].Id;
            Id trainerId = [SELECT Id FROM Trainer__c WHERE Id =: trainerName LIMIT 1].Id;
            Id courseId = [SELECT Id FROM Course__c WHERE Id =: courseName LIMIT 1].Id;
            system.debug('candidateId : '+candidateId+' trainerId : '+trainerId+' courseId : '+courseId);
            Training_Schedule__c schedule = [SELECT Id, Candidate__c, Trainer__c, Course__c FROM Training_Schedule__c WHERE (Candidate__c =: candidateId AND Trainer__c =: trainerId AND Course__c =: courseId) LIMIT 1];
            system.debug('Training_Schedule__c : '+schedule);
            Training_Feedback__c feedback = new Training_Feedback__c();
            feedback.Training_Schedule__c = (Id)schedule.Id;
            feedback.Candidate__c = (Id)schedule.Candidate__c;
            feedback.Trainer__c = (Id)schedule.Trainer__c;
            feedback.Course__c = (Id)schedule.Course__c;
            feedback.Feedback_Rating__c = feedbackRating;
            feedback.Feedback_Comments__c = feedbackComments;
            feedback.Completion_Date__c = System.today();
            
            insert feedback;
            
            return 'Feedback submitted successfully!';
        } catch (Exception e) {
            throw new AuraHandledException('Error submitting feedback: ' + e.getMessage());
        }
    }
}
