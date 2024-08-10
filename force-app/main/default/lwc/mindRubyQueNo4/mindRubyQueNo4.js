import { LightningElement } from 'lwc';
import getInfoForMindRubyQueNo4 from '@salesforce/apex/MindRubyQueNo4Class.getInfoForMindRubyQueNo4';
export default class MindRubyQueNo4 extends LightningElement {
    JSONBody='';
    selectedCountry;
    selectedYear;
    visitors='';
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
            value: '_2016',
            label: '2016',
        },
        {
            value: '_2017',
            label: '2017',
        },
        {
            value: '_2018',
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
        console.log('1Object : ', JSONObj.desc);
        console.log('2Object : ', JSON.stringify(JSONObj.records));
        JSONObj.records.forEach(element => {
            if(this.selectedCountry==element.country){
                console.log('Loop : ',JSON.stringify(element));
                if(element.hasOwnProperty(this.selectedYear)){
                    this.visitors=JSON.stringify(element[this.selectedYear]);
                    console.log('JSONBody : ', this.visitors);
                }
            }
        })
        console.log('JSONObj Type : ', typeof JSONObj);
    }
}