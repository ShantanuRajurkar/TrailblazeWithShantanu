import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import FIRST_NAME_FIELD from '@salesforce/schema/Lead.FirstName';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import STATUS_FIELD from '@salesforce/schema/Lead.Status';
import LAST_NAME_FIELD from '@salesforce/schema/Lead.LastName';
import EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import REFERENCE_BY_FIELD from '@salesforce/schema/Lead.Reference_By__c';
import REFERENCE_EMPLOYEE_ID_FIELD from '@salesforce/schema/Lead.Reference_Employee_ID__c';

export default class LeadCaptureForm extends LightningElement {
    firstName = '';
    lastName = '';
    email = '';
    phone = '';
    company = '';
    referenceBy = '';
    referenceEmployeeId = '';
    isShow = false;
    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleSubmit() {
        this.isShow = true;
        const fields = {};
        fields[FIRST_NAME_FIELD.fieldApiName] = this.firstName;
        fields[LAST_NAME_FIELD.fieldApiName] = this.lastName;
        fields[EMAIL_FIELD.fieldApiName] = this.email;
        fields[COMPANY_FIELD.fieldApiName] = this.company;
        fields[STATUS_FIELD.fieldApiName] = 'Open - Not Contacted';
        fields[PHONE_FIELD.fieldApiName] = this.phone;
        fields[REFERENCE_BY_FIELD.fieldApiName] = this.referenceBy;
        fields[REFERENCE_EMPLOYEE_ID_FIELD.fieldApiName] = this.referenceEmployeeId;

        const recordInput = { apiName: LEAD_OBJECT.objectApiName, fields };
        
        createRecord(recordInput)
            .then(lead => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead created with ID: ' + lead.id,
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                console.log(JSON.stringify(error))
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating lead',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}
