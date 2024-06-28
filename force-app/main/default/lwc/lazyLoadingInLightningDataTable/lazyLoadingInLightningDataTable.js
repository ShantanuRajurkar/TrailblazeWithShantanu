import { LightningElement, wire } from 'lwc';
import loadDataById from '@salesforce/apex/AccountDetails.loadDataById';
import countOfAccounts from '@salesforce/apex/AccountDetails.countOfAccounts';
import loadMoreData from '@salesforce/apex/AccountDetails.loadMoreData';
const columns=[
    {label: 'Name', fieldName: 'Name'},
    {label: 'Industry', fieldName: 'Industry'},
    {label: 'Rating', fieldName: 'Rating'},
];
export default class LazyLoadingInLightningDataTable extends LightningElement {
    columns=columns;
    accData;
    totalAccRecords=0;
    recordsLoaded=0;
    connectedCallback(){
        this.loadInitialData();
    }
    async loadInitialData(){
        try{
            this.totalAccRecords=await countOfAccounts();
            this.accData=await loadDataById();
            this.recordsLoaded=this.accData.length;
            console.log('loaded data : ',this.recordsLoaded);
            console.log('totalAccRecords : ',this.totalAccRecords);
        }catch(error){
            console.log('Error while loading Data : ',error);
        }
    }
    async loadMoreData(event){
        try{
            const { target }=event;
            target.isLoading=true;
            let currentRecords=this.accData;
            let lastRecord=currentRecords[currentRecords.length-1]
            let newlyLoadedRecords=await loadMoreData({
                lastName: lastRecord.Name,
                lastId: lastRecord.Id
            });
            this.accData=[...currentRecords,...newlyLoadedRecords];
            this.recordsLoaded=this.accData.length;
            console.log('More loaded data : ',this.recordsLoaded);
            target.isLoading=false;
        }catch(error){
            console.log('Error : ',error)
        }
    }
}