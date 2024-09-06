trigger FollowerRequestedTriggerNo1 on Contact (after update) {
    set<Id> conIds = new set<Id>();
    set<id> accIds = new set<Id>();
    map<Id, String> UserToEmail = new map<Id, String>();
    map<Id, String> UserToName = new map<Id, String>();
    map<Id, String> accIdToaccName = new map<Id, String>();
    set<Id> userIds = new set<Id>();
    for(Contact conNew : Trigger.New){
        if((conNew.Phone != Trigger.oldMap.get(conNew.Id).Phone) || (conNew.Email != Trigger.oldMap.get(conNew.Id).Email)){
            conIds.add(conNew.Id);
            accIds.add(conNew.AccountId);
        }
    }
    
    for(Account acc : [SELECT Id, OwnerId, Name FROM Account WHERE Id IN :accIds]){
        accIdToaccName.put(acc.Id, acc.Name);
    }

    System.debug(userIds);
    
    for(Contact con : [SELECT Id, Account.OwnerId FROM Contact WHERE Id IN :conIds]){
        userIds.add(con.Account.OwnerId);
    }
    
    for(User us : [SELECT Id, Name, Email FROM User WHERE Id IN :userIds]){
        UserToEmail.put(us.Id, us.Email);
        UserToName.put(us.Id, us.Name);
    }
    
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    
    for(Contact con : [SELECT Id, Name, AccountId, Account.OwnerId, Phone, Email FROM Contact WHERE Id IN :conIds]){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String htmlBody = '<html>' +
                          '<body>' +
                          '<p>Hi <b>'+UserToName.get(con.Account.OwnerId)+'</b>,</p>' +
                          '<p>Your account\'s child contacts have been changed.</p>' +
                          '<p>These are the details : </p>' +
                          '<p>Contact Name : '+con.Name+'</p>' +
                          '<p>Account Id : '+con.AccountId+'</p>' +
                          '<p>Account Name : '+accIdToaccName.get(con.AccountId)+'</p>' +
                          '<p>Email : '+con.Email+'</p>' +
                          '<p>Phone : '+con.Phone+'</p>' +
                          '<p>Thank you,</p>' +
                          '<p>Your Company</p>' +
                          '</body>' +
                          '</html>';
        email.setToAddresses(new List<String>{UserToEmail.get(con.Account.OwnerId)});
        email.setSubject('Child contacts Email And Phone Field is Changed Recently');
        email.setHtmlBody(htmlBody);
        System.debug('Email: '+email);
        emailList.add(email);
    }
    
    if(emailList.size()>0){
        Messaging.sendEmail(emailList);
    }
}