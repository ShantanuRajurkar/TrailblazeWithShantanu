/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class InventoryManagementTest {
    
    @isTest
    static void testReduceInventory() {
        Product2 product = new Product2(Name = 'Test Product', QuantityOnHand__c = 100);
        insert product;
        
        Test.startTest();
        InventoryManagement.reduceInventory(product.Id, 20);
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT QuantityOnHand__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(80, updatedProduct.QuantityOnHand__c, 'Inventory should be reduced by 20');
    }
    
    @isTest
    static void testReplenishInventory() {
        Product2 product = new Product2(Name = 'Test Product', QuantityOnHand__c = 50);
        insert product;
        
        Test.startTest();
        InventoryManagement.replenishInventory(product.Id, 30);
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT QuantityOnHand__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(80, updatedProduct.QuantityOnHand__c, 'Inventory should be replenished by 30');
    }
    
    @isTest
    static void testReduceInventoryInsufficientStock() {
        Product2 product = new Product2(Name = 'Test Product', QuantityOnHand__c = 10);
        insert product;
        
        Test.startTest();
        try {
            InventoryManagement.reduceInventory(product.Id, 20);
            System.assert(false, 'Exception should be thrown for insufficient stock');
        } catch (InventoryManagement.CustomException e) {
            System.assert(true, 'Exception caught for insufficient stock');
        }
        Test.stopTest();
    }
}
