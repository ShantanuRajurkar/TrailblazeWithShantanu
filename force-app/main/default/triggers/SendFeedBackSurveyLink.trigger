trigger SendFeedBackSurveyLink on Training_Schedule__c (After update) {
    Set<Id> candidateIds = new set<Id>();
    for(Training_Schedule__c tsNew : Trigger.new){
        if(Trigger.oldMap.get(tsNew.Id).Status__c != tsNew.Status__c && tsNew.Status__c == 'Completed'){
            candidateIds.add(tsNew.Candidate__c);
        }
    }
    Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
    for(Candidate__c ca : [SELECT Id, Name, Email__c FROM Candidate__c WHERE Id IN :candidateIds]){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        system.debug('Email : '+ca.Email__c);
        String link = 'https://cunning-shark-d3lq59-dev-ed.trailblaze.my.site.com/feedbackform';
        String emailBody = 'Hi there,<br/><br/>' +
                           'Please click the following link to to provoide feedback of your relavant course and trainer <br/>' +
                           '<a href="' + link + '">Click here to open feedback form</a><br/><br/>' +
                           'Thanks,<br/>Your Salesforce Team';
        String[] toAddresses = new String[] { ca.Email__c };
        email.setToAddresses(toAddresses);
        email.setSubject('Feedback Need For Coaching Academy');
        email.setHtmlBody(emailBody);
        emails.add(email);
    }
    system.debug('Emails : '+emails);
    Messaging.sendEmail(emails);
}