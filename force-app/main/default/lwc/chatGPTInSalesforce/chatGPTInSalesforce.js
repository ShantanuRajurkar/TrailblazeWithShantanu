import { LightningElement, track } from 'lwc';
export default class ChatGPTInSalesforce extends LightningElement {
    question='Hello';
    data;
    isLoaded=true;
    isChange=true;
    message='';
    handleOnChange(event){
        this.question=event.target.value;
        this.isChange=true;
    }
    handleOnClick(event){
        if(this.isChange){
            this.isLoaded=false;
            console.log('handleClicked 1');
            this.getChatGPTData();
            console.log('handleClicked 2');
            this.isChange=false;
        }
    }
    async getChatGPTData(){
        const endPoint='https://api.openai.com/v1/chat/completions';
        const myHeaders=new Headers();
        myHeaders.append('Authorization', 'Bearer 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');
        myHeaders.append('Content-Type', 'application/json');
        const raw=JSON.stringify({
            'model': 'gpt-4o',
            'messages':[
                {
                    'role':'user',
                    'content':this.question
                }
            ]
        });
        const requestOptions={
            method: 'POST',
            headers: myHeaders,
            body: raw,
            redirect: 'follow'
        };
        try{
            const response=await fetch(endPoint, requestOptions);
            const result_1=await response.json();
            this.data=result_1;
            console.log('Chat GPT data : ',this.data);
            if(this.data.choices[0].message.content){
                this.message=this.data.choices[0].message.content;
                console.log('Chat GPT message : ',this.message);
            }
            this.isLoaded=true;
        }catch(error){
            return console.log(error.message.body);
        }
    }
}