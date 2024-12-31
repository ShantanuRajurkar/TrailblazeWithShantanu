import { LightningElement, track } from 'lwc';
import getUserInfo from '@salesforce/apex/linkedInCallout.getUserInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LinkedInSalesforce extends LightningElement {
    linkedInTextMessage;postText;
    @track fileName = '';
    @track fileType = '';
    @track fileContent = '';
    handleChange(event){
        this.linkedInTextMessage = event.target.value;
    }
    handleFileChange(event) {
        const file = event.target.files[0]; // Get the first file
        if (file) {
            this.fileName = file.name;
            this.fileType = file.type;

            const reader = new FileReader();
            reader.onload = () => {
                // Capture the binary content
                this.fileContent = reader.result;
                console.log('Binary Value : ',this.fileContent);
            };
            reader.readAsDataURL(file); // Read file as Data URL
        }
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