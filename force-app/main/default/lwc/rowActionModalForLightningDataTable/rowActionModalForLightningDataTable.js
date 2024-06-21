import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RowActionsModalForLightningDataTable extends LightningElement {
    @api isViewMode=false;
    @api isEditMode=false;
    @api recordInputId;
    get ModalHeader(){
        if(this.isViewMode)
            return 'Contact Details';
        else if(this.isEditMode)
            return 'Edit Contact Details';
        else
            return '';
    }
    closeModalHandler(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
    successHandler(){
        this.showToast();
        this.closeModalHandler();    
    }
    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Record Saved Successfully',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
    
}