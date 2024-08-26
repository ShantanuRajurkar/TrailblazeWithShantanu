import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import MOVIE_CHANNEL from "@salesforce/messageChannel/movieChannel__c";

const Delay = 300;
export default class MovieSearch extends LightningElement {
    selectedType = '';
    loading = false;
    selectedSearch = '';
    selectedPage = '';
    delayTimeout;
    searchResult = [];
    selectedMovie = '';

    @wire(MessageContext) messageContext;

    get options(){
        return [
            { label: 'None', value: ''},
            { label: 'Movie', value: 'movie'},
            { label: 'Series', value: 'series'},
            { label: 'Episode', value: 'episode'},
        ]
    }

    handleChange(event){
        this.loading = true;
        if(event.target.name == 'type'){
            this.selectedType = event.target.value;        
        }else if(event.target.name == 'search'){
            this.selectedSearch = event.target.value;
        }else if(event.target.name == 'page'){
            this.selectedPage = event.target.value;
        }
        clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(()=>{
            this.searchMovie();
        },Delay);
    }

    async searchMovie(){
        const url = `https://www.omdbapi.com/?s=${this.selectedSearch}&type=${this.selectedType}&page=${this.selectedPage}&apikey=8ba72f8d`;
        const response = await fetch(url);
        const data = await response.json();
        console.log('Response : ', data);
        this.loading = false;
        if(data.Response === 'True'){
            this.searchResult = data.Search;
            console.log('Size of array : ', this.searchResult.length);
        }else if(data.Response === 'False'){
            this.searchResult = [];
        }
        
    }

    get displayTile(){
        return this.searchResult.length > 0 ? true : false ;
    }

    handleSelectedPoster(event){
        this.selectedMovie = event.detail;
        const payload = { movieId: this.selectedMovie };
        publish(this.messageContext, MOVIE_CHANNEL, payload);
    }
}