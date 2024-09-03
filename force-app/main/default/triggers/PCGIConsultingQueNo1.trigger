trigger PCGIConsultingQueNo1 on Contact (after insert) {
    set<Id> conIds = new set<Id>();
    for(Contact con : Trigger.new){
        conIds.add(con.Id);
    }
    WiproQueNo1Helper.insertUser(conIds);
}