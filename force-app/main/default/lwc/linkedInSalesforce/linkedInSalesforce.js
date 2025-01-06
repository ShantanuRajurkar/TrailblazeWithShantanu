import { LightningElement, track, wire } from 'lwc';
import getUserInfo from '@salesforce/apex/linkedInCallout.getUserInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DOCUMENT_URLS_OBJECT from '@salesforce/schema/Documents_Download_Urls__c';
import URL_FIELD from '@salesforce/schema/Documents_Download_Urls__c.Url__c';
import CONTENT_DOCUMENT_VERSION_ID from '@salesforce/schema/Documents_Download_Urls__c.Content_Version_Id__c'
import { getRecord } from 'lightning/uiRecordApi';
import { getListUi } from 'lightning/uiListApi';
const FIELDS = [URL_FIELD, CONTENT_DOCUMENT_VERSION_ID];
export default class LinkedInSalesforce extends LightningElement {
    linkedInTextMessage;postText;
    isShowDocOptions = false;
    @track selectedValue = '';
    @track documentOptions = [];
    @track documentContentVersionId;

    handleChange(event){
        this.linkedInTextMessage = event.target.value;
    }
    @wire(getRecord, { recordId: '$selectedValue', fields: FIELDS })
        wiredRecord({ error, data }) {
            if (data) {
                console.log('Url 1 : ', data);
                this.documentContentVersionId = data.fields.Content_Version_Id__c.value; // Get the URL field value
                console.log('Url 2 : ', this.documentContentVersionId);
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
                    value: record.id // Record ID as value
                }));
            } else if (error) {
                console.error('Error fetching document URLs:', error);
            }
        }
    handleCombo(event) {
        this.selectedValue = event.detail.value;
        console.log('Selected URL:', this.selectedValue);
    }
    handleClick(){
        this.isShowDocOptions = true;
    }

    postToLinkedIn(){
        getUserInfo({linkedInTextMessage: this.linkedInTextMessage, contentversionId: this.documentContentVersionId}).then(response => {
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