import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, api, wire } from 'lwc';
import Status from '@salesforce/schema/Case.Status';
import { getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/schema/Case.Id';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class platformEventSubscriber extends LightningElement {
    channelName='/event/Case_Event__e';
    picklistValues;
    currentStatusValue;
    subscription;
    @api recordId;
    @wire(getObjectInfo,{
        objectApiName : 'Case'
    })objInfo;
    @wire(getPicklistValues,{
        recordTypeId : '$objInfo.data.defaultRecordTypeId',
        fieldApiName : Status,
    })wiredPicklistFieldValue({data,error}){
        if(data)
            this.picklistValues=data.values;
        else
            console.log('Error while fetching picklist', error);
    };
    @wire(getRecord,{
        recordId : '$recordId',
        fields : [Status],
    })wiredCurrentStatusValue({data,error}){
        if(data)
            this.currentStatusValue=getFieldValue(data, Status);
    };
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
                let responseCaseId=response.data.payload.Case_Id__c;
                let responseCaseStatus=response.data.payload.Case_Status__c;
                let fields={};
            fields[Id.fieldApiName]=responseCaseId;
            fields[Status.fieldApiName]=responseCaseStatus;
            let recordInput={fields};
            updateRecord(recordInput).then(res=>{
                const event = new ShowToastEvent({
                    title : 'Success',
                    message : `Record Successfully Updated to Status : ${responseCaseStatus}`,
                    variant : 'success'
                });
                this.dispatchEvent(event);
                this.refreshUi(res.id);
                }).catch(error=>{
                    console.log('Error : ', error);
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