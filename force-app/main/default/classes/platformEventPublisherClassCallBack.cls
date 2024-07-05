public with sharing class platformEventPublisherClassCallBack implements EventBus.EventPublishFailureCallback,EventBus.EventPublishSuccessCallback {
    public void onSuccess(EventBus.SuccessResult result){
        system.debug('In OnSuccess');
        List<String> EventUUIdList = result.getEventUuids();
        system.debug('Succeeded Items Ids : '+EventUUIdList);
    }
    public void onFailure(EventBus.FailureResult result){
        system.debug('In OnFailure');
        List<String> EventUUIdList = result.getEventUuids();
        system.debug('Failed Items Ids : '+EventUUIdList);
    }
}