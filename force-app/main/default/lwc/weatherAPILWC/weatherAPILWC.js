import { LightningElement, track, wire } from 'lwc';
import performCallout from '@salesforce/apex/WeatherAPILWCCallOut.performCallout';
 
export default class WeatherAPILWC extends LightningElement {
 
    @track lat;
    @track long;
 
    @track mapMarkers = [];
    zoomLevel = 10;
    @track result;
    @track value;
 
    connectedCallback() {
        performCallout({location: 'Nagpur,IN'}).then(data => {
            this.mapMarkers = [{
                location: {
                    Latitude: data['cityLat'],
                    Longitude: data['cityLong']
                },
                title: data['cityName'] + ', ' + data['state'],
            }];
            this.result = data;
            console.log('Result : ',JSON.stringify(this.result));
        }).catch(err => console.log(err));
    }
 
    get getCityName() {
        if (this.result) {
            return this.result.cityName + ' Information';
        } else {
            return '---'
        }
    }
 
    get getConvertedTemp() {
        if (this.result) {
            return this.result.cityTemp + ' deg';
        } else {
            return '--'
        }
    }
 
    get getCurrentWindSpeed() {
        if (this.result) {
            return this.result.cityWindSpeed + ' mph';
        } else {
            return '--'
        }
    }
 
    get getCurrentPrecip() {
        if (this.result) {
            return this.result.cityPrecip + " inches"
        } else {
            return '--'
        }
    }
 
    get options() {
        return [
            { label: 'Lonavla, IN', value: 'Lonavla,IN' },
            { label: 'Mumbai, IN', value: 'Mumbai,IN' },
            { label: 'Pune, IN', value: 'Pune,IN' },
            { label: 'Delhi, IN', value: 'Delhi,IN'},
            { label: 'Pusad, IN', value: 'Pusad,IN'},
            { label: 'Latur, IN', value: 'Latur,IN'},
            { label: 'Shimla, IN', value: 'Shimla,IN'},
            { label: 'Srinagar, IN', value: 'Srinagar,IN'},
            { label: 'Chicago, US', value: 'Chicago,US'}
        ];
    }
 
    handleChange(event) {
        this.value = event.detail.value;
        performCallout({location: this.value}).then(data => {
            this.mapMarkers = [{
                location: {
                    Latitude: data['cityLat'],
                    Longitude: data['cityLong']
                },
                title: data['cityName'] + ', ' + data['state'],
            }];
            this.result = data;
            console.log('Result : ',JSON.stringify(this.result));
        }).catch(err => console.log(err));
    }
}