trigger ContentVersionTrigger on ContentVersion (after insert) {
    List<ContentDistribution> cdList = new list<ContentDistribution>();  
    for(ContentVersion con : Trigger.new){
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'External Link';
        cd.ContentVersionId = '';
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesAllowOriginalDownload = true;
        cdList.add(cd);
    }
    if(!cdList.isEmpty()){
        insert cdList;
    }

    List<ContentDistribution> destList = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE Id IN :cdList];
    for(ContentDistribution des : destList){
        String DownloadUrl = des.ContentDownloadUrl;
        String publicUrl = des.DistributionPublicUrl;
        system.debug('DownloadUrl '+DownloadUrl);
        system.debug('publicUrl '+publicUrl);
    }
}