import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
import Name from '@salesforce/schema/Opportunity.Name';
import LeadSource from '@salesforce/schema/Opportunity.LeadSource';
import Amount from '@salesforce/schema/Opportunity.Amount';
import CloseDate from '@salesforce/schema/Opportunity.CloseDate';
import StageName from '@salesforce/schema/Opportunity.StageName';
import { createRecord } from 'lightning/uiRecordApi';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
export default class PlatformEventOppSubscriber extends LightningElement {
    channelName = '/event/Opportunity_Event__e';
    recordId = '';
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
        if(response.hasOwnProperty('data')){
            let jsonBody=response.data;
            if(jsonBody.hasOwnProperty('payload')){
                let oppName=response.data.payload.Opportunity_Name__c;
                let oppLeadSource=response.data.payload.Lead_Source__c;
                let oppCloseDate=response.data.payload.Close_Date__c;
                let oppAmount=response.data.payload.Amount__c;
                let oppStageName=response.data.payload.Stage_Name__c;
                let fields={};
            fields[Name.fieldApiName]=oppName;
            fields[LeadSource.fieldApiName]=oppLeadSource;
            fields[CloseDate.fieldApiName]=oppCloseDate;
            fields[Amount.fieldApiName]=oppAmount;
            fields[StageName.fieldApiName]=oppStageName;
            const recordInput={apiName: 'Opportunity',fields};
            console.log('Hi');
            createRecord(recordInput).then(res=>{
                const event = new ShowToastEvent({
                    title : 'Success',
                    message : `Opprtunity Record Successfully Created : ${res.id}`,
                    variant : 'success'
                });
                this.dispatchEvent(event);
                this.refreshUi(res.id);
                this.recordId=res.id;
            }).catch(error=>{
                console.log('Error while creating the record : ', JSON.stringify(error));
            });
            }
        }
    }
    async refreshUi(Id){
        await notifyRecordUpdateAvailable([{recordId: Id}]);
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
}