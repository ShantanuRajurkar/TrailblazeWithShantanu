import { LightningElement, track, wire } from 'lwc';
import allMessages from '@salesforce/apex/SalesforceToWhatsAppCallout.allMessages';
import sentTextMessage from '@salesforce/apex/SalesforceToWhatsAppCallout.sentTextMessage';
import { subscribe, onError, unsubscribe } from 'lightning/empApi';
import sendTextMessageForPlatformEvent from '@salesforce/apex/SalesforceToWhatsAppCallout.sendTextMessageForPlatformEvent';
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

    /*@wire(allMessages, {CustomerPhone :'$enteredPhoneNo'})wiredMessages({error, data}){
        if(data){
            this.messages = data;
            this.messages.forEach(mes => {
                console.log('Message Content : ',JSON.stringify(mes));
              });
        }
        if(error){
            this.errorDetails = error;
            console.log('Error while getting list of WhatsApp messages : ', this.errorDetails);
        }
    };*/

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