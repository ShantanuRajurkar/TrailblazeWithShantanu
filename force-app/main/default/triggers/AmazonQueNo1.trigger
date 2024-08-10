trigger AmazonQueNo1 on Case (after update) {
    set<Id> reqCasesIds = new set<Id>();
    set<Id> reqAccIds = new set<Id>();
    for(Case cas : Trigger.new){
        if(Trigger.oldMap.get(cas.Id).Status=='Working' && cas.Status == 'Closed' && cas.AccountId != null){
            reqCasesIds.add(cas.Id);
            reqAccIds.add(cas.AccountId);
            system.debug(cas.AccountId+' '+reqAccIds);
        }
    }
    list<Account> accToUpdate = new list<Account>();
    for(Account acc : [SELECT Id, Case_Count__c,(SELECT Id, Subject FROM Cases) FROM Account WHERE Id IN :reqAccIds]){
        acc.Case_Count__c = acc.Cases.size();
        accToUpdate.add(acc);
    }
    if(accToUpdate.size() > 0){
        update accToUpdate;
    }
    
    map<Id, set<String>> accIdLastName = new Map<Id, set<String>>();
    for(Contact con : [SELECT Id, AccountId, LastName FROM Contact WHERE AccountId IN :reqAccIds]){
        set<String> temp = new set<String>();
        if(accIdLastName.containskey(con.AccountId) ==false){
            temp.add(con.LastName);
            accIdLastName.put(con.AccountId, temp);
        }else{
            temp = accIdLastName.get(con.AccountId);
            temp.add(con.LastName);    
        }
        accIdLastName.put(con.AccountId, temp);
    }
    List<Contact> conList = new list<Contact>();
    for(Case cs : [SELECT Id, AccountId, Subject FROM Case WHERE Id IN :reqCasesIds]){
        set<String> temp = accIdLastName.get(cs.AccountId);
        if(!temp.contains(cs.Subject)){
            Contact con = new Contact();
            con.LastName = cs.Subject;
            con.AccountId = cs.AccountId;
            conList.add(con);
            system.debug('Contact List '+conList);
    }
        if(conList.size() > 0){
            insert conList;
        }
    }
}