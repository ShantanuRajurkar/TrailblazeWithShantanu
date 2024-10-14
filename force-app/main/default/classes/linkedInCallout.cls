public with sharing class linkedInCallout {
    @AuraEnabled
    public static string getUserInfo(String linkedInTextMessage){
        try {
            linkedIn_Info__mdt metadata = linkedIn_Info__mdt.getInstance('LinkedIn_Access_Token');
            //String accessToken = metadata.Access_token__c;
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndPoint('https://api.linkedin.com/v2/userinfo');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer AQU4vZB27ZXdL5pinTWoYinAktgKbxaMjG0d5iLX1sO-QDO2B3i4p2JBcfRXFrwg-fg3zUfI1RohlLZoDfsPk3Z_fCs5lCIddFGo5fv7t5uHXN2L02HAxZs_Kut7QAKMorGBOHBOuj6Dw1T_Oy1ot2uTU0337pjwJtsIU187ibJmG2h24jsBXKo_al0Bt8gIxNlQSORO8exQpmxamVRtmc3kZBW2oD9MSXpR0po3s_UHsen2UX4aNAbWFV2bAD4ZqMz376WT2yD1VeeAHYo5UQpH4TYhVqLK3OItbblHOZs6ksCAINNHgGk5jOVYWrPSwMz84xA7kAFR1-dfvOoiODpjidDBXg');
            HttpResponse response = HTTP.send(request);
            String JSONString = response.getBody();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
            String subValue = (String) jsonMap.get('sub');
            //System.debug('Access Tocken : '+accessToken);
            System.debug('JSONString-->'+subValue);
            createLinkedInTextPost(subValue, linkedInTextMessage);
            return 'Text Posted Successfully !!';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @future(callout=true)
    public static void createLinkedInTextPost(String subValue, String message){
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(' https://api.linkedin.com/v2/ugcPosts');
        request.setHeader('Authorization', 'Bearer AQU4vZB27ZXdL5pinTWoYinAktgKbxaMjG0d5iLX1sO-QDO2B3i4p2JBcfRXFrwg-fg3zUfI1RohlLZoDfsPk3Z_fCs5lCIddFGo5fv7t5uHXN2L02HAxZs_Kut7QAKMorGBOHBOuj6Dw1T_Oy1ot2uTU0337pjwJtsIU187ibJmG2h24jsBXKo_al0Bt8gIxNlQSORO8exQpmxamVRtmc3kZBW2oD9MSXpR0po3s_UHsen2UX4aNAbWFV2bAD4ZqMz376WT2yD1VeeAHYo5UQpH4TYhVqLK3OItbblHOZs6ksCAINNHgGk5jOVYWrPSwMz84xA7kAFR1-dfvOoiODpjidDBXg');
        request.setMethod('POST');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        // Add the author field with LinkedIn ID (subValue)
        gen.writeStringField('author', 'urn:li:person:' + subValue);

        // Add lifecycleState
        gen.writeStringField('lifecycleState', 'PUBLISHED');

        // Start specificContent object
        gen.writeFieldName('specificContent');
        gen.writeStartObject();
        gen.writeFieldName('com.linkedin.ugc.ShareContent');
        gen.writeStartObject();

        // Add shareCommentary object with text
        gen.writeFieldName('shareCommentary');
        gen.writeStartObject();
        gen.writeStringField('text', message);
        gen.writeEndObject();

        // Add shareMediaCategory
        gen.writeStringField('shareMediaCategory', 'NONE');
        
        // End com.linkedin.ugc.ShareContent object
        gen.writeEndObject();
        gen.writeEndObject();

        // Add visibility object
        gen.writeFieldName('visibility');
        gen.writeStartObject();
        gen.writeStringField('com.linkedin.ugc.MemberNetworkVisibility', 'PUBLIC');
        gen.writeEndObject();

        // End the entire JSON object
        gen.writeEndObject();
        
        // Convert the JSON generator to string
        String requestBody = gen.getAsString();
        System.debug('Request Body: ' + requestBody);

        // Set the body for the HTTP request
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        System.debug('Body : '+response.getBody());
    }
}