public with sharing class TrainingSchedulerController {
    
    @AuraEnabled(cacheable=true)
    public static list<Candidate__c> getCandidates(){
        try {
            return [SELECT Id, Name, Email__c, Phone__c FROM Candidate__c WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Course__c> getCourses(){
        try {
            return [SELECT Id, Name FROM Course__c WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Trainer__c> getTrainers(){
        try {
            return [SELECT Id, Name, Email__c, Phone__c, Skillset__c, Availability__c FROM Trainer__c WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static String scheduleTraining(Id candidateId, Id courseId, Id trainerId, Datetime scheduleTime) {
        // Ensure trainer and candidate are available
        Trainer__c trainer = [SELECT Id, Availability__c FROM Trainer__c WHERE Id = :trainerId LIMIT 1];
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
        
        if (trainer.Availability__c == false) {
            return 'Trainer is not available';
        }
        
        // Create a new Training_Schedule__c record
        Training_Schedule__c newSchedule = new Training_Schedule__c();
        newSchedule.Name = 'Training Schedule ' + Date.today().format();
        newSchedule.Trainer__c = trainerId;
        newSchedule.Course__c = courseId;
        newSchedule.Candidate__c = candidateId;
        newSchedule.Scheduled_Time_And_Date__c = scheduleTime;
        newSchedule.Status__c = 'Scheduled';
        try{
            system.debug('Training_Schedule__c :'+newSchedule);
            insert newSchedule;
            system.debug('Training_Schedule__c :'+newSchedule);
        }catch(Exception ex){
            system.debug('Error while inserting Training Scheduler : '+ ex.getMessage());
        }
        Trainer__c trainer1 = [SELECT Id, Name, Phone__c, Email__c FROM Trainer__c WHERE Id = :trainerId LIMIT 1];
        Candidate__c candidate1 = [SELECT Id, Name, Phone__c, Email__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
        
        // Send reminder emails to both trainer and candidate
        //sendEmailReminder(trainerId, candidateId, scheduleTime);
        String candidate_message = 'Dear Candidate, Please be ready at Scheduled Time of ' + scheduleTime.format('dd/MM/yyyy hh:mm');
        String trainer_message = 'Dear Sir, Please be ready at Scheduled Time of ' + scheduleTime.format('dd/MM/yyyy hh:mm');
        //SendMessagesFromSalesforceToWhatsApp.sentTextMessage(candidate_message, (String)candidate1.Phone__c);
        //SendMessagesFromSalesforceToWhatsApp.sentTextMessage(trainer_message, (String)trainer1.Phone__c);    
        system.debug('trainer.Phone__c :'+trainer1.Phone__c);
        sendWhatsAppMessage(candidate_message, (String)candidate1.Phone__c);
        sendWhatsAppMessageTrainer(trainer_message, (String)trainer1.Phone__c);
        return 'Training scheduled successfully!';
    }

    @future(callout=true)
    public static void sendWhatsAppMessage(String candidate_message, String canPhone) {
        SendMessagesFromSalesforceToWhatsApp.sentTextMessage(candidate_message, canPhone);    
    }

    @future(callout=true)
    public static void sendWhatsAppMessageTrainer(String trainer_message, String trainPhone) {
        SendMessagesFromSalesforceToWhatsApp.sentTextMessage(trainer_message, trainPhone);
    }
    
    public static void sendEmailReminder(Id trainerId, Id candidateId, Datetime scheduleTime) {
        Trainer__c trainer = [SELECT Id, Name, Email__c FROM Trainer__c WHERE Id = :trainerId LIMIT 1];
        Candidate__c candidate = [SELECT Id, Name, Email__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
        
        // Trainer email
        Messaging.SingleEmailMessage trainerEmail = new Messaging.SingleEmailMessage();
        trainerEmail.setToAddresses(new String[] { trainer.Email__c });
        trainerEmail.setSubject('Training Reminder');
        trainerEmail.setPlainTextBody('Dear ' + trainer.Name + ',\n\nYou have a training scheduled with ' + candidate.Name + ' on ' + scheduleTime.format('yyyy-MM-dd HH:mm') + '.\n\nBest regards,\nAcademy Team');
        
        // Candidate email
        Messaging.SingleEmailMessage candidateEmail = new Messaging.SingleEmailMessage();
        candidateEmail.setToAddresses(new String[] { candidate.Email__c });
        candidateEmail.setSubject('Training Reminder');
        candidateEmail.setPlainTextBody('Dear ' + candidate.Name + ',\n\nYou have a training scheduled with ' + trainer.Name + ' on ' + scheduleTime.format('yyyy-MM-dd HH:mm') + '.\n\nBest regards,\nAcademy Team');
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { trainerEmail, candidateEmail });
    }
}
