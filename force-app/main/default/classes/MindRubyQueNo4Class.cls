public with sharing class MindRubyQueNo4Class {
    @AuraEnabled(cacheable=true)
    public static String getInfoForMindRubyQueNo4(){
        try {
            HTTP http = new HTTP();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.data.gov.in/resource/b9836bb8-d63a-4fb2-9a0f-26c4fb6017c4?api-key=579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b&format=json');
            request.setMethod('GET');
            HTTPResponse response = http.send(request);
            if(response.getStatusCode()==200){
                String responseBody = response.getBody();
                system.debug('Response '+responseBody);
                return responseBody;
            }else {
                System.debug('Error from API: ' + response.getStatus());
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}