trigger LumioPartnersQueNo1 on OrderItem (after insert) {
    set<Id> orderIds = new set<Id>();
    for(OrderItem ot : Trigger.new){
        if(ot.OrderId!=null){
            orderIds.add(ot.OrderId);
        }
    }
    list<Order> ordersToUpdate = new list<Order>();
    for(Order ord : [SELECT Id, Total_Quantity__c, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :orderIds]){
        ord.Total_Quantity__c = ord.OrderItems.size();
        ordersToUpdate.add(ord);
    }
    if(!ordersToUpdate.isEmpty()){
        update ordersToUpdate;
    }
}