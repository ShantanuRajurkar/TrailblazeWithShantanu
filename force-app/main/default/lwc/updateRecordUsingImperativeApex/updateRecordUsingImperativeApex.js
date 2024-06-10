import { LightningElement, api, wire } from 'lwc';
import Name from '@salesforce/schema/Account.Name';
import Phone from '@salesforce/schema/Account.Phone';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import updateAccountRecord from '@salesforce/apex/AccountDetails.updateAccountRecord';
export default class UpdateUsingImperativeApex extends LightningElement {
    @api recordId;
    accName;accPhone;
    @wire(getRecord,{
        recordId: "$recordId",
        fields: [Name, Phone],
    })outputFuntion({error,data}){
        if(data){
            console.log('Data : ', data);
            this.accName=getFieldValue(data, Name);
            this.accTicker=getFieldValue(data, Phone);
        }else if(error){
            console.log('Error : ', error);
        }
    };
    Handle(event){
        this.accPhone=event.target.value;
    }
    updateHandle(event){
        updateAccountRecord({
            recordId: this.recordId,
            newPhone: this.accPhone,
        }).then(res=>{
            notifyRecordUpdateAvailable([{recordId: this.recordId}]).then(()=>{
                console.log('UI Refresh Successfully');
            }).catch(error=>{
                console.log('Error : ', error);
            });
            console.log('Record Updated Successfully');
        }).catch(error=>{
            console.log('Record Update Failed',error);
        });
    }
}