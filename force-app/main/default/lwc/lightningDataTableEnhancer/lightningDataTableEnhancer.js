import { LightningElement, wire } from 'lwc';
import getConListForLigthningDataTable from '@salesforce/apex/ContactDetails.getConListForLigthningDataTable';
const columns=[
    {label: 'Name', type: 'customName', typeAttributes: {
        contactName: {
            fieldName: 'Name'
        }
    }},
    {label: 'Title', fieldName: 'Title', cellAttributes: {
        class: {
            fieldName: 'titleColor'
        }
    }},
    {label: 'Related Account', fieldName: 'accountLink', type: 'url', typeAttributes: {
        label: {
            fieldName: 'accountName',
        },
        target: '_blank'    
    }},
    {label: 'Rank', fieldName: 'Rank__c', type: 'customRank', typeAttributes:{
        contactRank: {
            fieldName: 'rank'
        }
    }},
    {label: 'Phone', fieldName: 'Phone', type: 'phone'},
    {label: 'Picture', type: 'customPicture', typeAttributes: {
        contactPicture:{
            fieldName: 'Picture__c'
        }
    }, cellAttributes: {
        alignment: 'center'
    }},
    {label: 'Email', fieldName: 'Email', type: 'email'},
]
export default class LightningDataTableExperiment extends LightningElement {
    columns=columns
    contacts;
    @wire(getConListForLigthningDataTable)wiredContacts({data,error}){
        if(data){
            this.contacts=data.map(currItem => {
                let accountLink = '/'+currItem.AccountId;
                let accountName;
                if(currItem.Account){
                    accountName = currItem.Account.Name;
                }
                let rank = currItem.Rank__c > 5 ? 'utility:ribbon' : '';
                let titleColor="slds-text-color_success";
                return {
                    ...currItem,
                    accountLink: accountLink, 
                    accountName: accountName,
                    titleColor: titleColor,
                    rank: rank
                };
            });
            console.log('Data : ', data);
        }else if(error){
            console.log('Error : ', error);
        }
    }
}