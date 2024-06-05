import { LightningElement, wire, api } from 'lwc';
import getAnnualAccountList from '@salesforce/apex/GetAccountList.getAnnualAccountList';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import SLA from '@salesforce/schema/Account.SLA__c';
import ParentId from '@salesforce/schema/Account.ParentId';
import AccountId from '@salesforce/schema/Account.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJ from '@salesforce/schema/Account';
import Name from '@salesforce/schema/Account.Name';
import NumberofLocations from '@salesforce/schema/Account.NumberofLocations__c'
import Description from '@salesforce/schema/Account.Description';
import SLAExpirationDate from '@salesforce/schema/Account.SLAExpirationDate__c';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
export default class CreateRecordForm extends NavigationMixin(LightningElement) {
    @api recordId;
    parentOptions=[];
    selectedAcc='';
    slaExpDate;
    accName='';
    slaType='';
    val = '1';discription='';
    @wire(getObjectInfo, {
        objectApiName : 'Account'
    })accObjectInfo;
    @wire(getPicklistValues,{
        recordTypeId : '$accObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SLA,
    })option;
    @wire(getAnnualAccountList)options({data,error}){
        this.parentOptions=[];
        if(data){
            this.parentOptions=data.map((curitem)=>({
                label: curitem.Name,
                value: curitem.Id
            }));
            console.log('Data : ',this.parentOptions);
        }else if(error){
            console.log('1Error while getting parent records ',error);
        }
    }
    Handle(event){
        let{name, value}=event.target;
        if(name=='parentacc'){
            this.selectedAcc=value;
            console.log('Value : ',this.selectedAcc);
        }else if(name=='accName'){
            this.accName=value;
            console.log('Value : ',this.accName);
        }else if(name=='slaExpDate'){
            this.slaExpDate=value;
            console.log('Value : ',this.slaExpDate);
        }else if(name=='slaType'){
            this.slaType = value;
            console.log('Value : ',this.slaType);
        }else if(name=='sliderVal'){
            this.val=value;
            console.log('Value : ',this.val);
        }else if(name=='description'){
            this.discription=value;
            console.log('Value : ',this.discription);
        }
        console.log('Value out : ',value);           
    }
    Save(){
        let fields={};
        fields[ParentId.fieldApiName] = this.selectedAcc; 
        fields[Name.fieldApiName] = this.accName; 
        fields[SLAExpirationDate.fieldApiName] = this.slaExpDate; 
        fields[SLA.fieldApiName] = this.slaType; 
        fields[NumberofLocations.fieldApiName] = this.val; 
        fields[Description.fieldApiName] = this.discription; 
        if(this.recordId){
            fields[AccountId.fieldApiName] = this.recordId;
            let recordToBeUpdate = {
                fields: fields,
            };
            updateRecord(recordToBeUpdate).then(res=>{
                console.log('Update Success');
                this.showToast();
            }).catch(err=>{
                alert('Error : ', err.body.message);
            });
        }else {
            if(this.validateInput){                
                let recordToCreate={
                    apiName: ACCOUNT_OBJ.objectApiName,
                    fields: fields,
                }
                createRecord(recordToCreate).then(res=>{
                    const pageRef={
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: res.id,
                            objectApiName: 'Account',
                            actionName: 'view'
                        }
                    }
                    this[NavigationMixin.Navigate](pageRef);
                }).catch(error=>{
                    console.log('Error : ', error.body.message);
                    alert('Error : ',error.body.message);
                })
            }else{
                alert('Inputs are not valid');
            }       
        }       
    }
    validateInput(){
        let fields=Array.from(this.template.querySelectorAll('.validateMe'));
        let isValid=fields.every(curritem => curritem.checkValidity());
        return isValid;
    }
    get formTitle(){
        if(this.recordId){
            return 'Edit Account';
        }else{
            return 'Create Account';
        }
    }
    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message:
                'Record is updated successfully',
        });
        this.dispatchEvent(event);
    }
}