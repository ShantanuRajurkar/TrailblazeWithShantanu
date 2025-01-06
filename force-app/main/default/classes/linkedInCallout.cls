/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LinkedInCallout {
    @AuraEnabled
    public static string getUserInfo(String linkedInTextMessage, String contentversionId){
        try {
            system.debug('ContentVersion Id : '+contentversionId);
            linkedIn_Info__mdt metadata = linkedIn_Info__mdt.getInstance('LinkedIn_Access_Token');
            //String accessToken = metadata.Access_token__c;
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndPoint('https://api.linkedin.com/v2/userinfo');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer AQW_ruC_jdk8qGWhP3Dv96QWT-CcBp7bP2bftvtVsxzoJh_cfy4gjv8DsVmLYnI5Jm68q-mQ1KFdF-Eb1OWAVvU20agcp8VJDpctkSijJhFf_xX9UwD4G19Jpsz4eRGA3gC-HBvl-s4MkKTYYPJ40vvOwvtwS_B0GTQz7wyAvTWvNqZFOkhA5OytPDJRIpzKU9WnvG0Ud-ZcMdCc_sCrED1JiHr51C2WZZOCrfH5qWqtCB7YmRYiOAyhujM0xgDF0_ijjpqIXzegFX5051L5ZRfpBjZRdOfrLm72VCnl9zaS8T5tmOkncPjSUDCwC1qJnQEPBjs6c1FRsr5emQmLAdj-3r4Cpw');
            HttpResponse response = HTTP.send(request);
            String JSONString = response.getBody();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
            String subValue = (String) jsonMap.get('sub');
            //System.debug('Access Tocken : '+accessToken);
            System.debug('JSONString-->'+subValue);
            if(contentversionId == null){
                //createLinkedInTextPost(subValue, linkedInTextMessage);
            } else if(contentversionId != null){
                createLinkedInMediaPost(subValue, linkedInTextMessage, contentversionId);
            }
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
        request.setHeader('Authorization', 'Bearer AQW_ruC_jdk8qGWhP3Dv96QWT-CcBp7bP2bftvtVsxzoJh_cfy4gjv8DsVmLYnI5Jm68q-mQ1KFdF-Eb1OWAVvU20agcp8VJDpctkSijJhFf_xX9UwD4G19Jpsz4eRGA3gC-HBvl-s4MkKTYYPJ40vvOwvtwS_B0GTQz7wyAvTWvNqZFOkhA5OytPDJRIpzKU9WnvG0Ud-ZcMdCc_sCrED1JiHr51C2WZZOCrfH5qWqtCB7YmRYiOAyhujM0xgDF0_ijjpqIXzegFX5051L5ZRfpBjZRdOfrLm72VCnl9zaS8T5tmOkncPjSUDCwC1qJnQEPBjs6c1FRsr5emQmLAdj-3r4Cpw');
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

    @future(callout = true)
    public static void createLinkedInMediaPost(String subValue, String linkedInTextMessage, String contentversionId){
        registerTheMedia(subValue, linkedInTextMessage, contentversionId);
    }

    public static void registerTheMedia(string subValue, String linkedInTextMessage, String contentversionId){
        String jsonBody = '{' +
    '    "registerUploadRequest": {' +
    '        "recipes": [' +
    '            "urn:li:digitalmediaRecipe:feedshare-image"' +
    '        ],' +
    '        "owner": "urn:li:person:' + subValue + '",' + // Insert variable x here
    '        "serviceRelationships": [' +
    '            {' +
    '                "relationshipType": "OWNER",' +
    '                "identifier": "urn:li:userGeneratedContent"' +
    '            }' +
    '        ]' +
    '    }' +
    '}';
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndPoint('https://api.linkedin.com/v2/assets?action=registerUpload');
        request.setHeader('Authorization', 'Bearer AQW_ruC_jdk8qGWhP3Dv96QWT-CcBp7bP2bftvtVsxzoJh_cfy4gjv8DsVmLYnI5Jm68q-mQ1KFdF-Eb1OWAVvU20agcp8VJDpctkSijJhFf_xX9UwD4G19Jpsz4eRGA3gC-HBvl-s4MkKTYYPJ40vvOwvtwS_B0GTQz7wyAvTWvNqZFOkhA5OytPDJRIpzKU9WnvG0Ud-ZcMdCc_sCrED1JiHr51C2WZZOCrfH5qWqtCB7YmRYiOAyhujM0xgDF0_ijjpqIXzegFX5051L5ZRfpBjZRdOfrLm72VCnl9zaS8T5tmOkncPjSUDCwC1qJnQEPBjs6c1FRsr5emQmLAdj-3r4Cpw');
        request.setMethod('POST');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        System.debug('Register an Image or a video Body : '+response.getBody());
        // Parse the JSON response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        // Access the 'value' map
        Map<String, Object> valueMap = (Map<String, Object>) responseMap.get('value');

        // Extract the 'asset'
        String asset = (String) valueMap.get('asset');

        // Extract the 'uploadUrl' from the nested map
        Map<String, Object> uploadMechanism = (Map<String, Object>) valueMap.get('uploadMechanism');
        Map<String, Object> mediaUploadRequest = (Map<String, Object>) uploadMechanism.get('com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest');
        String uploadUrl = (String) mediaUploadRequest.get('uploadUrl');

        // Debug the extracted values
        System.debug('Asset: ' + asset);
        System.debug('Upload URL: ' + uploadUrl);
        uploadTheMedia(uploadUrl, contentVersionId, asset, subValue);
    }

    private static void uploadTheMedia(string uploadUrl, String contentVersionId, String asset, String subValue){
        try {
            // Query the file content and metadata
            ContentVersion cv = [SELECT Id, VersionData, Title, FileType 
                                 FROM ContentVersion 
                                 WHERE Id = :contentVersionId 
                                 LIMIT 1];

            // Create an HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(uploadUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/octet-stream');
            request.setHeader('Authorization', 'Bearer AQW_ruC_jdk8qGWhP3Dv96QWT-CcBp7bP2bftvtVsxzoJh_cfy4gjv8DsVmLYnI5Jm68q-mQ1KFdF-Eb1OWAVvU20agcp8VJDpctkSijJhFf_xX9UwD4G19Jpsz4eRGA3gC-HBvl-s4MkKTYYPJ40vvOwvtwS_B0GTQz7wyAvTWvNqZFOkhA5OytPDJRIpzKU9WnvG0Ud-ZcMdCc_sCrED1JiHr51C2WZZOCrfH5qWqtCB7YmRYiOAyhujM0xgDF0_ijjpqIXzegFX5051L5ZRfpBjZRdOfrLm72VCnl9zaS8T5tmOkncPjSUDCwC1qJnQEPBjs6c1FRsr5emQmLAdj-3r4Cpw');
            request.setHeader('Authorization', 'Bearer redacted');  // Use appropriate content type if known
            // Set the binary body
            request.setBodyAsBlob(cv.VersionData);
            // Send the HTTP request
            Http http = new Http();
            HttpResponse res = http.send(request);

            // Handle the response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('File sent successfully. Response: ' + res.getStatusCode());
            } else {
                System.debug('Failed to send file. Status: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
            createTheMedia(asset, subValue);
        } catch (Exception e) {
            System.debug('Exception while sending file: ' + e.getMessage());
        }
    }

    private static void createTheMedia(String asset, String subValue){
        String jsonBody = '{'+
		'    "author": "urn:li:person:' + subValue + '",'+
		'    "lifecycleState": "PUBLISHED",'+
		'    "specificContent": {'+
		'        "com.linkedin.ugc.ShareContent": {'+
		'            "shareCommentary": {'+
		'                "text": "Feeling inspired after meeting so many talented individuals at this year"'+
		'            },'+
		'            "shareMediaCategory": "IMAGE",'+
		'            "media": ['+
		'                {'+
		'                    "status": "READY",'+
		'                    "description": {'+
		'                        "text": "Center stage!"'+
		'                    },'+
		'                    "media": "'+asset+'",'+
		'                    "title": {'+
		'                        "text": "LinkedIn Talent Connect 2021"'+
		'                    }'+
		'                }'+
		'            ]'+
		'        }'+
		'    },'+
		'    "visibility": {'+
		'        "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"'+
		'    }'+
		'}';
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndPoint('https://api.linkedin.com/v2/ugcPosts');
        request.setHeader('Authorization', 'Bearer AQW_ruC_jdk8qGWhP3Dv96QWT-CcBp7bP2bftvtVsxzoJh_cfy4gjv8DsVmLYnI5Jm68q-mQ1KFdF-Eb1OWAVvU20agcp8VJDpctkSijJhFf_xX9UwD4G19Jpsz4eRGA3gC-HBvl-s4MkKTYYPJ40vvOwvtwS_B0GTQz7wyAvTWvNqZFOkhA5OytPDJRIpzKU9WnvG0Ud-ZcMdCc_sCrED1JiHr51C2WZZOCrfH5qWqtCB7YmRYiOAyhujM0xgDF0_ijjpqIXzegFX5051L5ZRfpBjZRdOfrLm72VCnl9zaS8T5tmOkncPjSUDCwC1qJnQEPBjs6c1FRsr5emQmLAdj-3r4Cpw');
        request.setMethod('POST');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        System.debug('Body : '+response.getBody());
        System.debug('Body : '+response.getStatusCode());
    }
}