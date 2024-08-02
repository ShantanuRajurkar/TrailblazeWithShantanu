import { LightningElement, api, wire } from 'lwc';
import getOrderDetails from '@salesforce/apex/OrderSummaryController.getOrderDetails';
const columns = [
    { label: 'Product Name', fieldName: 'Product2.Name', type: 'text' },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' }
];
export default class OrderSummary extends LightningElement {
    @api recordId;
    orderDetails;
    isLoading = true;
    columns = columns;
    

    @wire(getOrderDetails, { orderId: '$recordId' })
    wiredOrderDetails({ error, data }) {
        if (data) {
            this.orderDetails = data;
            console.log('Order Details Data : ', this.orderDetails);
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.error('Error:', error);
        }
    }
}
