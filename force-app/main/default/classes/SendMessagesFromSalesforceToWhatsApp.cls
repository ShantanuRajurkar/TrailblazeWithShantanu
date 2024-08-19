public with sharing class SendMessagesFromSalesforceToWhatsApp {
    public static void sentTextMessage(String messageContent, String toPhone){
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://graph.facebook.com/v14.0/412439728614365/messages');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+System.Label.WhatsAppAccessToken);
        String json = '{'+
		'    "messaging_product": "whatsapp",    '+
		'    "recipient_type": "individual",'+
		'    "to": "'+toPhone+'",'+
		'    "type": "text",'+
		'    "text": {'+
		'        "preview_url": false,'+
		'        "body": "'+messageContent+'"'+
		'    }'+
		'}';
        request.setBody(json);
        try{
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                system.debug('Resonse Body : '+response.getBody());
                SendMessagesFromSalesforceToWhatsApp msg = (SendMessagesFromSalesforceToWhatsApp) JSON.deserialize(response.getBody(), SendMessagesFromSalesforceToWhatsApp.class);                WhatsApp__c WA = new WhatsApp__c();
                WA.Message_Content__c = messageContent;
                WA.Customer_Phone__c = toPhone;
                WA.Message_ID__c = msg.messages.get(0).id;
                WA.Message_Type__c = 'Text';
                upsert WA Message_ID__c;
            }
        }catch(System.CalloutException ex){
            system.debug('Error While Callout : '+ex.getStackTraceString());
        }catch(System.Exception ex){
            system.debug('Error While Callout : '+ex.getStackTraceString());
        }    
    }
    public String messaging_product;	//whatsapp
	public list<contacts> contacts;
	public list<messages> messages;
	public class contacts {
		public String input;	//919420181774
		public String wa_id;	//919420181774
	}
	public class messages {
		public String id;	//wamid.HBgMOTE5NDIwMTgxNzc0FQIAERgSQTA4NzA1MUYwODJFOTEyRUIwAA==
	}
}