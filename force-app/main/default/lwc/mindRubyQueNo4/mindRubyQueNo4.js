import { LightningElement } from 'lwc';
import getInfoForMindRubyQueNo4 from '@salesforce/apex/MindRubyQueNo4Class.getInfoForMindRubyQueNo4';
export default class MindRubyQueNo4 extends LightningElement {
    JSONBody='';
    selectedCountry;
    selectedYear;
    CountryOptions = [
        {
            value: 'Pakistan',
            label: 'Pakistan',
        },
        {
            value: 'Afghanistan',
            label: 'Afghanistan',
        },
        {
            value: 'Bangladesh',
            label: 'Bangladesh',
        },
    ];
    YearOptions = [
        {
            value: '2016',
            label: '2016',
        },
        {
            value: '2017',
            label: '2017',
        },
        {
            value: '2018',
            label: '2018',
        },
    ];
    handleCountryChange(event){
        this.selectedCountry=event.target.value;
    }
    handleYearChange(event){
        this.selectedYear=event.target.value;
    }
    connectedCallback(){
        getInfoForMindRubyQueNo4().then(res=>{
            console.log('Response ',res);
            this.JSONBody=res;
        }).catch(err=>{
            console.log('Error : ', JSON.stringify(err));
        });
    }
    handleClick(event){
        console.log('type',typeof this.JSONBody);
        let JSONObj = JSON.parse(this.JSONBody);
        console.log('1Object : ', JSONObj.);
        console.log('JSONObj Type : ', typeof JSONObj);
        const plainObject = Object.assign({}, JSONObj);
        console.log(plainObject);
    }
}