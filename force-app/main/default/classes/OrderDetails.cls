public with sharing class OrderDetails {
    @AuraEnabled(cacheable=true)
    public static OrderWrapper getOrderDetails(Id orderId) {
        Order order = [
            SELECT Id, OrderNumber, Account.Name, (SELECT Quantity, UnitPrice, Product2.Name FROM OrderItems)
            FROM Order
            WHERE Id = :orderId
        ];

        Integer totalQuantity = 0;
        for(OrderItem item : order.OrderItems) {
            totalQuantity += (Integer)item.Quantity;
        }

        return new OrderWrapper(order.OrderNumber, order.Account.Name, totalQuantity, order.OrderItems);
    }

    public class OrderWrapper {
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String customerName;
        @AuraEnabled public Integer totalQuantity;
        @AuraEnabled public List<OrderItem> orderItems;

        public OrderWrapper(String orderNumber, String customerName, Integer totalQuantity, List<OrderItem> orderItems) {
            this.orderNumber = orderNumber;
            this.customerName = customerName;
            this.totalQuantity = totalQuantity;
            this.orderItems = orderItems;
        }
    }
}