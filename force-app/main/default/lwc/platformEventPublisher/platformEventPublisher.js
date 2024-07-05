import { LightningElement, api, wire } from 'lwc';
import platformEventPublish from '@salesforce/apex/platformEventPublisherClass.platformEventPublish';
import Status from '@salesforce/schema/Case.Status';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
export default class platformEventPublisher extends LightningElement {
    @api recordId;
    picklistStatusValues;
    selectedStatus;
    @wire(getObjectInfo,{
        objectApiName : 'Case'
    })objInfo;
    @wire(getPicklistValues,{
        recordTypeId : '$objInfo.data.defaultRecordTypeId',
        fieldApiName : Status,
    })wiredPicklistVals({data,error}){
        if(data){
            this.picklistStatusValues=data.values;
        }else if(error){
            console.log('Error : ', error);
        }
    }
    HandleChange(event){
        this.selectedStatus=event.target.value;
        console.log('Stas : ', this.selectedStatus);
    }
    HandleClick(){
        platformEventPublish({
            Id: this.recordId,
            status: this.selectedStatus,
        }).then(res=>{
            console.log('Request Sent');
        }).catch(error=>{
            console.log('Error While sending the request', error);
        })
    }
}