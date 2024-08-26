@RestResource(urlMapping='/salesforcetowhatsapp/*')
global without sharing class SalesforceWARestResourceForWebHooks {
    private static Final String MessageValidity = 'Signature  Verified';
    private static Final String MessageNonValidity = 'Signature could not be Verified';

    @HttpGet
    global static void get(){
        System.debug('In Get Method');
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        if(request.params.get('hub.verify_token')=='salesforcewa'){
            response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
        }
    }

    @HttpPost
    global static void post(){
        System.debug('In Post Method');
        RestResponse response = RestContext.response;
        response.addHeader('Content-type', 'application/json');
        string resString = RestContext.request.requestBody.toString();
        Map<String, String> headers = RestContext.request.headers;
        String responseValid = validateWhatsAppSignature(RestContext.request, resString);
        if(responseValid == MessageValidity){
            System.debug(System.LoggingLevel.DEBUG+' Header Response From WhatsApp \n  '+JSON.serialize(headers));
            System.debug(System.LoggingLevel.DEBUG+' Response From WhatsApp \n  '+resString);
            String finalRes = resString.replace('type', 'typex'); 
            WhatsAppMessage parentMessage = (WhatsAppMessage)JSON.deserialize(finalRes, WhatsAppMessage.class);
            list<WhatsAppMessage.entry> messageEntries = parentMessage.entry;
            if(messageEntries != null && messageEntries.size() > 0){
                WhatsAppMessage.entry entryMessage = messageEntries.get(0);
                list<WhatsAppMessage.changes> changeMessages = entryMessage.changes;
                if(changeMessages != null && changeMessages.size() > 0){
                    WhatsAppMessage.changes changeMessage = changeMessages.get(0);
                    list<WhatsAppMessage.contacts> contactList = changeMessage.value.contacts;
                    list<WhatsAppMessage.messages> messageList = changeMessage.value.messages;
                    WhatsAppMessage.metadata metadata = changeMessage.value.metadata; 
                    WhatsApp__c WA = new WhatsApp__c();
                    WA.BusinessPhoneNumber__c = metadata != null ? metadata.display_phone_number : null;
                    if(contactList !=null && contactList.size() > 0){
                        WhatsAppMessage.contacts contact = contactList.get(0);
                        WA.Customer_Name__c = contact.profile.name;
                        WA.Customer_Phone__c = contact.wa_id;
                    }
                    if(messageList != null && messageList.size() > 0){
                        WhatsAppMessage.messages message = messageList.get(0);
                        WA.Message_ID__c = message.id;
                        WA.Message_Content__c = message.text != null ? message.text.body : null;
                        WA.Message_Sent_Time__c = System.now();
                        WA.Message_Type__c = message.typex;
                        WA.Reaction__c = message.reaction != null ? message.reaction.emoji : null;
                        WA.Parent_Message_ID__c = message.reaction != null ? message.reaction.message_id : null;
                        WA.Image_ID__c = message.image != null ? message.image.id : null;
                        WA.Image_Type__c = message.image != null ? message.image.mime_type : null;
                        WA.Image_sha256__c = message.image != null ? message.image.sha256 : null;
                        WA.Parent_Message_ID__c = message.context != null ? message.context.id : null;
                        
                        upsert WA Message_ID__c;
                    }
                }
            }
        }else{
            response.responseBody = Blob.valueOf('{success:false, event: "Unknown", "message"'+responseValid+'"}');
            response.statusCode = 401;
            return;
        }
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{success:true, event:"success"}');
    }

    private static String validateWhatsAppSignature(RestRequest request, String responseString){
        Map<String, String> headersMap = request.headers;
        string whatsAppSignature = headersMap.get('X-Hub-Signature-256');
        String whatsAppPayload = RestContext.request.requestBody.toString();
        String WhatsAppSecret = System.Label.FaceBookApp;
        Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(whatsAppPayload), Blob.valueOf(WhatsAppSecret));
        String encodedPayload = 'sha256=' + EncodingUtil.convertToHex(signedPayload);
        String response = (encodedPayload == whatsAppSignature) ? MessageValidity : MessageNonValidity;
        return response;
    }
}