import { LightningElement, api, wire } from 'lwc';
import getOrderDetails from '@salesforce/apex/OrderDetails.getOrderDetails';
const columns = [
    //{ label: 'Product Name', fieldName: 'Product2.Name', type: 'text' },
    { label: 'Product Name', fieldName: 'productName', type: 'text' },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' }
];
export default class LumioPartnersQuoNo2 extends LightningElement {
    @api recordId;
    orderDetails;
    isLoading = true;
    columns = columns;
    

    @wire(getOrderDetails, { orderId: '$recordId' })
    wiredOrderDetails({ error, data }) {
        if (data) {
            /*this.orderDetails = data;
            console.log('Order Details Data : ', this.orderDetails.orderItems);
            this.isLoading = false;*/
            this.orderDetails = {
                ...data,
                orderItems: data.orderItems.map(item => ({
                    ...item,
                    productName: item.Product2.Name // Flattening the Product2.Name field
                }))
            };
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.error('Error:', error);
        }
    }
}
