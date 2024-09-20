import { LightningElement, track, wire } from 'lwc';
import allMessages from '@salesforce/apex/SalesforceToWhatsAppCallout.allMessages';
import sentTextMessage from '@salesforce/apex/SalesforceToWhatsAppCallout.sentTextMessage';
import sendMediaMessage from '@salesforce/apex/SendMessagesFromSalesforceToWhatsApp.sendMediaMessage';
import { subscribe, onError, unsubscribe } from 'lightning/empApi';
import sendTextMessageForPlatformEvent from '@salesforce/apex/SalesforceToWhatsAppCallout.sendTextMessageForPlatformEvent';
import { getListUi } from 'lightning/uiListApi';
import DOCUMENT_URLS_OBJECT from '@salesforce/schema/Documents_Download_Urls__c';
import URL_FIELD from '@salesforce/schema/Documents_Download_Urls__c.Url__c'
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [URL_FIELD];
export default class WhatsAppChat extends LightningElement {
    @track messages;
    @track delayInMilliseconds = 5000;
    userMessage = '';
    channelName='/event/WhatsAppEvent__e';
    isSpinner = false;
    flag = false;
    @track errorDetails;
    enteredPhoneNo = '';
    enteredMessage = '';
    subscription;
    filesend = false;
    @track documentOptions = [];
    @track selectedValue = '';
    @track documentUrl;
    filename;
    captionline;

    captionLine(event){
        this.captionline = event.target.value;
    }

    fileName(event){
        this.filename = event.target.value;
    }

    @wire(getRecord, { recordId: '$selectedValue', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('Url : ', data);
            this.documentUrl = data.fields.Url__c.value; // Get the URL field value
             // Get the Name field value
        } else if (error) {
            console.error('Error fetching the document record:', error);
        }
    }
    
    @wire(getListUi, {
        objectApiName: DOCUMENT_URLS_OBJECT, // The API name of the custom object
        listViewApiName: 'All' // List view API name (use standard or custom)
    })
    wiredDocuments({ error, data }) {
        if (data) {
            // Map the records to the label-value pairs for the combobox
            const records = data.records.records;
            console.log('records : ', data.records.records);
            
            this.documentOptions = records.map(record => ({
                label: record.fields.Name.value,  // Document Name as label
                value: record.id // Document URL as value
            }));
        } else if (error) {
            console.error('Error fetching document URLs:', error);
        }
    }

    handleCombo(event) {
        this.selectedValue = event.detail.value;
        console.log('Selected URL:', this.selectedValue);
    }

    connectedCallback() {
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            this.handleEventResponse(response);
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            //this.toggleSubscribeButton(true);
        });
    }

    handleEventResponse(response){
        console.log('Response : ',JSON.parse(JSON.stringify(response)));
        let data = response.data.payload;
        let messegeId = data.Message_ID__c;
        let customerPhone = data.Customer_Phone__c;
        if(customerPhone === this.enteredPhoneNo){
            sendTextMessageForPlatformEvent({recordId : messegeId, customerPhone : customerPhone}).then(res => {
                this.messages.push(res);
            }).catch(error => {
                console.log('Error while sending message to platform event : ', error);
            }).finally(()=>{
                let scrollDown = this.template.querySelector('.scrollDown');
                if(scrollDown){
                    scrollDown.scrollTop = scrollDown.scrollHeight;
                }
            })
        }
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    disconnectedCallback(){
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    handlePhoneChange(event){
        this.enteredPhoneNo = event.target.value;
    }

    handleChange(event){
        event.preventDefault();
        this.enteredMessage = event.target.value;
    }

    sendMessage(){
        let valid = this.validity();
        if(valid){
            this.isSpinner = true;
            sentTextMessage({messageContent : this.enteredMessage, toPhone : this.enteredPhoneNo}).then(res=>{
                this.messages.push(res);
            }).catch(err=>{
                console.log('Error : ', err);
            }).finally(()=>{
                let scrollDown = this.template.querySelector('.scrollDown');
                if(scrollDown){
                    scrollDown.scrollTop = scrollDown.scrollHeight;
                }
                this.isSpinner = false;
                this.enteredMessage = '';
            });
        }
    }

    showSend(){
        this.filesend = true;
    }

    sendDocument(){
        this.filesend = false;
        let valid = this.validity();
        if(valid){
            this.isSpinner = true;
            sendMediaMessage({toPhone : this.enteredPhoneNo, url : this.documentUrl, filename : this.filename, caption : this.captionline}).then(res=>{
                this.messages.push(res);
            }).catch(err=>{
                console.log('Error : ', err);
            }).finally(()=>{
                let scrollDown = this.template.querySelector('.scrollDown');
                if(scrollDown){
                    scrollDown.scrollTop = scrollDown.scrollHeight;
                }
                this.isSpinner = false;
                this.enteredMessage = '';
            });
        }
    }

    handleChat(event){
        event.preventDefault();
        if(this.validity()){
            this.isSpinner = true;
            allMessages({CustomerPhone : this.enteredPhoneNo}).then(res=>{
                console.log('Flag Before : ', this.flag);
                this.messages = res;
                this.flag = true;
                console.log('Flag After : ', this.flag);
            }).catch(err=>{
                console.log('Error : ', err);
            }).finally(()=>{
                let scrollDown = this.template.querySelector('.scrollDown');
                if(scrollDown){
                    scrollDown.scrollTop = scrollDown.scrollHeight;
                }
                this.isSpinner = false;
                this.sendChatMessage();
            });
        }else{
            return;
        }
    }

    sendChatMessage(){
        let enterKey = this.template.querySelector('.enter-key');
        if(enterKey){
            enterKey.addEventListener('keydown', (event) => {
                if(event.key === 'Enter'){
                    this.sendMessage();
                }
            })
        }
    }

    handleBack(){
        this.enteredMessage = '';
        this.flag = false;
        this.messages = undefined;
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