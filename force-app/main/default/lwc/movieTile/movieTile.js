import { LightningElement, api } from 'lwc';

export default class MovieTile extends LightningElement {
    @api movie;
    @api selectedMovieId;
    clickHandler(event){
        console.log(JSON.stringify(this.movie.imdbID));
        this.dispatchEvent(new CustomEvent('selectedposter',{
            detail: this.movie.imdbID
        }));
    }

    get tileSelected(){
        return this.selectedMovieId === this.movie.imdbID ? 'tile selected' : 'tile';
    }
}