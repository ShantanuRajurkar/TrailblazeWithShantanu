import { LightningElement, track, wire } from 'lwc';
import allMessages from '@salesforce/apex/SalesforceToWhatsAppCallout.allMessages';
export default class WhatsAppChat extends LightningElement {
    @track messages;
    flag = false;
    @track errorDetails;
    enteredPhoneNo = '';
    @wire(allMessages)wiredMessages({error, data}){
        if(data){
            this.messages = data;
            this.messages.forEach(mes => {
                console.log('Message Content : ',JSON.stringify(mes));
              });
        }
        if(error){
            ths.errorDetails = error;
            console.log('Error while getting list of WhatsApp messages : ', this.errorDetails);
        }
    };

    handlePhoneChange(event){
        this.enteredPhoneNo = event.target.value;
    }

    handleChange(event){
        event.preventDefault();
    }

    handleChat(event){
        event.preventDefault();
        if(this.validity == true){
            this.flag = true;
        }else{
            return;
        }
    }

    validity(){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar &&  inputCmp.checkValidity();
        },true);
        return allValid;
    }
}