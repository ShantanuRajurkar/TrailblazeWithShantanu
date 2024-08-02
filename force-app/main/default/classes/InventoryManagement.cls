public class InventoryManagement {
    
    public static void reduceInventory(Id productId, Integer quantity) {
        Product2 product = [SELECT Id, QuantityOnHand__c FROM Product2 WHERE Id = :productId LIMIT 1];
        if (product.QuantityOnHand__c >= quantity) {
            product.QuantityOnHand__c -= quantity;
            update product;
        } else {
            throw new CustomException('Insufficient inventory');
        }
    }
    
    public static void replenishInventory(Id productId, Integer quantity) {
        Product2 product = [SELECT Id, QuantityOnHand__c FROM Product2 WHERE Id = :productId LIMIT 1];
        product.QuantityOnHand__c += quantity;
        update product;
    }
    
    public class CustomException extends Exception {}
}
