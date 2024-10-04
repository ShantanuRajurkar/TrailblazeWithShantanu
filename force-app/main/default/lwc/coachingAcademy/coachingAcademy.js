import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status from '@salesforce/schema/Lead.Status';
import Id from '@salesforce/schema/Lead.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getLeadListForCoachingAcademy from '@salesforce/apex/LeadDetails.getLeadListForCoachingAcademy';
import convertLeadsToOpportunities from '@salesforce/apex/LeadConversionController.convertLeadsToOpportunities';
import { refreshApex } from '@salesforce/apex';

const columns = [
    {label: 'Name', fieldName: 'Name', editable: true, hideDefaultActions: true},
    {label: 'Company', fieldName: 'Company'},
    {label: 'Reference Employee ID', fieldName: 'Reference_Employee_ID__c'},
    {label: 'Reference By', fieldName: 'Reference_By__c'},
    {label: 'Lead Status', fieldName: 'Status', type: 'customPicklist',  editable: true, typeAttributes: {
        options: {
            fieldName: 'pickListOptions'
        },
        value: {
            fieldName: 'Status'
        },
        context: {
            fieldName: 'Id'
        } 
    }, hideDefaultActions: true},
];

export default class CoachingAcademy extends LightningElement {
    @track leadInfo = {};
    draftValues;
    @track leadData;
    columns = columns;
    @track leadStatus = [];
    wiredLeads;

    @wire(getObjectInfo,{
         objectApiName: 'Lead'
    })wiredLeadInfo({data,error}){
        if(data){
            this.leadInfo = data;
        }else if(error){
            console.log('objInfo Error ', error);
        }
    };

    @wire(getPicklistValues,{
        recordTypeId: '$leadInfo.defaultRecordTypeId',
        fieldApiName: Status,
    })wirePicklist({data,error}){
        if(data){
            this.leadStatus = data.values;
        }else if(error){
            console.log('Error while loading data : ', error);
        }
    }

    @wire(getLeadListForCoachingAcademy,{pickList : '$leadStatus'})wiredLeadData({data,error}){
        if(data){
            this.wiredLeads = data;
            this.leadData = data.map(currItem=>{
                let pickListOptions = this.leadStatus;
                return{
                    ...currItem,
                    pickListOptions : pickListOptions
                }
            });
        }else if(error){
            console.log('Error while loading data : ', error);
        }
    };
    
    handleSave(event) {
        console.log('In Handle Save');
        const updatedFields = event.detail.draftValues.map(draftValue => {
            return {
                fields: {
                    [Id.fieldApiName]: draftValue.Id,
                    [Status.fieldApiName]: draftValue.Status
                }
            };
        });
        console.log('Update Fields : ', updatedFields);
        updatedFields.forEach(recordInput => {
            console.log('Record Input :', recordInput);
            updateRecord(recordInput).then((res) => {
                refreshApex(this.wiredLeads);
                if(res.fields.Status.value == 'Closed - Converted'){
                    convertLeadsToOpportunities({leadId : res.id}).then(()=>{
                    }).catch(error=>{
                        console.log('Error while coversion : ', error.body.message);
                    });
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead Status updated successfully!',
                        variant: 'success'
                    })
                );
                // Reset the draft values after saving
                this.draftValues = [];
            }).catch(error => {
                console.log('Update Lead Error : ',JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        });       
    }    
    navigateToRecordViewPage(event) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.row.Id,
                objectApiName: 'Opportunity', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}