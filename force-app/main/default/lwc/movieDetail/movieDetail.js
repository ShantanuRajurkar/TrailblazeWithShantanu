import { LightningElement, wire } from 'lwc';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import MOVIE_CHANNEL from "@salesforce/messageChannel/movieChannel__c";
export default class MovieDetail extends LightningElement {
    subscription = null;
    loadCMP = false;
    movieDetails = {};
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    @wire(MessageContext) messageContext;

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                MOVIE_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        let movieId = message.movieId;
        console.log('Details ', movieId);
        this.movieDetail(movieId);
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    async movieDetail(movieId){
        const res = await fetch(`https://www.omdbapi.com/?i=${movieId}&plot=full&apikey=8ba72f8d`);
        const data = await res.json();
        console.log('data detaiuls : ', data);
        this.loadCMP = true;
        this.movieDetails = data;
    }
}