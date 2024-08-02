trigger MindRubyQueNo1 on Contact (after insert, after update) {
    set<Id> primaryconIds = new set<Id>();
    set<Id> accIds = new set<Id>();
    for(Contact con : Trigger.new){
        if(con.IsPrimaryContact__c == true){
            primaryconIds.add(con.Id);
            accIds.add(con.AccountId);
        }
    }
    list<Contact> conToUpdate = new list<Contact>();
    for(Contact con : [SELECT Id, IsPrimaryContact__c FROM Contact WHERE AccountId IN :accIds]){
        if(!primaryconIds.contains(con.Id)){
            con.IsPrimaryContact__c = false;
            conToUpdate.add(con);
        }
    }
    try{
        update conToUpdate;
    }catch(Exception ex){
        system.debug('ERROR : '+ex.getMessage());
    }
}