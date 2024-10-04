trigger CreateCandidateRecordAfterClosedWon on Opportunity (after update) {
    list<Candidate__c> canList = new list<Candidate__c>();
    map<String, String> nameToEmail = new map<String, String>();
    map<String, String> nameToPhone = new map<String, String>();

    for(Lead ls : [SELECT Id, Name, Email, Phone FROM Lead WHERE Status = 'Closed - Converted']){
        //if(ls.Email != null && !nameToEmail.values().contains(ls.Email)){
            if(ls.Email != null){
            nameToEmail.put(ls.Name, ls.Email);
            system.debug('Name To Email : '+nameToEmail);
        }
        if(ls.Phone != null && !nameToPhone.values().contains(ls.Phone)){
            nameToPhone.put(ls.Name, ls.Phone);
        }
    }

    for(Opportunity oppNew : Trigger.new){
        if(Trigger.oldMap.get(oppNew.Id).StageName != oppNew.StageName && oppNew.StageName == 'Closed Won'){
            // Create Candidate Record
            Candidate__c candidate = new Candidate__c();
            candidate.Name = oppNew.Name;
            candidate.Email__c = nameToEmail.get(oppNew.Name);
            system.debug('Name To Email : '+nameToEmail.get(oppNew.Name));
            candidate.Phone__c = nameToPhone.get(oppNew.Name);
            canList.add(candidate);
        }
    }

    if(!canList.isEmpty()){
        system.debug('list : '+canList);
        insert canList;
    }
}