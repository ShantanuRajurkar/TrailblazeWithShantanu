import { LightningElement } from 'lwc';

export default class SynechronQueNo1 extends LightningElement {
    charCounts = [];
    inputString = '';
    isShow = false;

    handle(event){
        this.inputString = event.target.value;
    }

    handleClick(event){
        this.isShow = true;
        //this.nameArray = this.name.split('');
        this.countTheChar();
    }

    handleReset(event){
        this.isShow = false;
        this.inputString = '';
        this.charCounts = [];
    }

    countTheChar(char){
        const counts = {};
        for(const char of this.inputString){
            counts[char] = (counts[char] || 0) + 1;
        }
        this.charCounts = Object.keys(counts).map(char => ({
                char: char,
                count: counts[char]
        }))
    }
}