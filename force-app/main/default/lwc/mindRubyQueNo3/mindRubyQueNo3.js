import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, wire } from 'lwc';
import StageName from '@salesforce/schema/Opportunity.StageName';
import { NavigationMixin } from 'lightning/navigation';
import getOppListForMindRubyQueNo3 from '@salesforce/apex/OpportunityDetails.getOppListForMindRubyQueNo3';
const columns = [
    {label: 'Opportunity Name', fieldName: 'Name'},
    {label: 'Amount', fieldName: 'Amount', type: 'number'},
    {label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
    {label: 'Stage Name', fieldName: 'StageName'},
    {
        type: 'button',
        typeAttributes: { label: 'View', name: 'view', variant: 'base' }
    }
];
export default class MindRubyQueNo3 extends NavigationMixin(
    LightningElement
) {
    options=[];
    oppInfo;
    columns=columns;
    givenStageName;
    @wire(getObjectInfo,{
        objectApiName: 'Opportunity'
    })wiredOppInfo({data,error}){
        if(data){
            console.log('objInfo Data ', data);
            this.oppInfo = data;
        }else if(error){
            console.log('objInfo Error ', error);
        }
    };
    @wire(getPicklistValues, {
        recordTypeId: '$oppInfo.defaultRecordTypeId',
        fieldApiName: StageName
    })wiredPicklistValues(result) {
        if(result.data){
            console.log('data : ', result.data);
            this.options = result.data.values;
        }else if(result.error){
            console.log('Error while getting picklist values ', result.error);
        }
    }
    @wire(getOppListForMindRubyQueNo3,{
        Stage: '$givenStageName'
    })OppData;
    handleChange(event){
        this.givenStageName = event.target.value;
    }
    navigateToRecordViewPage(event) {
        // View a custom object record.
        console.log('Record Id ', event.detail.row.Id);
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