import { LightningElement, wire } from 'lwc';
const action = [
    {label: 'Show Details', name: 'view'},
    {label: 'Edit', name: 'edit'},
    {label: 'Delete', name: 'delete'}
]
const allAction = [
    {
        label: 'All',
        checked: true,
        name: 'All'
    }
]
const columns=[
    {label: 'Name', fieldName: 'Name', hideDefaultActions: true},
    {label: 'Phone', fieldName: 'Phone', hideDefaultActions: true, cellAttributes :{
        alignment: 'center'
    }},
    {label: 'Account Number', fieldName: 'AccountNumber', type: 'number', hideDefaultActions: true, cellAttributes :{
        alignment: 'center'
    }},
    {label: 'Type', fieldName: 'Type', hideDefaultActions: true, cellAttributes :{
        alignment: 'center'
    }},
    {label: 'Rating', fieldName: 'Rating', hideDefaultActions: true, actions: allAction, cellAttributes :{
        alignment: 'center'
    }},
    {
        type: 'action', typeAttributes: {
            rowActions: action, 
        }
    }
];
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountRecordsForRowAndHeraderActionOnLightningDataTable from '@salesforce/apex/AccountDetails.getAccountRecordsForRowAndHeraderActionOnLightningDataTable';
import { refreshApex } from '@salesforce/apex';
import Rating from '@salesforce/schema/Account.Rating';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
export default class RowActionsOnLightningDataTable extends LightningElement {
    picklist;
    accData;
    selectedRecord;
    refreshData;
    columns=columns;
    viewMode=false;
    editMode=false;
    showModal=false;
    isValueLoaded = false;
    ratingFullValues=[];
    actionFullValues=[];
    @wire(getObjectInfo, {
        objectApiName: 'Account'
    })objInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objInfo.data.defaultRecordTypeId',
        fieldApiName: Rating
    })wiredPickListRating(result){
        if(result.data){
            this.actionFullValues=[];
            this.picklist=result.data.values;
            this.picklist.forEach(currItem=>{
                this.actionFullValues.push({
                    label: currItem.label,
                    checked: false,
                    name: currItem.value
                });
                //console.log('Rating full values in array label', currItem.label)
            });
            this.columns.forEach(currItem=>{
                if(currItem.fieldName==='Rating'){
                    currItem.actions=[...currItem.actions, ...this.actionFullValues];
                }
            })
            this.isValueLoaded=true;
            console.log('action full values : ',this.actionFullValues);
        }else if(result.error){
            console.log('Error : ', error);
        }    
       
    }
    showModalHandler(){
        this.showModal=true;
    }
    headerActionHandler(event){
        //console.log('Rating : ', this.picklist);
        //console.log('Rating full values in headerActions : ', this.ratingFullValues);
        let actionName = event.detail.action.name;
        const colDefination = event.detail.columnDefinition;
        const col = [...this.columns];
        //console.log('action Name : ',actionName);
        //console.log('column defination : ',colDefination);
        //console.log('col : ',col);
        if(actionName==='All'){
            this.accData=[...this.ratingFullValues];
            //console.log('Action accData', this.accData);
        }else{
            this.accData=this.ratingFullValues.filter(currItem=>actionName===currItem['Rating']); 
        }
        let array = col.find((currItem)=>currItem.fieldName==='Rating');
        //console.log('Array ', array.actions);
        array.actions.forEach(currItem=>{
            if(actionName===currItem.name)
                currItem.checked=true;
            else
                currItem.checked=false;
        });
        this.columns=[...col];
    }
    @wire(getAccountRecordsForRowAndHeraderActionOnLightningDataTable)wiredAccData(result){
        this.refreshData=result;
        if(result.data){
            this.accData = result.data;
            this.ratingFullValues = [...this.accData];
            //console.log('Rating full values : ',this.accData);
        }else if(result.error){
            console.log('Error : ',result.error.body.message);
        }
    };
    rowActionHandler(event){
        this.editMode=false;
        this.viewMode=false;
        this.showModal=false;
        let action = event.detail.action;
        let row = event.detail.row;
        this.selectedRecord = row.Id;
        console.log('Id : ',this.selectedRecord);
        if(action.name==='view'){
            this.viewMode=true; 
            this.showModal=true;          
        }else if(action.name==='edit'){
            this.editMode=true;
            this.showModal=true
        }else if(action.name==='delete'){
            this.deleteHandler();
        }
    }
    async closeModal(event){
        this.showModal=false;
        await refreshApex(this.refreshData);
    }
    deleteHandler(){
        deleteRecord(this.selectedRecord).then(()=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Record deleted successfully',
                variant: 'success'
            }));
            refreshApex(this.refreshData);
        }).catch(error=>{
            console.log('Error : ', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: error.body.message,
                variant: 'error'
            }));
        })
    }
    get accList(){
        if(this.accData){
            return this.accData;
        }
    }
    get displayData(){
        if(this.accData && this.isValueLoaded===true)
            return true;
        else
            return false;
    }
}