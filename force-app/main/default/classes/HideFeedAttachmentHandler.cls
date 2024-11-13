/**
 * @description       : 
 * @author            : Shantanu Rajurkar
 * @group             : 
 * @last modified on  : 11-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class HideFeedAttachmentHandler {
    public static void processContentDocumentLinks(Set<Id> feedItemIds) {

    List<ContentDocumentLink> linksToDelete = new List<ContentDocumentLink>();
    Set<Id> profileIds = new Set<Id>();
    Map<Id, Id> contentDocumentToUserMap = new Map<Id, Id>();
    Map<Id, Id> userToProfileMap = new Map<Id, Id>();
    Map<Id, List<ContentDocumentLink>> parentToLinksMap = new Map<Id, List<ContentDocumentLink>>();
    Id empProfileId;

    for (Profile profile : [
        SELECT Id 
        FROM Profile 
        WHERE Name IN ('Standard Platform User', 'System Administrator')
    ]) {
        profileIds.add(profile.Id);
    }
    empProfileId = [
        SELECT Id 
        FROM Profile 
        WHERE Name = 'Marketing User'
        LIMIT 1
    ].Id;

    List<FeedItem> feedItems = [
        SELECT Id, Type, ParentId,
               (SELECT Id, RecordId, FeedEntityId FROM FeedAttachments)
        FROM FeedItem 
        WHERE Id IN :feedItemIds
    ];

    Map<Id, Id> feedToParentMap = new Map<Id, Id>();       
    Map<Id, Id> contentDocToParentMap = new Map<Id, Id>(); 
    Set<Id> contentDocumentIds = new Set<Id>();            
	set<Id> feedIdsWithContentPost = new Set<Id>();
    for (FeedItem feed : feedItems) {
     	feedToParentMap.put(feed.Id, feed.ParentId); 
        if(feed.Type == 'ContentPost'){
            feedIdsWithContentPost.add(feed.Id);
        }
    }
		
    List<FeedAttachment> attachments = new List<FeedAttachment>();
    for (FeedItem feed : feedItems) {
        attachments.addAll(feed.FeedAttachments);
    }

    for (FeedAttachment attachment : attachments) {
        contentDocToParentMap.put(attachment.RecordId, feedToParentMap.get(attachment.FeedEntityId));
        contentDocumentIds.add(attachment.RecordId);
    }

    for (ContentDocument doc : [
        SELECT Id, CreatedById 
        FROM ContentDocument 
        WHERE Id IN :contentDocumentIds
    ]) {
        contentDocumentToUserMap.put(doc.Id, doc.CreatedById);
    }
    list<Id> userIds = contentDocumentToUserMap.values();
    for (User user : [
        SELECT Id, ProfileId 
        FROM User 
        WHERE Id IN :userIds
    ]) {
        userToProfileMap.put(user.Id, user.ProfileId);
    }
    if(!feedIdsWithContentPost.isEmpty()){
		DealWithContentPost(feedIdsWithContentPost, profileIds, empProfileId);
    }
    
    for (ContentDocumentLink link : [
        SELECT Id, ContentDocumentId, LinkedEntityId 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId IN :feedToParentMap.values() 
          AND ContentDocumentId IN :contentDocumentIds
    ]) {
        if (!parentToLinksMap.containsKey(link.LinkedEntityId)) {
            parentToLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
        }
        parentToLinksMap.get(link.LinkedEntityId).add(link);
    }

    Set<Id> parentIdsToDeleteLinks = new Set<Id>();
    for (Id contentDocId : contentDocToParentMap.keySet()) {
        Id userId = contentDocumentToUserMap.get(contentDocId);
        Id userProfileId = userToProfileMap.get(userId);

        if (profileIds.contains(userProfileId) && userProfileId != empProfileId) {
            Id parentId = contentDocToParentMap.get(contentDocId);
            parentIdsToDeleteLinks.add(parentId);
        }
    }

    for (Id parentId : parentIdsToDeleteLinks) {
        List<ContentDocumentLink> linksForParent = parentToLinksMap.get(parentId);
        if (linksForParent != null) {
            linksToDelete.addAll(linksForParent);
        }
    }

    if (!linksToDelete.isEmpty()) {
        delete linksToDelete;
    }
}
    
    @future
    Public static void DealWithContentPost(Set<Id> feedItemIds, set<Id> profileIds, Id empProfileId){
        map<Id,Id> userToProfileMap = new map<Id,Id>();
       	Map<Id, Id> feedToParentMap = new Map<Id, Id>();       // Maps FeedItemId -> ParentId
        list<FeedItem> feedToUpdate = new List<FeedItem>();
        Map<Id, Id> contentDocToParentMap = new Map<Id, Id>(); // Maps ContentDocumentId -> ParentId
        Map<Id, Id> contentDocumentToUserMap = new Map<Id, Id>();
        map<Id, list<ContentDocumentLink>> caseIdToConDocLinks = new map<Id, list<ContentDocumentLink>>();
        Set<Id> contentDocumentIds = new Set<Id>();
        list<ContentDocumentLink> conDocLinksTodelete = new list<ContentDocumentLink>();
        set<Id> contentVersionIds = new Set<Id>();
        map<Id, Id> contentVerToContentDoc = new map<Id,Id>();
        map<Id, Id> feedIdToRecordId = new map<Id,Id>();
        map<Id, String> contentVerToPublickUrl = new map<Id,String>();
        map<Id, String> feedIdToBody = new map<Id, String>();
        map<Id,Id> contentDocIdToContentDocLink = new map<Id,Id>();
        list<FeedItem> feedToUpdateEarly = new list<FeedItem>();
        map<Id,String> contentVerToTitle = new map<Id,String>();
        
        for(FeedItem item : [SELECT Id, ParentId, Type, Body FROM FeedItem WHERE Id IN :feedItemIds]){
            if(item.Type == 'ContentPost'){
                feedIdToBody.put(item.Id, item.Body);
                feedToParentMap.put(item.Id, item.ParentId);
            }
        }
                
        for(FeedAttachment feedAttachment : [SELECT Id, Type, Title, FeedEntityId, RecordId FROM FeedAttachment WHERE FeedEntityId IN :feedItemIds]){
            if(feedAttachment.Type == 'Content'){
            	contentVersionIds.add(feedAttachment.RecordId);
                feedIdToRecordId.put(feedAttachment.FeedEntityId, feedAttachment.RecordId);
            }
        }
        createPublicUrl(contentVersionIds);
        for(ContentVersion version : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]){
            contentVerToContentDoc.put(version.Id, version.ContentDocumentId);
            contentDocumentIds.add(version.ContentDocumentId);
            contentVerToTitle.put(version.Id, version.Title);
        }
        
        for (ContentDocumentLink link : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :feedToParentMap.values() AND ContentDocumentId IN :contentDocumentIds]){
            if (!caseIdToConDocLinks.containsKey(link.LinkedEntityId)) {
                caseIdToConDocLinks.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            caseIdToConDocLinks.get(link.LinkedEntityId).add(link);
        }
        
        
        for(ContentDistribution contenDis : [SELECT Id, ContentVersionId, DistributionPublicUrl, PreferencesAllowViewInBrowser, PreferencesAllowOriginalDownload FROM ContentDistribution WHERE ContentVersionId IN :contentVersionIds]){
            contentVerToPublickUrl.put(contenDis.ContentVersionId, contenDis.DistributionPublicUrl);
        }
        for(FeedItem item : [SELECT Id, Body, Type, (SELECT Id, Type, Title, FeedEntityId, RecordId FROM FeedAttachments) FROM FeedItem WHERE Id IN :feedItemIds]){
            string body = '';
            if(item.Type == 'ContentPost'){
                for(FeedAttachment feedAttachment : item.FeedAttachments){             
                    contentDocToParentMap.put(contentVerToContentDoc.get(feedAttachment.RecordId), feedAttachment.FeedEntityId);
                    if(feedAttachment.Type == 'Content'){
                        String str = contentVerToTitle.get(feedAttachment.RecordId);
                        String imageTag = '';
                        if(item.Body != null){
                            imageTag = '<p>' + '<a href="' + contentVerToPublickUrl.get(feedAttachment.RecordId) + '" target="_blank">' + str + '</a>' + '</p>';
                        }else if(item.Body == null){
                            imageTag = '<p>' + '<a href="' + contentVerToPublickUrl.get(feedAttachment.RecordId) + '" target="_blank">' + str + '</a>' + '</p>';
                        }
                        body = body + imageTag + '\n';
                    }
                }
            }
            if(feedIdToBody.get(item.Id) == null){
            	item.Body = '<p>Attachments :</p> ' + body;
                item.IsRichText = true;
            }else{ 
                item.Body = feedIdToBody.get(item.Id) + ' <p>Attachments :</p> ' + body;
            }
            feedToUpdate.add(item);
        }
        
        if(!feedToUpdate.isEmpty()){
            update feedToUpdate;
        }
        for (ContentDocument doc : [SELECT Id, CreatedById FROM ContentDocument WHERE Id IN :contentVerToContentDoc.values()]){
            contentDocumentToUserMap.put(doc.Id, doc.CreatedById);
        }
        for (User user : [SELECT Id, ProfileId FROM User WHERE Id IN :contentDocumentToUserMap.values()]) {
            userToProfileMap.put(user.Id, user.ProfileId);
        } 
        
        list<Id> caseIdsForLinks = feedToParentMap.values();
        for (ContentDocumentLink link : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :caseIdsForLinks AND ContentDocumentId IN :contentDocumentIds]){
            Id userId = contentDocumentToUserMap.get(link.ContentDocumentId);
        	Id userProfileId = userToProfileMap.get(userId);
            if(profileIds.contains(userProfileId) && userProfileId != empProfileId){
            	conDocLinksTodelete.add(link);    
            }
        }
        
        
        if(!conDocLinksTodelete.isEmpty()){
            try {
            	delete conDocLinksTodelete;
        	} catch (DmlException e) {
            	System.debug('DML Exception: ' + e.getMessage());
        	}
        }     
    }
    
    public static void createPublicUrl(Set<Id> contentVersionIds){
        List<ContentDistribution> distributions = new List<ContentDistribution>();
        for (Id contentVerIds : contentVersionIds) { 
            ContentDistribution dist = new ContentDistribution();
            dist.Name = 'Public Link for ' + contentVerIds; 
            dist.ContentVersionId = contentVerIds;
            dist.PreferencesAllowViewInBrowser = true; 
            dist.PreferencesAllowOriginalDownload = true; 
            dist.PreferencesAllowPDFDownload = true; 
            distributions.add(dist);
		}
			if(!distributions.isEmpty())
            	insert distributions;
 	}

}