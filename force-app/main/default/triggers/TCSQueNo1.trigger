trigger TCSQueNo1 on Account (after insert) {
    list<Contact> conList = new List<Contact>();
    map<Id, Integer> accIdAndConCount = new Map<Id, Integer>();
    for(Account ac : Trigger.new){
        if(accIdAndConCount.containsKey(ac.Id)==false){
            accIdAndConCount.put(ac.Id, (Integer)ac.Total_Number_Of_Contacts__c);
        }
    }
    system.debug(accIdAndConCount);
    for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accIdAndConCount.keySet()]){
        for(Integer i = 1; i <= accIdAndConCount.get(acc.Id); i++){
            Contact con = new Contact();
            con.LastName = i+' Contact Of '+acc.Name;
            con.AccountId = acc.Id;
            conList.add(con);
        }
    }
    if(conList.size() > 0){
        insert conList;
    }
}