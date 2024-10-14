import { LightningElement } from 'lwc';
import getUserInfo from '@salesforce/apex/linkedInCallout.getUserInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LinkedInSalesforce extends LightningElement {
    linkedInTextMessage;postText;

    handleChange(event){
        this.linkedInTextMessage = event.target.value;
    }

    postToLinkedIn(){
        getUserInfo({linkedInTextMessage: this.linkedInTextMessage}).then(response => {
            console.log('Response : ',JSON.stringify(response));
            const event = new ShowToastEvent({
                title: 'Success!',
                message: response,
                variant: 'success'
            });
            this.dispatchEvent(event);
        }).catch(error => {
            console.log('Error While LinkedIn Callout : ',error);
        });
        this.postText = '';
    }
}