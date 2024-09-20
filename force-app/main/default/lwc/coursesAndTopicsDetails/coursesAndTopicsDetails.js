import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status from '@salesforce/schema/Training_Schedule__c.Status__c';
import Id from '@salesforce/schema/Training_Schedule__c.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTrainingScheduleDetailsList from '@salesforce/apex/TrainingScheduleDetails.getTrainingScheduleDetailsList';

const columns = [
    {label: 'Name', fieldName: 'Name', editable: true, hideDefaultActions: true},
    {label: 'Scheduled Time And Date', fieldName: 'Scheduled_Time_And_Date__c', type: 'date-local'},
    {label: 'Course', fieldName: 'Course__c'},
    {label: 'Trainer', fieldName: 'Trainer__c'},
    {label: 'Status', fieldName: 'Status__c', type: 'customPicklist',  editable: true, typeAttributes: {
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

export default class CoursesAndTopicsDetails extends LightningElement {
    @track tsInfo = {};
    @track draftValues = [];
    @track tsData;
    columns = columns;
    @track tsStatus = [];

    @wire(getObjectInfo,{
         objectApiName: 'Training_Schedule__c'
    })wiredtsInfo({data,error}){
        if(data){
            console.log('Wired training schedule : ',data);
            this.tsInfo = data;
        }else if(error){
            console.log('objInfo Error ', error);
        }
    };

    @wire(getPicklistValues,{
        recordTypeId: '$tsInfo.defaultRecordTypeId',
        fieldApiName: Status,
    })wirePicklist({data,error}){
        if(data){
            console.log('Status picklist Data : ',data);
            this.tsStatus = data.values;
        }else if(error){
            console.log('Error while loading data : ', error);
        }
    }

    @wire(getTrainingScheduleDetailsList,{pickList : '$tsStatus'})wiredtsData({data,error}){
        if(data){
            this.tsData = data.map(currItem=>{
                let pickListOptions = this.tsStatus;
                return{
                    ...currItem,
                    pickListOptions : pickListOptions
                }
            });
            console.log('Wired Data : ',data);
        }else if(error){
            console.log('Error while loading data : ', error);
        }
    };
    
    handleSave(event) {
        const updatedFields = event.detail.draftValues.map(draftValue => {
            return {
                fields: {
                    [Id.fieldApiName]: draftValue.Id,
                    [Status.fieldApiName]: draftValue.Status
                }
            };
        });
    
        updatedFields.forEach(recordInput => {
            updateRecord(recordInput).then((res) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Training Schedule Status updated successfully!',
                        variant: 'success'
                    })
                );
                // Reset the draft values after saving
                this.draftValues = [];
            }).catch(error => {
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