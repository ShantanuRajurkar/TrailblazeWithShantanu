/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger ContentVersionTrigger on ContentVersion (after insert) {
    List<ContentDistribution> cdList = new List<ContentDistribution>();  
    
    // Loop through ContentVersion trigger to create ContentDistribution records
    for(ContentVersion con : Trigger.new){
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'External Link1';
        cd.ContentVersionId = con.Id;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesAllowOriginalDownload = true;
        cdList.add(cd);
    }
    
    // Insert ContentDistribution records
    if(!cdList.isEmpty()){
        insert cdList;
    }

    // Query the created ContentDistribution records
    List<ContentDistribution> destList = [SELECT Id, Name, ContentDownloadUrl, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE Id IN :cdList];
    
    List<Documents_Download_Urls__c> DocList = new List<Documents_Download_Urls__c>();
    
    // Query the ContentVersion to get the Title (file name) for each record
    Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([
        SELECT Id, Title 
        FROM ContentVersion 
        WHERE Id IN :Trigger.newMap.keySet()
    ]);
    
    // Loop through the ContentDistribution records and create Documents_Download_Urls__c records
    for(ContentDistribution des : destList){
        // Get the related ContentVersion record to fetch the file name
        ContentVersion relatedContentVersion = contentVersionMap.get(des.ContentVersionId);
        
        // Create new Documents_Download_Urls__c record and assign the file name
        Documents_Download_Urls__c doc = new Documents_Download_Urls__c();
        doc.Name = relatedContentVersion.Title; // Use the Title from ContentVersion as the file name
        doc.Url__c = des.ContentDownloadUrl;
        doc.Content_Version_Id__c = des.ContentVersionId;
        String DownloadUrl = des.ContentDownloadUrl;
        String publicUrl = des.DistributionPublicUrl;
        System.debug('DownloadUrl ' + DownloadUrl);
        System.debug('publicUrl ' + publicUrl);
        
        DocList.add(doc);
    }

    // Insert the Documents_Download_Urls__c records
    if(!DocList.isEmpty()){
        insert DocList;
    }
}
