/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger HideFeedAttachment on FeedItem (After insert) {
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            HideFeedAttachmentHandler.processContentDocumentLinks(Trigger.newMap.keySet());
        }
    }
}