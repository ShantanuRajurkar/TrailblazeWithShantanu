public with sharing class SalesforceToWhatsAppCallout {
    public static void SalesforceWACallout(){
        string endpoint = 'https://graph.facebook.com/v20.0/412439728614365/messages';
        Map<String, Object> languageMap = new Map<String, Object>();
        languageMap.put('code', 'en_US');

        Map<String, Object> templateMap = new Map<String, Object>();
        templateMap.put('name', 'hello_world');
        templateMap.put('language', languageMap);

        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('messaging_product', 'whatsapp');
        jsonMap.put('to', '919420181774');
        jsonMap.put('type', 'template');
        jsonMap.put('template', templateMap);

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeObject(jsonMap);

        String jsonString = gen.getAsString();
        System.debug(jsonString);
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setBody(jsonString);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer EAARVOyxZAZC5oBO0oxIZB7NDzhyKP1mrYDioZCp1ZBiGl9iQaw6JQZCXRa7FrXgM7aegZBZAInkX0zGVdX7ZBB7BITSmsKW9tuV9kTW5ofGnZBZC0DAOUOZA8ZCDyLBV8Vkad3NWMBlTDB1SGy5IF5IFRPrcjsrogouaB3Ngsh0kRAC4pRAN4nup9EYiZAQEwkcjwrayvQTw4d2y8fTWHVwsaX');
        HttpResponse response = http.send(request);
        system.debug('Resonse Body : '+response.getBody());
    }

}